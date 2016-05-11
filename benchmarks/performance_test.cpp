/* 
	g++ -I /usr/local/include -L /usr/local/lib performance_test.cpp simple_message.pb.cc primitives.pb.cc -lprotobuf -pthread -o cpp_perf_test
*/

#include <iostream>
#include <fstream>
#include <chrono>

#include "simple_message.pb.h"
#include "primitives.pb.h"

using namespace std;

SimpleMessage simple_message;
FullPrimitiveCollection primitives_message;
FullPrimitiveCollection floating_point_message;

void readSimpleMessageFromFile() {
	fstream input("simple_message.dat", ios::in | ios::binary);
	if (!simple_message.ParseFromIstream(&input)) {
		cerr << "Failed to parse SimpleMessage instance from simple_message.dat\n";
	}
}

void readPrimitivesMessageFromFile() {
	fstream input("primitives_message.dat", ios::in | ios::binary);
	if (!primitives_message.ParseFromIstream(&input)) {
		cerr << "Failed to parse FullPrimitiveCollection instance from primitives_message.dat\n";
	}
}

void readFloatingPointMessageFromFile() {
	fstream input("floating_point_message.dat", ios::in | ios::binary);
	if (!floating_point_message.ParseFromIstream(&input)) {
		cerr << "Failed to parse FullPrimitiveCollection instance from floating_point_message.dat\n";
	}
}

void serialize_simple_message_test() {
	long long avg_duration = 0LL;
	for (int run = 1; run <= 5; run++) {
		// Start timer.
		std::chrono::high_resolution_clock::time_point start = 
			std::chrono::high_resolution_clock::now();

		for (int i = 0; i < 100000; i++) {
			std::string output;
			simple_message.SerializeToString(&output);
		}
		// Stop timer and print time.
	    std::chrono::high_resolution_clock::time_point finish = 
	    	std::chrono::high_resolution_clock::now();
	    if (run > 1 and run < 5) {
	    	avg_duration +=
	    	std::chrono::duration_cast<std::chrono::milliseconds>(finish - start).count();
	    }
    }
    cout << "SimpleMessage serialization test ran in " << avg_duration/3 << " ms\n";
}

void serialize_primitives_message_test() {
	long long avg_duration = 0LL;
	for (int run = 1; run <= 5; run++) {
		// Start timer.
		std::chrono::high_resolution_clock::time_point start = 
			std::chrono::high_resolution_clock::now();

		for (int i = 0; i < 100000; i++) {
			std::string output;
			simple_message.SerializeToString(&output);
		}

		// Stop timer and print time.
		std::chrono::high_resolution_clock::time_point finish = 
			std::chrono::high_resolution_clock::now();
		if (run > 1 and run < 5) {
	    	avg_duration +=
			std::chrono::duration_cast<std::chrono::milliseconds>(finish - start).count();
		}
	}
	cout << "FullPrimitiveCollection serialization (no floating point) ran in " 
		 << avg_duration/3 << " ms\n";
}

void serialize_floating_point_message_test() {
	long long avg_duration = 0LL;
	for (int run = 1; run <= 5; run++) {
		// Start timer.
		std::chrono::high_resolution_clock::time_point start = 
			std::chrono::high_resolution_clock::now();

		for (int i = 0; i < 100000; i++) {
			std::string output;
			floating_point_message.SerializeToString(&output);
		}

		// Stop timer and print time.
	    std::chrono::high_resolution_clock::time_point finish = 
	    	std::chrono::high_resolution_clock::now();
	   if (run > 1 and run < 5) {
	    	avg_duration +=
	    	std::chrono::duration_cast<std::chrono::milliseconds>(finish - start).count();
	    }
    }
    cout << "FullPrimitiveCollection serialization (WITH floating point) ran in "
    	 << avg_duration/3 << " ms\n";
}

void deserialize_simple_message_test() {
	// Prepare parse data string by serializing the default message.
	string parsed_simple_message;
	simple_message.SerializeToString(&parsed_simple_message);
	
	long long avg_duration = 0LL;
	for (int run = 1; run <= 5; run++) {
		// Start timer.
		std::chrono::high_resolution_clock::time_point start = 
			std::chrono::high_resolution_clock::now();

		for (int i = 0; i < 100000; i++) {
			SimpleMessage temporary;
			temporary.ParseFromString(parsed_simple_message);
		}

		// Stop timer and print time.
	    std::chrono::high_resolution_clock::time_point finish = 
	    	std::chrono::high_resolution_clock::now();
	    if (run > 1 and run < 5) {
	    	avg_duration +=
	    	std::chrono::duration_cast<std::chrono::milliseconds>(finish - start).count();
	    }
	}
    cout << "SimpleMessage deserialization test ran in " << avg_duration/3 
         << " ms\n";
}

void deserialize_primitives_message_test() {
	// Prepare parse data string by serializing the default message.
	string parsed_primitives_message;
	primitives_message.SerializeToString(&parsed_primitives_message);
	
	long long avg_duration = 0LL;
	for (int run = 1; run <= 5; run++) {
		// Start timer.
		std::chrono::high_resolution_clock::time_point start = 
			std::chrono::high_resolution_clock::now();

		for (int i = 0; i < 100000; i++) {
			FullPrimitiveCollection temporary;
			temporary.ParseFromString(parsed_primitives_message);
		}

		// Stop timer and print time.
	    std::chrono::high_resolution_clock::time_point finish = 
	    	std::chrono::high_resolution_clock::now();
	    if (run > 1 and run < 5) {
	    	avg_duration +=
	    	std::chrono::duration_cast<std::chrono::milliseconds>(finish - start).count();
	    }
	 }
    cout << "FullPrimitiveCollection deserialization (no floating point) test ran in "
         << avg_duration/3 << " ms\n";

}

void deserialize_floating_point_message_test() {
	// Prepare parse data string by serializing the default message.
	string parsed_fp_message;
	floating_point_message.SerializeToString(&parsed_fp_message);
	
	long long avg_duration = 0LL;
	for (int run = 1; run <= 5; run++) {
		// Start timer.
		std::chrono::high_resolution_clock::time_point start = 
			std::chrono::high_resolution_clock::now();

		for (int i = 0; i < 100000; i++) {
			FullPrimitiveCollection temporary;
			temporary.ParseFromString(parsed_fp_message);
		}

		// Stop timer and print time.
	    std::chrono::high_resolution_clock::time_point finish = 
	    	std::chrono::high_resolution_clock::now();
	    if (run > 1 and run < 5) {
		    avg_duration +=
	    	std::chrono::duration_cast<std::chrono::milliseconds>(finish - start).count();
	    }
	}
    cout << "FullPrimitiveCollection deserialization (WITH floating point) test ran in "
         << avg_duration/3 << " ms\n";
}

int main() {
	readSimpleMessageFromFile();
	readPrimitivesMessageFromFile();
	readFloatingPointMessageFromFile();

	serialize_simple_message_test();
	serialize_primitives_message_test();
	serialize_floating_point_message_test();
	deserialize_simple_message_test();
	deserialize_primitives_message_test();
	deserialize_floating_point_message_test();

	return 0;
}





