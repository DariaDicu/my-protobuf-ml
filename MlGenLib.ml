(*Things to do:
- generate init function for ML structures
- use init function to create empty object when first calling parseNextField
- write a generic function for parsing messages
- write a function for toplevel messages to strip the key
*)



(* For now, this is just a Word8Vector, it does not have a channel underneath*)
(* Buffer is a vector and an index in the vector*)
(* For now only considering integers, no floats or zigzags *)
use "realConverters.ml";

type byte = Word8.word
type key = int * int
datatype tag = Tag of int
datatype code = Code of int
datatype parsedByteCount = ParsedByteCount of int
datatype errorCode = BUILD | ENCODE | DECODE;
exception Exception of errorCode*string

signature ML_GEN_BYTE = 
sig
	val fromInt : int -> byte
	val toInt : byte -> int
	val getMsb : byte -> bool
	val getTail : byte -> byte
end

structure MlGenByte : ML_GEN_BYTE = 
struct
	fun fromInt n = Word8.fromInt n
	fun toInt b = Word8.toInt b
	fun getMsb b = Word8.>>(b, Word.fromInt 7) > (fromInt 0)
	fun getTail b = Word8.>>(Word8.<<(b, Word.fromInt 1), Word.fromInt 1)
end

signature BYTE_STREAM = 
sig
	type stream
	val fromVector : Word8Vector.vector -> stream
	val totalSize : stream -> int
	val fromList  : byte list -> stream
	(* Modifies buffer by putting index after next byte *)
	val nextByte : stream -> byte * stream
	(* Modifies buffer by putting index after next block. Returns both 
	buffers, first the next block, then the remaining one. *)
	val nextFixedBlock : stream -> int -> Word8Vector.vector * stream
end

structure ByteInputStream : BYTE_STREAM =
struct
	type stream = Word8Vector.vector * int
	fun fromVector buff = (buff, 0)
	fun fromList l = fromVector (Word8Vector.fromList l)
	fun totalSize (buff, i) = Word8Vector.length buff
	fun nextByte (buff, i) =
		let
			(*Subscript exception raise here if no next_byte*)
			(*TODO - build your own error *)
			val b = Word8Vector.sub (buff, i)
		in
			(b, (buff, i+1))
		end
	(* Tested, works. *)
	fun nextFixedBlock (buff, i) length = 
		(* get block from i to (i + length - 1) *)
		let 
			val block = Word8Vector.tabulate (length, fn n =>
							Word8Vector.sub (buff, i+n))
		in
			(block, (buff, i+length))
		end
end

datatype parseResult = ParseResult of ByteInputStream.stream*parsedByteCount

(* This returns the varint value, remaining buffer and #bytes parsed,
but not the key. The key parsing is delegated to parent message. *)
fun decodeVarint_core buff i prev_val (ParsedByteCount(s)) = 
let 
	val (b, next_buff) = ByteInputStream.nextByte buff
	(* TODO - Treat overflow? *)
	(* little endian *)
	val next_val = 
		prev_val + IntInf.<<((MlGenByte.toInt (MlGenByte.getTail b)), 
			Word.fromInt(i * 7))
	val msb = MlGenByte.getMsb b
in
	if (msb = true) then 
		(* if msb in this byte is 1, varint contains the next byte *)
		decodeVarint_core next_buff (i+1) next_val (ParsedByteCount(s+1))
	else
		(* final value is tuple of value, remaining buffer and
		number of bytes parsed *)
		(next_val, ParseResult(next_buff, ParsedByteCount(s)))
end

fun decodeVarint buff = decodeVarint_core buff 0 0 (ParsedByteCount(1))

fun decodeZigZag buff = 
let
	val (v, parse_result) = decodeVarint buff
	val signed_val = if (v mod 2 = 0) then (v div 2) else ((~1)*((v+1) div 2))
in
	(signed_val, parse_result)
end

fun decodeKey buff = 
let
	val (v, ParseResult(next_buff, parsedByteCount)) = decodeVarint buff
	(* Type of the key is represented by last 3 bits. *)
	val code_ = Code(IntInf.andb(v, 7))
	(* Field number is represented by the remaining bits. *)
	val tag_ = Tag(IntInf.~>>(v, Word.fromInt 3))
in
	((tag_, code_), ParseResult(next_buff, parsedByteCount))
end

