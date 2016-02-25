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

fun parseVarint_core buff i prev_val (ParsedByteCount(s)) = 
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
		parseVarint_core next_buff (i+1) next_val (ParsedByteCount(s+1))
	else
		(* final value is tuple of value, remaining buffer and
		number of bytes parsed *)
		(next_val, ParseResult(next_buff, ParsedByteCount(s)))
end

fun parseVarint buff = parseVarint_core buff 0 0 (ParsedByteCount(0))

fun parseKey buff = 
let
	val (v, ParseResult(next_buff, parsedByteCount)) = parseVarint buff
	(* Type of the key is represented by last 3 bits. *)
	val code_ = Code(IntInf.andb(v, 7))
	(* Field number is represented by the remaining bits. *)
	val tag_ = Tag(IntInf.~>>(v, Word.fromInt 3))
in
	((tag_, code_), ParseResult(next_buff, parsedByteCount))
end

fun parseFixed totalBytes i remaining buff prev_val = 
let
	val (b, next_buff) = ByteBuffer.nextByte buff
	val next_val = 
		prev_val + IntInf.<<((MlGenByte.toInt (MlGenByte.getTail b)), 
			Word.fromInt(i * 7))
in
	if (i > 1) then
		parseFixed totalBytes (i+1) (remaining-1) next_buff next_val
	else
		(next_val, ParseResult(next_buff, ParsedByteCount(totalBytes)))
end

fun parse32 buff = parseFixed 4 0 4 buff 0

fun parse64 buff = parseFixed 8 0 8 buff 0

(* Tested against encodeString *)
fun parseString buff = 
let 
	(*
	val ((tag_, code_), ParseResult(buff, ParsedByteCount(keyBytes))) = 
		parseKey buff
	*)
	val (length, ParseResult(buff, ParsedByteCount(lenBytes))) =
		parseVarint buff
	val (body, buff) = ByteBuffer.nextFixedBlock buff length
	val string_value = Byte.bytesToString body
in
	(* should return tag too? *)
	(string_value, ParseResult(buff, ParsedByteCount(keyBytes + lenBytes + length)))
end

(*
fun parseInt32 buff = 
let
	val ((tag_, code_), ParseResult(buff, ParsedByteCount(keyBytes))) = 
		parseKey buff
	val (v, ParseResult(next_buff, ParsedByteCount(valueBytes))) = 
		parseVarint buff
in	
	if (code_ <> Code(0)) then
		raise Exception(PARSE, "Attempting to parse wrong wire type.")
	else
		(* Return (tag, enum value) pair together with remaining buffer *)
		((v, tag_), 
			ParseResult(buff, ParsedByteCount(keyBytes + valueBytes)))
end*)

fun parseInt32 buff = parseVarint buff
fun parseInt64 buff = parseVarint buff

(*
fun parse_message buff fields_function = 
let
	val (length, ParseResult(buff, ParsedByteCount(lenBytes))) =
		parseVarint buff
	val 
in
end
*)

(*
fun parse_message_body buff = 
let
	val (length, buff) = parseVarint buff
	val (message, buff) = ByteBuffer.nextFixedBlock buff length
in
	(message, buff)
end


fun parse_message buff expected_tag = 
let
	val ((tag_, code_), buff) = parseKey buff
	val (length, buff) = parseVarint buff
in
	if (code_ <> Code(2)) then
		raise Exception(PARSE, "Attempting to parse wrong wire type.")
	else if (tag_ <> expected_tag) then
		raise Exception(PARSE, "Parsed tag does not match expected tag.")
	else
		(* Returns resulting message, as well as remaining buffer. *)
		parse_message_body buff
end
*)

fun parseEnum buff = parseVarint buff

(*
fun parseEnum buff = 
let
	val ((tag_, code_), ParseResult(buff, ParsedByteCount(keyBytes))) = 
		parseKey buff
	val (enum_val, ParseResult(buff, ParsedByteCount(valueBytes))) = 
		parseVarint buff 
in
	if (code_ <> Code(0)) then
		raise Exception(PARSE, "Attempting to parse wrong wire type.")
	else
		(* Return (tag, enum value) pair together with remaining buffer*)
		((enum_val, tag_), 
			ParseResult(buff, ParsedByteCount(keyBytes + valueBytes)))
end
*)

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

(* Encodes a string with a specific tag by prefixing it with key 
and length. *)
fun encodeString (s, tag_) = 
let
	(* Wire type of string is 2 (length delimited). *)
	val encoded_key = encodeKey (tag_, Code(2))
	val encoded_length = encodeVarint (String.size s)
	val encoded_body = Word8Vector.tabulate ((String.size s),
		fn i => Byte.charToByte (String.sub (s, i))
	)
in
	Word8Vector.concat [encoded_key, encoded_length, encoded_body]
end

(* Encodes a byte array with a specific tag by prefixing it with
key and length. *)
fun encodeByteArray (bytes, tag_) = 
let
	(* Wire type of byte sequence is 2 (length delimited). *)
	val encoded_key = encodeKey (tag_, Code(2))
	val encoded_length = encodeVarint (Word8Vector.length bytes)
in
	Word8Vector.concat [encoded_key, encoded_length, bytes]
end

(* Not really tested *)
fun encodeRepeated f ([], tag_:tag) = (Word8Vector.fromList [])
  | encodeRepeated f (x::xs, tag_:tag) = Word8Vector.concat 
  	[(f (x, tag_)), (encodeRepeated f (xs, tag_))]

fun encodeOptional f (NONE, tag_:tag) = (Word8Vector.fromList [])
  | encodeOptional f (SOME(x), tag_:tag) = (f (x, tag_))

(* Not really tested *)
fun encodeMessage (body, tag_) = 
let 
	(* Code is 2, since type is message (fixed length) *)
	val encoded_key = encodeKey (tag_, Code(2))
	val length = Word8Vector.length body
	val encoded_length = encodeVarint length
in
	Word8Vector.concat [encoded_key, encoded_length, body]
end

fun encodeInt32 (n, tag_) = 
let 
	val key = encodeKey (tag_, Code(0))
	val v = encodeVarint n
in
	Word8Vector.concat [key, v]
end


fun encodeInt64 (n, tag_) = 
let 
	val key = encodeKey (tag_, Code(0))
	val v = encodeVarint n
in
	Word8Vector.concat [key, v]
end

(* TODO add fixed32, 64 etc *)

