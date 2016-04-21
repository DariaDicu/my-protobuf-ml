/* 
	g++ -I /usr/local/include -L /usr/local/lib performance_test.cpp simple_message.pb.cc -lprotobuf -pthread
*/

#include <iostream>
#include <fstream>
#include <chrono>

#include "simple_message.pb.h"
#include "primitives.pb.h"

using namespace std;

SimpleMessage simple_message;
FullPrimitiveCollection primitives_message;

void readSimpleMessageFromFile() {
	fstream input("simple_message.dat", ios::in | ios::binary);
	if (!simple_message.ParseFromIstream(&input)) {
		cerr << "Failed to parse SimpleMessage instance from simple_message.dat\n";
	}
	/*
	cout << simple_message.id() << " is the id\n";
	cout << simple_message.name() << "\n";
	cout << simple_message.phone_number(0) << "\n";
	cout << simple_message.phone_number(1) << "\n";
	cout << simple_message.phone_number(2) << "\n";
	cout << simple_message.phone_number(3) << "\n";
	cout << simple_message.phone_number_size() << "\n";
	*/
}

void readPrimitivesMessageFromFile() {
	fstream input("primitives_message.dat", ios::in | ios::binary);
	if (!primitives_message.ParseFromIstream(&input)) {
		cerr << "Failed to parse FullPrimitiveCollection instance from primitives_message.dat\n";
	}
}

void serialize_simple_message_test() {
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
    long long duration = 
    	std::chrono::duration_cast<std::chrono::milliseconds>(finish - start).count();
    cout << "SimpleMessage serialization test ran in " << duration << " ms\n";
}

void serialize_primitives_message_test() {
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
    long long duration = 
    	std::chrono::duration_cast<std::chrono::milliseconds>(finish - start).count();
    cout << "FullPrimitiveCollection serialization ran in " << duration << " ms\n";
}

void deserialize_simple_message_test() {
	// Prepare parse data string by serializing the default message.
	string parsed_simple_message;
	simple_message.SerializeToString(&parsed_simple_message);

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
    long long duration = 
    	std::chrono::duration_cast<std::chrono::milliseconds>(finish - start).count();
    cout << "SimpleMessage deserialization test ran in " << duration << " ms\n";
}

void deserialize_primitives_message_test() {
	// Prepare parse data string by serializing the default message.
	string parsed_primitives_message;
	primitives_message.SerializeToString(&parsed_primitives_message);

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
    long long duration = 
    	std::chrono::duration_cast<std::chrono::milliseconds>(finish - start).count();
    cout << "FullPrimitiveCollection deserialization test ran in " << duration << " ms\n";

}

int main() {
	readSimpleMessageFromFile();
	readPrimitivesMessageFromFile();

	serialize_simple_message_test();
	serialize_primitives_message_test();
	deserialize_simple_message_test();
	deserialize_primitives_message_test();

	return 0;
}





