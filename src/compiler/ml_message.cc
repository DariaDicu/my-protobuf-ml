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
		printer->Print("val encode : t * tag -> Word8Vector.vector\n");
		printer->Print("val parse : ByteBuffer.buffer -> "
			"(t * tag) * parseResult\n");

		// Print function declarations for setters
		for (int i = 0; i < descriptor_->field_count(); i++) {
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);

			string type = GetFormattedTypeFromField(field);
			UncapitalizeString(type);

			string label = LabelName(field->label());

			printer->Print("val set_$name$: t * $type$ $label$ -> unit\n",
				"name", name,
				"type", type,
				"label", label);

			// If repeated field, then generate add functions.
			if (label == "list") {
				printer->Print("val add_$name$: t * $type$ -> unit\n",
					"name", name,
					"type", type);
			}
		}

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
			printer->Print("$name$: $type$ $label$ ref",
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

		// Printing setters.
		for (int i = 0; i < descriptor_->field_count(); i++) {
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);

			string type = GetFormattedTypeFromField(field);
			UncapitalizeString(type);

			string label = LabelName(field->label());

			printer->Print("fun set_$name$ (msg, value) = \n"
				"(#$name$ msg) := value\n",
				"name", name);

			// If repeated field, then generate add functions.
			if (label == "list") {
				printer->Print("fun add_$name$ (msg, value) = \n"
					"(#$name$ msg) := value :: !(#$name$ msg)\n",
					"name", name);
			}
		}


		// Printing the encode function.
		printer->Print("fun encode (m, tag) = \n");
		printer->Indent();
		printer->Print("let\n");
		printer->Indent();
		printer->Print("val l = [");
		for (int i = 0; i < descriptor_->field_count(); i++) {
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);
			string type_name = field->type_name();
			string tag = to_string(field->number());

			// Get name of the helper function we need to call.
			string function_name;

			bool is_repeated = (field->label() == 
				FieldDescriptor::LABEL_REPEATED);

			bool is_optional = (field->label() == 
				FieldDescriptor::LABEL_OPTIONAL);

			if (type_name.compare("message") == 0 || 
				type_name.compare("enum") == 0) {
				string type = GetFormattedTypeFromField(field);
				CapitalizeString(type);
				function_name = type + ".encode";
			} else {
				CapitalizeString(type_name);
				function_name = "encode" + type_name;
			}
			if (i > 0) printer->Print(", \n");
			if (is_repeated) {
				printer->Print("(encodeRepeated $enc_func$) (!(#$name$ m), "
					"Tag($tag$))",
					"name", name,
					"enc_func", function_name,
					"tag", tag);
			} else if (is_optional) {
				printer->Print("(encodeOptional $enc_func$) (!(#$name$ m), "
					"Tag($tag$))",
					"name", name,
					"enc_func", function_name,
					"tag", tag);
			} else {
				printer->Print("$enc_func$ (!(#$name$ m), Tag($tag$))", 
					"name", name,
					"enc_func", function_name,
					"tag", tag);
			}
		}
		printer->Print("]\n");
		printer->Outdent();
		printer->Print("in\n");
		printer->Indent();
		printer->Print("Word8Vector.concat l\n");
		printer->Outdent();
		printer->Print("end\n");
		printer->Outdent();

		// Printing the decode next field function. This is hidden from signature.
		printer->Print("fun parseNextField buff obj remaining = \n");
		printer->Indent();
		printer->Print("if (remaining == 0) then\n");
		printer->Indent();
		//TODO: count total bytes read... 0 for now. 
		printer->Print("(obj, ParseResult(buff, 0))\n");
		printer->Outdent();
		printer->Print("elseif (remaining < 0) then\n");
		printer->Indent();
		printer->Print("raise Exception(PARSE, \"Field encoding does not match "
			"length in message header\")\n");
		printer->Outdent();
		printer->Print("else\n");
		printer->Indent();
		printer->Print("let\n");
		printer->Indent();
		printer->Print("val ((Tag(t), Code(c)), parse_result) = "
			"parseKey buff\n");
		printer->Print("val ParseResult(buff, ParsedByteCount(keyByteCount)) = "
				"parse_result\n");
		printer->Print("val remaining = remaining - keyByteCount\n");
		printer->Outdent();
		printer->Print("in\n");
		printer->Indent();
		printer->Print("if (remaining <= 0) then\n");
		printer->Indent();
		printer->Print("raise Exception(PARSE, \"Not enough bytes in message "
			"to parse the message fields.\")\n");
		printer->Outdent();
		printer->Print("else case (t) of ");
		for (int i = 0; i < descriptor_->field_count(); i++) {
			/*
			ML code will look like:
			case (tag_) of 0 => 
			let
				val (field_value, parsed_bytes) = parseFuncForType buff
			in
				if (remaining > parsed_bytes)
					(ModuleName.setOrAddForLabel (obj, field_value),
					parseNextField buff obj (remaining - parsed_bytes))
				else 
					raise Exception(PARSE, 
						"Error in matching the message length with fields length.")
			end
			| 1 => ...
			*/
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);
			string type_name = field->type_name();
			string tag = to_string(field->number());
			string module_name = GetFormattedTypeFromField(field);
			CapitalizeString(module_name);

			string function_name;
			if (type_name.compare("message") == 0 || 
			  type_name.compare("enum") == 0) {
				function_name = module_name + ".parse";
			} else {
				CapitalizeString(type_name);
				function_name = "parse" + type_name;
			}
		
			bool is_repeated = (field->label() == 
				FieldDescriptor::LABEL_REPEATED);

			bool is_optional = (field->label() == 
				FieldDescriptor::LABEL_OPTIONAL);

			// TODO: implement functionality for compact fields.
			string setter_name;

			if (is_repeated) {
				setter_name = "add_" + name;
			} else {
				setter_name = "set_" + name;
			}

			if (i > 0) printer->Print("\n| ");
			printer->Print("$tag$ => \n", "tag", tag);
			printer->Indent();
			printer->Print("let\n");
			printer->Indent();
			printer->Print("val (field_value, parse_result) = "
				"$function_name$ buff\n",
				"function_name", function_name);
			printer->Print("val ParseResult(buff, "
				"ParsedByteCount(parsed_bytes)) = parse_result\n");
			printer->Outdent();
			printer->Print("in\n");
			printer->Indent();
			printer->Print("if (remaining > parsed_bytes) then\n");
			printer->Indent();
			/*$parent_name$.*/
			printer->Print("($setter$ (obj, field_value);\n"
				"parseNextField buff obj (remaining - parsed_bytes))\n",
				"parent_name", structure,
				"setter", setter_name);
			printer->Outdent();
			printer->Print("else\n");
			printer->Indent();
			printer->Print("raise Exception(PARSE, \"Error in matching the "
				"message length with fields length.\")\n");
			printer->Outdent();
			printer->Outdent();
			printer->Print("end");
			printer->Outdent();
		}
		printer->Print("\n");
		printer->Outdent();
		printer->Outdent();
		printer->Print("end\n");
		printer->Outdent();



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
}  // namespace ml
}  // namespace compiler
}  // namespace protobuf
}  // namespace google