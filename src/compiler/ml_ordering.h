#ifndef GOOGLE_PROTOBUF_COMPILER_ML_ORDERING_H__
#define GOOGLE_PROTOBUF_COMPILER_ML_ORDERING_H__

#include <algorithm>
#include <stack>
#include <vector>
#include <google/protobuf/stubs/strutil.h>
#include <unordered_map>
#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/stubs/common.h>

namespace google {
namespace protobuf {
	class FileDescriptor;
	class Descriptor;
}
}

namespace google {
namespace protobuf {
namespace compiler {
namespace ml {

class MessageSorter {
  public:
	explicit MessageSorter(const FileDescriptor* file);
	~MessageSorter();
	std::unordered_map<const Descriptor*, int> GetOrdering();

   private:
   	int index(const Descriptor* node);
	void index_nodes(const Descriptor* node);
  	void visit(const Descriptor* node);
	std::set<string> get_child_references(const Descriptor *node);
	void sort(const FileDescriptor *file);

  	int index_cnt;
  	// TODO: replace this with a std::vector.
  	bool visited[1000000];
  	bool in_stack[1000000];
  	std::stack<const Descriptor*> stack;
  	std::unordered_map<const Descriptor*, vector<const Descriptor*> > referenced_by;
  	std::unordered_map<const Descriptor*, int> node_indexer;
  	std::unordered_map<const Descriptor*, int> ordering;

  GOOGLE_DISALLOW_EVIL_CONSTRUCTORS(MessageSorter);
};

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf
}  // namespace google

#endif  // GOOGLE_PROTOBUF_COMPILER_ML_ORDERING_H__
