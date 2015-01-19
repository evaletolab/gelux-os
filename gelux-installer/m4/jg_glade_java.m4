
AC_DEFUN([JG_GLADE_JAVA],[

PKG_CHECK_MODULES(GLADEJAVA, glade-java >= $1)

if test -z "$PKG_CONFIG"; then
    AC_PATH_PROG(PKG_CONFIG, pkg-config, no)
fi

AC_MSG_CHECKING(for glade-java api version)
gladeapiversion=`$PKG_CONFIG --variable api_version glade-java`
AC_MSG_RESULT($gladeapiversion)
AC_SUBST(gladeapiversion)

AC_MSG_CHECKING(for glade-java jar file)
GLADEJAR=`$PKG_CONFIG --variable classpath glade-java`
AC_MSG_RESULT($GLADEJAR)
AC_SUBST(GLADEJAR)

dnl GLADEJAVA_MACROS=`$PKG_CONFIG --variable macro_dir glade-java`

AC_MSG_CHECKING(for glade-java library)
GLADEJAVA_LIBS=`$PKG_CONFIG --libs glade-java`
GLADEJAVA_LIBS=-lgladejar2.8
AC_MSG_RESULT($GLADEJAVA_LIBS)
AC_SUBST(GLADEJAVA_LIBS)

AC_MSG_CHECKING(for glade-java cflags)
GLADEJAVA_CFLAGS=`$PKG_CONFIG --cflags glade-java`

AC_MSG_RESULT($GLADEJAVA_CFLAGS)
AC_SUBST(GLADEJAVA_CFLAGS)

AC_MSG_CHECKING(for glade-java jni library)
GLADEJNI_LIBS=`$PKG_CONFIG --variable jnilibs glade-java`
AC_MSG_RESULT($GLADEJNI_LIBS)
GLADEJNI_LIBS=-lgladejava2.8
AC_SUBST(GLADEJNI_LIBS)

])
