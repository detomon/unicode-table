#SUBDIRS = test
#DIST_SUBDIRS = $(SUBDIRS)

UNICODE_FILES = UnicodeData.txt SpecialCasing.txt
SRC_TEMPLATES = unicode-table.h.in unicode-table.c.in
GENERATE_PROG = generate.pl

BUILT_SOURCES = unicode-table.h unicode-table.c

$(BUILT_SOURCES): $(GENERATE_PROG) $(UNICODE_FILES) $(SRC_TEMPLATES)
	/usr/bin/env perl $(srcdir)/$(GENERATE_PROG) $(UNICODE_FILES) --symbol-prefix=@SYMBOL_PREFIX@ -snake-case=@SNAKE_CASE@

lib_LIBRARIES = libunicodetable.a

libunicodetable_a_SOURCES = \
	unicode-table.c

HEADER_LIST = \
	unicode-table.h

pkginclude_HEADERS = $(HEADER_LIST)

EXTRA_DIST = \
	README.md \
	LICENSE \
	VERSION

clean-local:
	-rm -f $(BUILT_SOURCES)
