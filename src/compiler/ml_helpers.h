#ifndef GOOGLE_PROTOBUF_COMPILER_ML_HELPERS_H__
#define GOOGLE_PROTOBUF_COMPILER_ML_HELPERS_H__

#include <string>
#include <algorithm>
#include <unordered_map>
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
  MLTYPE_REAL,
  MLTYPE_MESSAGE,
  MLTYPE_STRING,
  MLTYPE_WORD8VEC,
  MLTYPE_VARIANT
};

MlType GetMlType(const FieldDescriptor::Type type);

int GetWireCode(const FieldDescriptor::Type type);

void SanitizeForMl(string& name);

string LabelName(const FieldDescriptor::Label label);

string PrimitiveTypeName(const FieldDescriptor::Type type);

bool PrimitiveType(const FieldDescriptor::Type type);

void CapitalizeString(string& input_string);

void UncapitalizeString(string& input_string);

string GetFormattedTypeFromField(const FieldDescriptor* field);

string GetCanonicalTypeFromField(const FieldDescriptor* field);

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf

}  // namespace google
#endif  // GOOGLE_PROTOBUF_COMPILER_ML_HELPERS_H__
