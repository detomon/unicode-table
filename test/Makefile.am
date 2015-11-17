AM_CFLAGS = -I$(srcdir)/.. -L$(srcdir)/..
LDADD = $(srcdir)/../libunicodetable.a

check_PROGRAMS = \
	test-category \
	test-special

test_category_SOURCES = test-category.c
test_category_LDADD = $(LDADD)

test_special_SOURCES = test-special.c
test_special_LDADD = $(LDADD)

TESTS_ENVIRONMENT = top_builddir=$(top_builddir)
TESTS = \
	test-category \
	test-special
