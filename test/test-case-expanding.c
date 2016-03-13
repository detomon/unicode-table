#include "test.h"

int main (int argc, char const * argv [])
{
	// character 0x00DF (ß) (LATIN SMALL LETTER SHARP S)
	UTRune rune = 0x00DF;
	UTInfo const * info = UTLookupRune (rune);

	// check if expansion occurs to prevent invalid index
	if (info -> flags & UT_FLAG_UPPER_EXPANDS) {
		// sequence index for uppercase variant
		int idx = info -> cases [UT_CASE_UPPER];
		int length = UTSpecialCases [idx];

		// character sequence
		UTRune const * sequence = &UTSpecialCases [idx + 1];

		// prints "00DF expands to 2 chars in uppercase"
		printf ("%04X expands to %d chars in uppercase\n", rune, length);

		assert (length == 2);

		// uppercase characters
		// prints:
		// "0: 0053"
		// "1: 0053"
		for (int i = 0; i < length; i ++) {
			printf ("%d: %04X\n", i, sequence [i]);
		}
	}
	else {
		printf ("Character %04X does not expand\n", rune);

		return RESULT_FAIL;
	}

	return RESULT_PASS;
}
