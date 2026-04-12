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
# Unicode definitions
#-------------------------------------------------------------------------------

use constant {
	unicodeVersion => '17.0.0',
	tableSize => 0x110000,
	pageSizeShift => 8,
};

use constant {
	categoryIndex => 0,
	categoryName => 1,
	categoryFlags => 2,
};

use constant {
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
	'' => [0, 'CategoryInvalid', 0],
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
# Arguments
#-------------------------------------------------------------------------------

if (($#ARGV + 1) < 2) {
	die "usage $0 UnicodeData.txt SpecialCasing.txt\n";
}

my @categoryKeys = keys %categories;
my %namedArgs = (
	categories => join ',', @categoryKeys,
);

foreach (@ARGV) {
	# Extract options.
	if ($_ =~ /^--([^=]+)=(.+)$/) {
		$namedArgs{$1} = $2;
	}
}

my $prefix = $namedArgs{'symbol-prefix'} || 'UT';
my $makeSnakeCase = int($namedArgs{'snake-case'} || 0);
my $includeInfos = $namedArgs{'include-info'} || 'flags,categories,casing,numbers';
my $excludeSurrogates = int($namedArgs{'strict-level'} || 0) > 0;

my %useCategories = ();
foreach (split /,/, $namedArgs{'categories'}) {
	die "Category '$_' not defined." if (not exists $categories{$_});
	$useCategories{$_} = 1;
}

# Full format: '{%1$5d, %2$3d, {%3$6d,%4$6d,%5$6d}, { %6$s }},'.
my %infoFormat = ();
my @infoFormat = ();
my %conditionalFlags = ();

foreach (split /,/, $includeInfos) {
	$infoFormat{$_} = 1;
}

if (exists $infoFormat{'flags'}) {
	$conditionalFlags{'flags'} = 1;
}

if (exists $infoFormat{'categories'}) {
	$conditionalFlags{'categories'} = 1;
}

if (exists $infoFormat{'casing'}) {
	$conditionalFlags{'flags'} = 1;
	$conditionalFlags{'casing'} = 1;
}

if (exists $infoFormat{'numbers'}) {
	$conditionalFlags{'flags'} = 1;
	$conditionalFlags{'numbers'} = 1;
}

push @infoFormat, '0x%1$04X' if (exists $conditionalFlags{'flags'});
push @infoFormat, '%2$2d' if (exists $conditionalFlags{'categories'});
push @infoFormat, '{%3$6d,%4$6d,%5$6d}' if (exists $conditionalFlags{'casing'});
push @infoFormat, '{ %6$s }' if (exists $conditionalFlags{'numbers'});

my $infoFormat = (join ', ', @infoFormat);
$infoFormat =~ s/^\s+|\s+$//g;
$infoFormat = "{$infoFormat},";

#-------------------------------------------------------------------------------
# Prepare tables
#-------------------------------------------------------------------------------

my @data = (0) x tableSize;
my %special = ();
my %types = (sprintf ($infoFormat, 0, 0, 0, 0, 0, 0) => 0);
my @pages = (0) x (tableSize >> pageSizeShift);
my %pageCache = ();
my @specialCasing = (0); # Empty case-folding sequence.

$pageCache{join ',', ((0) x (1 << pageSizeShift))} = 0;

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

sub makeCharSequence {
	my ($codes) = @_;

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

	if (exists $types{$type}) {
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
	my ($size) = @_;

	return 'uint8_t' if ($size <= 0xFF);
	return 'uint16_t' if ($size <= 0xFFFF);
	return 'uint32_t';
}

sub maxValue {
	my ($valueRef) = @_;
	my $max = 0;

	foreach (@$valueRef) {
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
# Read special cases
#-------------------------------------------------------------------------------

open my $specialFile, '<', $ARGV[1] or die "File '$ARGV[1]' not found";

while (my $line = readLine $specialFile) {
	my ($code, $lower, $title, $upper, $condition) = @$line;

	# Ignore conditional case-folding.
	next if ($condition);

	$code = hex $code;
	$lower = makeCharSequence $lower;
	$title = makeCharSequence $title;
	$upper = makeCharSequence $upper;

	my @cases = ($upper, $lower, $title);

	@{$special{$code}} = @cases;
}

close $specialFile;

#-------------------------------------------------------------------------------
# Read unicode data
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
	my $cat = $line[2];
	my $info = $categories{$cat}->[categoryFlags];

	my $number = $line[8];
	my $upper = hex ($line[12] or 0);
	my $lower = hex ($line[13] or 0);
	my $title = hex ($line[14] or 0);

	if (exists $useCategories{$cat}) {
		if (exists $specialChars{$code}) {
			$info |= $specialChars{$code};
		}

		$upper = $upper - $code if ($upper);
		$lower = $lower - $code if ($lower);
		$title = $title - $code if ($title);

		if ($number =~ /\//) {
			my ($v1, $v2) = split '/', $number;
			$number = ".numerator = $v1, .denominator = $v2";
			$info |= glyphInfoNumber | glyphInfoFraction;
		}
		elsif ($info & glyphInfoNumber) {
			$number = ".number = $number";
		}
		else {
			$number = 0;
		}

		if (exists $special{$code}) {
			my @cases = @{$special{$code}};

			if ($cases[0] >= 0) {
				$upper = $cases[0];
				$info |= glyphInfoUpperExpands;
			}

			if ($cases[1] >= 0) {
				$lower = $cases[1];
				$info |= glyphInfoLowerExpands;
			}

			if ($cases[2] >= 0) {
				$title = $cases[2];
				$info |= glyphInfoTitleExpands;
			}
		}
	}
	else {
		$info= glyphInfoOther;
		$cat = 'Cn';
		$number = 0;
		$upper = 0;
		$lower = 0;
		$title = 0;
	}

	my $type = getTypeIndex ($info, $categories{$cat}->[categoryIndex], $upper, $lower, $title, $number);

	# Read range.
	if ($line[1] =~ /First>$/i) {
		@line = @{readLine $dataFile};
		my $codeEnd = hex $line[0];

		if ($excludeSurrogates) {
			next if ($cat =~ /Cs/i);
		}

		for (; $code <= $codeEnd; $code++) {
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
# Build pages cache
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
# Print
#-------------------------------------------------------------------------------

my $outName = 'unicode-table';
my @infoKeys = keys %types;
my $infoSize = @infoKeys;
my $pagesSize = keys %pageCache;
my @pageCacheKeys = keys %pageCache;
my $infoType = unsignedTypeFromSize $infoSize;
my $pagesType = unsignedTypeFromSize $pagesSize;
my $specialCasingType = unsignedTypeFromSize (maxValue \@specialCasing);
my @categoryCodes = sort { $categories{$a}->[categoryIndex] <=> $categories{$b}->[categoryIndex] } @categoryKeys;

my %printMethods = ();

my $template = new Template(
	vars => {
		outName => $outName,
		infoType => $infoType,
		pagesType => $pagesType,
		specialCasingType => $specialCasingType,
		infoTableSize => $infoSize,
		pageIndexTableSize => $#pages + 1,
		infoIndexTableSize => $#pageCacheKeys + 1,
		specialCasesTableSize => $#specialCasing + 1,
		categoryNamesTableSize => $#categoryKeys + 1,
	},
	prefix => $prefix,
	makeSnakeCase => $makeSnakeCase,
	printMethods => \%printMethods,
	conditional => sub {
		return exists $conditionalFlags{$_[0]};
	},
);

%printMethods = (
	header => sub {
		my ($out) = @_;

		print $out " * Generated by $0\n";
		print $out " * Unicode version ".unicodeVersion."\n";
		print $out " * https://github.com/detomon/unicode-table\n";
	},
	categories => sub {
		my ($out) = @_;

		foreach (@categoryCodes) {
			my $line = $categories{$_}->[categoryName];
			$line = $template->toConstant($line);
			$line = sprintf "\t%s ///< %s", "$line,", $_;
			$line =~ s/\s+$//;

			print $out "$line\n";
		}
	},
	infos => sub {
		my ($out) = @_;

		foreach (sort { $types{$a} <=> $types{$b} } keys %types) {
			print $out "	$_\n";
		}
	},
	pageIndex => sub {
		my ($out) = @_;
		my $i = 0;

		print $out "\t";

		foreach (@pages) {
			print $out "\n\t" if ($i > 0 && $i % 16 == 0);
			printf $out "%3d,", $_;
			$i++;
		}

		print $out "\n";
	},
	infoIndex => sub {
		my ($out) = @_;
		my $page = 0;

		foreach (sort { $pageCache{$a} <=> $pageCache{$b} } @pageCacheKeys) {
			print $out "\t{" if ($page == 0);
			print $out "\n\t}, {" if ($page > 0);

			my $i = 0;
			foreach (split /,/, $_) {
				print $out "\n\t" if ($i % 16 == 0);
				printf $out "%3d,", $_;
				$i++;
			}

			$page++;
		}

		print $out "\n\t}\n";
	},
	specialCases => sub {
		my ($out) = @_;
		my $line = '';

		foreach (@specialCasing) {
			my $data = sprintf "%d, ", $_;

			if (length($line) + length($data) >= 66) {
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
	categoryNames => sub {
		my ($out) = @_;

		foreach (@categoryCodes) {
			my $name = $categories{$_}->[categoryName];
			$name = $template->toConstant($name);

			printf $out "\t%s = \"%s\",\n", "[$name]", $_;
		}
	},
);

sub main {
	my $headerFileIn = "$outName.h.in";
	my $sourceFileIn = "$outName.c.in";
	my $headerFile = "$outName.h";
	my $sourceFile = "$outName.c";

	open my $headerIn, '<', $headerFileIn or die "File '$headerFileIn' not found";
	open my $sourceIn, '<', $sourceFileIn or die "File '$sourceFileIn' not found";
	open my $headerOut, '>', $headerFile or die "File '$headerFile' not writable";
	open my $sourceOut, '>', $sourceFile or die "File '$sourceFile' not writable";

	$template->readLines($headerIn, $headerOut);
	$template->readLines($sourceIn, $sourceOut);

	close $headerIn;
	close $headerOut;
	close $sourceIn;
	close $sourceOut;

	return 0;
}

exit main @ARGV;
