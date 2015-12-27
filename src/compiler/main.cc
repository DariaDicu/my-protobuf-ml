#include <google/protobuf/compiler/plugin.h>

#include "ml_generator.h"
#include <iostream>

using namespace google::protobuf::compiler::ml;

int main(int argc, char **argv)
{
	MlGenerator generator;
	return PluginMain(argc, argv, &generator);
}