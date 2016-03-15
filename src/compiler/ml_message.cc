// Protocol Buffers - Google's data interchange format
// Copyright 2008 Google Inc.  All rights reserved.
// https://developers.google.com/protocol-buffers/
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following disclaimer
// in the documentation and/or other materials provided with the
// distribution.
//     * Neither the name of Google Inc. nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include "ml_enum.h"
#include "ml_helpers.h"
#include "ml_message.h"

#include <google/protobuf/io/printer.h>
#include <google/protobuf/io/zero_copy_stream.h>
#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/stubs/strutil.h>

namespace google {
namespace protobuf {
namespace compiler {
namespace ml {
	MessageGenerator::MessageGenerator(const Descriptor* descriptor):
		descriptor_(descriptor) {}

	MessageGenerator::~MessageGenerator() {};

	void MessageGenerator::GenerateSignature(io::Printer* printer, 
		bool toplevel) {
		if (toplevel) {
			string signature = descriptor_->name();
			UpperString(&signature);
			printer->Print("signature $signature$ =\nsig\n",
			"signature", signature);
		} else {
			string signature = descriptor_->name();
			printer->Print("structure $signature$ : sig\n",
			"signature", signature);
		}
		printer->Indent();

		// Print child signatures.
		for (int i = 0; i < descriptor_->enum_type_count(); i++) {
			EnumGenerator generator(descriptor_->enum_type(i));
			generator.GenerateSignature(printer, false /* toplevel */);
			// Print type alias.
			string name = descriptor_->enum_type(i)->name();
			UncapitalizeString(name);
			printer->Print("type $name$\n", "name", name);
		}

		// Print child signatures.
		for (int i = 0; i < descriptor_->nested_type_count(); i++) {
			MessageGenerator generator(descriptor_->nested_type(i));
			generator.GenerateSignature(printer, false /* toplevel */);
			// Print type alias.
			string name = descriptor_->nested_type(i)->name();
			UncapitalizeString(name);
			printer->Print("type $name$\n", "name", name);
		}

		printer->Print("type t\n");
		GenerateBuilderSignature(printer);
		printer->Print("val encode : t -> Word8Vector.vector\n");
		printer->Print("val decode : ByteBuffer.buffer -> t * parseResult\n");

		// End is the same regardless of toplevel being true/false.
		printer->Outdent();
		printer->Print("end\n");
	}

	void MessageGenerator::GenerateStructure(io::Printer* printer,
		bool toplevel) {
		// Generate structure.
		string structure = descriptor_->name();
		CapitalizeString(structure);
		//printer->Print("structure $structure$ :> $signature$ = ",
		if (toplevel) {
			string signature = descriptor_->name();
			UpperString(&signature);
			printer->Print("structure $structure$ :> $signature$ = \n",
				"structure", structure,
				"signature", signature);
		} else {
			printer->Print("structure $structure$ = \n",
				"structure", structure);
		}
		printer->Print("struct\n");
		printer->Indent();

		// Print structures for nested types.
		for (int i = 0; i < descriptor_->enum_type_count(); i++) {
			EnumGenerator generator(descriptor_->enum_type(i));
			generator.GenerateStructure(printer, false /* toplevel */);
		}
		for (int i = 0; i < descriptor_->nested_type_count(); i++) {
			MessageGenerator generator(descriptor_->nested_type(i));
			generator.GenerateStructure(printer, false /* toplevel */);
		}
		// Print main type declaration.
		printer->Print("type t = {\n");
		printer->Indent();
		for (int i = 0; i < descriptor_->field_count(); i++) {
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);

			string type = GetFormattedTypeFromField(field);
			UncapitalizeString(type);

			// TODO: decide if default should be required.
			string label = LabelName(field->label());
			printer->Print("$name$: $type$ $label$",
				"name", name,
				"type", type,
				"label", label);
			if (i < descriptor_->field_count() - 1) {
				printer->Print(",\n");
			} else {
				printer->Print("\n");
			}
		}
		printer->Outdent();
		// TODO: Print alias for main type declaration.
		printer->Print("}\n");

		GenerateBuilderStructure(printer);

		// Printing the encode function.
		printer->Print("fun encode m = \n");
		printer->Indent();
		printer->Print("let\n");
		printer->Indent();
		for (int i = 0; i < descriptor_->field_count(); i++) {
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);
			string type_name = field->type_name();
			string tag = to_string(field->number());
			string code = to_string(GetWireCode(field->type()));

