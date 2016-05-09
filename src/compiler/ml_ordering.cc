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
	// Simulate a DFS stack to avoid stack overflow for large collections.
	std::stack<const Descriptor*> dfs_stack;

	for (int i = 0; i < file->message_type_count(); i++) {
		dfs_stack.push(file->message_type(i));
	}

	while (!dfs_stack.empty()) {
		const Descriptor* node = dfs_stack.top();
		dfs_stack.pop();

		// If node has been visited, continue.
		if (index_map.find(node) != index_map.end()) {
  			continue;
  		}

  		index_map[node] = ++node_count;

		for (int i = 0; i < node->nested_type_count(); i++) {
			dfs_stack.push(node->nested_type(i));
		}
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
	// Simulate a DFS stack to avoid stack overflow for large collections.
	std::stack<const Descriptor*> dfs_stack;

	dfs_stack.push(node);

	while (!dfs_stack.empty()) {
		const Descriptor* node = dfs_stack.top();
		int x = get_index(node);

		// Check if we have finished visiting all neighbours of the node.
		if (in_stack[x]) {
			in_stack[x] = false;
			dfs_stack.pop();
			// Push on final stack that represents topological ordering.
			stack.push(node);
			continue;
		}

		visited[x] = true;
		in_stack[x] = true;

		for (int i = 0; i < adjacency_list[node].size(); i++) {
			int y = get_index(adjacency_list[node][i]);
			if (in_stack[y]) {
				GOOGLE_LOG(FATAL) << "Error: cycle detected in definition file. ML "
				"generator does not suport mutually recursive or recursive types. "
				"No code will be generated.";
			}
			if (!visited[y]) {
				dfs_stack.push(adjacency_list[node][i]);
			}
		}
	}
}

std::unordered_map<const Descriptor*, int> MessageSorter::get_ordering() {
	if (ordering.empty()) sort();
  	return ordering;
}

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf
}  // namespace google
