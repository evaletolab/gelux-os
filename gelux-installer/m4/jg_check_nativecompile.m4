dnl
AC_DEFUN([JG_CHECK_NATIVECOMPILE],[
dnl Check for a GCJ native compile option
AC_ARG_WITH(gcj_compile,[  --without-gcj-compile    Binary builds of Java 
with gcj compiler will not be made],
        gcj_compile="no", gcj_compile="yes")

if test $gcj_compile = "yes"; then
        AM_PATH_GCJ(3.3.0, , AC_ERROR(Need at lease GCJ version 3.3.0))
fi

AM_CONDITIONAL(BUILD_GCJ, test $gcj_compile = "yes")

])

