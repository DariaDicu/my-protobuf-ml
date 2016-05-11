(* ocamlfind ocamlc -linkpkg -package piqirun.pb simple_message_piqi.ml \
primitives_piqi.ml performance_test_ocaml.ml -o ocaml_perf_test *)

module SM = Simple_message_piqi;;
module PM = Primitives_piqi;;


let get_simple_message = 
let channel = Pervasives.open_in_bin "simple_message.dat" in
let buff = Piqirun.init_from_channel channel in
let simple_message = SM.parse_simple_message buff in
close_in channel; simple_message;;

let get_primitives_message = 
let channel = Pervasives.open_in_bin "primitives_message.dat" in
let buff = Piqirun.init_from_channel channel in
let primitives_message = PM.parse_full_primitive_collection buff in
close_in channel; primitives_message;;

let get_floating_point_message = 
let channel = Pervasives.open_in_bin "floating_point_message.dat" in
let buff = Piqirun.init_from_channel channel in
let floating_point_message = PM.parse_full_primitive_collection buff in
close_in channel; floating_point_message;;


(* Printing parsed contents for sanity check.
let contents z = 
   match z with
   Some c -> c;;

let simple_message = get_simple_message in
print_string (Int32.to_string simple_message.SM.Simple_message.id);
print_string (contents simple_message.SM.Simple_message.name)
;;

print_float (contents get_floating_point_message.PM.Full_primitive_collection.my_float);;
*)

let serialize_simple_message_test () = 
	let simple_message = get_simple_message in
	let start = Sys.time () in
	for counter = 1 to 100000 do 
		let s = Piqirun.to_string(SM.gen_simple_message simple_message) in ()
	done;
	let stop = Sys.time () in
	(stop -. start);;


let serialize_primitives_message_test () = 
	let primitives_message = get_primitives_message in
	let start = Sys.time () in
	for counter = 1 to 100000 do 
		let s = Piqirun.to_string(PM.gen_full_primitive_collection primitives_message) in ()
	done;
	let stop = Sys.time () in
	(stop -. start);;


let serialize_floating_point_message_test () = 
	let floating_point_message = get_floating_point_message in
	let start = Sys.time () in
	for counter = 1 to 100000 do 
		let s = Piqirun.to_string(PM.gen_full_primitive_collection floating_point_message) in ()
	done;
	let stop = Sys.time () in
	(stop -. start);;

let deserialize_simple_message_test () = 
	let encoded_simple_message = Piqirun.to_string(SM.gen_simple_message get_simple_message) in
	let start = Sys.time () in
	for counter = 1 to 100000 do 
		let buff = Piqirun.init_from_string encoded_simple_message in
		SM.parse_simple_message buff
	done;
	let stop = Sys.time () in
	(stop -. start);;

let deserialize_primitives_message_test () = 
	let encoded_primitives_message = Piqirun.to_string(PM.gen_full_primitive_collection get_primitives_message) in
	let start = Sys.time () in
	for counter = 1 to 100000 do 
		let buff = Piqirun.init_from_string encoded_primitives_message in
		PM.parse_full_primitive_collection buff
	done;
	let stop = Sys.time () in
	(stop -. start);;

let deserialize_floating_point_message_test () = 
	let encoded_floating_point_message = Piqirun.to_string(PM.gen_full_primitive_collection get_floating_point_message) in
	let start = Sys.time () in
	for counter = 1 to 100000 do 
		let buff = Piqirun.init_from_string encoded_floating_point_message in
		PM.parse_full_primitive_collection buff
	done;
	let stop = Sys.time () in
	(stop -. start);;

let average_test_runs test_function print_message = 
let avg_time = ref 0.0 in
for i = 1 to 5 do
	let t = test_function() in
	if (i > 1 && i < 5) then avg_time := !avg_time +. (t/.3.0)
done;
print_string (print_message);
print_float (!avg_time);
print_string ("\n");;

average_test_runs serialize_simple_message_test
"Simple message serialization ran in (averaged over mid 3 runs): ";;

average_test_runs serialize_primitives_message_test
"Primitives message (no floats) serialization ran in (averaged over mid 3 runs): ";;

average_test_runs serialize_floating_point_message_test
"Primitives message (WITH floats) serialization ran in (averaged over mid 3 runs): ";;

average_test_runs deserialize_simple_message_test
"Simple message deserialization ran in (averaged over 3 mid runs): ";;

average_test_runs deserialize_primitives_message_test
"Primitives message (no floats) deserialization ran in (averaged over mid 3 runs): ";;

average_test_runs deserialize_floating_point_message_test 
"Primitives message (WITH floats) deserialization ran in (averaged over mid 3 runs): ";;

print_string "done\n";;





