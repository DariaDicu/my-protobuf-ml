#include "ml_ordering.h"

#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/stubs/strutil.h>
#include <algorithm>
#include <set>
#include <string>
#include <unordered_map>
#include <vector>

namespace google {
namespace protobuf {
namespace compiler {
namespace ml {

MessageSorter::MessageSorter(const FileDescriptor* file) {
	index_cnt = 0;
	sort(file);
}

MessageSorter::~MessageSorter() {};

int MessageSorter::index(const Descriptor* node) {
	return node_indexer[node];
}

void MessageSorter::sort(const FileDescriptor *file) {
	for (int i = 0; i < file->message_type_count(); i++) {
		referenced_by[file->message_type(i)] = vector<const Descriptor*>();
	}

	// Build reference graph.
	for (int i = 0; i < file->message_type_count(); i++) {
		const Descriptor* msg_i = file->message_type(i);
		std::set<string> child_refs = get_child_references(msg_i);

		// Get siblings which are referenced by children.
		for (int j = 0; j < file->message_type_count(); j++) 
			// Check if nested type j is one of the children references.
			if (child_refs.find(file->message_type(j)->name()) != child_refs.end()) {
				referenced_by[file->message_type(j)].push_back(msg_i);
			}
	}

	// Index nodes to be represented by numbers and store list of all descriptors.
	for (int i = 0; i < file->message_type_count(); i++) {
		index_nodes(file->message_type(i));
	}

	// Do topological sorting.
	for (std::unordered_map<const Descriptor*, int>::iterator it = 
		node_indexer.begin(); it != node_indexer.end(); it++) {
		if (!visited[it->second]) visit(it->first);
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

std::set<string> MessageSorter::get_child_references(const Descriptor *node) {
	std::set<string> total_child_refs;
	for (int i = 0; i < node->nested_type_count(); i++) {
		referenced_by[node->nested_type(i)] = vector<const Descriptor*>();
	}

	for (int i = 0; i < node->nested_type_count(); i++) {
		const Descriptor* msg_i = node->nested_type(i);
		std::set<string> child_refs = get_child_references(msg_i);
		
		// Get siblings which are referenced by children.
		for (int j = 0; j < node->nested_type_count(); j++) 
			// Check if nested type j is one of the children references.
			if (child_refs.find(node->nested_type(j)->name()) != child_refs.end()) {
				referenced_by[node->nested_type(j)].push_back(msg_i);
				//GOOGLE_LOG(INFO) << node->nested_type(j)->name() << " referenced by " << msg_i->name();
			}

		// Merge child references into total set of references.
		total_child_refs.insert(child_refs.begin(), child_refs.end());
	}
	

	// Add own field names to total reference set.
	for (int i = 0; i < node->field_count(); i++) 
		if (node->field(i)->type() == FieldDescriptor::TYPE_MESSAGE) {
			string field_name = node->field(i)->message_type()->name();
			//GOOGLE_LOG(INFO) << node->field(i)->message_type()->name() << 
			//	" is field of " << node->name();
			total_child_refs.insert(field_name);
		}

	// Remove any child node names from referenced messages, as they go out of
	// scope.
	for (int i = 0; i < node->nested_type_count(); i++) {
		total_child_refs.erase(node->nested_type(i)->name());
	}
	return total_child_refs;
}

void MessageSorter::index_nodes(const Descriptor* node) {
  if (node_indexer.find(node) != node_indexer.end()) {
  	return;
  }
  node_indexer[node] = ++index_cnt;
  in_stack[index_cnt] = visited[index_cnt] = false;
  for (int i = 0; i < node->nested_type_count(); i++) {
  	index_nodes(node->nested_type(i));
  }
}

void MessageSorter::visit(const Descriptor* node) {
  int x = index(node);
  //GOOGLE_LOG(INFO) << "visiting " << node->name() << " index " << x << "\n";
  visited[x] = true;
  in_stack[x] = true;
  for (int i = 0; i < referenced_by[node].size(); i++) {
  	int y = index(referenced_by[node][i]);
  	if (in_stack[y]) {
  		GOOGLE_LOG(FATAL) << "Error: cycle detected in definition file. ML "
  		"generator does not suport mutually recursive or recursive types. "
  		"No code will be generated.";
  	}
  	if (!visited[y]) {
  		visit(referenced_by[node][i]);
  	}
  }
  in_stack[x] = false;
  stack.push(node);
}

std::unordered_map<const Descriptor*, int> MessageSorter::GetOrdering() {
  return ordering;
}

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf
}  // namespace google
