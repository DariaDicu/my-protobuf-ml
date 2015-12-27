#ifndef GOOGLE_PROTOBUF_COMPILER_ML_HELPERS_H__
#define GOOGLE_PROTOBUF_COMPILER_ML_HELPERS_H__

#include <string>
#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/descriptor.h>

namespace google {
namespace protobuf {
namespace compiler {
namespace ml {

enum MlType {
  MLTYPE_BIGINT,
  MLTYPE_BOOLEAN,
  MLTYPE_INT,
  MLTYPE_FLOAT,
  MLTYPE_MESSAGE,
  MLTYPE_STRING,
  MLTYPE_VARIANT
};

MlType GetMlType(const FieldDescriptor::Type type);

const char* LabelName(const FieldDescriptor::Label label);

const char* PrimitiveTypeName(const FieldDescriptor::Type type);

bool PrimitiveType(const FieldDescriptor::Type type);

const char* GetCapitalizedTypeFromString(const char* input_string);

const char* GetUncapitalizedTypeFromString(const char* input_string);

const char* GetFormattedTypeFromField(const FieldDescriptor* field);

const char* NonPrimitiveType(const FieldDescriptor type);

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf

}  // namespace google
#endif  // GOOGLE_PROTOBUF_COMPILER_ML_HELPERS_H__
