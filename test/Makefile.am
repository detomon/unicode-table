AM_CFLAGS = -I$(srcdir)/../src -L$(srcdir)/../src
LDADD = $(srcdir)/../src/libunicodetable.a

check_PROGRAMS = \
	test-category \
	test-special \
	test-case-expanding \
	test-numbers

test_category_SOURCES = test-category.c

test_special_SOURCES = test-special.c

test_case_expanding_SOURCES = test-case-expanding.c

test_numbers_SOURCES = test-numbers.c

TESTS_ENVIRONMENT = top_builddir=$(top_builddir)
TESTS = \
	test-category \
	test-special \
	test-case-expanding \
	test-numbers
