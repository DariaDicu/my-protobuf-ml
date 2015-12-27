#include "ml_helpers.h"

namespace google {
namespace protobuf {
namespace compiler {
namespace ml {

MlType GetMlType(const FieldDescriptor::Type type) {
switch (type) {
    case FieldDescriptor::TYPE_INT32:
    case FieldDescriptor::TYPE_UINT32:
    case FieldDescriptor::TYPE_SINT32:
    case FieldDescriptor::TYPE_FIXED32:
    case FieldDescriptor::TYPE_SFIXED32:
      return MLTYPE_INT;

    case FieldDescriptor::TYPE_INT64:
    case FieldDescriptor::TYPE_UINT64:
    case FieldDescriptor::TYPE_SINT64:
    case FieldDescriptor::TYPE_FIXED64:
    case FieldDescriptor::TYPE_SFIXED64:
      return MLTYPE_BIGINT;

    case FieldDescriptor::TYPE_FLOAT:
    case FieldDescriptor::TYPE_DOUBLE:
      return MLTYPE_FLOAT;

    case FieldDescriptor::TYPE_BOOL:
      return MLTYPE_BOOLEAN;

    case FieldDescriptor::TYPE_STRING:
    case FieldDescriptor::TYPE_BYTES:
      return MLTYPE_STRING;

    case FieldDescriptor::TYPE_ENUM:
      return MLTYPE_VARIANT;

    case FieldDescriptor::TYPE_GROUP:
    case FieldDescriptor::TYPE_MESSAGE:
      return MLTYPE_MESSAGE;

    // No default because we want the compiler to complain if any new
    // types are added.
  }

  GOOGLE_LOG(FATAL) << "Can't get here.";
  return MLTYPE_INT;
}

const char* PrimitiveTypeName(const FieldDescriptor::Type type) {
  MlType ml_type = GetMlType(type);
  switch (ml_type) {
    // TODO: replace this with implementation for big ints.
      case MLTYPE_BIGINT : return "int";
      case MLTYPE_BOOLEAN : return "bool";
      case MLTYPE_INT : return "int";
      case MLTYPE_FLOAT : return "float";
      case MLTYPE_MESSAGE : return NULL;
      case MLTYPE_STRING : return "string";
      case MLTYPE_VARIANT : return NULL;

    // No default because we want the compiler to complain if any new
    // types are added.
  }

  GOOGLE_LOG(FATAL) << "Can't get here.";
  return NULL;
}

const char* LabelName(const FieldDescriptor::Label label) {
  switch (label) {
    case FieldDescriptor::LABEL_OPTIONAL : return "option";
    case FieldDescriptor::LABEL_REQUIRED : return "";
    case FieldDescriptor::LABEL_REPEATED : return "list";
    default : return NULL;
  }

  GOOGLE_LOG(FATAL) << "Can't get here.";
  return NULL;
}

bool PrimitiveType(const FieldDescriptor::Type type) {
  return type != FieldDescriptor::TYPE_MESSAGE &&
    type != FieldDescriptor::TYPE_GROUP &&
    type != FieldDescriptor::TYPE_ENUM;
}

const char* GetCapitalizedTypeFromString(const char* type) {
  // TODO: Format here as necessary.
  return type;
}

const char* GetUncapitalizedTypeFromString(const char* type) {
  // TODO: Format here as necessary.
  return type;
}

// TODO: const reference instead?
const char* GetFormattedTypeFromField(const FieldDescriptor* field) {
  if (PrimitiveType(field->type())) {
    return PrimitiveTypeName(field->type());
  }
  if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
    return GetCapitalizedTypeFromString(field->message_type()->name().c_str());
  }
  if (field->type() == FieldDescriptor::TYPE_ENUM) {
    return GetCapitalizedTypeFromString(field->enum_type()->name().c_str());
  }
  GOOGLE_LOG(FATAL) << "Can't get here.";
  return NULL;
}

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf

}  // namespace google