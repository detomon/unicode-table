#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.63])
AC_INIT([unicode-table], [0.3.1], [simon@monoxid.net], [unicode-table], [https://github.com/detomon/unicode-table])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

# Checks for programs.
AC_PROG_CC
AC_PROG_RANLIB
m4_ifdef([AM_PROG_AR], [AM_PROG_AR])

# Checks for header files.
AC_CHECK_HEADERS([stdint.h stdlib.h string.h])

if test "x${UT_SYMBOL_PREFIX}" = x; then
	UT_SYMBOL_PREFIX="UT"
fi

if test "x${UT_SNAKE_CASE}" = x; then
	UT_SNAKE_CASE=0
fi

if test "x${UT_CATEGORIES}" = x; then
	UT_CATEGORIES=""
fi

if test "x${UT_INCLUDE_INFO}" = x; then
	UT_INCLUDE_INFO=""
fi

AC_ARG_ENABLE([symbol-prefix],
	[  --disable-symbol-prefix use default symbol prefix],
	[UT_SYMBOL_PREFIX=${enableval}],
	[])

AC_ARG_ENABLE([snake-case],
	[  --disable-snake-case    use camel-case symbols],
	[UT_SNAKE_CASE=${enableval}],
	[])

AC_ARG_ENABLE([categories],
	[  --disable-categories    only include certain character categories],
	[UT_CATEGORIES=${enableval}],
	[])

AC_ARG_ENABLE([include-info],
	[  --disable-include-info  only include certain character information],
	[UT_INCLUDE_INFO=${enableval}],
	[])

if test "x${SNAKE_CASE}" = xyes; then
	UT_SNAKE_CASE=1
fi

if test "x${SNAKE_CASE}" = xno; then
	UT_SNAKE_CASE=0
fi

AC_SUBST([UT_SYMBOL_PREFIX])
AC_SUBST([UT_SNAKE_CASE])
AC_SUBST([UT_CATEGORIES])
AC_SUBST([UT_INCLUDE_INFO])

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
