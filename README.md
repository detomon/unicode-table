Unicode Lookup Table
====================

This script generates an Unicode character lookup table with linear access time. It creates a header and source file and compiles a static library usable within C/C++. The source data is contained in the files [UnicodeData.txt](http://www.unicode.org/Public/8.0.0/ucd/UnicodeData.txt) and [SpecialCasing.txt](http://www.unicode.org/Public/8.0.0/ucd/SpecialCasing.txt) and can be found on [http://www.unicode.org](). Currently Unicode version 8.0.0 is used, but the files can be replaced with newer versions in the future.

The only function is `UTLookupRune` that looks up a single character by its Unicode value. It returns a pointer to an `UTInfo` struct containing the character informations. It always returns a valid pointer, even for invalid characters. In this case, the field `category` has the value `UTCategoryInvalid` assigned.

Available Informations
----------------------

`UTInfo` contains the following fields:

- `category` contains one of the character categories listed in `UTCategory`
- `flags` contains multiple flags listed in `UTFlag`
- `cases` contains values to be added to the character value in order to convert it to the desired case variant (uppercase, lowercase or titlecase). The field is indexable with `UTRuneCase`. If a `case` field is `0`, that specific case variant does not exist. If one of the flags `UTFlagUpperExpands`, `UTFlagLowerExpands` or `UTFlagTitleExpands` is set in `flags`, the character expands to multiple characters when case-folding. For example, the lowercase letter "ß" (`0x00DF`) expands to the 2 uppercase letter "SS" (`0x0053 0x0053`). `cases` then contains an index usable for the array `UTSpecialCases`. The index itself points to the number of character in the expanded sequence. The following indexes contain the expanded sequence's character values (see [example below](#user-content-case-fold-expansion)).
- `number` contains numeric values for digits, number-like and fraction characters. For example, the roman number "Ⅶ" (`0x2166`) has the value `7` in `number.i`. Fractions are represented by strings that contain the nominator and denominater separated by `/` (`"n/d"`). For example, the fraction character "¼" (`0x00BC`) has the value `"1/4"` in `number.s`.

Lookup Character
----------------

Looking up a character with its Unicode value:

```c
// character 0x0110 (Đ) (LATIN CAPITAL LETTER D WITH STROKE)
UTRune rune = 0x0110;
UTInfo const * info = UTLookupRune (rune);

// get lowercase variant 0x0111 (đ) (LATIN SMALL LETTER D WITH STROKE)
UTRune lower = rune + info -> cases [UTCaseLower];

// prints "Lowercase variant of 0110: 0111"
printf ("Lowercase variant of %04X: %04X \n", rune, lower);
```

Numeric and Fraction Values
---------------------------

Get the representing integer or fraction value:

```c
UTRune rune;
UTInfo const * info;

// character 0x2166 (Ⅶ) (ROMAN NUMERAL SEVEN)
rune = 0x2166;
info = UTLookupRune (rune);

// check if character is a number
if (info -> flags & UTFlagNumber) {
	// prints "Integer value of 2166: 7"
	printf ("Integer value of %04X: %lld\n", rune, info -> number.i);
}

// character 0x00BC (¼) (VULGAR FRACTION ONE QUARTER)
rune = 0x00BC;
info = UTLookupRune (rune);

// check if character is a fraction
if (info -> flags & UTFlagFraction) {
	// prints "String representation of 00BC: 1/4"
	printf ("String representation of %04X: %s \n", rune, info -> number.s);
}
```

Case-Fold Expansion
-------------------

Handling cases, where case-folding expands to multiple characters:

```c
// character 0x00DF (ß) (LATIN SMALL LETTER SHARP S)
UTRune rune = 0x00DF;
UTInfo const * info = UTLookupRune (rune);

// check if expansion occurs to prevent invalid index
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

Run `./autogen.sh` to generate the build system. Then run `./configure` and `make` to build `libunicodetable.a` in the `src` directory:

```sh
./autogen.sh
./configure
make
```

`configure` can take some options:

- `--enable-symbol-prefix=bla` changes the prefix for library symbols to `bla` (instead of the default `UT`).
- `--enable-snake-case`, `--disable-snake-case` enables or disables snake-case symbol names (For example, `bla_lookup_rune` instead of `blaLookupRune`).

```sh
./configure --enable-symbol-prefix=bla --enable-snake-case
```

Source Templates
----------------

The source templates `unicode-table.h.in` and `unicode-table.c.in` contain the structure and data placeholders for the header and source file. They can be editted if needed.
