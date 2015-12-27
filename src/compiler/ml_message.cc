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

	void MessageGenerator::Generate(io::Printer* printer) {
		// Generate signature.
		// string signature = descriptor_->name();
		// UpperString(&signature);
		// printer->Print("signature $signature$ =\n",
		// 	"signature", signature);
		// printer->Indent();
		// printer->Print("sig\n");
		// printer->Indent();
		// printer->Print("type t\n");
		// // Add setter functions here.
		// printer->Outdent();
		// printer->Print("end\n");
		// printer->Outdent();

		// Generate structure.
		string structure = descriptor_->name();
		structure[0] = toupper(structure[0]);
		//printer->Print("structure $structure$ :> $signature$ = ",
		printer->Print("structure $structure$ = ",
			"structure", structure);
			//"signature", signature);
		printer->Indent();
		printer->Print("struct\n");
		printer->Indent();
		// TODO: Print here other type declarations
		for (int i = 0; i < descriptor_->nested_type_count(); i++) {
			MessageGenerator generator(descriptor_->nested_type(i));
			generator.Generate(printer);
		}
		for (int i = 0; i < descriptor_->enum_type_count(); i++) {
			EnumGenerator generator(descriptor_->enum_type(i));
			generator.Generate(printer);
		}
		// Print main type declaration.
		printer->Print("type t = {\n");
		printer->Indent();
		for (int i = 0; i < descriptor_->field_count(); i++) {
			const FieldDescriptor* field = descriptor_->field(i);
			string name = field->name();

			string type = GetFormattedTypeFromField(field);

			// TODO: decide if default should be required.
			string label = LabelName(field->label());
			printer->Print("$name$: $type$ $label$,\n",
				"name", name,
				"type", type,
				"label", label);
		}
		printer->Outdent();
		// TODO: Print alias for main type declaration.
		printer->Print("}\n");
		printer->Outdent();
		printer->Print("end\n");
		printer->Outdent();
	}

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf
}  // namespace google