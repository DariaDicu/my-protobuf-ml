/* 
	make check
	./topological_test	
*/

#include <chrono>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/descriptor.pb.h>
#include "../src/compiler/ml_ordering.h"
#include "../src/compiler/graph_builder.h"

using namespace google::protobuf;
using namespace google::protobuf::compiler::ml;

DescriptorPool* pool;
int next_unique_suffix = 0;

// Returns a completely unconnected graph of size n.
// For type 1.
vector<vector<int> > buildFlatGraph(int n) {
	vector<vector<int> > RG(n, vector<int>());
	return RG;
}

// Returns (the inverse of) a graph of size n where nodes are connected as a 
// chain (acyclic).
// For type 3.
vector<vector<int> > buildChainGraph(int n) {
	vector<vector<int> > RG(n, vector<int>());
	for (int i = 1; i < n; i++) {
		RG[i].push_back(i-1);
	}
	return RG;
}

// Returns the *inverse* graph for a binary tree (i.e. entry i in the vector is 
// the list of "parent" nodes for node i).
// For type 2.
vector<vector<int> > buildBinaryTree(int n) {
	vector<vector<int> > RG(n, vector<int>());
	for (int i = 1; i < n; i++) {
		// The only parent for each node is a single node with index (i-1)/2.
		RG[i].push_back((i-1)/2);
	}
	return RG;
}

// Returns the *inverse* graph for a random tree. TODO: replace tree with DAG.
// For type 4.
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
// of indices, G. This function takes as argument the inverse graph of G (RG).
// This must be well formed (i.e. have size n and only contain vertex indices 
// between 0 and n).
// For type 1,2,3,4.
const FileDescriptor* buildOneLevelDescriptorGraph(int n, 
  vector<vector<int> >* RG) {
	google::protobuf::FileDescriptorProto file;
	string unique_prefix = "_" + std::to_string(++next_unique_suffix);
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
			field->set_type(
				google::protobuf::FieldDescriptorProto::TYPE_MESSAGE);
			field->set_label(
				google::protobuf::FieldDescriptorProto::LABEL_OPTIONAL);
			// Name and number don't matter, as long as they are unique within 
			// this message.
			field->set_name("node"+std::to_string(referenced_node_number));
			field->set_number(j+1);
		}
	}
	return pool->BuildFile(file);
}

// Helper for builing a nested type tree with branch factor 10 that where each 
// message has 10 fields that refer to a random ancestor sibling (with replace-
// ment). Care is taken to not introduce mutual recursion (only siblings with
// index < ancestor index are considered).
// For type 6.
void buildBranchedDescriptorGraph_recursive(google::protobuf::DescriptorProto* 
	d, int i, int n, vector<int>* possible_references) {
	string unique_prefix = "_" + std::to_string(next_unique_suffix);
	d->set_name("Node"+std::to_string(i)+unique_prefix);

	for (int child = 1; child <= 10; child++) 
		if (10*i + child < n) {
			buildBranchedDescriptorGraph_recursive(d->add_nested_type(), 
				10*i + child, n, possible_references);
			(*possible_references).push_back(10*i + child);
		}

	// Push all children off the stack.
	for (int child = 1; child <= 10; child++) 
		if (10*i + child < n) {
			(*possible_references).pop_back();
		}

	// It may be the case that there are no possible references.
	if (possible_references->size() == 0) return;
	
	for (int f = 1; f <= 1; f++) {
		int index = rand()%(possible_references->size());
		int reference = (*possible_references)[index];

		// Add a field from Message i to Message i+m.
		google::protobuf::FieldDescriptorProto* field = d->add_field();

		field->set_type_name("Node"+std::to_string(reference)+
			unique_prefix);

		// Unimportant, but required data.
		field->set_type(
			google::protobuf::FieldDescriptorProto::TYPE_MESSAGE);
		field->set_label(
			google::protobuf::FieldDescriptorProto::LABEL_OPTIONAL);
		// Name and number don't matter, as long as they are unique within 
		// this message.
		field->set_name("node"+std::to_string(f));
		field->set_number(f);
		//cout << i << " has field " << reference << "\n";
	}
	//cout << "----------\n";
}

// For type 6.
const FileDescriptor* buildBranchedDescriptorGraph(int n) {
	google::protobuf::FileDescriptorProto file;
	string unique_prefix = "_" + std::to_string(++next_unique_suffix);
	file.set_name("graph"+unique_prefix);

	google::protobuf::DescriptorProto* d = file.add_message_type();
	vector<int>*possible_references = new vector<int>();
	possible_references->reserve(n);
	srand(time(NULL));
	buildBranchedDescriptorGraph_recursive(d, 0, n, possible_references);

	delete possible_references;
	return pool->BuildFile(file);
}

// For type 5.
const FileDescriptor* buildChainDescriptorGraph(int n) {
	google::protobuf::FileDescriptorProto file;
	google::protobuf::FieldDescriptorProto* field;
	string unique_prefix = "_" + std::to_string(++next_unique_suffix);
	file.set_name("graph"+unique_prefix);

	google::protobuf::DescriptorProto* next_descriptor = 
		file.add_message_type();

	// Chain of n-1 messages + 1 extra message which all messages refer to.
	for (int i = 1; i < n; i++) {
		next_descriptor->set_name("Node"+std::to_string(i)+unique_prefix);
		field = next_descriptor->add_field();

		field->set_type_name("Node"+std::to_string(n)+unique_prefix);

		// Unimportant, but required data.
		field->set_type(google::protobuf::FieldDescriptorProto::TYPE_MESSAGE);
		field->set_label(google::protobuf::FieldDescriptorProto::LABEL_OPTIONAL);
		// Name and number don't matter, as long as they are unique within 
		// this message.
		field->set_name("node"+std::to_string(n));
		field->set_number(1);
		// Prepare descriptor for next node in chain.
		if (i != n-1) {
			next_descriptor = next_descriptor->add_nested_type();
		}
	}
	// Add the extra top level node that all messages refer to (empty message).
	next_descriptor = file.add_message_type();
	next_descriptor->set_name("Node"+std::to_string(n)+unique_prefix);
	const google::protobuf::FileDescriptor* fd = pool->BuildFile(file);
	return fd;
}

