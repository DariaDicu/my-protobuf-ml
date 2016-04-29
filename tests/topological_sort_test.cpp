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

// Returns a completely unconnected graph of size n.
vector<vector<int> > buildFlatGraph(int n) {
	vector<vector<int> > RG(n, vector<int>());
	return RG;
}

// Returns (the inverse of) a graph of size n where nodes are connected as a 
// chain (acyclic).
vector<vector<int> > buildChainGraph(int n) {
	vector<vector<int> > RG(n, vector<int>());
	for (int i = 1; i < n; i++) {
		RG[i].push_back(i-1);
	}
	return RG;
}

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

// Returns the *inverse* graph for an inverse binary tree (i.e. entry i in the 
// vector is he list of "parent" nodes for node i), which has root n (not 0).
vector<vector<int> > buildInverseBinaryTree(int n) {
	vector<vector<int> > RG(n, vector<int>());
	for (int i = 1; i < n; i++) {
		// The only parent for each node is a single node with index (i-1)/2.
		RG[n-1-i].push_back(n-1-((i-1)/2));
	}
	return RG;
}

vector<vector<int> > buildRandomTree(int n) {
	// Build a random tree rooted at 0.
	vector<vector<int> > RG(n, vector<int>());
	srand(time(NULL));
	for (int i = 1; i < n; i++) {
		// Pick a node in interval [0,i).
		int parent = rand() % i;
		RG[i].push_back(parent);
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
    cout << "------topological ran in " << duration << " ms\n";

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

void flatGraphTest() {
	vector<vector<int> > flat_graph = buildFlatGraph(10000);
	const FileDescriptor* file = buildDescriptorGraph(10000, &flat_graph);
	cout << "Running test for completely disconnected graph.\n";
	run_test(file);
}

void chainGraphTest() {
	vector<vector<int> > chain_graph = buildChainGraph(10000);
	const FileDescriptor* file = buildDescriptorGraph(10000, &chain_graph);
	cout << "Running test for chain graph.\n";
	run_test(file);
}

// Builds a binary tree with normal order of edges {0, 1, 2, 3, ..., n-1} (0 is
// the root).
void binaryTreeTest() {
	// TODO: average over 10 runs.
	vector<vector<int> > binary_tree = buildBinaryTree(10000);
	const FileDescriptor* file = buildDescriptorGraph(10000, &binary_tree);
	cout << "Running test for binary tree graph, nodes in order 0, 1, 2, ...\n";
	run_test(file);
}

void randomTreeTest() {
	// TODO: average over 10 runs.
	vector<vector<int> > random_tree = buildRandomTree(10000);
	const FileDescriptor* file = buildDescriptorGraph(10000, &random_tree);
	cout << "Running test for random tree rooted at 0\n";
	run_test(file);
}

// Builds a binary tree with normal order of edges {0, 1, 2, 3, ..., n-1} (0 is
// the root).
void inverseBinaryTreeTest() {
	// TODO: average over 10 runs.
	vector<vector<int> > binary_tree = buildInverseBinaryTree(10000);
	const FileDescriptor* file = buildDescriptorGraph(10000, &binary_tree);
	cout << "Running test for binary tree graph, nodes in order n, n-1 ...\n";
	run_test(file);
}

int main() {
	pool = new DescriptorPool();
	flatGraphTest();
	chainGraphTest();
	binaryTreeTest();
	inverseBinaryTreeTest();
	randomTreeTest();
	delete pool;
	return 0;
}