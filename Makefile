CC            ?= gcc
CFLAGS        ?= -Wall -O2
GENERATOR      = generate.pl
DATA           = UnicodeData.txt SpecialCasing.txt

OUT_NAME      ?= unicode-table
SYMBOL_PREFIX ?= UT
SNAKE_CASE    ?= 0

$(OUT_NAME).o: $(OUT_NAME).h $(OUT_NAME).c
	$(CC) $(CFLAGS) -o $@ -c $<

$(OUT_NAME).h $(OUT_NAME).c: $(DATA)
	export OUT_NAME='$(OUT_NAME)'
	export SYMBOL_PREFIX='$(SYMBOL_PREFIX)'
	export SNAKE_CASE='$(SNAKE_CASE)'
	/usr/bin/env perl $(GENERATOR) $(DATA)

.PHONY: clean
clean:
	rm -f $(OUT_NAME).h $(OUT_NAME).c $(OUT_NAME).o
