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

package Template;

sub toCamelCase {
	my ($self, $var) = @_;
	my $prefix = $self->{prefix};

	$var = "$prefix$var" if ($prefix);

	$var =~ s/_([a-z])/uc($1)/ge;
	$var =~ s/^(\w)/lc($1)/ge unless ($prefix);

	return $var;
}

sub toSnakeCase {
	my ($self, $var) = @_;
	my $prefix = $self->{prefix};

	$var = "$prefix"."_$var" if ($prefix);

	$var =~ s/([a-z])([A-Z])/"$1_$2"/ge;
	$var = lc $var;

	return $var;
}

sub toUserCase {
	my ($self, $var) = @_;

	if ($self->{makeSnakeCase}) {
		return $self->toSnakeCase($var);
	}
	else {
		return $self->toCamelCase($var);
	}
}

sub toConstant {
	my ($self, $var) = @_;

	$var = uc $self->toSnakeCase($var);

	return $var;
}

sub replaceName {
	my ($self, $type, $name) = @_;
	my %vars = %{$self->{vars}};

	if ($type eq 'n') {
		$name = $self->toUserCase($name);
	}
	elsif ($type eq 'c') {
		$name = $self->toConstant($name);
	}
	elsif ($type eq 'v') {
		$name = $self->{vars} {$name};
	}

	return $name;
}

sub readLine {
	my $self = shift;
	my $line = shift;
	my $out = shift;
	my %methods = %{$self->{printMethods}};
	my $conditions = $self->{conditional};

	if ($line =~ /##([\w_]+)/) {
		my $method = $1;

		unless (exists $methods {$method}) {
			die "Print method '$method' does not exist\n";
		}

		$methods {$method} -> ($out);

		# do not output line
		return 1;
	}
	# handle if:
	elsif ($line =~ /{(if:)([\w_]+)}/) {
		return $conditions -> ($2);
	}
	# ignore endif:
	elsif ($line =~ /{(endif:)([\w_]*)}/) {
		return 1;
	}

	$line =~ s/{((\w+):)([\w_]+)}/$self->replaceName($2, $3)/ge;

	print $out $line;

	return 1;
}

sub readToEndIf {
	my ($self, $file) = @_;

	while (<$file>) {
		return if ($_ =~ /{(endif:)([\w_]*)}/);
	}
}

sub readLines {
	my $self = shift;
	my $infile = shift;
	my $outfile = shift;

	while (<$infile>) {
		if (!$self->readLine($_, $outfile)) {
			$self->readToEndIf($infile);
		}
	}
}

sub new {
	my $class = shift;
	my $self = {
		'vars' => {},
		'prefix' => '',
		'makeSnakeCase' => 0,
		'printMethods' => {},
		'conditional' => sub {},
		# overwrite default values
		@_,
	};

	bless $self, $class;

    return $self;
}

1;