			// Get name of the helper function we need to call.
			string function_name;

			bool is_repeated = (field->label() == 
				FieldDescriptor::LABEL_REPEATED);

			bool is_optional = (field->label() == 
				FieldDescriptor::LABEL_OPTIONAL);

			bool is_required = (field->label() ==
				FieldDescriptor::LABEL_REQUIRED);

			// Default is optional.
			if ((!is_required) && (!is_repeated)) is_optional = true;

			// Default value for packed encoding is true, unless otherwise 
			// specified. Only primitives can be packed.
			bool is_packed = (code == "2") ? false : true;
			if(field->options().has_packed() && !field->options().packed()) {
				is_packed = false;
			}
			// Packed fields have wire type 2.
			if (is_packed) code = "2";

			if (type_name.compare("message") == 0 || 
				type_name.compare("enum") == 0) {
				string type = GetFormattedTypeFromField(field);
				CapitalizeString(type);
				function_name = type + ".encode";
			} else {
				CapitalizeString(type_name);
				function_name = "encode" + type_name;
			}

			// Get function for label.
			string label_function = "encodeOptional";
			if (is_repeated) {
				if (is_packed) {
					label_function = "encodePackedRepeated";
				} else {
					label_function = "encodeRepeated";
				}
			} else if (is_optional) {
				label_function = "encodeOptional";
			} else if (is_required) {
				label_function = "encodeRequired";
			}
			printer->Print("val $name$ = ($label_function$ $enc_func$)"
				" (encodeKey(Tag($tag$), Code($code$))) (#$name$ m)\n",
				"name", name,
				"code", code,
				"enc_func", function_name,
				"label_function", label_function,
				"tag", tag);
		}
		printer->Outdent();
		printer->Print("in\n");
		printer->Indent();
		printer->Print("Word8Vector.concat [\n");
		printer->Indent();
		// Listing all encoded fields in the message.
		for (int i = 0; i < descriptor_->field_count(); i++) {
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);

			if (i > 0) printer->Print(",\n");
			printer->Print("$name$", "name", name);
		}
		printer->Print("\n");
		printer->Outdent();
		printer->Print("]\n");
		printer->Outdent();
		printer->Print("end\n\n");
		printer->Outdent();

		// Printing the decode next field function. This is hidden from signature.
		// ========== Start of decode next field ==========
		printer->Print("fun decodeNextField buff obj remaining = \n");
		printer->Indent();
		printer->Print("if (remaining = 0) then\n");
		printer->Indent();
		//TODO: count total bytes read... 0 for now. 
		printer->Print("(obj, buff)\n");
		printer->Outdent();
		printer->Print("else if (remaining < 0) then\n");
		printer->Indent();
		printer->Print("raise Exception(PARSE, \"Field encoding does not match "
			"length in message header.\")\n");
		printer->Outdent();
		printer->Print("else\n");
		printer->Indent();
		printer->Print("let\n");
		printer->Indent();
		printer->Print("val ((Tag(t), Code(c)), parse_result) = "
			"decodeKey buff\n");
		printer->Print("val ParseResult(buff, ParsedByteCount(keyByteCount)) = "
				"parse_result\n");
		printer->Print("val remaining = remaining - keyByteCount\n");
		printer->Outdent();
		printer->Print("in\n");
		printer->Indent();
		printer->Print("if (remaining <= 0) then\n");
		printer->Indent();
		printer->Print("raise Exception(PARSE, \"Not enough bytes left after "
			"parsing message field key.\")\n");
		printer->Outdent();
		printer->Print("else case (t) of ");
		for (int i = 0; i < descriptor_->field_count(); i++) {
			// ML code will look like:
			// fun decodeMessageHelper decode_fun modifier_fun rec_fun obj buff remaining = 
			// case (tag_) of 0 => 
			// let
			// 	val (field_value, parsed_bytes) = parseFuncForType buff
			// in
			// 	if (remaining > parsed_bytes)
			// 		(ModuleName.setOrAddForLabel (obj, field_value),
			// 		parseNextField buff obj (remaining - parsed_bytes))
			// 	else 
			// 		raise Exception(PARSE, 
			// 			"Error in matching the message length with fields length.")
			// end
			// | 1 => ...
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);
			string type_name = field->type_name();
			string tag = to_string(field->number());
			string module_name = GetFormattedTypeFromField(field);
			CapitalizeString(module_name);
			string code = to_string(GetWireCode(field->type()));

