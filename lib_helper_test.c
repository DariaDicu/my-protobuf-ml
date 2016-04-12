#include "lib_helpers.c"
#include <stdio.h>

int main() {
	uint32_t x = bits32_of_real(3.0);
	printf("%d\n", x);
	return 0;
}