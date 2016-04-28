#TESTS = topological_sort_test

check_PROGRAMS = topological_sort_test

topological_sort_test_SOURCES = topological_sort_test.cpp
topological_sort_test_LDFLAGS = -lprotobuf -lprotoc
topological_sort_test_LDADD = $(top_builddir)/src/compiler/ml_ordering.o \
							  $(top_builddir)/src/compiler/graph_builder.o
