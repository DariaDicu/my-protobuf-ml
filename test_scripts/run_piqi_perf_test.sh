#!/bin/bash
# Script for running Piqi performance tests.

echo "\nRunning test for measuring Piqi serialization times.\n";
cd benchmarks/
ocamlfind ocamlc -linkpkg -package piqirun.pb simple_message_piqi.ml \
primitives_piqi.ml performance_test_ocaml.ml
./a.out