fun decodeFixedWord totalBytes i remaining buff prev_val =
let
	val (b, next_buff) = ByteInputStream.nextByte buff
	val new_byte = LargeWord.fromInt (Word8.toInt b)
	val next_val = 
		prev_val + LargeWord.<<(new_byte, Word.fromInt(i * 8))
in
	if (i < totalBytes-1) then
		decodeFixedWord totalBytes (i+1) (remaining-1) next_buff next_val
	else
		(next_val, ParseResult(next_buff, ParsedByteCount(totalBytes)))
end

fun decodeFixed32Word buff = decodeFixedWord 4 0 4 buff 0wx0

fun decodeFixed64Word buff = decodeFixedWord 8 0 8 buff 0wx0

fun decodeSfixed32 buff = 
let
	val (w, parse_result) = decodeFixed32Word buff
	val sign_bit = ((LargeWord.andb(w, 0wx80000000)) = 0wx80000000)
	(* We must copy the sign bit on bits 32-63, since parsed val is 32-bits. *)
	val w = if (sign_bit) then (LargeWord.orb(w, 0wxFFFFFFFF00000000))
		else w
in
	(LargeWord.toIntX w, parse_result)
end

fun decodeSfixed64 buff = 
let
	val (w, parse_result) = decodeFixed64Word buff
in
	(LargeWord.toIntX w, parse_result)
end

fun decodeFixed32 buff = decodeSfixed32 buff

fun decodeFixed64 buff = decodeSfixed64 buff

fun decodeDouble buff = 
let
	val (w, parse_result) = decodeFixed64Word buff
	val v = LargeWord.toIntX w
in
	(real_of_bits64 v, parse_result)
end

fun decodeFloat buff = 
let
	val (w, parse_result) = decodeFixed32Word buff
	val v = LargeWord.toIntX w
in
	(real_of_bits32 v, parse_result)
end

fun decodeString buff = 
let
	val (length, ParseResult(buff, ParsedByteCount(lenBytes))) =
		decodeVarint buff
	val (body, buff) = ByteInputStream.nextFixedBlock buff length
	val string_value = Byte.bytesToString body
in
	(string_value, ParseResult(buff, ParsedByteCount(lenBytes + length)))
end

fun decodeBytes buff = 
let
	val (length, ParseResult(buff, ParsedByteCount(lenBytes))) =
		decodeVarint buff
	val (body, buff) = ByteInputStream.nextFixedBlock buff length
in
	(body, ParseResult(buff, ParsedByteCount(lenBytes + length)))
end

(* Converts a parse result containing an integer (of maximum 64-bit) to a signed integer. *)
fun unsignedToSigned result = 
let 
 	val (n, parse_result:parseResult) = result
in
	(LargeWord.toIntX (LargeWord.fromInt n), parse_result)
end

(* Decode function returns an unsigned int on 64 bits. *)
(* PolyML does not provide 32-bit int. If type is int32/sint32/uint32, leaving
it on 64-bits is not a problem for the user (semantics preserved). *)
(* However, for signed types, we must convert to a signed integer. *)
(* TODO *)
fun decodeInt32 buff = unsignedToSigned (decodeVarint buff)
fun decodeInt64 buff = unsignedToSigned (decodeVarint buff)
fun decodeUint32 buff = decodeVarint buff
fun decodeUint64 buff = decodeVarint buff

(* Is unsignedtosigned really necessary here? TODO - Remove it.*)
fun decodeSint32 buff = unsignedToSigned (decodeZigZag buff)
fun decodeSint64 buff = unsignedToSigned (decodeZigZag buff)

fun decodeBool buff = 
let
	val (v, parse_result) = decodeVarint buff
in
	if (v = 0) then (false, parse_result)
	else if (v = 1) then (true, parse_result)
	else raise Exception(DECODE, "Attempting to decode boolean of invalid value (not 0 or 1).") 
end

(*------------------------------------*)
(* Encoding *)

(* *)

