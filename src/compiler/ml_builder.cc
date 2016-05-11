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

#include "ml_builder.h"
#include "ml_helpers.h"

#include <algorithm>
#include <google/protobuf/io/printer.h>
#include <google/protobuf/io/zero_copy_stream.h>
#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/stubs/strutil.h>

namespace google {
namespace protobuf {
namespace compiler {
namespace ml {
	BuilderGenerator::BuilderGenerator(const Descriptor* descriptor):
		descriptor_(descriptor) {};

	BuilderGenerator::~BuilderGenerator() {};

	void BuilderGenerator::GenerateSignature(io::Printer* printer) {
		printer->Print("structure Builder : sig\n");
		printer->Indent();

		printer->Print("type t\n");
		printer->Print("type parentType\n");

		// Print function declarations for setters
		for (int i = 0; i < descriptor_->field_count(); i++) {
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();
			SanitizeForMl(name);

			string type = GetCanonicalTypeFromField(field);

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

	void BuilderGenerator::GenerateStructure(io::Printer* printer) {
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
			if (type != "Word8Vector.vector") UncapitalizeString(type);

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