#!/usr/bin/env perl

# Copyright (c) 2015 Simon Schoenenberger
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

#-------------------------------------------------------------------------------
#
# Unicode definitions
#
#-------------------------------------------------------------------------------

use constant unicodeVersion => '8.0.0';
use constant tableSize      => 0x110000;
use constant infoFormat     => "{%5d,%3d,{%6d,%6d,%6d}, {%s}},";

use constant moLetterRuneInfo       => 1 << 0;
use constant moUppercaseRuneInfo    => 1 << 1;
use constant moLowercaseRuneInfo    => 1 << 2;
use constant moTitlecaseRuneInfo    => 1 << 3;
use constant moSpaceRuneInfo        => 1 << 4;
use constant moLinebreakRuneInfo    => 1 << 5;
use constant moPunctuationRuneInfo  => 1 << 6;
use constant moDigitRuneInfo        => 1 << 7;
use constant moNumberRuneInfo       => 1 << 8;
use constant moFractionRuneInfo     => 1 << 9;
use constant moControlRuneInfo      => 1 << 10;
use constant moSymbolRuneInfo       => 1 << 11;
use constant moOtherRuneInfo        => 1 << 12;
use constant moUpperExpandsRuneInfo => 1 << 13;
use constant moLowerExpandsRuneInfo => 1 << 14;
use constant moTitleExpandsRuneInfo => 1 << 15;

my %flagNames = (
	moLetterRuneInfo       => 'moLetterRuneInfo',
	moUppercaseRuneInfo    => 'moUppercaseRuneInfo',
	moLowercaseRuneInfo    => 'moLowercaseRuneInfo',
	moTitlecaseRuneInfo    => 'moTitlecaseRuneInfo',
	moSpaceRuneInfo        => 'moSpaceRuneInfo',
	moLinebreakRuneInfo    => 'moLinebreakRuneInfo',
	moPunctuationRuneInfo  => 'moPunctuationRuneInfo',
	moDigitRuneInfo        => 'moDigitRuneInfo',
	moNumberRuneInfo       => 'moNumberRuneInfo',
	moFractionRuneInfo     => 'moFractionRuneInfo',
	moControlRuneInfo      => 'moControlRuneInfo',
	moSymbolRuneInfo       => 'moSymbolRuneInfo',
	moOtherRuneInfo        => 'moOtherRuneInfo',
	moUpperExpandsRuneInfo => 'moUpperExpandsRuneInfo',
	moLowerExpandsRuneInfo => 'moLowerExpandsRuneInfo',
	moTitleExpandsRuneInfo => 'moTitleExpandsRuneInfo',
);

