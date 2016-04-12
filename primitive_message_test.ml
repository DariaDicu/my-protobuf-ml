use "tests/primitives.pb.ml";

(* Test uses precompiled file called primitives.pb.ml*)
exception invalidTest

fun test 0 = 
	(* Simple test for message of type SmallPrimitiveCollection *)
	let
		val builder = SmallPrimitiveCollection.Builder.init();
		val record = (
			SmallPrimitiveCollection.Builder.set_my_int32 (builder, ~1);
			SmallPrimitiveCollection.Builder.set_my_int64 (builder, 221921921929121);
			SmallPrimitiveCollection.Builder.set_my_string (builder, "hello");
			SmallPrimitiveCollection.Builder.build builder
		) 
		val enc = SmallPrimitiveCollection.encode record
		val (dec, parse_result) = SmallPrimitiveCollection.decode (ByteInputStream.fromVector enc) 
	in
		(print("Running test 0.\n"); record = dec)
	end
  | test 1 = (* Test for message of type FullPrimitiveCollection *)
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
			FullPrimitiveCollection.Builder.build builder
		) 
		val enc = FullPrimitiveCollection.encode record
		val (dec, parse_result) = FullPrimitiveCollection.decode (ByteInputStream.fromVector enc) 
	in
		(print "Running test 1.\n"; 
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
			(#my_string record) = (#my_string dec) (*andalso
			(#my_float record) = (#my_float dec) *)
			(* TODO add float & double *)
		)
	end
  | test n = raise invalidTest

val lastTest = 1;

(* use "primitive_test.ml"; runTests(); *)
fun runTests () = 
let
	fun run i = 
	if i > lastTest then (true, "All tests pass!")
	else if (test i) then (run (i+1))
	else (false, "Test " ^ Int.toString(i) ^ " failed")
in
	run 0
end