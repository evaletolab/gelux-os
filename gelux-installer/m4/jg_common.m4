AC_DEFUN([JG_COMMON],[

dnl dependencies needed by most projects

dnl check to see if the user wants to generate javadoc
AC_ARG_WITH(javadocs,[  --without-javadocs    Do not build the javadocs for the bindings],
        javadocs="no", javadocs="yes")
AM_CONDITIONAL(BUILD_JAVADOC, test $javadocs = "yes")

AC_ARG_WITH([jardir], AS_HELP_STRING([--with-jardir],
		      [where to install jar files]),
            [jardir="$with_jardir"], [jardir="${datadir}/java"])
AC_SUBST(jardir)

dnl Checks for programs.
AC_PROG_CC
AC_PROG_INSTALL
AM_PATH_DOCBOOK
AC_PROG_JAVAC
if test $javadocs = "yes"; then
	AC_PROG_JAVADOC
fi
AC_PROG_JAR
 
JG_CHECK_NATIVECOMPILE

dnl Check to see what platform and set jni include path
dnl AC_CANONICAL_HOST
AC_MSG_CHECKING([platform to setup platform specific variables])
platform_win32="no"
case $host in
  *-*-msdos* | *-*-go32* | *-*-mingw32* | *-*-cygwin* | *-*-windows*)
    if test $gcj_compile = "yes"; then
      JNI_INCLUDES=
    else
      JNI_INCLUDES="-I$JAVA_HOME/include -I$JAVA_HOME/include/win32"
    fi
    platform_win32="yes"
    PLATFORM_CFLAGS="-mms-bitfields"
    PLATFORM_LDFLAGS="-Wl,--kill-at"
    PLATFORM_CLASSPATH_SEPARATOR=";"
    ;;
  *-*-linux*)
    if test $gcj_compile = "yes"; then
      JNI_INCLUDES=
    else
      JNI_INCLUDES="-I$JAVA_HOME/include -I$JAVA_HOME/include/linux"
    fi
    PLATFORM_CFLAGS=
    PLATFORM_LDFLAGS=
    PLATFORM_CLASSPATH_SEPARATOR=":"
    ;;
  *)
    if test $gcj_compile = "yes"; then
      JNI_INCLUDES=
    else
      JNI_INCLUDES="-I$JAVA_HOME/include -I$JAVA_HOME/include/$host_os"
    fi
    PLATFORM_CFLAGS=
    PLATFORM_LDFLAGS=
    PLATFORM_CLASSPATH_SEPARATOR=":"
    ;;
esac
AC_MSG_RESULT([$host_os])
AC_SUBST(JNI_INCLUDES)
AC_SUBST(PLATFORM_CFLAGS)
AC_SUBST(PLATFORM_LDFLAGS)
AC_SUBST(PLATFORM_CLASSPATH_SEPARATOR)
AM_CONDITIONAL(WINDOWS_BUILD, test $platform_win32 = "yes")

dnl Checks for libraries.
dnl Replace `main' with a function in -libs:
AC_CHECK_LIB(ibs, main)

##dnl Check for GTK >= 2.0 and GNOME >= 1.0
##PKG_CHECK_MODULES(GTK, gtk+-2.0 >= 2.6.0)
##AC_SUBST(GTK_CFLAGS)
##AC_SUBST(GTK_LIBS)

AC_SUBST(TOPLEVEL_TARGETS)
AC_SUBST(INSTALL_TARGETS)
AC_SUBST(UNINSTALL_TARGETS)
AC_SUBST(MACRO_FLAG)

dnl Checks for header files.
dnl Fails at this stage
##dnl AC_CHECK_FILE(jni.h)

dnl Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST

dnl Checks for library functions.
AC_FUNC_ALLOCA

])
