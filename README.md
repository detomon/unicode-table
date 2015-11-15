Unicode Lookup Table
====================

This script generates an Unicode character lookup table with linear access time. It creates a header and source file usable within C/C++. The data is contained in the files [UnicodeData.txt](http://www.unicode.org/Public/8.0.0/ucd/UnicodeData.txt) and [SpecialCasing.txt](http://www.unicode.org/Public/8.0.0/ucd/SpecialCasing.txt) and can be found on [http://www.unicode.org](). Currently Unicode version 8.0.0 is used, but the files can be replaced with newer versions in the future.

Available Informations
----------------------

`UTRuneInfo` contains the following fields:

- `category` contains one of the character categories listed in `UTCategory`
- `flags` contains multiple flags listed in `UTFlag`
- `cases` contains values which can be added to the character value to convert it to the desired case variant (uppercase, lowercase or titlecase). The field is indexable with `UTRuneCase`. If a `case` field is `0`, that specific case variant does not exist. If one of the flags `UTFlagUpperExpands`, `UTFlagLowerExpands` or `UTFlagTitleExpands` is set in `flags`, the character expands to multiple characters when case-folding. For example, the lowercase character "ß" (`0x00DF`) expands to 2 uppercase characters "SS" (`0x0053 0x0053`). `cases` then contains an index usable for the array `UTSpecialCases`. The index itself points the number of character in the expanded sequence. The following indexes contain the character values (see example below).
- `number` contains numeric values for digits, number-like and fraction characters. For example, the roman number "Ⅶ" (`0x2166`) has the value `7` in `number.i`. Whereas fractions are represented by a string that contains the nominator and denominater separated by `/` (`"n/d"`). For example, the fraction character "¼" (`0x00BC`) has the value `"1/4"` in `number.s`.

Lookup Character
----------------

The function `UTLookupRune` is used to lookup a single character. It returns a pointer to a `UTInfo` struct containing the character information. The function always returns a valid pointer, even for invalid characters. They have the category `UTCategoryLetterInvalid` assigned to the `category` field.

Looking up a character with its Unicode value:

```c
// character 0x0110 (Đ)
UTRune rune = 0x0110;
UTInfo const * info = UTLookupRune (rune);

UTRune lower = rune + info -> cases [UTCaseLower];

// prints "Lowercase variant of 0110: 0111"
printf ("Lowercase variant of %04X: %04X \n", rune, lower);
```

Get the representing integer or fraction value:

```c
UTRune rune;
UTInfo const * info;

// character 0x2166 (Ⅶ)
rune = 0x2166;
info = UTLookupRune (rune);

// prints "Integer value of 2166: 7"
printf ("Integer value of %04X: %lld\n", rune, info -> number.i);

// character 0x00BC (¼)
rune = 0x00BC;
info = UTLookupRune (rune);

// prints "String representation of 00BC: 1/4"
printf ("String representation of %04X: %s \n", rune, info -> number.s);

```

Handling case-fold expansion:

```c
// character 0x00DF (ß)
UTRune rune = 0x00DF;
UTInfo const * info = UTLookupRune (rune);

if (info -> flags & UTFlagUpperExpands) {
	// sequence index for uppercase variant
	int idx = info -> cases [UTCaseUpper];
	int length = UTSpecialCases [idx];

	// character sequence
	UTRune const * sequence = &UTSpecialCases [idx + 1];

	// prints "00DF expands to 2 chars in uppercase"
	printf ("%04X expands to %d chars in uppercase\n", rune, length);

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
}
```

Building the Table
------------------

Run `make` to build the table with the default settings:

```sh
make
```

`make` can take some enviroment variables:

- `OUT_NAME` sets the output file names for the header and source file.
- You can also change the used symbol prefix with `SYMBOL_PREFIX` to match you project's namespace.
- Use `SNAKE_CASE=1` to use snake-case symbol names.

This runs `make` with the default settings:

```sh
make OUT_NAME=unicode-table SYMBOL_PREFIX=UT SNAKE_CASE=0
```

Source Templates
----------------

The source templates `unicode-table.h.in` and `unicode-table.c.in` contain the structure for the header and source file. They can be editted if needed.
