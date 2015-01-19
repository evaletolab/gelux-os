
AC_DEFUN([JG_PARTED_JAVA],[

PKG_CHECK_MODULES(PARTEDJAVA, parted-java >= $1)

if test -z "$PKG_CONFIG"; then
    AC_PATH_PROG(PKG_CONFIG, pkg-config, no)
fi

AC_MSG_CHECKING(for parted-java api version)
partedapiversion=`$PKG_CONFIG --variable api_version parted-java`
AC_MSG_RESULT($partedapiversion)
AC_SUBST(partedapiversion)

AC_MSG_CHECKING(for parted-java jar file)
PARTEDJAR=`$PKG_CONFIG --variable classpath parted-java`
AC_MSG_RESULT($PARTEDJAR)
AC_SUBST(PARTEDJAR)

dnl PARTEDJAVA_MACROS=`$PKG_CONFIG --variable macro_dir parted-java`

AC_MSG_CHECKING(for parted-java library)
PARTEDJAVA_LIBS=`$PKG_CONFIG --libs parted-java`
AC_MSG_RESULT($PARTEDJAVA_LIBS)
AC_SUBST(PARTEDJAVA_LIBS)

AC_MSG_CHECKING(for parted-java cflags)
PARTEDJAVA_CFLAGS=`$PKG_CONFIG --cflags parted-java`
AC_MSG_RESULT($partedJAVA_CFLAGS)
AC_SUBST(PARTEDJAVA_CFLAGS)

])
