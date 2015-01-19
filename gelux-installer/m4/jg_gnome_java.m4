
AC_DEFUN([JG_GNOME_JAVA],[

PKG_CHECK_MODULES(GNOMEJAVA, gnome2-java >= $1)

if test -z "$PKG_CONFIG"; then
    AC_PATH_PROG(PKG_CONFIG, pkg-config, no)
fi

AC_MSG_CHECKING(for gnome-java api version)
gnomeapiversion=`$PKG_CONFIG --variable api_version gnome2-java`
AC_MSG_RESULT($gnomeapiversion)
AC_SUBST(gnomeapiversion)

AC_MSG_CHECKING(for gnome-java jar file)
GNOMEJAR=`$PKG_CONFIG --variable classpath gnome2-java`
AC_MSG_RESULT($GNOMEJAR)
AC_SUBST(GNOMEJAR)

dnl GTKJAVA_MACROS=`$PKG_CONFIG --variable macro_dir gtk2-java`

AC_MSG_CHECKING(for gnome-java library)
GNOMEJAVA_LIBS=`$PKG_CONFIG --libs gnome2-java`
GNOMEJAVA_LIBS=-lgnomejar2.8
AC_MSG_RESULT($GNOMEJAVA_LIBS)
AC_SUBST(GNOMEJAVA_LIBS)

])