(* Encodes a single Word.word as a varint. *)
(* Least significant BYTES first, but within byte it's big endian. *)
fun encodeVarint n = 
let 
	fun encodeVarint_core v =
	let
		(* We want last 7 of the 8 LSB in val, and put a 1 bit at the beginning.*)
		fun toWord8 x = Word8.fromInt (LargeWord.toInt x)
		val last7 = LargeWord.andb (v, 0wx7F)
		val new_v = LargeWord.>>(v, 0wx7)
		(* If this is last byte, then MSB has to be 0.*)
		val last7 = if (new_v = 0wx0) then last7
			else LargeWord.orb(last7, 0wx80)
	in
		if (new_v <> 0wx0) then 
			(toWord8 last7)::(encodeVarint_core new_v)
		else
			(* Stop iteration and return single element list *)
			[toWord8 last7]
	end
in
	Word8Vector.fromList (encodeVarint_core (LargeWord.fromInt n))
end

(* Returns a Word8Vector *)
fun encodeZigZag value = 
let
	val abs_val = if (value < 0) then ~value else value
	(* -1 if negative, 0 if positive *)
	val add_on = if (value < 0) then ~1 else 0
in
	encodeVarint (abs_val*2 + add_on)
end


fun encodeFixed32Word w =
let
	val vect = Word8Vector.tabulate (4, fn i =>
		Word8.fromInt(LargeWord.toInt(LargeWord.andb(LargeWord.>>(
			w, Word.fromInt(i*8)), 0wxFF))))
in
	vect
end

fun encodeFixed64Word w =
let
	val vect = Word8Vector.tabulate (8, fn i =>
		Word8.fromInt(LargeWord.toInt(LargeWord.andb(LargeWord.>>(
			w, Word.fromInt(i*8)), 0wxFF))))
in
	vect
end

fun encodeDouble d = encodeFixed64Word (LargeWord.fromInt (bits64_of_real d))

fun encodeFloat f = encodeFixed32Word (LargeWord.fromInt (bits32_of_real f))

(* Returns a Word8Vector of size 4. *)
fun encodeFixed32 number = encodeFixed32Word (LargeWord.fromInt number)

(* Returns a Word8Vector of size 8. *)
fun encodeFixed64 number = encodeFixed64Word (LargeWord.fromInt number)

fun encodeSfixed32 number = encodeFixed32 number

fun encodeSfixed64 number = encodeFixed64 number

(* Encodes the (tag, code) pair into a varint representing the key. *)
fun encodeKey (Tag(t), Code(c)) = 
let
	val key = IntInf.orb(IntInf.<<(t, Word.fromInt 3), c)
in
	if (c < 0 orelse c > 5) then
		raise Exception(ENCODE, "Attemping to encode unsupported wire type")
	else 
		encodeVarint key
end

(* Encodes a string. *)
fun encodeString s = 
let
	(* Wire type of string is 2 (length delimited). *)
	val encoded_length = encodeVarint (String.size s)
	val encoded_body = Word8Vector.tabulate ((String.size s),
		fn i => Byte.charToByte (String.sub (s, i))
	)
in
	Word8Vector.concat [encoded_length, encoded_body]
end

(* Encodes a byte array with a specific tag by prefixing it with
key and length. *)
fun encodeBytes bytes = 
let
	val encoded_length = encodeVarint (Word8Vector.length bytes)
in
	Word8Vector.concat [encoded_length, bytes]
end

(* Functions for encoding functions with different labels *)
(* They compile, but not tested. *)
(* changed to concat from fromList *)
fun encodeRequired encode_fun encoded_key x = 
	Word8Vector.concat [encoded_key, encode_fun x]

fun encodeRepeated encode_fun encoded_key [] = Word8Vector.fromList []
  | encodeRepeated encode_fun encoded_key (x::xs) = Word8Vector.concat 
  	[encoded_key, encode_fun x, encodeRepeated encode_fun encoded_key xs]

fun encodePacked_core encode_fun [] = Word8Vector.fromList []
  | encodePacked_core encode_fun (x::xs) = Word8Vector.concat 
  	[encode_fun x, encodePacked_core encode_fun xs]

fun encodePackedRepeated encode_fun encoded_key l = 
let
	val encoded_body = encodePacked_core encode_fun l
	val encoded_length = encodeVarint (Word8Vector.length encoded_body)
in
	Word8Vector.concat [encoded_key, encoded_length, encoded_body]
end

fun encodeOptional encode_fun encoded_key NONE = Word8Vector.fromList []
  | encodeOptional encode_fun encoded_key (SOME(x)) = 
  Word8Vector.concat [encoded_key, encode_fun x]

(* ===== end of label functions ==== *)

(* Not really tested *)
fun encodeMessage encoded_body = 
let
	val length = Word8Vector.length encoded_body
	val encoded_length = encodeVarint length
in
	Word8Vector.concat [encoded_length, encoded_body]
end

(* Use plain varint encoding *)
(* This is always a signed integer. Check if bits 32-63 are all 0 or all 1,
otherwise int32 overflows, so return error. *)
fun encodeInt32 n = 
let
	val first32 = LargeWord.andb (LargeWord.fromInt n, 0wxFFFFFFFF00000000)
in
	if (first32 <> 0wxFFFFFFFF00000000 andalso first32 <> 0wx0000000000000000) then
		raise Exception(ENCODE, "Error. Attempting to encode a 64-bit value as a 32-bit integer.")
	else
		encodeVarint n
end

fun encodeInt64 n = encodeVarint n


(* Check if bits 32-63 are all 0, otherwise uint32 overflows, so return error. *)
fun encodeUint32 n = 
let
	val first32 = LargeWord.andb (LargeWord.fromInt n, 0wxFFFFFFFF00000000)
in
	if (first32 <> 0wx0000000000000000) then
		raise Exception(ENCODE, "Error. Attempting to encode a 64-bit value as a 32-bit integer.")
	else
		encodeVarint n
end

fun encodeUint64 n = encodeVarint n

fun encodeBool b = 
	if (b = true) then encodeVarint 1 else encodeVarint 0

(* Use zig zag encoding *)
fun encodeSint32 n = 
let
	val first32 = LargeWord.andb (LargeWord.fromInt n, 0wxFFFFFFFF00000000)
in
	if (first32 <> 0wxFFFFFFFF00000000 andalso first32 <> 0wx0000000000000000) then
		raise Exception(ENCODE, "Error. Attempting to encode a 64-bit value as a 32-bit integer.")
	else
		encodeZigZag n
end

fun encodeSint64 n = encodeZigZag n

(* ====== Helper method for decoding ===== *)
(* This method is a helper for smaller code size. *)
(* decode_fun -> Function for decoding this field. *)
(* modifier_fun -> Accessor method to call on object for adding the new field. *)
(* rec_fun -> Function to call on the object to decode next field. *)
(* obj -> Partially constructed object of type Builder. *)
(* buff -> Input buffer. *)
(* remaining -> Number of remaining bits in the message, as parsed from key. *)
fun decodeNextUnpacked decode_fun modifier_fun rec_fun obj buff remaining = 
let
    val (field_value, parse_result) = decode_fun buff
    val ParseResult(buff, ParsedByteCount(parsed_bytes)) = parse_result
    val obj = if (remaining >= parsed_bytes) then modifier_fun (obj, field_value)
		else raise Exception(DECODE, "Error in matching the message length with fields length.")
in
    rec_fun buff obj (remaining - parsed_bytes)
end

fun decodeFullHelper is_toplevel next_field_fun build_fun empty_obj buff =
let
	val (length, ParseResult(buff, ParsedByteCount(lenBytes))) =
		if (is_toplevel) then (ByteInputStream.totalSize buff, ParseResult(buff, ParsedByteCount(0)))
		else decodeVarint buff
	val (obj, buff) = next_field_fun buff empty_obj length
in
	(build_fun obj, ParseResult(buff, ParsedByteCount(lenBytes+length)))
end

(* Decodes the next packed field and uses the modifier to add it to obj. *)
(* decode_fun -> Function for decoding individual field. *)
(* modifier_fun -> Will be add_someName, the modifier that adds the field to the list. *)
(* Returns a tuple (obj, buff) *)
(* Not to be exposed, just used by decodeNextPacked *)
fun decodeNextPacked_core decode_fun modifier_fun obj buff remaining =
let
    val (field_value, parse_result) = decode_fun buff
    val ParseResult(buff, ParsedByteCount(parsed_bytes)) = parse_result
    val obj = if (remaining >= parsed_bytes) then modifier_fun (obj, field_value)
		else raise Exception(DECODE, "Error in matching the specified packed length with actual length.")
in
	if (remaining > parsed_bytes) then
		decodeNextPacked_core decode_fun modifier_fun obj buff (remaining - parsed_bytes)
	else (* We have parsed the last field. *)
		(obj, buff)
end


fun decodeNextPacked decode_fun modifier_fun rec_fun obj buff remaining = 
let 
	val (length, ParseResult(buff, ParsedByteCount(lenBytes))) = 
		decodeVarint buff
	val (obj, buff) = decodeNextPacked_core decode_fun modifier_fun obj buff length
	val parsed_bytes = lenBytes + length
in 
	rec_fun buff obj (remaining - parsed_bytes)
end