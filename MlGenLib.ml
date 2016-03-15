(*Things to do:
- generate init function for ML structures
- use init function to create empty object when first calling parseNextField
- write a generic function for parsing messages
- write a function for toplevel messages to strip the key
*)



(* For now, this is just a Word8Vector, it does not have a channel underneath*)
(* Buffer is a vector and an index in the vector*)
(* For now only considering integers, no floats or zigzags *)
type byte = Word8.word
type key = int * int
datatype tag = Tag of int
datatype code = Code of int
datatype parsedByteCount = ParsedByteCount of int
datatype errorCode = PARSE | ENCODE;
exception Exception of errorCode*string

signature ML_GEN_BYTE = 
sig
	val fromInt : int -> byte
	val toInt : byte -> int
	val getMsb : byte -> bool
	val getTail : byte -> byte
end

structure MlGenByte :> ML_GEN_BYTE = 
struct
	fun fromInt n = Word8.fromInt n
	fun toInt b = Word8.toInt b
	fun getMsb b = Word8.>>(b, Word.fromInt 7) > (fromInt 0)
	fun getTail b = Word8.>>(Word8.<<(b, Word.fromInt 1), Word.fromInt 1)
end

signature BYTE_BUFFER = 
sig
	type buffer
	val fromVector : Word8Vector.vector -> buffer
	val fromList  : byte list -> buffer
	(* Modifies buffer by putting index after next byte *)
	val nextByte : buffer -> byte * buffer
	(* Modifies buffer by putting index after next block. Returns both 
	buffers, first the next block, then the remaining one. *)
	val nextFixedBlock : buffer -> int -> Word8Vector.vector * buffer
end

structure ByteBuffer :> BYTE_BUFFER =
struct
	type buffer = Word8Vector.vector * int
	fun fromVector buff = (buff, 0)
	fun fromList l = fromVector (Word8Vector.fromList l)
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

datatype parseResult = ParseResult of ByteBuffer.buffer*parsedByteCount

(* This returns the varint value, remaining buffer and #bytes parsed,
but not the key. The key parsing is delegated to parent message. *)
fun decodeVarint_core buff i prev_val (ParsedByteCount(s)) = 
let 
	val (b, next_buff) = ByteBuffer.nextByte buff
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

fun decodeVarint buff = decodeVarint_core buff 0 0 (ParsedByteCount(0))

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

fun decodeFixed totalBytes i remaining buff prev_val = 
let
	val (b, next_buff) = ByteBuffer.nextByte buff
	val next_val = 
		prev_val + IntInf.<<((MlGenByte.toInt (MlGenByte.getTail b)), 
			Word.fromInt(i * 7))
in
	if (i > 1) then
		decodeFixed totalBytes (i+1) (remaining-1) next_buff next_val
	else
		(next_val, ParseResult(next_buff, ParsedByteCount(totalBytes)))
end

fun decode32 buff = decodeFixed 4 0 4 buff 0

fun decode64 buff = decodeFixed 8 0 8 buff 0

(* Tested against encodeString *)
(* Modified, since we only parse body but not key. *)
fun decodeString buff = 
let
	val (length, ParseResult(buff, ParsedByteCount(lenBytes))) =
		decodeVarint buff
	val (body, buff) = ByteBuffer.nextFixedBlock buff length
	val string_value = Byte.bytesToString body
in
	(string_value, ParseResult(buff, ParsedByteCount(lenBytes + length)))
end

fun decodeInt32 buff = decodeVarint buff
fun decodeInt64 buff = decodeVarint buff

(*------------------------------------*)
(* Encoding *)

(* Creates a Word8 list. The wrapper function uses this to 
create a Word8Vector. *)
fun encodeVarint_core byte_list remaining_int = 
let
	(* Binary-and to get least significant 7 bits *)
	val last7bits = IntInf.andb(remaining_int, 127)
	val remaining_int = IntInf.~>>(remaining_int, Word.fromInt 7)
	val msb = if (remaining_int > 0) then 1 else 0
	(* The new byte we add to the list *)
	val first_byte = if (msb = 1) then Word8.fromInt (IntInf.orb(last7bits, 128)) else Word8.fromInt last7bits
in
	if (msb = 1) then
		(* Making first bit of byte 1 and appending to list *)
		encodeVarint_core (first_byte::byte_list) remaining_int
	else
		(* Resulting list is in reverse order, so must reverse it. *)
		rev (first_byte::byte_list)
end


(* Returns a Word8Vector (be careful, not a buffer.) *)
fun encodeVarint value = Word8Vector.fromList
	(encodeVarint_core [] value)

(* Returns a Word8Vector of size 4. *)
fun encode32 number =
let 
	val vect = Word8Vector.tabulate (4, fn i =>
		Word8.fromInt(IntInf.andb(
			(IntInf.~>>(number, Word.fromInt (i*8))), 255))
	)
in
	vect
end

(* Returns a Word8Vector of size 8. *)
fun encode64 number =
let 
	val vect = Word8Vector.tabulate (8, fn i =>
		Word8.fromInt(IntInf.andb((IntInf.~>>(number, Word.fromInt (i*8))), 255))
	)
in
	vect
end

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
fun encodeByteArray bytes = 
let
	val encoded_length = encodeVarint (Word8Vector.length bytes)
in
	Word8Vector.concat [encoded_length, bytes]
end

(* Functions for encoding functions with different labels *)
(* They compile, but not tested. *)
fun encodeRequired encode_fun encoded_key x = 
	Word8Vector.fromList [encoded_key, encode_fun x]

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

fun encodeInt32 n = encodeVarint n
fun encodeInt64 n = encodeVarint n

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
		else raise Exception(PARSE, "Error in matching the message length with fields length.")
in
    rec_fun buff obj (remaining - parsed_bytes)
end

fun decodeFullHelper next_field_fun build_fun empty_obj buff =
let
	val (length, ParseResult(buff, ParsedByteCount(lenBytes))) =
		decodeVarint buff
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
		else raise Exception(PARSE, "Error in matching the specified packed length with actual length.")
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




