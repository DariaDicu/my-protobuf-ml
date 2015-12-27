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

#include "ml_generator.h"
#include "ml_file.h"

#include <google/protobuf/io/printer.h>
#include <google/protobuf/io/zero_copy_stream.h>
#include <google/protobuf/descriptor.pb.h>
#include <google/protobuf/stubs/strutil.h>

namespace google {
namespace protobuf {
namespace compiler {
namespace ml {


MlGenerator::MlGenerator() {}
MlGenerator::~MlGenerator() {}

bool MlGenerator::Generate(const FileDescriptor* file,
                           const string& parameter,
                           GeneratorContext* context,
                           string* error) const {
  FileGenerator file_generator(file);

  /*
  // No need to parse options for now, as we do not support any.
  vector<pair<string, string> > options;
  ParseGeneratorParameter(parameter, &options);
  string output_list_file;
  for (int i = 0; i < options.size(); i++) {
    if (options[i].first == "output_list_file") {
      output_list_file = options[i].second;
    } else {
      *error = "Unknown generator option: " + options[i].first;
      return false;
    }
  }
  */

  // For now, the filename is simply the name of the .proto file. 
  // TODO: Consider replacing this with an implementation for a name resolver. 
  string filename = StripSuffixString(file->name(), ".proto") + ".pb.ml";
  scoped_ptr<io::ZeroCopyOutputStream> output(context->Open(filename));
  io::Printer printer(output.get(), '$');
  file_generator.Generate(&printer);

  return true;
}

}  // namespace ml
}  // namespace compiler
}  // namespace protobuf
}  // namespace google