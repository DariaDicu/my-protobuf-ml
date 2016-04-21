#include <stdio.h>
#include <stdint.h>

int64_t bits64_of_real(double d) {
	union doubleConverter {
	  double d;
	  int64_t u;
	};
	union doubleConverter conv;
	conv.d = d;
	return conv.u; 
}

int32_t bits32_of_real(double d) {
	union floatConverter {
	  float f;
	  int32_t u;
	};
	union floatConverter conv;
	conv.f = (float)d;
	return conv.u;
}

double real_of_bits64(int64_t u) {
	union doubleConverter {
	  double d;
	  int64_t u;
	};
	union doubleConverter conv;
	conv.u = u;
	return conv.d;
}

double real_of_bits32(int32_t u) {
	union floatConverter {
	  float f;
	  int32_t u;
	};
	union floatConverter conv;
	conv.u = u;
	return (double)conv.f; 
}