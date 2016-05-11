#!/bin/bash
# Script for testing correctness of ML implementation against C++ library.

echo "\nGenerating encoded data from ML library.\n";
polyc generate_ml_encoding_data.ml
./a.out
echo "\nTesting the encoding using C++ decoder and generating encoded data from C++ library.\n";
cd "./tests"
g++ -I /usr/local/include -L /usr/local/lib ml_cpp_test.cpp embedded.pb.cc primitives.pb.cc -lprotobuf -pthread
./a.out

echo "\nTesting the decoding using C++ encoded data.\n";
cd ".."
polyc ml_cpp_test.ml
./a.out