/* 
	g++ -I /usr/local/include -L /usr/local/lib ml_cpp_test.cpp embedded.pb.cc primitives.pb.cc -lprotobuf -pthread
*/

#include <iostream>
#include <fstream>
#include <chrono>

#include "embedded.pb.h"
#include "primitives.pb.h"
#include <google/protobuf/util/message_differencer.h>

using namespace std;

// Parsed messages, as decoded from the *_ml_encoded.dat files.
SmallPrimitiveCollection parsed_small_collection;
FullPrimitiveCollection parsed_full_collection;
M1 parsed_embedded_message;

// Original messages (values set by hand, they match ML test values.)
SmallPrimitiveCollection original_small_collection;
FullPrimitiveCollection original_full_collection;
M1 original_embedded_message;

// Build functions build the original objects (values added by hand).
void buildSimpleCollection() {
	original_small_collection.set_my_int32(-1);
	original_small_collection.set_my_int64(221921921929121);
	original_small_collection.set_my_string("hello");
}

void buildFullCollection() {
	original_full_collection.set_my_int32(-1);
	original_full_collection.set_my_uint32(3232321);
	original_full_collection.set_my_int32(-1);
	original_full_collection.set_my_int64(221921921929121);
	original_full_collection.set_my_uint32(3232321);
	original_full_collection.set_my_uint64(9977533344322);
	original_full_collection.set_my_sint32(-123);
	original_full_collection.set_my_sint64(-221921921929121);
	original_full_collection.set_my_fixed32(-323231);
	original_full_collection.set_my_fixed64(221921921929121);
	original_full_collection.set_my_sfixed32(-67565);
	original_full_collection.set_my_sfixed64(69595969659659);
	original_full_collection.set_my_bool(true);
	char arr[] = {0x1,0xFF,0x23}; 
	string s(arr);
	original_full_collection.set_my_bytes(s);
	original_full_collection.set_my_string("hello");
	original_full_collection.set_my_float((float)219129.2111);
	original_full_collection.set_my_double((double)-8382832823.392932211);
}

void buildEmbeddedMessage() {
	M1_M2* m2_1 = original_embedded_message.mutable_message2_1();
	M1_M2* m2_2 = original_embedded_message.mutable_message2_2();
	m2_1->set_name("random");
	m2_1->set_id(121);
	m2_2->set_name("my name");
	m2_2->set_id(223);
	
	M3* m3_1 = original_embedded_message.add_message3_list();
	m3_1->set_name("some name");
	M3* m3_2 = original_embedded_message.add_message3_list();
	m3_2->set_name("another");
	M3* m3_3 = original_embedded_message.add_message3_list();
	m3_3->set_name("yet another");
}

// Functions to parse messages encoded by ML library.
void readSimpleCollectionFromFile() {
	fstream input("smallcollection_ml_encoded.dat", ios::in | ios::binary);
	if (!parsed_small_collection.ParseFromIstream(&input)) {
		cerr << "Failed to parse SmallPrimitiveCollection instance from smallcollection_ml_encoded.dat\n";
	}
}

void readFullCollectionFromFile() {
	fstream input("fullcollection_ml_encoded.dat", ios::in | ios::binary);
	if (!parsed_full_collection.ParseFromIstream(&input)) {
		cerr << "Failed to parse FullPrimitiveCollection instance from fullcollection_ml_encoded.dat\n";
	}
}

void readEmbeddedMessageFromFile() {
	fstream input("embedded_ml_encoded.dat", ios::in | ios::binary);
	if (!parsed_embedded_message.ParseFromIstream(&input)) {
		cerr << "Failed to parse embedded message instance from embedded_ml_encoded.dat\n";
	}
}

// Compares each field in between the parsed and original messages.
void compareSimpleCollection() {
	string error_string;
	google::protobuf::util::MessageDifferencer differencer;

	differencer.ReportDifferencesToString(&error_string);

	if (differencer.Compare(parsed_small_collection, 
		original_small_collection)) {
		cout << "SUCCESS: Small collection messages match!\n";
	} else {
		cout << "ERROR: Small collection messages don't match!\n";
		cerr << error_string << "\n";
	}
}

void compareFullCollection() {
	string error_string;
	google::protobuf::util::MessageDifferencer differencer;

	differencer.ReportDifferencesToString(&error_string);

	if (differencer.Compare(parsed_full_collection, original_full_collection)) {
		cout << "SUCCESS: Full collection messages match!\n";
	} else {
		cout << "ERROR: Full collection messages don't match!\n";
		cerr << error_string << "\n";
	}
}

// Compares lists as sets and outputs any differences.
void compareEmbeddedMessage() {
	string error_string;
	google::protobuf::util::MessageDifferencer differencer;

	differencer.set_repeated_field_comparison(
		google::protobuf::util::MessageDifferencer::AS_SET);
	differencer.ReportDifferencesToString(&error_string);

	if (differencer.Compare(parsed_embedded_message, 
		original_embedded_message)) {
		cout << "SUCCESS: Embedded messages match!\n";
	} else {
		cout << "ERROR: Embedded messages don't match!\n";
		cerr << error_string << "\n";
	}
}

void serialize_small_collection_test() {
	fstream output("smallcollection_cpp_encoded.dat", ios::out | ios::trunc 
		| ios::binary);
	original_small_collection.SerializeToOstream(&output);
}

void serialize_full_collection_test() {
	fstream output("fullcollection_cpp_encoded.dat", ios::out | ios::trunc | ios::binary);
	original_full_collection.SerializeToOstream(&output);
}

void serialize_embedded_message_test() {
	fstream output("embedded_cpp_encoded.dat", ios::out | ios::trunc | ios::binary);
	original_embedded_message.SerializeToOstream(&output);
}

int main() {
	buildSimpleCollection();
	buildFullCollection();
	buildEmbeddedMessage();

	readSimpleCollectionFromFile();
	readFullCollectionFromFile();
	readEmbeddedMessageFromFile();

	compareSimpleCollection();
	compareFullCollection();
	compareEmbeddedMessage();

	serialize_small_collection_test();
	serialize_full_collection_test();
	serialize_embedded_message_test();
	return 0;
}