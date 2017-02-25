#include "test.h"

int main (int argc, char const * argv [])
{
	UTGlyph glyph;
	UTInfo const * info;

	// character `Ⅶ` (0x2166; ROMAN NUMERAL SEVEN)
	glyph = 0x2166;
	info = UTLookupGlyph (glyph);

	// check if character is a number
	if (info -> flags & UT_FLAG_NUMBER) {
		// prints "Integer value of 0x2166: 7"
		printf ("Integer value of 0x%04X: %zd\n", glyph, info -> num);
	}
	else {
		return RESULT_FAIL;
	}

	// character `¼` (0x00BC; VULGAR FRACTION ONE QUARTER)
	glyph = 0x00BC;
	info = UTLookupGlyph (glyph);

	// check if character is a fraction
	if (info -> flags & UT_FLAG_FRACTION) {
		// prints "String representation of 0x00BC: 1/4"
		printf ("String representation of 0x%04X: %s \n", glyph, info -> frac);
	}
	else {
		return RESULT_FAIL;
	}

	return RESULT_PASS;
}
