
#ifndef GOOGLE_PROTOBUF_COMPILER_ML_ENUM_H__
#define GOOGLE_PROTOBUF_COMPILER_ML_ENUM_H__

#include <string>
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

class EnumGenerator {
 public:
  explicit EnumGenerator(const EnumDescriptor* descriptor);
  ~EnumGenerator();
  
  void GenerateStructure(io::Printer* printer);
  void GenerateFunctions(io::Printer* printer);

 private:
  const EnumDescriptor* descriptor_;
  vector<const EnumValueDescriptor*> canonical_values_;
  struct Alias {
      const EnumValueDescriptor* value;
      const EnumValueDescriptor* canonical_value;
  };
  vector<Alias> aliases_;

  GOOGLE_DISALLOW_EVIL_CONSTRUCTORS(EnumGenerator);
};

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf

}  // namespace google
#endif  // GOOGLE_PROTOBUF_COMPILER_JAVA_ENUM_H__
