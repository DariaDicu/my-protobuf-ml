use "MlGenLib.ml";

(* PolyML:
	
	use "primitive_test.ml"; runTests();


*)
exception invalidTest


(*Tests if encode-decode match for a given tuple of encode, decode functions.*)
(*Works for equality types only.*)
fun test_serialization (enc_func, dec_func) v = 
	let val enc = enc_func v
		val istream = ByteInputStream.fromVector enc
		val (dec, parse_result) = dec_func istream
	in
	    (print ("Expected " ^ Int.toString(v) ^ ", decoded " ^ Int.toString(dec) ^ "\n")
		; dec = v)
	end

(*Tests if encode-decode match for a given tuple of encode, decode functions.*)
fun test_serialization_bools (enc_func, dec_func) b = 
	let val enc = enc_func b
		val istream = ByteInputStream.fromVector enc
		val (dec, parse_result) = dec_func istream
	in
	    (print ("Expected " ^ Bool.toString(b) ^ ", decoded " ^ Bool.toString(dec) ^ "\n")
		; dec = b)
	end

(*Tests if encode-decode match for a given tuple of encode, decode functions.*)
fun test_serialization_strings(enc_func, dec_func) s = 
	let val enc = enc_func s
		val istream = ByteInputStream.fromVector enc
		val (dec, parse_result) = dec_func istream
	in
	    (print ("Expected \"" ^ s ^ "\", decoded \"" ^ dec ^ "\"\n")
		; dec = s)
	end

(*Tests if encode-decode match for a given tuple of encode, decode functions.*)
fun test_serialization_bytes(enc_func, dec_func) bytes = 
	let val enc = enc_func bytes
		val istream = ByteInputStream.fromVector enc
		val (dec, parse_result) = dec_func istream
	in
	    (if (dec = bytes) then print ("Bytes encoded successfully\n")
						  else print ("Bytes encoding failed.\n")
		; dec = bytes)
	end

