Unicode Lookup Table
====================

This script generates a Unicode character lookup table with linear access time. It creates a header and source file usable within C/C++ from the Unicode data files [UnicodeData.txt](http://www.unicode.org/Public/8.0.0/ucd/UnicodeData.txt) and [SpecialCasing.txt](http://www.unicode.org/Public/8.0.0/ucd/SpecialCasing.txt) found on [http://www.unicode.org](). Currently Unicode version 8.0.0 is used, but the files can be replaced with newer versions in the future.

Lookup Character
----------------


This will lookup character informations using the Uncode value:

```
// lookup character 0x0110 (Đ)
UTRuneInfo const * info = UTLookupRune (0x0110);
```

Available Character Informations
--------------------------------

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

- `info` contains flags contained in `UTFlag`

- If `(info & UTCasedRuneMask)` is not `0`, `cases` contains the value which must be added to convert to character to the desired case variant (uppercase, lowercase or titlecase). The field is indexable with `UTRuneCase`.
- If either `UTUpperExpandsRuneInfo`, `UTLowerExpandsRuneInfo` or `UTTitleExpandsRuneInfo` is set, expanding informations are available for characters which are split into multiple characters when case-folding. For example, the lowercase character `ß` (`\u00DF`) expands to 2 uppercase characters `SS` (`\u0053\u0053`).
- `numValue` contains numeric values for digits, number-like and characters representing fractions. For example, the roman number `Ⅶ` (`\u2166`) has the value `7` in `numValue.i`. Whereas fractions are represented by a string that contains the nominator and denominater separated by `/` (`n/d`). For example, `¼` has the value `1/4` in `numValue.s`.

Building the Table
------------------

Run `make` to build the table with the default settings:

```
make
```

`make` can take some enviroment variables. `OUT_NAME` sets the output file names. You can also change the used symbol prefix with `SYMBOL_PREFIX` to match you project's namespace. Use `SNAKE_CASE=1` to use snake-case symbol names.

This runs `make` with the default settings:

```
make OUT_NAME=unicode-table SYMBOL_PREFIX=UT SNAKE_CASE=0
```

Source Templates
----------------

The source templates `unicode-table.h.in` and `unicode-table.c.in` contain the basic structure which is written to header and source file. They can be editted if needed.