my %categoryFlags = (
	''   => 0,
	'Lu' => moLetterRuneInfo | moUppercaseRuneInfo,
	'Ll' => moLetterRuneInfo | moLowercaseRuneInfo,
	'Lt' => moLetterRuneInfo | moTitlecaseRuneInfo,
	'Lm' => moLetterRuneInfo,
	'Lo' => moLetterRuneInfo,
	'Mn' => moOtherRuneInfo,
	'Mc' => moOtherRuneInfo,
	'Me' => moOtherRuneInfo,
	'Nd' => moLetterRuneInfo | moDigitRuneInfo | moNumberRuneInfo,
	'Nl' => moLetterRuneInfo | moNumberRuneInfo,
	'No' => moLetterRuneInfo | moNumberRuneInfo,
	'Pc' => moPunctuationRuneInfo,
	'Pd' => moPunctuationRuneInfo,
	'Ps' => moPunctuationRuneInfo,
	'Pe' => moPunctuationRuneInfo,
	'Pi' => moPunctuationRuneInfo,
	'Pf' => moPunctuationRuneInfo,
	'Po' => moPunctuationRuneInfo,
	'Sm' => moSymbolRuneInfo,
	'Sc' => moSymbolRuneInfo,
	'Sk' => moSymbolRuneInfo,
	'So' => moSymbolRuneInfo,
	'Zs' => moSpaceRuneInfo,
	'Zl' => moSpaceRuneInfo | moLinebreakRuneInfo,
	'Zp' => moSpaceRuneInfo | moLinebreakRuneInfo,
	'Cc' => moControlRuneInfo,
	'Cf' => moOtherRuneInfo,
	'Cs' => moOtherRuneInfo,
	'Co' => moOtherRuneInfo,
	'Cn' => moOtherRuneInfo,
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
	'',  => 'CategoryLetterInvalid',
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

my $outName       = $ENV {'OUT_NAME'}      || 'unicode-table';
my $prefix        = $ENV {'SYMBOL_PREFIX'} || 'UT';
my $makeSnakeCase = $ENV {'SNAKE_CASE'}    || 0;

my $hdrFile   = "$outName.h";
my $hdrFileIn = "unicode-table.h.in";
my $srcFile   = "$outName.c";
my $srcFileIn = "unicode-table.c.in";

#-------------------------------------------------------------------------------
#
# Check arguments
#
#-------------------------------------------------------------------------------

if (($#ARGV + 1) < 2) {
	print "usage $0 UnicodeData.txt SpecialCasing.txt\n";
	exit 1;
}

#-------------------------------------------------------------------------------
#
# Prepare tables
#
#-------------------------------------------------------------------------------

my @data          = (0 .. (tableSize - 1));
my %special       = ();
my %types         = (sprintf (infoFormat, 0, 0, 0, 0, 0, 0) => 0);
my @pages         = (0 .. (tableSize >> 8) - 1);
my %pageCache     = ();
my @specialCasing = ();

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

sub toCamelCase {
	my $var = shift;
	my $prefix = shift;

	$var = "$prefix$var" if ($prefix);

	$var =~ s/_([a-z])/uc($1)/ge;
	$var =~ s/^(\w)/lc($1)/ge unless ($prefix);

	return $var;
}

sub toSnakeCase {
	my $var = shift;
	my $prefix = shift;

	$var = "$prefix"."_$var" if ($prefix);

	$var =~ s/([a-z])([A-Z])/"$1_$2"/ge;
	$var = lc $var;

	return $var;
}

sub toUserCase {
	my $var = shift;

	if ($makeSnakeCase) {
		return toSnakeCase $var, $prefix;
	}
	else {
		return toCamelCase $var, $prefix;
	}
}

sub toConstant {
	my $var = shift;
	my $prefix = shift;

	$var = "$prefix"."_$var" if ($prefix);

	$var = uc (toSnakeCase $var);

	return $var;
}

sub makeCharSequence {
	my $codes = shift;

	$codes =~/\s*(.+)\s*/;

	my @sequence = split /\s+/, $1;
	my $offset   = $#specialCasing + 1;

	# ignore single character
	return -1 if ($#sequence == 0);

	push @specialCasing, $#sequence + 1;
	push @specialCasing, hex ($_) foreach (@sequence);

	return $offset;
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
	0x0009 => moSpaceRuneInfo,                       # CHARACTER TABULATION
	0x000A => moSpaceRuneInfo | moLinebreakRuneInfo, # LINE FEED (LF)
	0x000B => moSpaceRuneInfo,                       # LINE TABULATION
	0x000C => moSpaceRuneInfo,                       # FORM FEED (FF)
	0x000D => moSpaceRuneInfo | moLinebreakRuneInfo, # CARRIAGE RETURN (CR)
	0xFEFF => moSpaceRuneInfo,                       # ZERO WIDTH NO-BREAK SPACE (BYTE ORDER MARK)
);

open DATA, "<$ARGV[0]" or die "File '$ARGV[0]' not found";

while (<DATA>) {
	chomp;

	my @line = split /;/, $_;
	my $code = hex ($line [0]);
	my $cat  = $line [2];
	my $info = $categoryFlags {$cat};

	if (exists $specialChars {$code}) {
		$info |= $specialChars {$code};
	}

	$pages [$code >> 8] = 1;

	my $upper = hex ($line [12]);
	my $lower = hex ($line [13]);
	my $title = hex ($line [14]);

	$upper = $upper - $code if ($upper);
	$lower = $lower - $code if ($lower);
	$title = $title - $code if ($title);

	my $number = $line [8];

	if ($number =~ /\//) {
		my ($v1, $v2) = split '/', $number;

		$number = ".s=\"$v1/$v2\"";
		$info |= moFractionRuneInfo;
	}
	elsif ($info & moNumberRuneInfo) {
		$number = int ($number);
	}
	else {
		$number = 0;
	}

	if ($special {$code}) {
		my @cases = @{$special {$code}};

		if ($cases [0] != -1) {
			$upper = $cases [0];
			$info |= moUpperExpandsRuneInfo;
		}

		if ($cases [1] != -1) {
			$lower = $cases [1];
			$info |= moLowerExpandsRuneInfo;
		}

		if ($cases [2] != -1) {
			$title = $cases [2];
			$info |= moTitleExpandsRuneInfo;
		}
	}

	my $type = sprintf (infoFormat, $info, $categoryIndexes {$cat}, $upper, $lower, $title, $number);

	if ($types {$type}) {
		$type = $types {$type};
	}
	else {
		my $count = keys %types;

		$types {$type} = $count;
		$type = $count;
	}

	$data [$code] = $type;

	# read private use pages
	if ($code >= 0xF0000) {
		while (<DATA>) {
			my @line2 = split /;/, $_;
			my $code2 = hex ($line2 [0]);

			my $type = sprintf (infoFormat, $info, $categoryIndexes {$cat}, 0, 0, 0, 0);

			if ($types {$type}) {
				$type = $types {$type};
			}
			else {
				my $count = keys %types;

				$types {$type} = $count;
				$type = $count;
			}

			for (; $code <= $code2; $code ++) {
				$pages [$code >> 8] = 1;
				$data [$code] = $type;
			}

			my $line = <DATA>;

			last unless ($line);

			@line = split /;/, $line;
			$code = hex ($line [0]);
			$cat  = $line [2];
			$info = $categoryFlags {$cat};
		}

		last;
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

open my $hdrin,  "<$hdrFileIn" or die "File '$hdrFileIn' not found";
open my $hdrout, ">$hdrFile" or die "File '$hdrFile' not found";

open my $srcin,  "<$srcFileIn" or die "File '$srcFileIn' not found";
open my $srcout, ">$srcFile" or die "File '$srcFile' not found";

my %vars = (
	'prefix'  => $prefix,
	'outName' => $outName,
);

my %printMethods = (
	'header' => sub {
		my $out = shift;

		print $out " * Generated by $0\n";
		print $out " * Unicode version ".unicodeVersion."\n";
	},
	'categories' => sub {
		my $out = shift;

		foreach (sort { $categoryIndexes {$a} <=> $categoryIndexes {$b} } keys %categoryIndexes) {
			my $line = $categoryName {$_};

			$line = toUserCase $line;
			$line = sprintf "\t%-39s // %s", "$line,", $_;
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

			$key = toUserCase $key;

			printf $out "\t%-39s = \"%s\",\n", "[$key]", $_;
		}
	},
);

sub replaceName {
	my $type = shift;
	my $name = shift;

	if ($type eq 'n') {
		$name = toUserCase $name;
	}
	elsif ($type eq 'c') {
		$name = toConstant $name, $prefix;
	}
	elsif ($type eq 'v') {
		$name = $vars {$name};
	}

	return $name;
}

sub handleLine {
	my $line = shift;
	my $out = shift;

	if ($line =~ /##([\w_]+)/) {
		my $method = $1;

		die "Print method '$method' does not exist" unless (exists $printMethods {$method});

		$printMethods {$method} -> ($out);
		next;
	}

	$line =~ s/{((\w+):)([\w_]+)}/replaceName($2, $3)/ge;

	print $out $line;

}

while (<$hdrin>) {
	handleLine $_, $hdrout;
}

while (<$srcin>) {
	handleLine $_, $srcout;
}

close $hdrin;
close $hdrout;

close $srcin;
close $srcout;
