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

int GetWireCode(const FieldDescriptor::Type type) {
  switch (type) {
    case FieldDescriptor::TYPE_INT32:
    case FieldDescriptor::TYPE_UINT32:
    case FieldDescriptor::TYPE_SINT32:
    case FieldDescriptor::TYPE_INT64:
    case FieldDescriptor::TYPE_UINT64:
    case FieldDescriptor::TYPE_SINT64:
    case FieldDescriptor::TYPE_BOOL:
    case FieldDescriptor::TYPE_ENUM:
      return 0;

    case FieldDescriptor::TYPE_FIXED64:
    case FieldDescriptor::TYPE_SFIXED64:
    case FieldDescriptor::TYPE_DOUBLE:
      return 1;

    case FieldDescriptor::TYPE_STRING:
    case FieldDescriptor::TYPE_BYTES:
    case FieldDescriptor::TYPE_MESSAGE:
      return 2;

    case FieldDescriptor::TYPE_FIXED32:
    case FieldDescriptor::TYPE_SFIXED32:
    case FieldDescriptor::TYPE_FLOAT:
      return 5;

    // TODOL Be careful and check return value.
    case FieldDescriptor::TYPE_GROUP:
      return -1;
    // No default because we want the compiler to complain if any new
    // types are added.
  }

  GOOGLE_LOG(FATAL) << "Can't get here.";
  return -1;
}

void SanitizeForMl(string& name) {
  if (name == "type") name += "_";
}

string PrimitiveTypeName(const FieldDescriptor::Type type) {
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

string LabelName(const FieldDescriptor::Label label) {
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

void CapitalizeString(string& type) {
  if (type[0] >= 'a' && type[0] <= 'z') type[0] -= 'a' - 'A';
}

void UncapitalizeString(string& type) {
  if (type[0] >= 'A' && type[0] <= 'Z') type[0] += 'a' - 'A';
}

// TODO: const reference instead?
string GetFormattedTypeFromField(const FieldDescriptor* field) {
  if (PrimitiveType(field->type())) {
    return PrimitiveTypeName(field->type());
  }
  if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
    string name = field->message_type()->name();
    CapitalizeString(name);
    return name;
  }
  if (field->type() == FieldDescriptor::TYPE_ENUM) {
    string name = field->enum_type()->name();
    CapitalizeString(name);
    return name.c_str();
  }
  GOOGLE_LOG(FATAL) << "Can't get here.";
  return NULL;
}

string GetCanonicalTypeFromField(const FieldDescriptor* field) {
  if (PrimitiveType(field->type())) {
    return PrimitiveTypeName(field->type());
  }
  if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
    string name = field->message_type()->name() + ".t";
    CapitalizeString(name);
    return name;
  }
  if (field->type() == FieldDescriptor::TYPE_ENUM) {
    string name = field->enum_type()->name() + ".t";
    CapitalizeString(name);
    return name.c_str();
  }
  GOOGLE_LOG(FATAL) << "Can't get here.";
  return NULL;
}

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf

}  // namespace google