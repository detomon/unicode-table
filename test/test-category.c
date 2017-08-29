#include "test.h"

int main(int argc, char const* argv[])
{
	char const* dataName = "../src/UnicodeData.txt";
	FILE* data = fopen(dataName, "r");

	if (!data) {
		fprintf(stderr, "File '%s' not found\n", dataName);
		return RESULT_ERROR;
	}

	uint32_t value;
	char line[1024];
	char name[63];
	char categoryName[3];

	UTInfo const* info;
	UTCategory category;

	// read UnicodeData.txt
	while (fgets(line, 1024, data)) {
		sscanf(line, "%x;%63[^;];%2[^;]", &value, name, categoryName);

		info = UTLookupGlyph(value);
		category = info->category;

#if UT_STRICT_LEVEL >= 1
		// is surrogate
		if ((value & ~0x07FF) == 0xD800) {
			if (category != UT_CATEGORY_INVALID) {
				fprintf(stderr, "ERROR: %x should be invalid (strict_level=%u)\n", value, UT_STRICT_LEVEL);
				return RESULT_ERROR;
			}

			continue;
		}
#endif

		// test category
		if (strcmp(UTCategoryNames[category], categoryName) != 0) {
			fprintf(stderr, "ERROR: %x: %s != %s (%d)\n", value, categoryName, UTCategoryNames[category], category);
			return RESULT_ERROR;
		}
	}

	fclose(data);

	return RESULT_PASS;
}
