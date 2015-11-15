CFLAGS        ?= -Wall -O2
GENERATOR      = generate.pl
DATA           = UnicodeData.txt SpecialCasing.txt

OUT_NAME      ?= unicode-table
SYMBOL_PREFIX ?= UT
SNAKE_CASE    ?= 0

.PHONY: generate clean

generate:
	export OUT_NAME='$(OUT_NAME)'
	export SYMBOL_PREFIX='$(SYMBOL_PREFIX)'
	export SNAKE_CASE='$(SNAKE_CASE)'
	/usr/bin/env perl $(GENERATOR) $(DATA)

compile: $(OUT_NAME).c
	$(CC) $(CFLAGS) -o $(OUT_NAME).o -c $<

clean:
	rm -f $(OUT_NAME).h $(OUT_NAME).c $(OUT_NAME).o
