(* Test for decoding (attempts to decode a data file encoded using the C++
library. *)

use "tests/primitives.pb.ml";
use "tests/embedded.pb.ml";
use "tests/test_helpers.ml";

exception invalidTest

(* Writes to file_name bytes from the Word8Vector argument. Useful for porting 
benchmark test data to other languages for testing *)
fun writeToFile file_name raw_bytes = 
let
	val ostream = BinIO.openOut file_name
in
	(BinIO.output (ostream, raw_bytes);
	BinIO.flushOut ostream)
end

(* Returns a Word8Vector from the raw bits in the file *)
fun getByteInputStream file_name = 
let
	val raw_vector = BinIO.inputAll (BinIO.openIn file_name)
	val input_stream = ByteInputStream.fromVector raw_vector
in
	input_stream
end

fun smallCollection () = 
let
	val builder = SmallPrimitiveCollection.Builder.init();
	val record = (
		SmallPrimitiveCollection.Builder.set_my_int32 (builder, ~1);
		SmallPrimitiveCollection.Builder.set_my_int64 (builder, 221921921929121);
		SmallPrimitiveCollection.Builder.set_my_string (builder, "hello");
		SmallPrimitiveCollection.Builder.build builder
	) 
in
	record
end

fun fullCollection () = 
let 
	val builder = FullPrimitiveCollection.Builder.init();
	val record = (
		FullPrimitiveCollection.Builder.set_my_int32 (builder, ~1);
		FullPrimitiveCollection.Builder.set_my_int64 (builder, 221921921929121);
		FullPrimitiveCollection.Builder.set_my_uint32 (builder, 3232321);
		FullPrimitiveCollection.Builder.set_my_uint64 (builder, 9977533344322);
		FullPrimitiveCollection.Builder.set_my_sint32 (builder, ~123);
		FullPrimitiveCollection.Builder.set_my_sint64 (builder, ~221921921929121);
		FullPrimitiveCollection.Builder.set_my_fixed32 (builder, ~323231);
		FullPrimitiveCollection.Builder.set_my_fixed64 (builder, 221921921929121);
		FullPrimitiveCollection.Builder.set_my_sfixed32 (builder, ~67565);
		FullPrimitiveCollection.Builder.set_my_sfixed64 (builder, 69595969659659);
		FullPrimitiveCollection.Builder.set_my_bool (builder, true);
		FullPrimitiveCollection.Builder.set_my_bytes (builder, Word8Vector.fromList [0wx1,0wxFF,0wx23]);
		FullPrimitiveCollection.Builder.set_my_string (builder, "hello");
		(* 219129.21875 is the cast to double of the next representable float
		of 219129.2111 *)
		FullPrimitiveCollection.Builder.set_my_float (builder, 219129.2111);
		FullPrimitiveCollection.Builder.set_my_double (builder, ~8382832823.392932211);
		FullPrimitiveCollection.Builder.build builder
	) 
in
	record
end

fun embeddedMessage () = 
let 
	(* Build 3 M3 messages to add to repeated field *)
	val m3_builder1 = M3.Builder.set_name (M3.Builder.init(), "some name");
	val m3_builder2 = M3.Builder.set_name (M3.Builder.init(), "another");
	val m3_builder3 = M3.Builder.set_name (M3.Builder.init(), "yet another");
	val m3_1 = M3.Builder.build m3_builder1
	val m3_2 = M3.Builder.build m3_builder2
	val m3_3 = M3.Builder.build m3_builder3

	val m2_builder1 = M1.M2.Builder.set_name (M1.M2.Builder.init(), "random");
	val m2_builder1 = M1.M2.Builder.set_id (m2_builder1, 121);
	val m2_builder2 = M1.M2.Builder.set_name (M1.M2.Builder.init(), "my name");
	val m2_builder2 = M1.M2.Builder.set_id (m2_builder2, 223);
	val m2_1 = M1.M2.Builder.build m2_builder1;
	val m2_2 = M1.M2.Builder.build m2_builder2;

	val m1_builder = M1.Builder.init();
	val m1_record = (
		M1.Builder.set_message2_1 (m1_builder, m2_1);
		M1.Builder.set_message2_2 (m1_builder, m2_2);
		M1.Builder.add_message3_list (m1_builder, m3_1);
		M1.Builder.add_message3_list (m1_builder, m3_2);
		M1.Builder.add_message3_list (m1_builder, m3_3);
		M1.Builder.build m1_builder
	)
in 
	m1_record
end

fun decode 0 = 
	let
		val input_stream = getByteInputStream "tests/smallcollection_cpp_encoded.dat";
		val (dec, parse_result) = SmallPrimitiveCollection.decodeToplevel input_stream
	in
		dec = (smallCollection())
	end
| decode 1 = 
	let
		val input_stream = getByteInputStream "tests/fullcollection_cpp_encoded.dat";
		val (dec, parse_result) = FullPrimitiveCollection.decodeToplevel input_stream
		val record = fullCollection()
	in
		(#my_int32 record) = (#my_int32 dec) andalso
		(#my_int64 record) = (#my_int64 dec) andalso
		(#my_uint32 record) = (#my_uint32 dec) andalso
		(#my_uint64 record) = (#my_uint64 dec) andalso
		(#my_sint32 record) = (#my_sint32 dec) andalso
		(#my_sint64 record) = (#my_sint64 dec) andalso
		(#my_fixed32 record) = (#my_fixed32 dec) andalso
		(#my_fixed64 record) = (#my_fixed64 dec) andalso
		(#my_sfixed32 record) = (#my_sfixed32 dec) andalso
		(#my_sfixed64 record) = (#my_sfixed64 dec) andalso
		(#my_bool record) = (#my_bool dec) andalso
		(#my_bytes record) = (#my_bytes dec) andalso
		(#my_string record) = (#my_string dec) andalso
		(* Manually comparing the float value as precision is lost, but 
		value is deterministic: the cast to double of the next representable
		float of the original value.*)
		(Real.== (219129.21875, Option.valOf(#my_float dec))) andalso
		(Real.== (Option.valOf (#my_double record), Option.valOf(#my_double dec)))
	end
| decode 2 = 
	let
		val input_stream = getByteInputStream "tests/embedded_cpp_encoded.dat";
		val (dec, parse_result) = M1.decodeToplevel input_stream
		val m1_record = embeddedMessage()
	in
		list_eq((#message3_list) m1_record, (#message3_list) dec) andalso
		(#message2_1) m1_record = (#message2_1) dec andalso
		(#message2_2) m1_record = (#message2_2) dec
	end
| decode n = raise invalidTest

fun encode 0 = 
	(* Simple test for message of type SmallPrimitiveCollection *)
	let
		val record = smallCollection ();
		val enc = SmallPrimitiveCollection.encodeToplevel record
	in
		(print("Writing SmallPrimitiveCollection to \"tests/smallcollection_ml_encoded.dat\".\n");
		 writeToFile "tests/smallcollection_ml_encoded.dat" enc)
	end
  | encode 1 = (* Test for message of type FullPrimitiveCollection, with floats. *)
	let
		val builder = FullPrimitiveCollection.Builder.init();
		val record = fullCollection ();
		val enc = FullPrimitiveCollection.encodeToplevel record
	in
		(print("Writing FullPrimitiveCollection to \"tests/fullcollection_ml_encoded.dat\".\n");
		 writeToFile "tests/fullcollection_ml_encoded.dat" enc)
	end
  | encode 2 = 	(* Simple test for message of type M1 in embedded.proto *)
	let
		val m1_record = embeddedMessage();
		val enc = M1.encodeToplevel m1_record
	in
		
		(print("Writing M1 embedded message to \"tests/embedded_ml_encoded.dat\".\n");
		 writeToFile "tests/embedded_ml_encoded.dat" enc)
	end
  | encode n = raise invalidTest

val lastTest = 2;

fun runEncoding () = 
let
	fun run i = if i <= lastTest then (encode i; run (i+1)) else ()
in
	run 0
end

fun runDecoding () = 
let
	fun run i = 
		if i > lastTest then (true, "TESTS PASS! All messages were decoded correctly!")
		else if (decode i) then (run (i+1))
		else (false, "Test " ^ Int.toString(i) ^ " failed")
	val (b, message) = run 0
in
	print(message^"\n")
end

fun main() = runDecoding ();