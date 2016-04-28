#ifndef GOOGLE_PROTOBUF_COMPILER_GRAPH_BUILDER_H__
#define GOOGLE_PROTOBUF_COMPILER_GRAPH_BUILDER_H__

#include <algorithm>
#include <stack>
#include <vector>
#include "google/protobuf/stubs/strutil.h"
#include <unordered_map>
#include <unordered_set>
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

class GraphBuilder {
  public:
    // Constructor takes as argument a definition file descriptor.
  	explicit GraphBuilder(const FileDescriptor* file);
  	~GraphBuilder();

    // Returns adjacency list if not empty, otherwise calls 
    // rebuild_dependency_graph and then returns the adjacency list.
    std::unordered_map<const Descriptor*, vector<const Descriptor*> > 
      get_adjacency_list();

    // Builds the dependency graph for all reachable descriptor nodes from the
    // file descriptor. Uses the method get_unresolved_references() to build the 
    // graph by recursively exploring the nested message tree structure.
    void rebuild_dependency_graph();
  
  private:
    // Returns a list of message names representing all the unresolved 
    // references in the subtree, and builds the dependency graph for the 
    // subtree rooted at "node". A reference of a node x to a message M is 
    // unresolved if no node or sibling of a node on the path from the
    // subtree root to node x has the name M.
	  std::unordered_set<string> get_unresolved_references(const Descriptor *node);

    // Adjacency list for the reference graph (on which topological sort can be
    // performed).
  	std::unordered_map<const Descriptor*, vector<const Descriptor*> > 
      adjacency_list;

    const FileDescriptor* file;

  GOOGLE_DISALLOW_EVIL_CONSTRUCTORS(GraphBuilder);
};

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf
}  // namespace google

#endif  // GOOGLE_PROTOBUF_COMPILER_GRAPH_BUILDER_H__
