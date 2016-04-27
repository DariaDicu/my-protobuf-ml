#include "ml_ordering.h"

#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/stubs/strutil.h>
#include <algorithm>
#include <set>
#include <string>
#include <unordered_map>
#include <vector>

#define map_iterator std::unordered_map<const Descriptor*, int>::iterator

namespace google {
namespace protobuf {
namespace compiler {
namespace ml {

MessageSorter::MessageSorter(const FileDescriptor* file) : file(file), 
	node_count(0) {}

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

  // Initialize adjacency list for this Descriptor node.
  adjacency_list[node] = vector<const Descriptor*>();

  for (int i = 0; i < node->nested_type_count(); i++) {
  	index_nodes_traversal(node->nested_type(i));
  }
}


void MessageSorter::sort() {
	// Build reference graph for the toplevel messages by using information
	// returned by the get_unresolved_references (see function description in
	// header file for more details).
	for (int i = 0; i < file->message_type_count(); i++) {
		const Descriptor* child_node = file->message_type(i);
		std::set<string> child_references = get_unresolved_references(
			child_node);

		// Get siblings which are referenced by children.
		for (int j = 0; j < file->message_type_count(); j++) {
			string sibling_name = file->message_type(j)->name();
			const Descriptor* sibling_node = file->message_type(j);

			// Only add an edge in the dependency graph if the sibling is one
			// of the unresolved references.
			if (child_references.find(sibling_name) != child_references.end()) {
				adjacency_list[sibling_node].push_back(child_node);
			}
		}
	}

	// Index nodes to be represented by numbers and store list of all descriptors.
	index_nodes();

	// Initialize in_stack and visited to be false for every index.
	in_stack = vector<bool>(node_count, false);
	visited = vector<bool>(node_count, false);

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

std::set<string> MessageSorter::get_unresolved_references(const Descriptor *node) {
	std::set<string> total_references;

	for (int i = 0; i < node->nested_type_count(); i++) {
		const Descriptor* child_node = node->nested_type(i);
		std::set<string> child_references = get_unresolved_references(
			child_node);
		
		// Add to the adjacency list of this nested type node all other nested
		// types (siblings) that are unresolved references in the subtree of the
		// child.
		for (int j = 0; j < node->nested_type_count(); j++) {
			string sibling_name = node->nested_type(j)->name();
			const Descriptor* sibling_node = node->nested_type(j);

			// Only add an edge in the dependency graph if the sibling is one
			// of the unresolved references.
			if (child_references.find(sibling_name) != child_references.end()) {
				adjacency_list[sibling_node].push_back(child_node);
			}
		}
		// Merge unresolved children references into total set of references.
		total_references.insert(child_references.begin(), 
			child_references.end());
	}
	
	// Add the field names for message type fields to the final unresolved 
	// reference set.
	for (int i = 0; i < node->field_count(); i++) 
		if (node->field(i)->type() == FieldDescriptor::TYPE_MESSAGE) {
			string field_name = node->field(i)->message_type()->name();
			total_references.insert(field_name);
		}

	// Remove any child node names from unresolved reference set, as they get 
	// resolved at the current level.
	for (int i = 0; i < node->nested_type_count(); i++) {
		total_references.erase(node->nested_type(i)->name());
	}
	return total_references;
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