void run_test_for_plot(const FileDescriptor* file, int n, fstream* output) {
	std::chrono::high_resolution_clock::time_point start;
	std::chrono::high_resolution_clock::time_point finish;
	long long summed_duration = 0;
	MessageSorter* sorter;

	for (int r = 0; r < 3; r++) {
		// Start timer.
		start = std::chrono::high_resolution_clock::now();

		sorter = new MessageSorter(file);
		sorter->get_ordering();

		// Stop timer and print time.
	    finish = std::chrono::high_resolution_clock::now();
	    long long duration = 
	    	std::chrono::duration_cast<std::chrono::nanoseconds>
	    	(finish - start).count();

		delete sorter;
	    summed_duration += duration;
	}
	*output << n << " " << (summed_duration/3) << "\n";
	output->flush();
	cout << n << " -- time " << ((double)summed_duration/3000000000) << " s \n";
	/*
    summed_duration = 0;
    for (int r = 0; r < 3; r++) {
	    start = std::chrono::high_resolution_clock::now();
		GraphBuilder graph_builder(file);
		
		// Run graph builder separately
		graph_builder.rebuild_dependency_graph();

		// Stop timer and print time.
	    finish = std::chrono::high_resolution_clock::now();
	    long long duration = 
	    	std::chrono::duration_cast<std::chrono::nanoseconds>
	    	(finish - start).count();
	    summed_duration += duration;
	}
    *output << (summed_duration/3) << "\n";
    */
}

// TEST CASE I. 1 level nested type tree; disconnected dependency graph.
void type1Test(int n) {
	vector<vector<int> > flat_graph = buildFlatGraph(n);
	const FileDescriptor* file = buildOneLevelDescriptorGraph(n, &flat_graph);
	cout << "Running test for type 1 topology.\n";
	// run_test(file);
	// Running to plot graph
	fstream output("plots/type1_plot.txt", ios::out | ios::app);
	run_test_for_plot(file, n, &output);
}

// TEST CASE II. 1 level nested type tree; binary dependency graph.
void type2Test(int n) {
	vector<vector<int> > binary_tree = buildBinaryTree(n);
	const FileDescriptor* file =  buildOneLevelDescriptorGraph(n, &binary_tree);

	fstream output("plots/type2_plot.txt", ios::out | ios::app);
	cout << "Running test for type 2 topology.\n";
	run_test_for_plot(file, n, &output);
}

// TEST CASE III. 1 level nested type tree; chain dependency graph.
void type3Test(int n) {
	vector<vector<int> > chain_graph = buildChainGraph(n);
	const FileDescriptor* file = buildOneLevelDescriptorGraph(n, &chain_graph);
	cout << "Running test for type 3 topology.\n";
	//run_test(file);
	// Running to plot graph

	fstream output("plots/type3_plot.txt", ios::out | ios::app);
	run_test_for_plot(file, n, &output);
}

// TEST CASE IV. 1 level nested type tree; random (DAG) dependency graph.
void type4Test(int n) {
	vector<vector<int> > random_tree = buildRandomTree(n);
	const FileDescriptor* file = buildOneLevelDescriptorGraph(n, &random_tree);
	cout << "Running test for type 4 topology.\n";
	//run_test(file);

	// Running to plot graph
	fstream output("plots/type4_plot.txt", ios::out | ios::app);
	run_test_for_plot(file, n, &output);
}

// TEST CASE V. chain nested type tree; (almost) disconnected dependency graph.
void type5Test(int n) {
	const FileDescriptor* file = buildChainDescriptorGraph(n);
	cout << "Running test for type 5 topology.\n";
	//run_test(file);

	fstream output("plots/type5_plot.txt", ios::out | ios::app);
	run_test_for_plot(file, n, &output);
}

// TEST CASE VI. branch factor 10 nested type tree; 
void type6Test(int n) {
	const FileDescriptor* file = buildBranchedDescriptorGraph(n);
	cout << "Running test for type 6 topology.\n";
	//run_test(file);
	fstream output("plots/type6_plot.txt", ios::out | ios::app);
	file = buildBranchedDescriptorGraph(n);
	run_test_for_plot(file, n, &output);
}

int main(int argc, char** argv) {
	if (argc != 3) {
		cout << "Not enough/too many arguments. Aborting.\n";
		return 0;
	}
	int t = atoi(argv[1]);
	int n = atoi(argv[2]);

	pool = new DescriptorPool();
	switch (t) {
		case 1:
			type1Test(n); break;
		case 2:
			type2Test(n); break;
		case 3:
			type3Test(n); break;
		case 4:
			type4Test(n); break;
		case 5:
			type5Test(n); break;
		case 6:
			type6Test(n); break;
		default:
			cout << "Unknown test\n";
	}
	delete pool;
	return 0;
}