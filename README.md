# Unicode Lookup Table

[![Build Status](https://github.com/detomon/unicode-table/actions/workflows/c.yml/badge.svg)](https://github.com/detomon/unicode-table/actions/workflows/c.yml)

This script generates a Unicode character lookup table with linear access time. It creates a header and source file and compiles a static library usable within C/C++. The source data is contained in the files [UnicodeData.txt](https://www.unicode.org/Public/17.0.0/ucd/UnicodeData.txt) and [SpecialCasing.txt](https://www.unicode.org/Public/17.0.0/ucd/SpecialCasing.txt), and can be found on <https://www.unicode.org/Public/UNIDATA/>. Currently Unicode version 17.0.0 is used, but the files can be replaced with newer versions in the future.

## Available Character Informations

`UTInfo` contains the following fields:

| Field | Type | Description |
|---|---|---|
| `flags` | `UTFlag` | Combination of multiple `UTFlag`. |
| `category` | `UTCategory` | A `UTCategory`. |
| `cases[3]` | `int32_t` | Contains values to be added to the character value in order to convert it to the desired case variant. The field is indexable with `UTCase`. |
| `number` | `int64_t` | Number value if `flags & UT_FLAG_NUMBER`. |
| `numerator` | `int32_t` | Fraction numerator if `flags & UT_FLAG_FRACTION`. |
| `denominator` | `int32_t` | Fraction denominator if `flags & UT_FLAG_FRACTION`. |

If one of the flags `UT_FLAG_UPPER_EXPANDS`, `UT_FLAG_LOWER_EXPANDS` or `UT_FLAG_TITLE_EXPANDS` is set in `flags`, the character expands to multiple characters when case-folding. For example, the lowercase letter "ß" (`0x00DF; LATIN SMALL LETTER SHARP S`) expands to the 2 uppercase letters "SS" (`0x0053 0x0053; LATIN CAPITAL LETTER S`). `cases` then contains an index usable for the array `UTSpecialCases`. The index itself points to the number of character in the expanded sequence. The following array elements contain the expanded sequence's character values (see [example below](#user-content-case-fold-expansion)).

## Lookup Character

The function `UTLookupGlyph` looks up a single character by its Unicode value. It returns a pointer to a `UTInfo` struct containing the character informations. It always returns a valid pointer, even for invalid characters. In this case, the field `category` has the value `UT_CATEGORY_INVALID` assigned.

*if `--enable-include-info` is used, `flags` must be set.*

```c
// Character `Đ` (0x0110; LATIN CAPITAL LETTER D WITH STROKE).
UTGlyph glyph = 0x0110;
UTInfo const* info = UTLookupGlyph(glyph);

// Get lowercase variant `đ` (0x0111; LATIN SMALL LETTER D WITH STROKE).
UTGlyph lower = glyph + info->cases[UT_CASE_LOWER];

// Prints "Lowercase variant of 0x0110: 0x0111".
printf("Lowercase variant of 0x%04X: 0x%04X\n", glyph, lower);
```

If a `cases` field is `0`, that specific case variant does not exist or is the same case variant as the character value itself.

## Numeric and Fraction Values

Get the representing integer or fraction value.

*if `--enable-include-info` is used, `numbers` must be set.*

```c
UTGlyph glyph;
UTInfo const* info;

// Character `Ⅶ` (0x2166; ROMAN NUMERAL SEVEN).
glyph = 0x2166;
info = UTLookupGlyph(glyph);

// Check if character is a number.
if (info->flags & UT_FLAG_NUMBER) {
	// Prints "Integer value of 2166: 7".
	printf("Integer value of 0x%04X: %lld\n", glyph, info->number);
}

// Character `¼` (0x00BC; VULGAR FRACTION ONE QUARTER).
glyph = 0x00BC;
info = UTLookupGlyph(glyph);

// Check if character is a fraction.
if (info->flags & UT_FLAG_FRACTION) {
	// Prints "String representation of 0x00BC: 1/4".
	printf("String representation of 0x%04X: %d/%d\n", glyph, info->numerator, info->denominator);
}
```

## Case-Fold Expansion

Handling cases, where case-folding expands to multiple characters. Conditional case-folding is not supported.

*if `--enable-include-info` is used, `casing` must be set.*

```c
// Character `ß` (0x00DF; LATIN SMALL LETTER SHARP S).
UTGlyph glyph = 0x00DF;
UTInfo const* info = UTLookupGlyph(glyph);

// Check if expansion occurs to prevent invalid index.
if (info->flags & UT_FLAG_UPPER_EXPANDS) {
	UTSpecialCase const* special_case = UTGetSpecialCase(info, UT_CASE_UPPER);

	int count = special_case->count;

	// Prints "0x00DF expands to 2 chars in uppercase".
	printf("0x%04X expands to %d chars in uppercase\n", glyph, count);

	// Uppercase characters.
	// Prints:
	// "0: 0x0053"
	// "1: 0x0053"
	for (int i = 0; i < count; i++) {
		printf("%d: 0x%04X\n", i, special_case->glyphs[i]);
	}
}
else {
	printf("Character 0x%04X does not expand\n", glyph);
}
```

## Additional Cases

These characters have additional flags set which are not present in the unicode data.

| Unicode | Name | Flags |
|---|---|---|
| `0x0009` | `CHARACTER TABULATION` | `UT_FLAG_SPACE` |
| `0x000A` | `LINE FEED (LF)` | `UT_FLAG_SPACE | UT_FLAG_LINEBREAK` |
| `0x000B` | `LINE TABULATION` | `UT_FLAG_SPACE` |
| `0x000C` | `FORM FEED (FF)` | `UT_FLAG_SPACE` |
| `0x000D` | `CARRIAGE RETURN (CR)` | `UT_FLAG_SPACE | UT_FLAG_LINEBREAK` |
| `0xFEFF` | `ZERO WIDTH NO-BREAK SPACE (BYTE ORDER MARK)` | `UT_FLAG_SPACE` |

## Building the Table

- Run `./autogen.sh` to generate the build system
- Then run `./configure` and `make` to build `libunicodetable.a` in the `src` directory:

```sh
./autogen.sh
./configure
make
```

### Options

`configure` options with their default values. If omitted, the default values are used.

#### `--enable-symbol-prefix=UT`

Changes the prefix for library symbols.

####  `--enable-snake-case`, `--disable-snake-case` (default)

Enables or disables snake-case symbol names (For example, `ut_lookup_glyph` instead of `UTLookupGlyph`).

#### `--enable-categories=Lu,Ll,Lt,Lm,Lo,Mn,Mc,Me,Nd,Nl,No,Pc,Pd,Ps,Pe,Pi,Pf,Po,Sm,Sc,Sk,So,Zs,Zl,Zp,Cc,Cf,Cs,Co,Cn`

Sets the Unicode character categories to be include in the table. All other characters have their category set to `UT_CATEGORY_OTHER_NOT_ASSIGNED`. Removing unused ones can reduce the table size.

#### `--enable-include-info=flags,categories,casing,numbers`

Sets the character informations to be included in the `UTInfo` struct. Removing unused ones can reduce the table size.

#### `--enable-strict-level=0`

Sets the strict level, which excludes certain characters considered unsafe, for example, surrogates. These characters have their category set to `UT_CATEGORY_INVALID`.

- `0`: Do not exclude any characters
 -`1`: Define surrogates as invalid

### Example

```sh
./configure \
	--enable-symbol-prefix=bla \
	--enable-categories=Lu,Ll,Lt,Lm,Lo \
	--enable-snake-case \
	--enable-include-info=flags,categories \
	--enable-strict-level=1
```

## Using as Automake Subproject

This project is designed to be used as an Automake subproject. To match your projects namespace, export the enviroment variables inside the main project's `configure.ac`:

```sh
...

# Put before `AC_CONFIG_SUBDIRS`.

# Use symbol prefix.
# Omit for default prefix.
export UT_SYMBOL_PREFIX="myprefix"
# Use snake case symbols.
export UT_SNAKE_CASE=1
# Define character categories to include.
# Omit to include all categories.
export UT_CATEGORIES=Lu,Ll,Lt
# Define character information to include.
# Omit to include all available information.
export UT_INCLUDE_INFO=flags,categories
# Exclude additional characters, for example, surrogates.
# Omit for using default (0).
# 0: Do not exclude any characters.
# 1: Define surrogates as invalid.
export UT_STRICT_LEVEL=0

AC_CONFIG_SUBDIRS([unicode-table])

...
```

## Source Templates

The source templates [`unicode-table.h.in`](src/unicode-table.h.in) and [`unicode-table.c.in`](src/unicode-table.c.in) located in [`src`](src) contain the structure and data placeholders for the header and source file. They can be editted if needed.
