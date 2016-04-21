#include "lib_helpers.c"
#include <stdio.h>

int main() {
	double x = real_of_bits64(13903985423498049657ULL);
	printf("%f\n", x);
	return 0;
}