Unicode Lookup Table
====================

[![Build Status](https://api.travis-ci.org/detomon/unicode-table.svg?branch=master)](https://travis-ci.org/detomon/unicode-table)

This script generates a Unicode character lookup table with linear access time. It creates a header and source file and compiles a static library usable within C/C++. The source data is contained in the files [UnicodeData.txt](https://www.unicode.org/Public/10.0.0/ucd/UnicodeData.txt) and [SpecialCasing.txt](https://www.unicode.org/Public/10.0.0/ucd/SpecialCasing.txt) and can be found on <https://www.unicode.org/Public/UNIDATA/>. Currently Unicode version 10.0.0 is used, but the files can be replaced with newer versions in the future.

The only function is `UTLookupGlyph` that looks up a single character by its Unicode value. It returns a pointer to a `UTInfo` struct containing the character informations. It always returns a valid pointer, even for invalid characters. In this case, the field `category` has the value `UT_CATEGORY_INVALID` assigned.

Available Informations
----------------------

`UTInfo` contains the following fields:

```c
typedef struct {
    uint32_t flags;    ///< Combination of UTFlag.
    uint32_t category; ///< One of UTCategory.
    int32_t cases[3];  ///< Distance to case variant. Indexable with UTCase.
    union {
        int64_t num;      ///< Number value if `flags & UT_FLAG_NUMBER`.
        char const* frac; ///< Fraction string if `flags & UT_FLAG_FRACTION`.
    };
} UTInfo;
```

- `category` contains one of the character categories listed in `UTCategory`
- `flags` contains multiple flags listed in `UTFlag`
- `cases` contains values to be added to the character value in order to convert it to the desired case variant (uppercase, lowercase or titlecase). The field is indexable with `UTCase`. If a `case` field is `0`, that specific case variant does not exist. If one of the flags `UT_FLAG_UPPER_EXPANDS`, `UT_FLAG_LOWER_EXPANDS` or `UT_FLAG_TITLE_EXPANDS` is set in `flags`, the character expands to multiple characters when case-folding. For example, the lowercase letter "ß" (`0x00DF; LATIN SMALL LETTER SHARP S `) expands to the 2 uppercase letters "SS" (`0x0053 0x0053; LATIN CAPITAL LETTER S `). `cases` then contains an index usable for the array `UTSpecialCases`. The index itself points to the number of character in the expanded sequence. The following indexes contain the expanded sequence's character values (see [example below](#user-content-case-fold-expansion)).
- `number` contains numeric values for digits, number-like and fraction characters. For example, the roman number "Ⅶ" (`0x2166; ROMAN NUMERAL SEVEN `) has the value `7` in `num`. Fractions are represented by strings that contain the nominator and denominator separated by `/` (`"n/d"`). For example, the fraction character "¼" (`0x00BC; VULGAR FRACTION ONE QUARTER `) has the value `"1/4"` in `frac`.

Lookup Character
----------------

Looking up a character with its Unicode value:

```c
// character `Đ` (0x0110; LATIN CAPITAL LETTER D WITH STROKE)
UTGlyph glyph = 0x0110;
UTInfo const* info = UTLookupGlyph(glyph);

// get lowercase variant `đ` (0x0111; LATIN SMALL LETTER D WITH STROKE)
UTGlyph lower = glyph + info->cases[UT_CASE_LOWER];

// prints "Lowercase variant of 0x0110: 0x0111"
printf("Lowercase variant of 0x%04X: 0x%04X\n", glyph, lower);
```

Numeric and Fraction Values
---------------------------

Get the representing integer or fraction value:

```c
UTGlyph glyph;
UTInfo const* info;

// character `Ⅶ` (0x2166; ROMAN NUMERAL SEVEN)
glyph = 0x2166;
info = UTLookupGlyph(glyph);

// check if character is a number
if (info->flags & UT_FLAG_NUMBER) {
    // prints "Integer value of 2166: 7"
    printf("Integer value of %04X: %lld\n", glyph, info->num);
}

// character `¼` (0x00BC; VULGAR FRACTION ONE QUARTER)
glyph = 0x00BC;
info = UTLookupGlyph(glyph);

// check if character is a fraction
if (info->flags & UT_FLAG_FRACTION) {
    // prints "String representation of 0x00BC: 1/4"
    printf("String representation of 0x%04X: %s\n", glyph, info->frac);
}
```

Case-Fold Expansion
-------------------

Handling cases, where case-folding expands to multiple characters:

```c
// character `ß` (0x00DF; LATIN SMALL LETTER SHARP S)
UTGlyph glyph = 0x00DF;
UTInfo const* info = UTLookupGlyph(glyph);

// check if expansion occurs to prevent invalid index
if (info->flags & UT_FLAG_UPPER_EXPANDS) {
    // sequence index for uppercase variant
    int idx = info->cases[UT_CASE_UPPER];
    int length = UTSpecialCases[idx];

    // character sequence
    UTGlyph const* sequence = &UTSpecialCases[idx + 1];

    // prints "0x00DF expands to 2 chars in uppercase"
    printf("0x%04X expands to %d chars in uppercase\n", glyph, length);

    // uppercase characters
    // prints:
    // "0: 0x0053"
    // "1: 0x0053"
    for (int i = 0; i < length; i ++) {
        printf("%d: 0x%04X\n", i, sequence[i]);
    }
}
else {
    printf("Character %04X does not expand\n", glyph);
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

- `--enable-symbol-prefix=bla` changes the prefix for library symbols to `bla`. The default is `UT`.
- `--enable-snake-case`, `--disable-snake-case` enables or disables snake-case symbol names (For example, `bla_lookup_glyph` instead of `blaLookupGlyph`). The default is `disable`.
- `--enable-categories=Lu,Ll,Lt,Lm,Lo,Mn,Mc,Me,Nd,Nl,No,Pc,Pd,Ps,Pe,Pi,Pf,Po,Sm,Sc,Sk,So,Zs,Zl,Zp,Cc,Cf,Cs,Co,Cn` sets the required Unicode character categories to be include in the table. This can reduce the table size. All other characters will have their category set to `UT_CATEGORY_OTHER_NOT_ASSIGNED`. If omitted, all categories are included.
- `--enable-include-info=flags,categories,casing,numbers` sets the required character informations to be included in the table. If omitted, all available informations are included.
- `--enable-strict-level=0` sets the strict level, which excludes certain characters considered as unsafe, for example, surrogates. Defaut is 0.  
0: do not exclude any characters  
1: define surrogates as invalid  

### Example

```sh
./configure \  
    --enable-symbol-prefix=bla \  
    --enable-categories=Lu,Ll,Lt,Lm,Lo \  
    --enable-snake-case \  
    --enable-strict-level=1
```

Using as Automake Subproject
----------------------------

This project is designed to be used as an Automake subproject. To match your projects namespace, export the enviroment variables inside the main project's `configure.ac`:

```sh
...

# put before `AC_CONFIG_SUBDIRS`

# use symbol prefix
# omit for default prefix
export UT_SYMBOL_PREFIX="myprefix"
# use snake case symbols
export UT_SNAKE_CASE=1
# define character categories to include
# omit to include all categories
export UT_CATEGORIES=Lu,Ll,Lt
# define character information to include
# omit to include all available information
export UT_INCLUDE_INFO=flags,categories
# exclude additional characters, for example, surrogates
# omit for using default (0)
# 0: do not exclude any characters
# 1: define surrogates as invalid
export UT_STRICT_LEVEL=0

AC_CONFIG_SUBDIRS([unicode-table])

...
```

Source Templates
----------------

The source templates `unicode-table.h.in` and `unicode-table.c.in` located in `src` contain the structure and data placeholders for the header and source file. They can be editted if needed.
