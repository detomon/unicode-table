#include "test.h"

int main (int argc, char const * argv [])
{
	UTGlyph glyph;
	UTInfo const * info;

	// character 0x2166 (Ⅶ) (ROMAN NUMERAL SEVEN)
	glyph = 0x2166;
	info = UTLookupGlyph (glyph);

	// check if character is a number
	if (info -> flags & UT_FLAG_NUMBER) {
		// prints "Integer value of 2166: 7"
		printf ("Integer value of %04X: %lld\n", glyph, info -> number.i);
	}
	else {
		return RESULT_FAIL;
	}

	// character 0x00BC (¼) (VULGAR FRACTION ONE QUARTER)
	glyph = 0x00BC;
	info = UTLookupGlyph (glyph);

	// check if character is a fraction
	if (info -> flags & UT_FLAG_FRACTION) {
		// prints "String representation of 00BC: 1/4"
		printf ("String representation of %04X: %s \n", glyph, info -> number.s);
	}
	else {
		return RESULT_FAIL;
	}

	return RESULT_PASS;
}
