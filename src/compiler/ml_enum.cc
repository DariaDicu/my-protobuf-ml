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

#include <cctype>
#include <google/protobuf/io/printer.h>
#include <google/protobuf/io/zero_copy_stream.h>
#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/stubs/strutil.h>
#include <iostream>
#include <string>

namespace google {
namespace protobuf {
namespace compiler {
namespace ml {
	EnumGenerator::EnumGenerator(const EnumDescriptor* descriptor):descriptor_(
		descriptor) {
		for (int i = 0; i < descriptor_->value_count(); i++) {
			const EnumValueDescriptor* value = descriptor_->value(i);
			const EnumValueDescriptor* canonical_value = descriptor_->
				FindValueByNumber(value->number());
			if (value == canonical_value) {
				canonical_values_.push_back(value);
			} else {
				Alias alias;
				alias.value = value;
				alias.canonical_value = canonical_value;
				aliases_.push_back(alias);
			}
		}
	}

	EnumGenerator::~EnumGenerator() {};

	void EnumGenerator::GenerateSignature(io::Printer* printer, bool toplevel) {
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
		printer->Print("type t\n");
		printer->Outdent();
		printer->Print("end\n");
	}

	void EnumGenerator::GenerateStructure(io::Printer* printer, bool toplevel) {
		string structure = descriptor_->name();
		CapitalizeString(structure);
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
		printer->Print("datatype t = ");
		printer->Indent();
		for (int i = 0; i < canonical_values_.size(); i++) {
			// Capitalize each constructor.
			string constructor = canonical_values_[i]->name();
			CapitalizeString(constructor);

			if (i > 0) printer->Print("\n| ");
			printer->Print("$constructor$", 
				"constructor", constructor);
		}
		printer->Print("\n");
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