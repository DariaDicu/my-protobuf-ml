#include "graph_builder.h"

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

GraphBuilder::GraphBuilder(const FileDescriptor* file) : file(file) {}

GraphBuilder::~GraphBuilder() {};

std::unordered_map<const Descriptor*, vector<const Descriptor*> > 
  GraphBuilder::get_adjacency_list() {
	if (adjacency_list.empty()) rebuild_dependency_graph();
	return adjacency_list;
}

void GraphBuilder::rebuild_dependency_graph() {
	// Initialize adjacency list.
	adjacency_list.clear();

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
}

std::set<string> GraphBuilder::get_unresolved_references(const Descriptor *node) {
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

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf
}  // namespace google
