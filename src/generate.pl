#!/usr/bin/env perl

# Copyright (c) 2016-2017 Simon Schoenenberger
# https://github.com/detomon/unicode-table
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

use strict;
use warnings;

use Template;

#-------------------------------------------------------------------------------
#
# Unicode definitions
#
#-------------------------------------------------------------------------------

use constant {
	unicodeVersion => '17.0.0',
	tableSize => 0x110000,
	pageSizeShift  => 8,

	categoryIndex => 0,
	categoryName => 1,
	categoryFlags => 2,

	glyphInfoLetter => 1 << 0,
	glyphInfoUppercase => 1 << 1,
	glyphInfoLowercase => 1 << 2,
	glyphInfoTitlecase => 1 << 3,
	glyphInfoSpace => 1 << 4,
	glyphInfoLinebreak => 1 << 5,
	glyphInfoPunctuation => 1 << 6,
	glyphInfoDigit => 1 << 7,
	glyphInfoNumber => 1 << 8,
	glyphInfoFraction => 1 << 9,
	glyphInfoControl => 1 << 10,
	glyphInfoSymbol => 1 << 11,
	glyphInfoOther => 1 << 12,
	glyphInfoUpperExpands => 1 << 13,
	glyphInfoLowerExpands => 1 << 14,
	glyphInfoTitleExpands => 1 << 15,
};

my %categories = (
	''   => [0, 'CategoryInvalid', 0],
	'Lu' => [1, 'CategoryLetterUppercase', glyphInfoLetter | glyphInfoUppercase],
	'Ll' => [2, 'CategoryLetterLowercase', glyphInfoLetter | glyphInfoLowercase],
	'Lt' => [3, 'CategoryLetterTitlecase', glyphInfoLetter | glyphInfoTitlecase],
	'Lm' => [4, 'CategoryLetterModifier', glyphInfoLetter],
	'Lo' => [5, 'CategoryLetterOther', glyphInfoLetter],
	'Mn' => [6, 'CategoryMarkNonspacing', glyphInfoOther],
	'Mc' => [7, 'CategoryMarkSpacingCombining', glyphInfoOther],
	'Me' => [8, 'CategoryMarkEnclosing', glyphInfoOther],
	'Nd' => [9, 'CategoryNumberDecimalDigit', glyphInfoLetter | glyphInfoDigit | glyphInfoNumber],
	'Nl' => [10, 'CategoryNumberLetter', glyphInfoLetter | glyphInfoNumber],
	'No' => [11, 'CategoryNumberOther', glyphInfoLetter | glyphInfoNumber],
	'Pc' => [12, 'CategoryPunctuationConnector', glyphInfoPunctuation],
	'Pd' => [13, 'CategoryPunctuationDash', glyphInfoPunctuation],
	'Ps' => [14, 'CategoryPunctuationOpen', glyphInfoPunctuation],
	'Pe' => [15, 'CategoryPunctuationClose', glyphInfoPunctuation],
	'Pi' => [16, 'CategoryPunctuationInitialQuote', glyphInfoPunctuation],
	'Pf' => [17, 'CategoryPunctuationFinalQuote', glyphInfoPunctuation],
	'Po' => [18, 'CategoryPunctuationOther', glyphInfoPunctuation],
	'Sm' => [19, 'CategorySymbolMath', glyphInfoSymbol],
	'Sc' => [20, 'CategorySymbolCurrency', glyphInfoSymbol],
	'Sk' => [21, 'CategorySymbolModifier', glyphInfoSymbol],
	'So' => [22, 'CategorySymbolOther', glyphInfoSymbol],
	'Zs' => [23, 'CategorySeparatorSpace', glyphInfoSpace],
	'Zl' => [24, 'CategorySeparatorLine', glyphInfoSpace | glyphInfoLinebreak],
	'Zp' => [25, 'CategorySeparatorParagraph', glyphInfoSpace | glyphInfoLinebreak],
	'Cc' => [26, 'CategoryOtherControl', glyphInfoControl],
	'Cf' => [27, 'CategoryOtherFormat', glyphInfoOther],
	'Cs' => [28, 'CategoryOtherSurrogate', glyphInfoOther],
	'Co' => [29, 'CategoryOtherPrivateUse', glyphInfoOther],
	'Cn' => [30, 'CategoryOtherNotAssigned', glyphInfoOther],
);

#-------------------------------------------------------------------------------
#
# Arguments
#
#-------------------------------------------------------------------------------

