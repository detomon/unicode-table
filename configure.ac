#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.63])
AC_INIT([unicode-table], [0.1], [simon@monoxid.net], [unicode-table], [https://github.com/detomon/unicode-table])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

# Checks for programs.
AC_PROG_CC
AC_PROG_RANLIB
m4_ifdef([AM_PROG_AR], [AM_PROG_AR])

# Checks for header files.
AC_CHECK_HEADERS([stdint.h stdlib.h string.h])

AC_ARG_ENABLE([symbol-prefix],
	[  --disable-symbol-prefix use default symbol prefix],
	[SYMBOL_PREFIX=${enableval}],
	[SYMBOL_PREFIX='UT'])

AC_ARG_ENABLE([snake-case],
	[  --disable-snake-case    use camel-case symbols],
	[SNAKE_CASE=${enableval}],
	[SNAKE_CASE=0])

if test "x${SNAKE_CASE}" = xyes; then
	SNAKE_CASE=1
fi

if test "x${SNAKE_CASE}" = xno; then
	SNAKE_CASE=0
fi

AC_SUBST([SYMBOL_PREFIX])
AC_SUBST([SNAKE_CASE])

# Checks for typedefs, structures, and compiler characteristics.
AC_C_INLINE
AC_TYPE_INT32_T
AC_TYPE_INT64_T
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T

AC_CONFIG_FILES([
	Makefile
	src/Makefile
	test/Makefile
])

# Flags
CFLAGS="$CFLAGS -std=c99 -Wall"

AC_OUTPUT
