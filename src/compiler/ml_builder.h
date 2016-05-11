
#ifndef GOOGLE_PROTOBUF_COMPILER_ML_BUILDER_H__
#define GOOGLE_PROTOBUF_COMPILER_ML_BUILDER_H__

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

class BuilderGenerator {
 public:
  explicit BuilderGenerator(const Descriptor* descriptor);
  ~BuilderGenerator();

  void GenerateSignature(io::Printer* printer);
  void GenerateStructure(io::Printer* printer);

 private:
  const Descriptor* descriptor_;
};

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf

}  // namespace google
#endif  // GOOGLE_PROTOBUF_COMPILER_JAVA_MESSAGE_H__