(*Tests that running encode-decode raises an exception.*)
fun test_serialization_expect_exception (enc_func, dec_func) v =
	(dec_func (ByteInputStream.fromVector (enc_func v)); print ("Failed - no exception raised.\n"); false)
		handle e' => (print ("Expected exception was successfully raised.\n"); true)
		(*(print ("Expected exception " ^ e ^ ". " ^ (#1 e') ^ " was raised.");
			e = (#1 e'))*)

fun test 0 = test_serialization (encodeInt32, decodeInt32) 332323
  | test 1 = test_serialization (encodeInt32, decodeInt32) 0
  | test 2 = test_serialization (encodeInt32, decodeInt32) ((IntInf.pow(2,31)) - 1)
  | test 3 = test_serialization (encodeInt32, decodeInt32) (~(IntInf.pow(2,31)))
  | test 4 = test_serialization (encodeInt32, decodeInt32) ~1

  | test 5 = test_serialization (encodeInt64, decodeInt64) 2932283232323223
  | test 6 = test_serialization (encodeInt64, decodeInt64) ~392
  | test 7 = test_serialization (encodeInt64, decodeInt64) ~392323203020032
  | test 8 = test_serialization (encodeInt64, decodeInt64) 3232
  | test 9 = test_serialization (encodeInt64, decodeInt64) (~(IntInf.pow(2,63)))
  | test 10 = test_serialization (encodeInt64, decodeInt64) ((IntInf.pow(2,63)) - 1)

  | test 11 = test_serialization (encodeSfixed32, decodeSfixed32) 33232239
  | test 12 = test_serialization (encodeSfixed32, decodeSfixed32) ~92122239
  | test 13 = test_serialization (encodeSfixed32, decodeSfixed32) 0
  | test 14 = test_serialization (encodeSfixed32, decodeSfixed32) ((IntInf.pow(2,31)) - 1)
  | test 15 = test_serialization (encodeSfixed32, decodeSfixed32) (~(IntInf.pow(2,31)))

  | test 16 = test_serialization (encodeSfixed64, decodeSfixed64) 33232239
  | test 17 = test_serialization (encodeSfixed64, decodeSfixed64) ~92122239
  | test 18 = test_serialization (encodeSfixed64, decodeSfixed64) 0
  | test 19 = test_serialization (encodeSfixed64, decodeSfixed64) 291929247563727
  | test 20 = test_serialization (encodeSfixed64, decodeSfixed64) ~9328328322122239
  | test 21 = test_serialization (encodeSfixed64, decodeSfixed64) ((IntInf.pow(2,63)) - 1)
  | test 22 = test_serialization (encodeSfixed64, decodeSfixed64) (~(IntInf.pow(2,63)))

  | test 23 = test_serialization (encodeSint32, decodeSint32) 332323
  | test 24 = test_serialization (encodeSint32, decodeSint32) 0
  | test 25 = test_serialization (encodeSint32, decodeSint32) ((IntInf.pow(2,31)) - 1)
  | test 26 = test_serialization (encodeSint32, decodeSint32) (~(IntInf.pow(2,31)))
  | test 27 = test_serialization (encodeSint32, decodeSint32) ~1

  | test 28 = test_serialization (encodeSint64, decodeSint64) 332323323232
  | test 29 = test_serialization (encodeSint64, decodeSint64) 0
  | test 30 = test_serialization (encodeSint64, decodeSint64) ((IntInf.pow(2,63)) - 1)
  | test 31 = test_serialization (encodeSint64, decodeSint64) (~(IntInf.pow(2,63)))
  | test 32 = test_serialization (encodeSint64, decodeSint64) ~13828328238232
  | test 33 = test_serialization (encodeSint64, decodeSint64) ~1

  | test 34 = test_serialization (encodeUint32, decodeUint32) 0
  | test 35 = test_serialization (encodeUint32, decodeUint32) 12
  | test 36 = test_serialization (encodeUint32, decodeUint32) 123923923
  | test 37 = test_serialization (encodeUint32, decodeUint32) ((IntInf.pow(2,32)) - 1)

  | test 38 = test_serialization (encodeUint64, decodeUint64) 0
  | test 39 = test_serialization (encodeUint64, decodeUint64) 12322
  | test 40 = test_serialization (encodeUint64, decodeUint64) 1239239233232932
  | test 41 = test_serialization (encodeUint64, decodeUint64) ((IntInf.pow(2,64)) - 1)

  | test 42 = test_serialization (encodeFixed32, decodeFixed32) 12911933
  | test 43 = test_serialization (encodeFixed32, decodeFixed32) ~128323823
  | test 44 = test_serialization (encodeFixed32, decodeFixed32) 0
  | test 45 = test_serialization (encodeFixed32, decodeFixed32) ((IntInf.pow(2,31)) - 1)
  | test 46 = test_serialization (encodeFixed32, decodeFixed32) (~(IntInf.pow(2,31)))

  | test 47 = test_serialization (encodeFixed64, decodeFixed64) 12911933
  | test 48 = test_serialization (encodeFixed64, decodeFixed64) ~128323823
  | test 49 = test_serialization (encodeFixed64, decodeFixed64) 0
  | test 50 = test_serialization (encodeFixed64, decodeFixed64) 192038447563727
  | test 51 = test_serialization (encodeFixed64, decodeFixed64) ~2731192932929323
  | test 52 = test_serialization (encodeFixed64, decodeFixed64) ((IntInf.pow(2,63)) - 1)
  | test 53 = test_serialization (encodeFixed64, decodeFixed64) (~(IntInf.pow(2,63)))

  | test 54 = test_serialization_bools (encodeBool, decodeBool) true
  | test 55 = test_serialization_bools (encodeBool, decodeBool) false

  | test 56 = test_serialization_strings (encodeString, decodeString) ""
  | test 57 = test_serialization_strings (encodeString, decodeString) "here"
  | test 58 = test_serialization_strings (encodeString, decodeString) "Here is some longer and more complex string to encode."

  | test 59 = test_serialization_bytes (encodeBytes, decodeBytes) (Word8Vector.fromList [])
  | test 60 = test_serialization_bytes (encodeBytes, decodeBytes) (Word8Vector.fromList [0wx1,0wx2])
  | test 61 = test_serialization_bytes (encodeBytes, decodeBytes) (Word8Vector.fromList [0wx21,0wx2,0wx32,0wxFF,0wx0,0wxFA])

  | test 62 = test_serialization_expect_exception (encodeUint32, decodeUint32) 1239239233232932
  | test n = raise invalidTest

val lastTest = 62;
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