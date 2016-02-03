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