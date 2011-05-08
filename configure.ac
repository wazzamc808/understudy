AC_INIT([Understudy], [0.10.1+], [kirk.kelsey@0x4b.net], [],
  [http://code.google.com/p/understudy/])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_SRCDIR([src/UNDAppliance.h])
AC_CONFIG_HEADERS([src/config.h])
AC_LANG(Objective C)
AM_INIT_AUTOMAKE([foreign])

DX_DOXYGEN_FEATURE(ON)
DX_DOT_FEATURE(OFF)
DX_HTML_FEATURE(ON)
DX_CHM_FEATURE(OFF)
DX_CHI_FEATURE(OFF)
DX_MAN_FEATURE(OFF)
DX_RTF_FEATURE(OFF)
DX_XML_FEATURE(OFF)
DX_PDF_FEATURE(OFF)
DX_PS_FEATURE(OFF)
DX_INIT_DOXYGEN([Understudy], [doc/doxygen.cfg])

AC_PROG_OBJC
AC_PROG_RANLIB

AC_CHECK_PROG([HAVE_SCAN_BUILD], [scan-build], [yes])
AM_CONDITIONAL([HAVE_SCAN_BUILD], [test x$HAVE_SCAN_BUILD == xyes])

AC_CONFIG_FILES([Makefile src/Makefile doc/doxygen.cfg])
AC_OUTPUT
