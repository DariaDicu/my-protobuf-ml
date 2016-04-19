
#ifndef GOOGLE_PROTOBUF_COMPILER_ML_MESSAGE_H__
#define GOOGLE_PROTOBUF_COMPILER_ML_MESSAGE_H__

#include <string>
#include <unordered_map>
#include <vector>
#include <google/protobuf/descriptor.h>

namespace google {
namespace protobuf {
  namespace io {
    class Printer;             // printer.h
  }
}

namespace protobuf {
namespace compiler {
namespace ml {

class MessageGenerator {
 public:
  explicit MessageGenerator(const Descriptor* descriptor, 
    const unordered_map<const Descriptor*, int>* message_order);
  ~MessageGenerator();

  void GenerateSignature(io::Printer* printer, bool toplevel);
  void GenerateStructure(io::Printer* printer, bool toplevel);

  // TODO: Extract this in BuilderGenerator class.
  void GenerateBuilderSignature(io::Printer* printer);
  void GenerateBuilderStructure(io::Printer* printer);

 private:
  const Descriptor* descriptor_;
  const unordered_map<const Descriptor*, int>* message_order_;
  vector<const Descriptor*> ordered_nested_types_;
  void SortNestedTypes();
};

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf

}  // namespace google
#endif  // GOOGLE_PROTOBUF_COMPILER_JAVA_MESSAGE_H__
