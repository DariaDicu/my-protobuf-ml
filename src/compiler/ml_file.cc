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
#include "ml_file.h"
#include "ml_message.h"
#include "ml_ordering.h"

#include <google/protobuf/compiler/code_generator.h>
#include <google/protobuf/io/printer.h>
#include <google/protobuf/io/zero_copy_stream.h>
#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/stubs/strutil.h>
#include <iostream>

namespace google {
namespace protobuf {
namespace compiler {
namespace ml {

// TODO(dicu): module name here should be resolved in case of conflicts.
FileGenerator::FileGenerator(const FileDescriptor* file) : file_(file) {
	modulename_ = file->name();
	MessageSorter sorter(file_);
	message_order_ = sorter.GetOrdering();
	SortNestedTypes();
}

FileGenerator::~FileGenerator() {}

void FileGenerator::Generate(io::Printer* printer) {
	// Import ProtoBuf ML core library.
	printer->Print("use \"MlGenLib.ml\";\n\n");

	// First generate structures/signatures.
	for (int i = 0; i < file_->enum_type_count(); i++) {
		EnumGenerator generator(file_->enum_type(i));
		generator.GenerateSignature(printer, true /* toplevel */);
		generator.GenerateStructure(printer, true /* toplevel */);
		printer->Print("\n");
	}
	for (int i = 0; i < ordered_nested_types_.size(); i++) {
		MessageGenerator generator(ordered_nested_types_[i], &message_order_);
		generator.GenerateSignature(printer, true /* toplevel */);
		printer->Print("\n");
		generator.GenerateStructure(printer, true /* toplevel */);
		printer->Print("\n");
	}
}

struct op_comp : std::binary_function<const Descriptor*, const Descriptor*, bool>
{
    op_comp(const unordered_map<const Descriptor*, int>* order) : order_(order) {}
    bool operator() (const Descriptor* d1, const Descriptor* d2) {
		return (*order_).find(d1)->second < (*order_).find(d2)->second;
	}
    const unordered_map<const Descriptor*, int>* order_;
};

void FileGenerator::SortNestedTypes() {
	vector<const Descriptor*> ordered_nested_types;
	for (int i = 0; i < file_->message_type_count(); i++) {
		ordered_nested_types.push_back(file_->message_type(i));
	}
	std::sort(ordered_nested_types.begin(), ordered_nested_types.end(), 
		op_comp(&message_order_));
	ordered_nested_types_ = ordered_nested_types;
}

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf
}  // namespace google