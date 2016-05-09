(* encodeVarint takes an Int.int and produces a Word8Vector.vector. *)
(* val encodeVarint = fn: int -> Word8Vector.vector *)
fun encodeVarint v = 
let 
	fun encodeIteration v =
	let
		(* Function toWord8 extracts the last byte from a LargeWord.*)
		fun toWord8 x = Word8.fromInt (LargeWord.toInt x)

		val last7bits = LargeWord.andb (v, 0wx7F)
		val remaining_bits = LargeWord.>>(v, 0wx7)

		(* Add the MSB depending on whether this is the last byte (0) or not (1).*)
		val byte_value = if (remaining_bits = 0wx0) then last7bits
			else LargeWord.orb(last7bits, 0wx80)
	in
		if (remaining_bits <> 0wx0) then 
			(toWord8 byte_value)::(encodeIteration remaining_bits)
		else
			[toWord8 byte_value]
	end
in
	Word8Vector.fromList (encodeIteration (LargeWord.fromInt v))
end

(* decodeVarint takes a ByteInputStream and produces a tuple containing an Int.int and a parseResult datatype. Keeping track of the parsed byte count is necessary for decoding message fields.*)
(* val decodeVarint = fn: ByteInputStream.stream -> int * parseResult *)
fun decodeVarint instream = 
let
	(* 
		instream -- input stream of type ByteInputStream,
		i -- the index of the current byte,
		prev_value -- partially parsed value
	*)
	fun decodeIteration instream i prev_val (ParsedByteCount(s)) = 
	let 
		val (byte_value, instream) = ByteInputStream.nextByte instream
		val next_val = 
			prev_val + IntInf.<<((MlGenByte.toInt (MlGenByte.getTail byte_value)), 
				Word.fromInt(i * 7))
		val msb = MlGenByte.getMsb byte_value
	in
		(* Perform the next iteration after inserting the current byte in the parsed value.*)
		if (msb = true) then
			decodeIteration instream (i+1) next_val (ParsedByteCount(s+1))
		else
			(next_val, ParseResult(instream, ParsedByteCount(s)))
	end
in
	decodeIteration instream 0 0 (ParsedByteCount(1))
end