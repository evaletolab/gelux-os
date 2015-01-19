
AC_DEFUN([AM_PATH_DOCBOOK],[
AC_REQUIRE([AC_EXEEXT])dnl
AC_PATH_PROG(DB1, db2html$EXEEXT, nocommand)
if test "$DB1" = nocommand; then
	AC_PATH_PROG(DB2, docbook2html$EXEEXT, nocommand)
  	if test "$DB2" = nocommand; then
   		AC_MSG_WARN([Some documentation will not be installed - docbook not found in $PATH])
	else
		DOCBOOK=$DB2
  	fi;
else
  DOCBOOK=$DB1
fi;
AC_SUBST(DOCBOOK)
AM_CONDITIONAL(HAVE_DOCBOOK, test $DOCBOOK != nocommand)
])
