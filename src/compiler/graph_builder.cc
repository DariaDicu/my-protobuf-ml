#include "graph_builder.h"

#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/stubs/strutil.h>
#include <algorithm>
#include <iostream>
#include <set>
#include <string>
#include <unordered_map>
#include <vector>

#define map_iterator std::unordered_map<const Descriptor*, int>::iterator
#define set_iterator std::unordered_set<string>::iterator

namespace google {
namespace protobuf {
namespace compiler {
namespace ml {

GraphBuilder::GraphBuilder(const FileDescriptor* file) : file(file) {
	adjacency_list = new std::unordered_map<const Descriptor*,
		vector<const Descriptor*> >();
}

GraphBuilder::~GraphBuilder() {
	delete adjacency_list;
};

std::unordered_map<const Descriptor*, vector<const Descriptor*> >* 
  GraphBuilder::get_adjacency_list() {
	if (adjacency_list->empty()) rebuild_dependency_graph();
	return adjacency_list;
}

void GraphBuilder::rebuild_dependency_graph() {
	// Initialize adjacency list.
	if (!adjacency_list->empty()) adjacency_list->clear();

	// Build map for accessing the nested types at this level by name in O(1).
	std::unordered_map<string, const Descriptor*> messages;
	for (int i = 0; i < file->message_type_count(); i++) {
		const Descriptor* message = file->message_type(i);
		messages[message->name()] = message;
	}

	// Build reference graph for the toplevel messages by using information
	// returned by the get_unresolved_references (see function description in
	// header file for more details).
	for (int i = 0; i < file->message_type_count(); i++) {
		const Descriptor* child_node = file->message_type(i);
		std::unordered_set<string> child_references = get_unresolved_references(
			child_node);
		for (set_iterator it = child_references.begin(); 
		  it != child_references.end(); it++) {
			string reference_name = *it;
			// Only add an edge in the dependency graph if the unresolved 
			// reference is one of the sibling message names.
			if (messages.find(reference_name) != messages.end()) {
				(*adjacency_list)[messages[reference_name]].push_back(
					child_node);
			}
		}
	}
}

std::unordered_set<string> GraphBuilder::get_unresolved_references(
  const Descriptor *node) {
	std::unordered_set<string> total_references;

	// Build map for accessing the nested types at this level by name in O(1).
	std::unordered_map<string, const Descriptor*> messages;
	for (int i = 0; i < node->nested_type_count(); i++) {
		const Descriptor* message = node->nested_type(i);
		messages[message->name()] = message;
	}

	for (int i = 0; i < node->nested_type_count(); i++) {
		const Descriptor* child_node = node->nested_type(i);
		std::unordered_set<string> child_references = get_unresolved_references(
			child_node);
		
		for (set_iterator it = child_references.begin(); 
		  it != child_references.end(); it++) {
			string reference_name = *it;
			// Only add an edge in the dependency graph if the unresolved 
			// reference is one of the sibling message names.
			if (messages.find(reference_name) != messages.end()) {
				(*adjacency_list)[messages[reference_name]].push_back(
					child_node);
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

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf
}  // namespace google
