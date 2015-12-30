(* For now, this is just a Word8Vector, it does not have a channel underneath*)
(* Buffer is a vector and an index in the vector*)
type byte = Word8.word
signature BYTE = 
sig
	val fromInt : int -> byte
	val toInt : byte -> int
	val getMsb : byte -> bool
	val getTail : byte -> byte
end

structure Byte :> BYTE = 
struct
	fun fromInt n = Word8.fromInt n
	fun toInt b = Word8.toInt b
	fun getMsb b = Word8.>>(b, Word.fromInt 7) > (fromInt 0)
	fun getTail b = Word8.>>(Word8.<<(b, Word.fromInt 1), Word.fromInt 1)
end

signature BYTE_BUFFER = 
sig
	type byte_vector
	type buffer
	val fromVector : byte_vector -> buffer
	val fromList  : byte list -> buffer
	val nextByte : buffer -> byte * buffer
end

structure ByteBuffer :> BYTE_BUFFER =
struct
	type byte_vector = Word8Vector.vector
	type buffer = byte_vector * int
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
end

fun parseVarint_core buff i prev_val = 
let 
	val (b, next_buff) = ByteBuffer.nextByte buff
	(* TODO - Treat overflow? *)
	(* little endian *)
	val next_val = 
		prev_val + IntInf.<<((Byte.toInt (Byte.getTail b)), Word.fromInt(i * 7))
	val msb = Byte.getMsb b
in
	if (msb = true) then 
		(* if msb in this byte is 1, varint contains the next byte *)
		parseVarint_core next_buff (i+1) next_val
	else
		(* final value is tuple of value and remaining buffer *)
		(next_val, next_buff)
end

fun parseVarint buff = parseVarint_core buff 0 0;
