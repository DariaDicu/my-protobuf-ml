#include "ml_ordering.h"

#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/stubs/strutil.h>
#include <algorithm>
#include <set>
#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>

#define map_iterator std::unordered_map<const Descriptor*, int>::iterator

namespace google {
namespace protobuf {
namespace compiler {
namespace ml {

MessageSorter::MessageSorter(const FileDescriptor* file) : file(file), 
	graph_builder(file), node_count(0) {}

MessageSorter::~MessageSorter() {};

int MessageSorter::get_index(const Descriptor* node) {
	return index_map[node];
}

void MessageSorter::index_nodes() {
	for (int i = 0; i < file->message_type_count(); i++) {
		index_nodes_traversal(file->message_type(i));
	}
}

void MessageSorter::index_nodes_traversal(const Descriptor* node) {
  if (index_map.find(node) != index_map.end()) {
  	return;
  }
  index_map[node] = ++node_count;

  for (int i = 0; i < node->nested_type_count(); i++) {
  	index_nodes_traversal(node->nested_type(i));
  }
}

void MessageSorter::sort() {
	// Build the dependency graph from FileDescriptor using GraphBuilder class.
	adjacency_list = graph_builder.get_adjacency_list();

	// Index nodes to be represented by numbers and store list of all 
	// descriptors.
	index_nodes();

	// Initialize in_stack and visited to be false for every index.
	in_stack = vector<bool>(node_count+3, false);
	visited = vector<bool>(node_count+3, false);

	// Do topological sort for each connected component of the graph.
	for (map_iterator it = index_map.begin(); it != index_map.end(); it++) {
		if (!visited[it->second]) topological_traversal(it->first);
	}

	// Extract ordering from resulting stack.
	int cnt = 0;
	while (!stack.empty()) {
		cnt++;
		const Descriptor* d = stack.top();
		ordering[d] = cnt;
		stack.pop();
	}
}

void MessageSorter::topological_traversal(const Descriptor* node) {
  int x = get_index(node);
  visited[x] = true;
  in_stack[x] = true;

  // Loop through all Descriptors adjacent to node. 
  for (int i = 0; i < adjacency_list[node].size(); i++) {
  	int y = get_index(adjacency_list[node][i]);
  	if (in_stack[y]) {
  		GOOGLE_LOG(FATAL) << "Error: cycle detected in definition file. ML "
  		"generator does not suport mutually recursive or recursive types. "
  		"No code will be generated.";
  	}
  	if (!visited[y]) {
  		topological_traversal(adjacency_list[node][i]);
  	}
  }
  in_stack[x] = false;

  // Push node onto the stack that will determine the topological ordering.
  stack.push(node);
}

std::unordered_map<const Descriptor*, int> MessageSorter::get_ordering() {
	if (ordering.empty()) sort();
  	return ordering;
}

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf
}  // namespace google
