
AC_DEFUN([JG_GTK_JAVA],[

PKG_CHECK_MODULES(GTKJAVA, gtk2-java >= $1)

if test -z "$PKG_CONFIG"; then
    AC_PATH_PROG(PKG_CONFIG, pkg-config, no)
fi

AC_MSG_CHECKING(for gtk-java api version)
gtkapiversion=`$PKG_CONFIG --variable api_version gtk2-java`
AC_MSG_RESULT($gtkapiversion)
AC_SUBST(gtkapiversion)

AC_MSG_CHECKING(for gtk-java jar file)
GTKJAR=`$PKG_CONFIG --variable classpath gtk2-java`
AC_MSG_RESULT($GTKJAR)
AC_SUBST(GTKJAR)

dnl GTKJAVA_MACROS=`$PKG_CONFIG --variable macro_dir gtk2-java`

AC_MSG_CHECKING(for gtk-java library)
GTKJAVA_LIBS=`$PKG_CONFIG --libs gtk2-java`

GTKJAVA_LIBS=-lgtkjar2.4

AC_MSG_RESULT($GTKJAVA_LIBS)
AC_SUBST(GTKJAVA_LIBS)

AC_MSG_CHECKING(for gtk-java cflags)
GTKJAVA_CFLAGS=`$PKG_CONFIG --cflags gtk2-java`
AC_MSG_RESULT($GTKJAVA_CFLAGS)
AC_SUBST(GTKJAVA_CFLAGS)

AC_MSG_CHECKING(for gtk-java jni library)
GTKJNI_LIBS=`$PKG_CONFIG --variable jnilibs gtk2-java`
AC_MSG_RESULT($GTKJNI_LIBS)
AC_SUBST(GTKJNI_LIBS)

])
