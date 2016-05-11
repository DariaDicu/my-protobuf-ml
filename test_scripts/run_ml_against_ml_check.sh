#!/bin/bash 
#Script for running all correctness tests.
echo "\nRunning primitive types correctness test.\n";
polyc primitive_test.ml
./a.out
echo "\nRunning primitive message test.\n";
polyc primitive_message_test.ml
./a.out
echo "\nRunning embedded message test.\n";
polyc embedded_message_test.ml
./a.out