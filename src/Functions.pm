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
	my $prefix = shift;
	my $makeSnakeCase = shift;

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

1;
