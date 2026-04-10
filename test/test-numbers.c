#include "test.h"

int main(int argc, char const* argv[]) {
	UTGlyph glyph;
	UTInfo const* info;

	// Character `Ⅶ` (0x2166; ROMAN NUMERAL SEVEN).
	glyph = 0x2166;
	info = UTLookupGlyph(glyph);

	// Check if character is a number.
	if (info->flags & UT_FLAG_NUMBER) {
		// Prints "Integer value of 0x2166: 7".
		printf("Integer value of 0x%04X: %"PRId64"\n" , glyph, info->number);
	}
	else {
		return RESULT_FAIL;
	}

	// Character `¼` (0x00BC; VULGAR FRACTION ONE QUARTER).
	glyph = 0x00BC;
	info = UTLookupGlyph(glyph);

	// Check if character is a fraction.
	if (info->flags & UT_FLAG_FRACTION) {
		if (info->numerator != 1 || info->denominator != 4) {
			fprintf(stderr, "%d/%d != 1/4\n", info->numerator, info->denominator);
			return RESULT_FAIL;
		}

		// Prints "String representation of 0x00BC: 1/4".
		printf("String representation of 0x%04X: %d/%d\n", glyph, info->numerator, info->denominator);
	}
	else {
		return RESULT_FAIL;
	}

	return RESULT_PASS;
}