			string function_name;
			if (type_name.compare("message") == 0 || 
			  type_name.compare("enum") == 0) {
				function_name = module_name + ".decode";
			} else {
				CapitalizeString(type_name);
				function_name = "decode" + type_name;
			}
		
			bool is_repeated = (field->label() == 
				FieldDescriptor::LABEL_REPEATED);

			bool is_optional = (field->label() == 
				FieldDescriptor::LABEL_OPTIONAL);

			// TODO: implement functionality for compact fields.
			string setter_name;

			if (is_repeated) {
				setter_name = "Builder.add_" + name;
			} else {
				setter_name = "Builder.set_" + name;
			}

			if (i > 0) printer->Print("\n| ");
			printer->Print("$tag$ => ", "tag", tag);

			// If it is possible to get packed encoding (wire type is not zero),
			// then we must print function for packed encoding if extracted
			// wire type is 2 (it becomes 2 for packed encoded fields). 
			if (is_repeated && code != "2") {
				printer->Print("if (c = 2) then (decodeNextPacked ($function_name$) "
					"($setter_name$) (decodeNextField) obj buff remaining)\n"
					"else (decodeNextUnpacked ($function_name$) "
					"($setter_name$) (decodeNextField) obj buff remaining)\n",
					"function_name", function_name,
					"setter_name", setter_name);
			} else {
				printer->Print("decodeNextUnpacked ($function_name$) "
					"($setter_name$) (decodeNextField) obj buff remaining",
					"function_name", function_name,
					"setter_name", setter_name);
			}
		}
		// Raise exception for unknown tag. TODO: skip based on wire type, length.
		printer->Print("\n| n => raise Exception(PARSE, \"Unknown field tag\")\n");
		printer->Outdent();
		printer->Print("end\n\n");
		printer->Outdent();
		printer->Outdent();
		// ========== End of decode next field ==========

		// ========== Start of decode ==========
		printer->Print("fun decode buff = decodeFullHelper decodeNextField "
			"(Builder.build) (Builder.init ()) buff\n\n");

		// ========== End of decode ==========
		printer->Outdent();
		printer->Print("end\n");

