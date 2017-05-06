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

use constant unicodeVersion => '9.0.0';
use constant tableSize      => 0x110000;

use constant moLetterGlyphInfo       => 1 << 0;
use constant moUppercaseGlyphInfo    => 1 << 1;
use constant moLowercaseGlyphInfo    => 1 << 2;
use constant moTitlecaseGlyphInfo    => 1 << 3;
use constant moSpaceGlyphInfo        => 1 << 4;
use constant moLinebreakGlyphInfo    => 1 << 5;
use constant moPunctuationGlyphInfo  => 1 << 6;
use constant moDigitGlyphInfo        => 1 << 7;
use constant moNumberGlyphInfo       => 1 << 8;
use constant moFractionGlyphInfo     => 1 << 9;
use constant moControlGlyphInfo      => 1 << 10;
use constant moSymbolGlyphInfo       => 1 << 11;
use constant moOtherGlyphInfo        => 1 << 12;
use constant moUpperExpandsGlyphInfo => 1 << 13;
use constant moLowerExpandsGlyphInfo => 1 << 14;
use constant moTitleExpandsGlyphInfo => 1 << 15;

my %categoryFlags = (
	''   => 0,
	'Lu' => moLetterGlyphInfo | moUppercaseGlyphInfo,
	'Ll' => moLetterGlyphInfo | moLowercaseGlyphInfo,
	'Lt' => moLetterGlyphInfo | moTitlecaseGlyphInfo,
	'Lm' => moLetterGlyphInfo,
	'Lo' => moLetterGlyphInfo,
	'Mn' => moOtherGlyphInfo,
	'Mc' => moOtherGlyphInfo,
	'Me' => moOtherGlyphInfo,
	'Nd' => moLetterGlyphInfo | moDigitGlyphInfo | moNumberGlyphInfo,
	'Nl' => moLetterGlyphInfo | moNumberGlyphInfo,
	'No' => moLetterGlyphInfo | moNumberGlyphInfo,
	'Pc' => moPunctuationGlyphInfo,
	'Pd' => moPunctuationGlyphInfo,
	'Ps' => moPunctuationGlyphInfo,
	'Pe' => moPunctuationGlyphInfo,
	'Pi' => moPunctuationGlyphInfo,
	'Pf' => moPunctuationGlyphInfo,
	'Po' => moPunctuationGlyphInfo,
	'Sm' => moSymbolGlyphInfo,
	'Sc' => moSymbolGlyphInfo,
	'Sk' => moSymbolGlyphInfo,
	'So' => moSymbolGlyphInfo,
	'Zs' => moSpaceGlyphInfo,
	'Zl' => moSpaceGlyphInfo | moLinebreakGlyphInfo,
	'Zp' => moSpaceGlyphInfo | moLinebreakGlyphInfo,
	'Cc' => moControlGlyphInfo,
	'Cf' => moOtherGlyphInfo,
	'Cs' => moOtherGlyphInfo,
	'Co' => moOtherGlyphInfo,
	'Cn' => moOtherGlyphInfo,
);

my %categoryIndexes = (
	''   => 0,
	'Lu' => 1,
	'Ll' => 2,
	'Lt' => 3,
	'Lm' => 4,
	'Lo' => 5,
	'Mn' => 6,
	'Mc' => 7,
	'Me' => 8,
	'Nd' => 9,
	'Nl' => 10,
	'No' => 11,
	'Pc' => 12,
	'Pd' => 13,
	'Ps' => 14,
	'Pe' => 15,
	'Pi' => 16,
	'Pf' => 17,
	'Po' => 18,
	'Sm' => 19,
	'Sc' => 20,
	'Sk' => 21,
	'So' => 22,
	'Zs' => 23,
	'Zl' => 24,
	'Zp' => 25,
	'Cc' => 26,
	'Cf' => 27,
	'Cs' => 28,
	'Co' => 29,
	'Cn' => 30,
);

