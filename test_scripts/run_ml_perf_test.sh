#!/bin/bash
# Script for running PolyML performance tests.

echo "\nRunning test for measuring PolyML serialization times.\n";
polyc performance_test_wall_timer.ml
./a.out