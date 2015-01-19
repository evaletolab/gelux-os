
AC_DEFUN([AC_ENABLE_FULLINSTALL],[

AC_MSG_CHECKING([whether to enable a the normal installer (not p2p)])
AC_ARG_ENABLE(optimize,
AS_HELP_STRING([--enable-fullinstall],[Enable the full installer to build (not p2p)]),
[if test "$enableval" = yes; then
	AC_MSG_RESULT([yes])
	AM_CONDITIONAL(USE_FULLINSTALL, test "$enableval" = yes)
fi],[AC_MSG_RESULT([no])])
])