my %categoryName = (
	'',  => 'CategoryInvalid',
	'Lu' => 'CategoryLetterUppercase',
	'Ll' => 'CategoryLetterLowercase',
	'Lt' => 'CategoryLetterTitlecase',
	'Lm' => 'CategoryLetterModifier',
	'Lo' => 'CategoryLetterOther',
	'Mn' => 'CategoryMarkNonspacing',
	'Mc' => 'CategoryMarkSpacingCombining',
	'Me' => 'CategoryMarkEnclosing',
	'Nd' => 'CategoryNumberDecimalDigit',
	'Nl' => 'CategoryNumberLetter',
	'No' => 'CategoryNumberOther',
	'Pc' => 'CategoryPunctuationConnector',
	'Pd' => 'CategoryPunctuationDash',
	'Ps' => 'CategoryPunctuationOpen',
	'Pe' => 'CategoryPunctuationClose',
	'Pi' => 'CategoryPunctuationInitialQuote',
	'Pf' => 'CategoryPunctuationFinalQuote',
	'Po' => 'CategoryPunctuationOther',
	'Sm' => 'CategorySymbolMath',
	'Sc' => 'CategorySymbolCurrency',
	'Sk' => 'CategorySymbolModifier',
	'So' => 'CategorySymbolOther',
	'Zs' => 'CategorySeparatorSpace',
	'Zl' => 'CategorySeparatorLine',
	'Zp' => 'CategorySeparatorParagraph',
	'Cc' => 'CategoryOtherControl',
	'Cf' => 'CategoryOtherFormat',
	'Cs' => 'CategoryOtherSurrogate',
	'Co' => 'CategoryOtherPrivateUse',
	'Cn' => 'CategoryOtherNotAssigned',
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

my $outName   = 'unicode-table';
my $hdrFile   = "$outName.h";
my $hdrFileIn = "unicode-table.h.in";
my $srcFile   = "$outName.c";
my $srcFileIn = "unicode-table.c.in";

my $args = join ' ', @ARGV;
my $prefix = 'UT';
my $makeSnakeCase = 0;
my $useCategories = 0;
my %useCategories = ();
my $includeInfos = 'flags,categories,casing,numbers';
my %includeInfos = ();
my $excludeSurrogates = 0;
my %conditionalFlags = ();

if ($args =~ /--symbol-prefix=([\w_]+)/) {
	$prefix = $1;
}

if ($args =~ /--snake-case=(\d+)/) {
	$makeSnakeCase = int $1;
}

if ($args =~ /--categories=([\w_,]+)/) {
	foreach (split /,/, $1) {
		$useCategories {$_} = 1;
	}

	$useCategories = 1;
}

if ($args =~ /--include-info=([\w_,]+)/) {
	$includeInfos = $1;
}

if ($args =~ /--strict-level=(\d+)/) {
	$excludeSurrogates = int $1 > 0;
}

# full format: '{%1$5d,%2$3d,{%3$6d,%4$6d,%5$6d}, {%6$s}},'
my $infoFormat = '';
my %infoFormat = ();
my @infoFormat = ();

foreach (split /,/, $includeInfos) {
	$infoFormat {$_} = 1;
}

if (exists $infoFormat {'flags'}) {
	push @infoFormat, '%1$5d';
	$conditionalFlags {'addFlags'} = 1;
}

if (exists $infoFormat {'categories'}) {
	push @infoFormat, '%2$3d';
	$conditionalFlags {'addCategories'} = 1;
}

if (exists $infoFormat {'casing'}) {
	push @infoFormat, '{%3$6d,%4$6d,%5$6d}';
	$conditionalFlags {'addCasing'} = 1;
}

if (exists $infoFormat {'numbers'}) {
	push @infoFormat, ' {%6$s}';
	$conditionalFlags {'addNumbers'} = 1;
}

$infoFormat = (join ',', @infoFormat);
$infoFormat =~ s/^\s+|\s+$//g;
$infoFormat = "{$infoFormat},";

#-------------------------------------------------------------------------------
#
# Prepare tables
#
#-------------------------------------------------------------------------------

my @data           = (0 .. (tableSize - 1));
my %special        = ();
my %types          = (sprintf ($infoFormat, 0, 0, 0, 0, 0, 0) => 0);
my @pages          = (0 .. (tableSize >> 8) - 1);
my %pageCache      = ();
my @specialCasing  = ();

for (my $i = 0; $i < tableSize; $i ++) {
	$data [$i] = 0;
}

for (my $i = 0; $i < tableSize >> 8; $i ++) {
	$pages [$i] = 0;
}

my @emptyPage = (0 .. 255);

for (my $i = 0; $i < 256; $i ++) {
	$emptyPage [$i] = 0;
}

$pageCache {join ',', @emptyPage} = 0;

#-------------------------------------------------------------------------------
#
# Functions
#
#-------------------------------------------------------------------------------

sub makeCharSequence {
	my $codes = shift;

	$codes =~/\s*(.+)\s*/;

	my @sequence = split /\s+/, $1;
	my $offset   = $#specialCasing + 1;

	# ignore single glyph
	return -1 if ($#sequence == 0);

	push @specialCasing, $#sequence + 1;
	push @specialCasing, hex ($_) foreach (@sequence);

	return $offset;
}

sub getTypeIndex {
	my $info = shift;
	my $catIdx = shift;
	my $upper = shift;
	my $lower = shift;
	my $title = shift;
	my $number = shift;

	my $type = sprintf ($infoFormat, $info, $catIdx, $upper, $lower, $title, $number);

	if ($types {$type}) {
		$type = $types {$type};
	}
	else {
		my $count = keys %types;

		$types {$type} = $count;
		$type = $count;
	}

	return $type;
}

#-------------------------------------------------------------------------------
#
# Read special cases
#
#-------------------------------------------------------------------------------

open SPECIAL, "<$ARGV[1]" or die "File '$ARGV[1]' not found";

while (<SPECIAL>) {
	chomp;

	# ignore empty lines and comments
	next if ($_ =~ /^$|^#/);

	$_ =~ /(.+);\s*#/;

	my @line = split ';', $1;

	# ignore conditional case-folding
	next if ($line [4]);

	my $code  = hex ($line [0]);
	my $lower = makeCharSequence $line [1];
	my $title = makeCharSequence $line [2];
	my $upper = makeCharSequence $line [3];

	my @cases = ($upper, $lower, $title);

	@{$special {$code}} = @cases;

	@line = split ';', $_;
}

close SPECIAL;

#-------------------------------------------------------------------------------
#
# Read unicode data
#
#-------------------------------------------------------------------------------

my %specialChars = (
	0x0009 => moSpaceGlyphInfo,                        # CHARACTER TABULATION
	0x000A => moSpaceGlyphInfo | moLinebreakGlyphInfo, # LINE FEED (LF)
	0x000B => moSpaceGlyphInfo,                        # LINE TABULATION
	0x000C => moSpaceGlyphInfo,                        # FORM FEED (FF)
	0x000D => moSpaceGlyphInfo | moLinebreakGlyphInfo, # CARRIAGE RETURN (CR)
	0xFEFF => moSpaceGlyphInfo,                        # ZERO WIDTH NO-BREAK SPACE (BYTE ORDER MARK)
);

open DATA, "<$ARGV[0]" or die "File '$ARGV[0]' not found";

while (<DATA>) {
	chomp;

	my @line = split /;/, $_;
	my $code = hex ($line [0]);
	my $cat  = $line [2];
	my $info = $categoryFlags {$cat};

	my $number = $line [8];
	my $upper  = hex ($line [12] || 0);
	my $lower  = hex ($line [13] || 0);
	my $title  = hex ($line [14] || 0);

	if ($useCategories && !$useCategories {$cat}) {
		$info   = moOtherGlyphInfo;
		$cat    = 'Cn';
		$number = 0;
		$upper  = 0;
		$lower  = 0;
		$title  = 0;
	}
	else {
		if ($specialChars {$code}) {
			$info |= $specialChars {$code};
		}

		$upper = $upper - $code if ($upper);
		$lower = $lower - $code if ($lower);
		$title = $title - $code if ($title);

		if ($number =~ /\//) {
			my ($v1, $v2) = split '/', $number;

			$number = ".frac=\"$v1/$v2\"";
			$info |= moFractionGlyphInfo;
		}
		elsif ($info & moNumberGlyphInfo) {
			$number = int ($number);
		}
		else {
			$number = 0;
		}

		if ($special {$code}) {
			my @cases = @{$special {$code}};

			if ($cases [0] != -1) {
				$upper = $cases [0];
				$info |= moUpperExpandsGlyphInfo;
			}

			if ($cases [1] != -1) {
				$lower = $cases [1];
				$info |= moLowerExpandsGlyphInfo;
			}

			if ($cases [2] != -1) {
				$title = $cases [2];
				$info |= moTitleExpandsGlyphInfo;
			}
		}
	}

	my $type = getTypeIndex ($info, $categoryIndexes {$cat}, $upper, $lower, $title, $number);

	# read range
	if ($line [1] =~ /First>$/i) {
		$_ = <DATA>;
		chomp;

		my @line2 = split /;/, $_;
		my $code2 = hex ($line2 [0]);

		if ($excludeSurrogates) {
			if ($cat =~ /Cs/i) {
				next;
			}
		}

		for (; $code <= $code2; $code ++) {
			$pages [$code >> 8] = 1;
			$data [$code] = $type;
		}
	}
	else {
		$pages [$code >> 8] = 1;
		$data [$code] = $type;
	}
}

close DATA;

#-------------------------------------------------------------------------------
#
# Build pages cache
#
#-------------------------------------------------------------------------------

my $cacheCount = 1;

for (my $i = 0; $i <= $#pages; $i ++) {
	next unless ($pages [$i]);

	my $index = 0;
	my $page  = join ',',  @data [($i << 8) .. ((($i + 1) << 8) - 1)];

	if ($pageCache {$page}) {
		$index = $pageCache {$page};
	}
	else {
		$index = $cacheCount ++;
		$pageCache {$page} = $index;
	}

	$pages [$i] = $index;
}

#-------------------------------------------------------------------------------
#
# Print
#
#-------------------------------------------------------------------------------

my %printMethods = (
	'header' => sub {
		my $out = shift;

		print $out " * Generated by $0\n";
		print $out " * Unicode version ".unicodeVersion."\n";
		print $out " * https://github.com/detomon/unicode-table\n";
	},
	'categories' => sub {
		my $out = shift;

		foreach (sort { $categoryIndexes {$a} <=> $categoryIndexes {$b} } keys %categoryIndexes) {
			my $line = $categoryName {$_};

			$line = Template::toConstant $line;
			$line = sprintf "\t%-39s ///< %s", "$line,", $_;
			$line =~ s/\s+$//;

			print $out "$line\n";
		}
	},
	'infos' => sub {
		my $out = shift;

		foreach (sort { $types {$a} <=> $types {$b} } keys %types) {
			print $out "	$_\n";
		}
	},
	'pageIndex' => sub {
		my $out = shift;
		my $i = 0;
		my $p = 0;

		print $out "\t";

		foreach (@pages) {
			print $out "\n\t" if ($i > 0 && $i % 16 == 0);
			printf $out "%3d,", $_;

			$i ++;
		}

		print $out "\n";
	},
	'infoIndex' => sub {
		my $out = shift;
		my $p = 0;
		my $i = 0;

		foreach (sort { $pageCache {$a} <=> $pageCache {$b} } keys %pageCache) {
			print $out "\t{" if ($p == 0);
			print $out "\n\t}, {" if ($p > 0);

			foreach (split /,/, $_) {
				print $out "\n\t" if ($i % 16 == 0);
				printf $out "%3d,", $_;

				$i ++;
			}

			$p ++;
		}

		print $out "\n\t}\n";
	},
	'specialCases' => sub {
		my $out = shift;
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
		my $out = shift;

		foreach (sort { $categoryIndexes {$a} <=> $categoryIndexes {$b} } keys %categoryIndexes) {
			my $key = $categoryName {$_};

			$key = Template::toConstant $key;

			printf $out "\t%-39s = \"%s\",\n", "[$key]", $_;
		}
	},
);

open my $hdrin,  "<$hdrFileIn" or die "File '$hdrFileIn' not found";
open my $hdrout, ">$hdrFile" or die "File '$hdrFile' not found";

open my $srcin,  "<$srcFileIn" or die "File '$srcFileIn' not found";
open my $srcout, ">$srcFile" or die "File '$srcFile' not found";

my @infoKeys  = keys %types;
my $infoSize  = @infoKeys;
my $pagesSize = @pages;

my %vars = (
	'outName'   => $outName,
	'infoType'  => $infoSize >= 256 ? 'uint16_t' : 'uint8_t',
	'pagesType' => $pagesSize >= 256 ? 'uint16_t' : 'uint8_t',
);

%Template::vars = %vars;
$Template::prefix = $prefix;
$Template::makeSnakeCase = $makeSnakeCase;

Template::readLines $hdrin, $hdrout, \%printMethods, sub {
	my $name = shift;

	return exists $conditionalFlags {$name};
};

Template::readLines $srcin, $srcout, \%printMethods, sub {
	my $name = shift;

	return exists $conditionalFlags {$name};
};

close $hdrin;
close $hdrout;

close $srcin;
close $srcout;
