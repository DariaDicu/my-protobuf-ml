(* Testing correctness of ML encoding against ML decoding on embedded.proto. *)

use "tests/embedded.pb.ml";
use "tests/test_helpers.ml";


(* Test uses precompiled file called embedded.pb.ml*)
exception invalidTest

fun test 0 = 
	(* Simple test for message of type M1 in embedded.proto *)
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
		val enc = M1.encode m1_record
		val (dec, parse_result) = M1.decode (ByteInputStream.fromVector enc)
	in
		(print("Running test 0.\n"); 
		list_eq((#message3_list) m1_record, (#message3_list) dec) andalso
		(#message2_1) m1_record = (#message2_1) dec andalso
		(#message2_2) m1_record = (#message2_2) dec
		)
	end
  | test n = raise invalidTest

val lastTest = 0;

fun runTests () = 
let
	fun run i = 
		if i > lastTest then (true, "All tests pass!")
		else if (test i) then (run (i+1))
		else (false, "Test " ^ Int.toString(i) ^ " failed");
	val (b, message) = run 0;
in
	print(message^"\n")
end;

fun main () = runTests ();