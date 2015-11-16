#SUBDIRS = test
#DIST_SUBDIRS = $(SUBDIRS)

BUILT_SOURCES = unicode-table.h unicode-table.c

$(BUILT_SOURCES): generate.pl unicode-table.h.in unicode-table.c.in
	$(srcdir)/generate.pl UnicodeData.txt SpecialCasing.txt

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
