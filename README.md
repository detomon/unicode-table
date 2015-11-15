Unicode Lookup Table
====================

This script generates a Unicode character lookup table with linear access time. It creates a header and source file usable within C/C++. The data is contained in the files [UnicodeData.txt](http://www.unicode.org/Public/8.0.0/ucd/UnicodeData.txt) and [SpecialCasing.txt](http://www.unicode.org/Public/8.0.0/ucd/SpecialCasing.txt) and can be found on [http://www.unicode.org](). Currently Unicode version 8.0.0 is used, but the files can be replaced with newer versions in the future.

Available Informations
----------------------

`UTRuneInfo` contains the following fields:

- `category` contains one of the following character categories:
	- `UTLetterUppercaseRuneCategory` (Lu)
	- `UTLetterLowercaseRuneCategory` (Ll)
	- `UTLetterTitlecaseRuneCategory` (Lt)
	- `UTLetterModifierRuneCategory` (Lm)
	- `UTLetterOtherRuneCategory` (Lo)
	- `UTMarkNonspacingRuneCategory` (Mn)
	- `UTMarkSpacingCombiningRuneCategory` (Mc)
	- `UTMarkEnclosingRuneCategory` (Me)
	- `UTNumberDecimalDigitRuneCategory` (Nd)
	- `UTNumberLetterRuneCategory` (Nl)
	- `UTNumberOtherRuneCategory` (No)
	- `UTPunctuationConnectorRuneCategory` (Pc)
	- `UTPunctuationDashRuneCategory` (Pd)
	- `UTPunctuationOpenRuneCategory` (Ps)
	- `UTPunctuationCloseRuneCategory` (Pe)
	- `UTPunctuationInitialQuoteRuneCategory` (Pi)
	- `UTPunctuationFinalQuoteRuneCategory` (Pf)
	- `UTPunctuationOtherRuneCategory` (Po)
	- `UTSymbolMathRuneCategory` (Sm)
	- `UTSymbolCurrencyRuneCategory` (Sc)
	- `UTSymbolModifierRuneCategory` (Sk)
	- `UTSymbolOtherRuneCategory` (So)
	- `UTSeparatorSpaceRuneCategory` (Zs)
	- `UTSeparatorLineRuneCategory` (Zl)
	- `UTSeparatorParagraphRuneCategory` (Zp)
	- `UTOtherControlRuneCategory` (Cc)
	- `UTOtherFormatRuneCategory` (Cf)

- `info` contains flags listed in `UTFlag`

- `cases` contains relative values which can be added to the character value to convert it to the desired case variant (uppercase, lowercase or titlecase). The field is indexable with `UTRuneCase`. If a character can be case-folded, the `info` flag `UTFlagUppercase`, `UTFlagLowercase` or `UTFlagTitlecase` is set. If either `UTUpperExpandsRuneInfo`, `UTLowerExpandsRuneInfo` or `UTTitleExpandsRuneInfo` is set, the character expands to multiple characters when case-folding. For example, the lowercase character "ß" (`00DF`) expands to 2 uppercase characters "SS" (`0053 0053`). `cases` then contains an index usable for `UTSpecialCases`. The index itself points to the value which gives the number of character following the index (see example below).
- `numValue` contains numeric values for digits, number-like and characters representing fractions. For example, the roman number "Ⅶ" (`2166`) has the integer value `7` in `numValue.i`. Whereas fractions are represented by a string that contains the nominator and denominater separated by `/` (`"n/d"`). For example, the fraction character "¼" has the value `"1/4"` in `numValue.s`.

Lookup Character
----------------

Looking up character informations using an Unicode value:

```c
// character 0x0110 (Đ)
UTRune rune = 0x0110;
UTInfo const * info = UTLookupRune (rune);

// get lower-case variant
UTRune lower = rune + info -> cases [UTCaseLower];

printf ("Lowercase variant of %04X is %04X \n", rune, lower);
```

Handling expanding characters:

```c
// character 0x00DF (ß)
UTRune rune = 0x00DF;
UTInfo const * info = UTLookupRune (rune);

// sequence index for uppercase variant
int index = info -> cases [UTCaseUpper];
int length = UTSpecialCases [index];

// character sequence
UTRune const * sequence = &UTSpecialCases [index + 1];

printf ("Uppercase %04X expands to %d chars in upper-case\n", rune, length);

// upper-case characters
for (int i = 0; i < length; i ++) {
	printf ("%d: %04X\n", i, sequence [i]);
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

The source templates `unicode-table.h.in` and `unicode-table.c.in` contain the basic structure which is written to the header and source file. They can be editted if needed.
