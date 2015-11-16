CFLAGS        ?= -Wall -O2
GENERATOR      = generate.pl
DATA           = UnicodeData.txt SpecialCasing.txt

OUT_NAME      ?= unicode-table
SYMBOL_PREFIX ?= UT
SNAKE_CASE    ?= 0

TEST_NAME      = unicode-test
TEST_PROG      = test

.PHONY: generate clean test

generate:
	export OUT_NAME='$(OUT_NAME)'
	export SYMBOL_PREFIX='$(SYMBOL_PREFIX)'
	export SNAKE_CASE='$(SNAKE_CASE)'
	/usr/bin/env perl $(GENERATOR) $(DATA)

compile: $(OUT_NAME).c
	$(CC) $(CFLAGS) -o $(OUT_NAME).o -c $<

clean:
	rm -f $(OUT_NAME).h $(OUT_NAME).c $(OUT_NAME).o
	rm -f $(TEST_NAME).h $(TEST_NAME).c $(TEST_NAME).o
	rm -f $(TEST_PROG)

check:
	make generate OUT_NAME=$(TEST_NAME) SYMBOL_PREFIX=UT SNAKE_CASE=0
	make compile OUT_NAME=$(TEST_NAME)
	$(CC) $(CFLAGS) -o $(TEST_PROG) $(TEST_PROG).c $(TEST_NAME).o
	./$(TEST_PROG) $(DATA)
	rm -f $(TEST_NAME).h $(TEST_NAME).c $(TEST_NAME).o
	rm -f $(TEST_PROG)
