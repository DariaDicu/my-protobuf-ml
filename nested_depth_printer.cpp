#include <fstream>
#include <iostream>

using namespace std;

ofstream fo("nested_depth.proto", ios::trunc);

void recurse(int level) {
	if (level > 10000) return;
	fo << "message M" << level << " {\n";
	recurse(level+1);
	fo << "}\n";
}
int main() {
	fo << "syntax=\"proto2\";\n\n";
	recurse(0);
	return 0;
}