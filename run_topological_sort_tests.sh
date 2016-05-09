#!/bin/bash
#Script for running tests for topological sort. Used so that each sort is a new 
#process, making sure memory allocated for building the FileDescriptors are 
#freed.

#Type 1
for i in `seq 1 15`;
do
  tests/topological_sort_test 1 $((i*100000))
done

#Type 2
for i in `seq 1 15`;
do
  tests/topological_sort_test 2 $((i*100000))
done

#Type 3
for i in `seq 1 15`;
do
  tests/topological_sort_test 3 $((i*100000))
done

#Type 4
for i in `seq 1 15`;
do
  tests/topological_sort_test 4 $((i*100000))
done

 #Type 5
for i in `seq 1 2000`;
do
  tests/topological_sort_test 5 $i
done

#Type 6
for i in `seq 1 15`;
do
  tests/topological_sort_test 6 $((i*100000))
done