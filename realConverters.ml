val get = CInterface.get_sym "./lib_helpers.dylib";

fun bits64_of_real args = CInterface.call1 (get "bits64_of_real") 
	(CInterface.DOUBLE) CInterface.LONG args;

fun bits32_of_real args = CInterface.call1 (get "bits32_of_real") 
	(CInterface.DOUBLE) CInterface.LONG args;

fun real_of_bits64 args = CInterface.call1 (get "real_of_bits64") 
	(CInterface.LONG) CInterface.DOUBLE args;

fun real_of_bits32 args = CInterface.call1 (get "real_of_bits32") 
	(CInterface.LONG) CInterface.DOUBLE args;