#include "test.h"

int main(int argc, char const* argv[])
{
	// character `ß` (0x00DF; LATIN SMALL LETTER SHARP S)
	UTGlyph glyph = 0x00DF;
	UTInfo const* info = UTLookupGlyph(glyph);

	// check if expansion occurs to prevent invalid index
	if (info->flags & UT_FLAG_UPPER_EXPANDS) {
		// sequence index for uppercase variant
		int idx = info->cases[UT_CASE_UPPER];
		int length = UTSpecialCases[idx];

		// character sequence
		UTGlyph const* sequence = &UTSpecialCases[idx + 1];

		// prints "0x00DF expands to 2 chars in uppercase"
		printf("0x%04X expands to %d chars in uppercase\n", glyph, length);

		assert(length == 2);

		// uppercase characters
		// prints:
		// "0: 0x0053"
		// "1: 0x0053"
		for (int i = 0; i < length; i ++) {
			printf("%d: 0x%04X\n", i, sequence[i]);
		}
	}
	else {
		printf("Character 0x%04X does not expand\n", glyph);

		return RESULT_FAIL;
	}

	UTSpecialCase const* specialCase = UTGetSpecialCase(glyph, info, UT_CASE_UPPER);

	if (specialCase) {
		int length = specialCase->count;

		// prints "0x00DF expands to 2 chars in uppercase"
		printf("0x%04X expands to %d chars in uppercase\n", glyph, length);

		assert(length == 2);

		// uppercase characters
		// prints:
		// "0: 0x0053"
		// "1: 0x0053"
		for (int i = 0; i < length; i ++) {
			printf("%d: 0x%04X\n", i, specialCase->glyphs[i]);
		}
	}
	else {
		printf("Character 0x%04X does not expand\n", glyph);

		return RESULT_FAIL;
	}

	return RESULT_PASS;
}
