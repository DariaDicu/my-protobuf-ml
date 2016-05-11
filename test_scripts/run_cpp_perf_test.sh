#!/bin/bash
# Script for running C++ performance tests.

echo "\nRunning test for measuring C++ serialization times.\n";
cd "./benchmarks"
g++ -I /usr/local/include -L /usr/local/lib performance_test.cpp simple_message.pb.cc primitives.pb.cc -lprotobuf -pthread
./a.out
