#include <stdio.h>
#include <string.h>
#include "unicode-test.h"

static int getSequence (char const * sequence, int values [])
{
	return sscanf (sequence, " %x %x %x %x", &values [0], &values [1], &values [2], &values [3]);
}

int main (int argc, char const * argv [])
{
	if (argc <= 1) {
		fprintf (stderr, "usage: %s UnicodeData.txt SpecialCasing.txt\n", argv [0]);
		return 1;
	}

	char const * dataFile = argv [1];
	char const * specialCasingFile = argv [2];

	FILE * data = fopen (dataFile, "r");
	FILE * specialCasing = fopen (specialCasingFile, "r");

	char line [1024];
	unsigned value;
	char name [63];
	char categoryName [3];

	UTInfo const * info;
	UTCategory category;

	printf ("checking...\n");
	printf ("reading %s...\n", dataFile);

	// read UnicodeData.txt
	while (fgets (line, 1024, data)) {
		sscanf (line, "%x;%63[^;];%2[^;]", &value, name, categoryName);

		info = UTLookupRune (value);
		category = info -> category;

		// test category
		if (strcmp (UTCategoryNames [category], categoryName) != 0) {
			fprintf (stderr, "ERROR: %x: %s != %s (%d)\n", value, categoryName, UTCategoryNames [category], category);
			return 1;
		}
	}

	char upperSequence [64];
	char lowerSequence [64];
	char titleSequence [64];
	int length;
	int values [4];

	printf ("reading %s...\n", specialCasingFile);

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

		if (!(info -> flags & (UTFlagUpperExpands | UTFlagLowerExpands | UTFlagTitleExpands))) {
			fprintf (stderr, "No special case found for '%04x'\n", value);
			return 1;
		}

		length = getSequence (upperSequence, values);

		if (length > 1) {
			if (!(info -> flags & UTFlagUpperExpands)) {
				fprintf (stderr, "Missing upper special seqeunce for '%04x'", value);
				return 1;
			}

			if (UTSpecialCases [info -> cases [UTCaseUpper]] != length) {
				fprintf (stderr, "Wrong upper seqeunce length for '%04x'", value);
				return 1;
			}
		}

		length = getSequence (lowerSequence, values);

		if (length > 1) {
			if (!(info -> flags & UTFlagLowerExpands)) {
				fprintf (stderr, "Missing lower special seqeunce for '%04x'", value);
				return 1;
			}

			if (UTSpecialCases [info -> cases [UTCaseLower]] != length) {
				fprintf (stderr, "Wrong lower seqeunce length for '%04x'", value);
				return 1;
			}
		}

		length = getSequence (titleSequence, values);

		if (length > 1) {
			if (!(info -> flags & UTFlagTitleExpands)) {
				fprintf (stderr, "Missing title special seqeunce for '%04x'", value);
				return 1;
			}

			if (UTSpecialCases [info -> cases [UTCaseTitle]] != length) {
				fprintf (stderr, "Wrong title seqeunce length for '%04x'", value);
				return 1;
			}
		}
	}

	fclose (data);
	fclose (specialCasing);

	printf ("-- all good --\n");

	return 0;
}
