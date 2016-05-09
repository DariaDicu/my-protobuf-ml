#ifndef GOOGLE_PROTOBUF_COMPILER_ML_ORDERING_H__
#define GOOGLE_PROTOBUF_COMPILER_ML_ORDERING_H__

#include <algorithm>
#include <stack>
#include <vector>
#include "graph_builder.h"
#include "google/protobuf/stubs/strutil.h"
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
    // Constructor takes as argument a definition file descriptor.
  	explicit MessageSorter(const FileDescriptor* file);
  	~MessageSorter();

    // Returns a map where the key is a Descriptor and the value is the position
    // of that Descriptor in the topological sort. If the "ordering" member of 
    // the class is empty, the it calls sort(), otherwise it returns
    // the stored ordering. 
  	std::unordered_map<const Descriptor*, int> get_ordering();

   private:
    // Returns the index associated with the given descriptor. Access time is 
    // O(1) because indexes are values in a std::map.
   	int get_index(const Descriptor* node);

    // Visits all Descriptors accessible from the FileDescriptor and associates
    // an unique integer in the range [0, total_descriptor_count) to each
    // Descriptor, then stores it into index_map_.
	  void index_nodes();

    // Performs the DFS for cycle detection and topological sort.
  	void topological_traversal(const Descriptor* node);

    // Performs a topological sorting and places the result in the "ordering"
    // member, which is an unordered map where the key is a Descriptor and the 
    // value is the position of that Descriptor in the topological sort.
	  void sort();

  	// Boolean vectors used for keeping track of visited and marked nodes in the
    // topological sort depth first search.
  	vector<bool> visited;
  	vector<bool> in_stack;

    // Stack used in the topological sort depth first search to place nodes
    // after having visited all their neighbours. At the end of the sort, the 
    // stack contains the topological ordering.
  	std::stack<const Descriptor*> stack;

    // Adjacency list for the reference graph on which topological sort is 
    // performed.
  	std::unordered_map<const Descriptor*, vector<const Descriptor*> > adjacency_list;

    // A map that contains an unique integer in the range 
    // [0, total_descriptor_count) for each message Descriptor in the file.
  	std::unordered_map<const Descriptor*, int> index_map;

    // An unordered map where the key is a Descriptor and the value is the 
    // position of that Descriptor in the topological sort
  	std::unordered_map<const Descriptor*, int> ordering;

    const FileDescriptor* file;
    GraphBuilder graph_builder;
    int node_count;

  GOOGLE_DISALLOW_EVIL_CONSTRUCTORS(MessageSorter);
};

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf
}  // namespace google

#endif  // GOOGLE_PROTOBUF_COMPILER_ML_ORDERING_H__
