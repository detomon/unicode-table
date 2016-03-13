#include "test.h"

static int getSequence (char const * sequence, int values [])
{
	return sscanf (sequence, " %x %x %x %x", &values [0], &values [1], &values [2], &values [3]);
}

int main (int argc, char const * argv [])
{
	char const * specialCasingName = "../src/SpecialCasing.txt";
	FILE * specialCasing = fopen (specialCasingName, "r");

	if (!specialCasing) {
		fprintf (stderr, "File  '%s' not found\n", specialCasingName);
		return RESULT_ERROR;
	}

	char line [1024];
	unsigned value;
	char name [63];

	char upperSequence [64];
	char lowerSequence [64];
	char titleSequence [64];
	int length;
	int values [4];

	UTInfo const * info;

	// read SpecialCasing.txt
	while (fgets (line, 1024, specialCasing)) {
		for (int i = 0; line [i]; i ++) {
			if (line [i] == '#') {
				line [i] = '\0';
				break;
			}
		}

		strcpy (name, "");

		if (sscanf (line, "%x ; %63[^;] ; %63[^;] ; %63[^;] ; %63[^;]", &value, lowerSequence, titleSequence, upperSequence, name) < 3) {
			continue;
		}

		// ignore conditional case-folding
		if (name [0]) {
			continue;
		}

		info = UTLookupRune (value);

		if (!(info -> flags & (UT_FLAG_UPPER_EXPANDS | UT_FLAG_LOWER_EXPANDS | UT_FLAG_TITLE_EXPANDS))) {
			fprintf (stderr, "No special case found for '%04x'\n", value);
			return RESULT_FAIL;
		}

		length = getSequence (upperSequence, values);

		if (length > 1) {
			if (!(info -> flags & UT_FLAG_UPPER_EXPANDS)) {
				fprintf (stderr, "Missing upper special seqeunce for '%04x'", value);
				return RESULT_FAIL;
			}

			if (UTSpecialCases [info -> cases [UT_CASE_UPPER]] != length) {
				fprintf (stderr, "Wrong upper seqeunce length for '%04x'", value);
				return RESULT_FAIL;
			}
		}

		length = getSequence (lowerSequence, values);

		if (length > 1) {
			if (!(info -> flags & UT_FLAG_LOWER_EXPANDS)) {
				fprintf (stderr, "Missing lower special seqeunce for '%04x'", value);
				return RESULT_FAIL;
			}

			if (UTSpecialCases [info -> cases [UT_CASE_LOWER]] != length) {
				fprintf (stderr, "Wrong lower seqeunce length for '%04x'", value);
				return RESULT_FAIL;
			}
		}

		length = getSequence (titleSequence, values);

		if (length > 1) {
			if (!(info -> flags & UT_FLAG_TITLE_EXPANDS)) {
				fprintf (stderr, "Missing title special seqeunce for '%04x'", value);
				return RESULT_FAIL;
			}

			if (UTSpecialCases [info -> cases [UT_CASE_TITLE]] != length) {
				fprintf (stderr, "Wrong title seqeunce length for '%04x'", value);
				return RESULT_FAIL;
			}
		}
	}

	fclose (specialCasing);

	return RESULT_PASS;
}