		string type_name = descriptor_->name();
		string structure_name = descriptor_->name();
		UncapitalizeString(type_name);
		CapitalizeString(structure_name);
		printer->Print("type $type_name$ = $structure_name$.t\n",
			"type_name", type_name,
			"structure_name", structure_name);
	}

	void MessageGenerator::GenerateBuilderSignature(io::Printer* printer) {
		printer->Print("structure Builder : sig\n");
		printer->Indent();

		printer->Print("type t\n");
		printer->Print("type parentType\n");

		// Print function declarations for setters
		for (int i = 0; i < descriptor_->field_count(); i++) {
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);

			string type = GetFormattedTypeFromField(field);
			UncapitalizeString(type);

			string label = LabelName(field->label());

			// Print an empty line between methods for different fields.
			printer->Print("\n");

			// If repeated field, then generate add functions.
			if (label == "list") {
				printer->Print("val clear_$name$: t -> t\n",
					"name", name);

				printer->Print("val set_$name$: t * $type$ list -> t\n",
					"name", name,
					"type", type);

				printer->Print("val merge_$name$: t * $type$ list -> t\n",
					"name", name,
					"type", type);

				printer->Print("val add_$name$: t * $type$ -> t\n",
					"name", name,
					"type", type);
			} else {
				printer->Print("val clear_$name$: t -> t\n",
					"name", name);

				printer->Print("val set_$name$: t * $type$ -> t\n",
					"name", name,
					"type", type);
			}
		}
		printer->Print("\n");
		printer->Print("val init : unit -> t\n");

		string parent = descriptor_->name();
		CapitalizeString(parent);
		printer->Print("\n");
		printer->Print("val build : t -> parentType\n");

		// End is the same regardless of toplevel being true/false.
		printer->Outdent();
		printer->Print("end where type parentType = t\n");
	}

	void MessageGenerator::GenerateBuilderStructure(io::Printer* printer) {
		printer->Print("structure Builder = \nstruct\n");
		printer->Indent();
		printer->Print("type parentType = t\n");
		printer->Print("type t = {\n");
		printer->Indent();
		for (int i = 0; i < descriptor_->field_count(); i++) {
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);

			string type = GetFormattedTypeFromField(field);
			UncapitalizeString(type);

			string label = LabelName(field->label());

			if (label == "list") {
				printer->Print("$name$: $type$ list option ref",
					"name", name,
					"type", type);
			} else {
				printer->Print("$name$: $type$ option ref",
					"name", name,
					"type", type);
			}
			if (i < descriptor_->field_count() - 1) {
				printer->Print(",\n");
			} else {
				printer->Print("\n");
			}
		}
		printer->Outdent();
		printer->Print("}\n");

		/*
		TODO: delete.
		// Print type declaration for parent type.
		string parent = descriptor_->name();
		CapitalizeString(parent);
		printer->Print("type parentType = $parent$.t\n",
			"parent", parent);
		*/

		// Printing setters.
		for (int i = 0; i < descriptor_->field_count(); i++) {
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);

			string type = GetFormattedTypeFromField(field);
			UncapitalizeString(type);

			string label = LabelName(field->label());

			// Print an empty line between methods for different fields.
			printer->Print("\n");

			printer->Print("fun clear_$name$ msg = \n"
				"((#$name$ msg) := NONE; msg)\n",
				"name", name);

			printer->Print("fun set_$name$ (msg, l) = \n"
				"((#$name$ msg) := SOME(l); msg)\n",
				"name", name);

			// If repeated field, then generate add and merge functions.
			if (label == "list") {
				printer->Print("fun add_$name$ (msg, v) = \n",
					"name", name);
				printer->Indent();
				printer->Print("((case (!(#$name$ msg)) of "
					"NONE => (#$name$ msg) := SOME([v])\n"
					"| SOME(l) => (#$name$ msg) := SOME(v :: l)); msg)\n",
					"name", name);
				printer->Outdent();

				printer->Print("fun merge_$name$ (msg, l) = \n",
					"name", name);
				printer->Indent();
				printer->Print("((case (!(#$name$ msg)) of "
					"NONE => (#$name$ msg) := SOME(l)\n"
					"| SOME(ll) => (#$name$ msg) := SOME(List.concat [ll, l])); msg)\n",
					"name", name);
				printer->Outdent();
			}
		}

		// Print initialization function.
		printer->Print("\n");
		printer->Print("fun init () = { ");
		printer->Indent();
		for (int i = 0; i < descriptor_->field_count(); i++) {
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);

			printer->Print("$name$ = ref NONE",
				"name", name);
			if (i < descriptor_->field_count() - 1) {
				printer->Print(",\n");
			} else {
				printer->Print("\n");
			}
		}
		printer->Outdent();
		printer->Print("}\n");

		// Print build function.
		printer->Print("\n");
		printer->Print("fun build msg = \nlet\n");
		printer->Indent();
		for (int i = 0; i < descriptor_->field_count(); i++) {
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);

			bool is_repeated = (field->label() == 
				FieldDescriptor::LABEL_REPEATED);

			bool is_optional = (field->label() == 
				FieldDescriptor::LABEL_OPTIONAL);

			bool is_required = (field->label() ==
				FieldDescriptor::LABEL_REQUIRED);

			// Default is optional.
			if ((!is_required) && (!is_repeated)) is_optional = true;

			// Need to throw error if required field is missing.
			if (is_optional) {
				printer->Print("val $name$Val = (!(#$name$ msg))\n",
					"name", name);
			} else if (is_repeated) {
				printer->Print("val $name$Val = case (!(#$name$ msg)) of "
					"NONE => [] | SOME(v) => v\n",
					"name", name);
			} else if (is_required) {
				printer->Print("val $name$Val = case (!(#$name$ msg)) of "
					"NONE => raise Exception(BUILD, "
					"\"Required field missing.\") | SOME(v) => v\n",
					"name", name);
			}
		}
		printer->Outdent();
		printer->Print("in { \n");
		printer->Indent();
		for (int i = 0; i < descriptor_->field_count(); i++) {
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);
			printer->Print("$name$ = $name$Val",
				"name", name);
			// Print appropriate end of line.
			if (i < descriptor_->field_count() - 1) {
				printer->Print(",\n");
			} else {
				printer->Print("\n");
			}
		}
		printer->Outdent();
		printer->Print("}\n");
		printer->Print("end\n");
		printer->Outdent();
		printer->Print("end\n");
	}
}  // namespace ml
}  // namespace compiler
}  // namespace protobuf
}  // namespace google