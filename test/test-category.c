#include "test.h"

int main (int argc, char const * argv [])
{
	FILE * data = fopen ("../UnicodeData.txt", "r");

	char line [1024];
	unsigned value;
	char name [63];
	char categoryName [3];

	UTInfo const * info;
	UTCategory category;

	// read UnicodeData.txt
	while (fgets (line, 1024, data)) {
		sscanf (line, "%x;%63[^;];%2[^;]", &value, name, categoryName);

		info = UTLookupRune (value);
		category = info -> category;

		// test category
		if (strcmp (UTCategoryNames [category], categoryName) != 0) {
			fprintf (stderr, "ERROR: %x: %s != %s (%d)\n", value, categoryName, UTCategoryNames [category], category);
			return RESULT_ERROR;
		}
	}

	fclose (data);

	return RESULT_PASS;
}