if (($#ARGV + 1) < 2) {
	print "usage $0 UnicodeData.txt SpecialCasing.txt\n";
	exit 1;
}

my $args = join ' ', @ARGV;
my $prefix = 'UT';
my $makeSnakeCase = 0;
my %useCategories = ();
my $includeInfos = 'flags,categories,casing,numbers';
my %includeInfos = ();
my $excludeSurrogates = 0;
my @categoryKeys = keys %categories;
my %namedArgs = (
	'categories' => join ',', @categoryKeys,
);

foreach (@ARGV) {
	if ($_ =~ /^--([^=]+)=(.+)$/) {
		$namedArgs{$1} = $2;
	}
}

$prefix = $namedArgs{'symbol-prefix'} if (exists $namedArgs{'symbol-prefix'});
$makeSnakeCase = int $namedArgs{'snake-case'} if (exists $namedArgs{'snake-case'});
$includeInfos = $namedArgs{'include-info'} if (exists $namedArgs{'include-info'});
$excludeSurrogates = int($namedArgs{'strict-level'}) > 0 if (exists $namedArgs{'strict-level'});

foreach (split /,/, $namedArgs{'categories'}) {
	die "Category '$_' not defined." if (not exists $categories{$_});
	$useCategories{$_} = 1;
}

# Full format: '{%1$5d, %2$3d, {%3$6d,%4$6d,%5$6d}, { %6$s }},'.
my $infoFormat = '';
my %infoFormat = ();
my @infoFormat = ();
my %conditionalFlags = ();

foreach (split /,/, $includeInfos) {
	$infoFormat{$_} = 1;
}

if (exists $infoFormat{'flags'}) {
	$conditionalFlags{'addFlags'} = 1;
}

if (exists $infoFormat{'categories'}) {
	$conditionalFlags{'addCategories'} = 1;
}

if (exists $infoFormat{'casing'}) {
	$conditionalFlags{'addFlags'} = 1;
	$conditionalFlags{'addCasing'} = 1;
}

if (exists $infoFormat{'numbers'}) {
	$conditionalFlags{'addFlags'} = 1;
	$conditionalFlags{'addNumbers'} = 1;
}

if (exists $conditionalFlags{'addFlags'}) {
	push @infoFormat, '0x%1$04X';
}

if (exists $conditionalFlags{'addCategories'}) {
	push @infoFormat, '%2$3d';
}

if (exists $conditionalFlags{'addCasing'}) {
	push @infoFormat, '{%3$6d,%4$6d,%5$6d}';
}

if (exists $conditionalFlags{'addNumbers'}) {
	push @infoFormat, '{ %6$s }';
}

$infoFormat = (join ', ', @infoFormat);
$infoFormat =~ s/^\s+|\s+$//g;
$infoFormat = "{$infoFormat},";

my $outName   = 'unicode-table';
my $hdrFile   = "$outName.h";
my $hdrFileIn = "unicode-table.h.in";
my $srcFile   = "$outName.c";
my $srcFileIn = "unicode-table.c.in";

#-------------------------------------------------------------------------------
#
# Prepare tables
#
#-------------------------------------------------------------------------------

my @data          = (0) x tableSize;
my %special       = ();
my %types         = (sprintf ($infoFormat, 0, 0, 0, 0, 0, 0) => 0);
my @pages         = (0) x (tableSize >> pageSizeShift);
my %pageCache     = ();
my @specialCasing = (0);

$pageCache{join ',', ((0) x (1 << pageSizeShift))} = 0;

#-------------------------------------------------------------------------------
#
# Functions
#
#-------------------------------------------------------------------------------

sub makeCharSequence {
	my $codes = $_[0];

	$codes =~/\s*(.+)\s*/;

	my @sequence = split /\s+/, $1;

	# Ignore single glyph.
	return -1 if ($#sequence == 0);

	my $offset = $#specialCasing + 1;
	push @specialCasing, $#sequence + 1;
	push @specialCasing, hex $_ foreach (@sequence);

	return $offset;
}

sub getTypeIndex {
	my ($info, $catIdx, $upper, $lower, $title, $number) = @_;
	my $type = sprintf $infoFormat, $info, $catIdx, $upper, $lower, $title, $number;

	if ($types{$type}) {
		$type = $types{$type};
	}
	else {
		my $count = keys %types;

		$types{$type} = $count;
		$type = $count;
	}

	return $type;
}

sub unsignedTypeFromSize {
	my $size = $_[0];

	if ($size <= 0xFF) {
		return 'uint8_t';
	}
	elsif ($size <= 0xFFFF) {
		return 'uint16_t';
	}

	return 'uint32_t';
}

sub maxValue {
	my $valueRref = $_[0];
	my $max = 0;

	foreach (@$valueRref) {
		if ($_ > $max) {
			$max = $_;
		}
	}

	return $max;
}

sub readLine {
	my ($file) = @_;

	while (<$file>) {
		chomp;
		next if (/^\s*($|#)/); # Ignore empty and comment-only lines.
		s/#.*$//g; # Cut off comment.

		my @line = split ';';
		@line = map { s/^\s+|\s+$//g; $_; } @line;

		return \@line;
	}

	return undef;
}

#-------------------------------------------------------------------------------
#
# Read special cases
#
#-------------------------------------------------------------------------------

open my $specialFile, '<', $ARGV[1] or die "File '$ARGV[1]' not found";

while (my $line = readLine $specialFile) {
	my @line = @$line;

	# Ignore conditional case-folding.
	next if ($line[4]);

	my $code  = hex $line[0];
	my $lower = makeCharSequence $line[1];
	my $title = makeCharSequence $line[2];
	my $upper = makeCharSequence $line[3];

	my @cases = ($upper, $lower, $title);

	@{$special{$code}} = @cases;
}

close $specialFile;

#-------------------------------------------------------------------------------
#
# Read unicode data
#
#-------------------------------------------------------------------------------

my %specialChars = (
	0x0009 => glyphInfoSpace,                      # CHARACTER TABULATION
	0x000A => glyphInfoSpace | glyphInfoLinebreak, # LINE FEED (LF)
	0x000B => glyphInfoSpace,                      # LINE TABULATION
	0x000C => glyphInfoSpace,                      # FORM FEED (FF)
	0x000D => glyphInfoSpace | glyphInfoLinebreak, # CARRIAGE RETURN (CR)
	0xFEFF => glyphInfoSpace,                      # ZERO WIDTH NO-BREAK SPACE (BYTE ORDER MARK)
);

open my $dataFile, '<', $ARGV[0] or die "File '$ARGV[0]' not found";

while (my $line = readLine $dataFile) {
	my @line = @$line;
	my $code = hex $line[0];
	my $cat  = $line[2];
	my $info = $categories{$cat}->[categoryFlags];

	my $number = $line[8];
	my $upper  = hex ($line[12] or 0);
	my $lower  = hex ($line[13] or 0);
	my $title  = hex ($line[14] or 0);

	if (not exists $useCategories{$cat}) {
		$info   = glyphInfoOther;
		$cat    = 'Cn';
		$number = 0;
		$upper  = 0;
		$lower  = 0;
		$title  = 0;
	}
	else {
		if (exists $specialChars{$code}) {
			$info |= $specialChars{$code};
		}

		$upper = $upper - $code if ($upper);
		$lower = $lower - $code if ($lower);
		$title = $title - $code if ($title);

		if ($number =~ /\//) {
			my ($v1, $v2) = split '/', $number;

			$number = ".numerator = $v1, .denominator = $v2";
			$info |= glyphInfoFraction;
		}
		elsif ($info & glyphInfoNumber) {
			$number = ".number = $number";
		}
		else {
			$number = 0;
		}

		if (exists $special{$code}) {
			my @cases = @{$special{$code}};

			if ($cases[0] != -1) {
				$upper = $cases[0];
				$info |= glyphInfoUpperExpands;
			}

			if ($cases[1] != -1) {
				$lower = $cases[1];
				$info |= glyphInfoLowerExpands;
			}

			if ($cases[2] != -1) {
				$title = $cases[2];
				$info |= glyphInfoTitleExpands;
			}
		}
	}

	my $type = getTypeIndex ($info, $categories{$cat}->[categoryIndex], $upper, $lower, $title, $number);

	# Read range.
	if ($line[1] =~ /First>$/i) {
		$_ = <$dataFile>;
		chomp;

		my @line2 = split /;/, $_;
		my $code2 = hex $line2[0];

		if ($excludeSurrogates) {
			if ($cat =~ /Cs/i) {
				next;
			}
		}

		for (; $code <= $code2; $code++) {
			$pages[$code >> pageSizeShift] = 1;
			$data[$code] = $type;
		}
	}
	else {
		$pages[$code >> pageSizeShift] = 1;
		$data[$code] = $type;
	}
}

close $dataFile;

#-------------------------------------------------------------------------------
#
# Build pages cache
#
#-------------------------------------------------------------------------------

my $cacheCount = 1;

for (my $i = 0; $i <= $#pages; $i++) {
	next unless ($pages[$i]);

	my $index = 0;
	my $pageStart = $i << pageSizeShift;
	my $pageEnd = (($i + 1) << pageSizeShift) - 1;
	my $page = join ',', @data[$pageStart..$pageEnd];

	if (exists $pageCache{$page}) {
		$index = $pageCache{$page};
	}
	else {
		$index = $cacheCount++;
		$pageCache{$page} = $index;
	}

	$pages[$i] = $index;
}

#-------------------------------------------------------------------------------
#
# Print
#
#-------------------------------------------------------------------------------

my @infoKeys = keys %types;
my $infoSize = @infoKeys;
my $pagesSize = keys %pageCache;
my @pageCacheKeys = keys %pageCache;
my $infoType = unsignedTypeFromSize $infoSize;
my $pagesType = unsignedTypeFromSize $pagesSize;
my $specialCasingType = unsignedTypeFromSize (maxValue \@specialCasing);

my %printMethods = ();

my $template = new Template(
	'vars' => {
		'outName' => $outName,
		'infoType' => $infoType,
		'pagesType' => $pagesType,
		'specialCasingType' => $specialCasingType,
		'infoTableSize' => $infoSize,
		'pageIndexTableSize' => $#pages + 1,
		'infoIndexTableSize' => $#pageCacheKeys + 1,
		'specialCasesTableSize' => $#specialCasing + 1,
		'categoryNamesTableSize' => $#categoryKeys + 1,
	},
	'prefix' => $prefix,
	'makeSnakeCase' => $makeSnakeCase,
	'printMethods' => \%printMethods,
	'conditional' => sub {
		return exists $conditionalFlags{$_[0]};
	},
);

%printMethods = (
	'header' => sub {
		my $out = $_[0];

		print $out " * Generated by $0\n";
		print $out " * Unicode version ".unicodeVersion."\n";
		print $out " * https://github.com/detomon/unicode-table\n";
	},
	'categories' => sub {
		my $out = $_[0];

		foreach (sort { $categories{$a}->[categoryIndex] <=> $categories{$b}->[categoryIndex] } @categoryKeys) {
			my $line = $categories{$_}->[categoryName];

			$line = $template->toConstant($line);
			$line = sprintf "\t%-39s ///< %s", "$line,", $_;
			$line =~ s/\s+$//;

			print $out "$line\n";
		}
	},
	'infos' => sub {
		my $out = $_[0];

		foreach (sort { $types{$a} <=> $types{$b} } keys %types) {
			print $out "	$_\n";
		}
	},
	'pageIndex' => sub {
		my $out = $_[0];
		my $i = 0;
		my $p = 0;

		print $out "\t";

		foreach (@pages) {
			print $out "\n\t" if ($i > 0 && $i % 16 == 0);
			printf $out "%3d,", $_;

			$i++;
		}

		print $out "\n";
	},
	'infoIndex' => sub {
		my $out = $_[0];
		my $p = 0;
		my $i = 0;

		foreach (sort { $pageCache{$a} <=> $pageCache{$b} } @pageCacheKeys) {
			print $out "\t{" if ($p == 0);
			print $out "\n\t}, {" if ($p > 0);

			foreach (split /,/, $_) {
				print $out "\n\t" if ($i % 16 == 0);
				printf $out "%3d,", $_;

				$i++;
			}

			$p++;
		}

		print $out "\n\t}\n";
	},
	'specialCases' => sub {
		my $out = $_[0];
		my $line = '';

		foreach (@specialCasing) {
			my $data = sprintf "%d, ", $_;

			if (length ($line) + length ($data) >= 66) {
				$line =~ s/\s+$//;
				print $out "\t$line\n";

				$line = $data;
			}
			else {
				$line .= $data;
			}
		}

		$line =~ s/\s+$//;
		print $out "\t$line\n";
	},
	'categoryNames' => sub {
		my $out = $_[0];

		foreach (sort { $categories{$a}->[categoryIndex] <=> $categories{$b}->[categoryIndex] } @categoryKeys) {
			my $key = $categories{$_}->[categoryName];

			$key = $template->toConstant($key);

			printf $out "\t%-39s = \"%s\",\n", "[$key]", $_;
		}
	},
);

sub main {
	open my $hdrin,  '<', $hdrFileIn or die "File '$hdrFileIn' not found";
	open my $hdrout, '>', $hdrFile or die "File '$hdrFile' not writable";

	open my $srcin,  '<', $srcFileIn or die "File '$srcFileIn' not found";
	open my $srcout, '>', $srcFile or die "File '$srcFile' not writable";

	$template->readLines($hdrin, $hdrout);
	$template->readLines($srcin, $srcout);

	close $hdrin;
	close $hdrout;

	close $srcin;
	close $srcout;

	return 0;
}

exit main @ARGV;
