/* 
	g++ -I /usr/local/include -L /usr/local/lib topological_sort_test.cpp -lprotobuf -pthread
*/

#include <chrono>
#include <cstdlib>
#include <iostream>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/descriptor.pb.h>
#include "../src/compiler/ml_ordering.h"
#include "../src/compiler/graph_builder.h"

using namespace google::protobuf;
using namespace google::protobuf::compiler::ml;

DescriptorPool* pool;
int next_unique_suffix = 0;

// Returns the *inverse* graph for a binary tree (i.e. entry i in the vector is 
// the list of "parent" nodes for node i).
vector<vector<int> > buildBinaryTree(int n) {
	vector<vector<int> > RG(n, vector<int>());
	for (int i = 1; i < n; i++) {
		// The only parent for each node is a single node with index (i-1)/2.
		RG[i].push_back((i-1)/2);
	}
	return RG;
}

// Builds a 1-level nested type graph which is isomorphic to the directed graph 
// of indices, G. This function takes as argument the inverse graph of G, RG.
// This must be well formed (i.e. have size n and only contain vertex indices 
// between 0 and n).
const FileDescriptor* buildDescriptorGraph(int n, vector<vector<int> >* RG) {
	google::protobuf::FileDescriptorProto file;
	string unique_prefix = "_" + std::to_string(next_unique_suffix++);
	file.set_name("graph"+unique_prefix);

	for (int i = 0; i < n; i++) {
		google::protobuf::DescriptorProto* d = file.add_message_type();
		d->set_name("Node"+std::to_string(i)+unique_prefix);
		for (int j = 0; j < (*RG)[i].size(); j++) {
			int referenced_node_number = (*RG)[i][j];		
			google::protobuf::FieldDescriptorProto* field = d->add_field();

			// Each node has a field of the type NodeX, where NodeX is the 
			// parent in the binary reference graph we want to build, and X is a
			// number.
			field->set_type_name("Node"+std::to_string(referenced_node_number)
				+unique_prefix);

			// Unimportant, but required data.
			field->set_type(google::protobuf::FieldDescriptorProto::TYPE_MESSAGE);
			field->set_label(google::protobuf::FieldDescriptorProto::LABEL_OPTIONAL);
			// Name and number don't matter, as long as they are unique within 
			// this message.
			field->set_name("node"+std::to_string(referenced_node_number));
			field->set_number(j+1);
		}
	}
	return pool->BuildFile(file);
}

// Runs the sorter and graph builder on the given FileDescriptor and prints to
// standard output the times for each operation.
void run_test(const FileDescriptor* file) {
	// Start timer.
	std::chrono::high_resolution_clock::time_point start = 
		std::chrono::high_resolution_clock::now();
	MessageSorter sorter(file);

	// Get ordering, but ignore return value.
	sorter.get_ordering();

	// Stop timer and print time.
    std::chrono::high_resolution_clock::time_point finish = 
    	std::chrono::high_resolution_clock::now();
    long long duration = 
    	std::chrono::duration_cast<std::chrono::milliseconds>(finish - start).count();
    cout << "Topological sort of binary tree with root 0 ran in " << duration 
    	 << " ms\n";

    start = std::chrono::high_resolution_clock::now();
	GraphBuilder graph_builder(file);
	
	// Run graph builder separately
	graph_builder.rebuild_dependency_graph();

	// Stop timer and print time.
    finish = std::chrono::high_resolution_clock::now();
    duration = std::chrono::duration_cast<std::chrono::milliseconds>
    	(finish - start).count();
    cout << "------out of which building the dependency graph takes " 
         << duration << " ms\n";
}

// Builds a binary tree with normal order of edges {0, 1, 2, 3, ..., n-1} (0 is
// the root).
void binaryTreeTest() {
	vector<vector<int> > binary_tree = buildBinaryTree(10000);
	const FileDescriptor* file = buildDescriptorGraph(10000, &binary_tree);
	run_test(file);
	



	/*
	cout << fd->message_type(5)->name() << "\n";
	cout << fd->message_type(5)->field(0)->message_type()->name() << "\n";
	cout << fd->message_type(5)->name() << "\n";
	cout << fd->message_type(6)->field(0)->message_type()->name() << "\n";
	*/
}

int main() {
	pool = new DescriptorPool();
	binaryTreeTest();
	delete pool;
	return 0;
}