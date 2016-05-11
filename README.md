polyml-protobuf
===============
[Protobuf](https://developers.google.com/protocol-buffers/docs/overview) implementation in [Poly/ML](http://polyml.org).

## Building
This library needs the Google Protocol Buffers library for code generation (not needed at compile-time). On OS X this can be installed using Homebrew:
```
brew install protobuf
```
Building the library for Poly/ML is done by:
```
./configure
make
make install
```
## Generating code
The protocol buffer library takes a .proto file and generates a .pb.ml file containing type definitions for messages and enumerations, as well as serialization functions. To generate code for a file `my_descriptor.proto` in the current working directory, use the following command:
```
protoc my_descriptor.proto --ml_out="./"
```
Note: any generated files are dependent on the MlGenLib.ml file that provides serialization functions and other core functionality.

## Tests

There are 3 types of tests: correctness of wire format, serialization speed and message ordering speed. Scripts for running these tests are located in test_scripts/. Correctness is evaluated by:
* encoding benchmark data in ML and decoding it in ML
* encoding benchmark data in ML and decoding it in C++ and vice-versa

Performance is evaluated by comparing C++, OCaml and Poly/ML Protocol Buffers implementations.