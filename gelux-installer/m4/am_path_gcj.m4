dnl This file is part of Java-GNOME.
dnl
dnl Java-GNOME is free software; you can redistribute it and/or modify it
dnl under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2, or (at your option)
dnl any later version.
dnl
dnl Java-GNOME is distributed in the hope that it will be useful, but
dnl WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with Jade; see the file COPYING.  If not, write to
dnl the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

dnl Copied blatantly from other source.

dnl Borrowed HEAVILY from AM_PATH_GTK
dnl
dnl AM_PATH_GCJ([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
dnl Test for GCJ
dnl
AC_DEFUN([AM_PATH_GCJ],
[dnl 
dnl Get the environmental variables necessary for GCJ
dnl
AC_ARG_WITH(gcj-prefix,[  --with-gcj-prefix=PFX   Prefix where gcj is installed (optional)],
            gcj_prefix="$withval", gcj_prefix="")

  if test x$gcj_prefix != x ; then
    GCJ_HOME=$gcj_prefix
  fi

  dnl 
  dnl CHANGE: Now FIRST put GCJ_HOME/bin in the path before testing for 
  dnl the java executable.
  dnl
  if test x$GCJ_HOME != x ; then
    echo "Add $GCJ_HOME/bin to path and check again."
    PATH="$GCJ_HOME/bin:$PATH"
  fi
  AC_PATH_PROG(GCJ, gcj, no)

  min_gcj_version=ifelse([$0], ,3.0.0,$1)
  AC_MSG_CHECKING(for GCJ - version >= $min_gcj_version)
  min_gcj_major_version=`echo $min_gcj_version |\
           sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\).*/\1/'`
  min_gcj_minor_version=`echo $min_gcj_version |\
           sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\).*/\2/'`
  min_gcj_micro_version=`echo $min_gcj_version |\
           sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\).*/\3/'`
  if test "$GCJ" = "no" ; then
    no_gcj=yes
  else
    gcj_version=`$GCJ --version 2>&1 | grep GCC | sed 's/gcj (GCC) \([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\).*/\1.\2.\3/'`
    gcj_major_version=`echo $gcj_version | \
           sed 's/\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\).*/\1/'`
    gcj_minor_version=`echo $gcj_version | \
           sed 's/\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\).*/\2/'`
    gcj_micro_version=`echo $gcj_version | \
           sed 's/\([[0-9]]*\)\.\([[0-9]]*\)\.\([[0-9]]*\).*/\3/'`
    AC_TRY_RUN([
#include <stdio.h>

main()
{
    if ((1$gcj_major_version > 1$min_gcj_major_version) ||
	((1$gcj_major_version == 1$min_gcj_major_version) &&
	    (1$gcj_minor_version > 1$min_gcj_minor_version)) ||
	((1$gcj_major_version == 1$min_gcj_major_version) &&
	    (1$gcj_minor_version == 1$min_gcj_minor_version) &&
	    (1$gcj_micro_version >= 1$min_gcj_micro_version)))
    {
	return(0);
    }
    else
    {
	return(1);
    }
}], , no_gcj=yes, [echo $ac_n "cross compiling; assumed OK... $ac_c"])
  fi
  if test "x$no_gcj" = x ; then
     AC_MSG_RESULT(yes)
     dnl
     dnl Check for gcj executables and set appropriate viarable
     dnl
     AC_PATH_PROG(GCJ, gcj, no)
     AC_PATH_PROG(JAR, jar, no)
     dnl
     dnl Set CLASSPATH
     dnl
     if test x$GCJ_HOME != x ; then
        :
     else
        GCJ_HOME=`which gcj | sed 's/\(.*\).bin.*gcj/\1/'`
     fi

	cat << EOF > Test.java
/* [#]line __oline__ "configure" */
public class Test {
	public static void main(String[[]] args) {
		System.out.println(System.getProperty("sun.boot.class.path"));
	}
}
EOF
	GCJ_JAR=`gcj -C Test.java && gij Test`
	rm Test.java Test.class
	if test x$GCJ_JAR == x ; then
      GCJ_JAR=`(test -d /usr/share/local/java && find /usr/local/share/java -name libgcj-?.?.?.jar) || (test -d /usr/share/java && find /usr/share/java -name libgcj-?.?.?.jar)`
	  if test x$GCJ_JAR == x ; then
	 	GCJ_JAR=`locate libgcj | grep libgcj.*\.jar`	
      fi
    fi
     if test x$GCJ_JAR != x ; then
        GCJ_CLASSPATH="${GCJ_JAR}:${CLASSPATH}"
     else
	   echo "***"
	   echo "*** Unable to locate libgcj.jar needed by gcj"
	   echo "***"
 	   ifelse([$3], , :, [$3])
    fi	
     AC_SUBST(GCJ_CLASSPATH)
     ifelse([$2], , :, [$2])
  else
     AC_MSG_RESULT(no)
     echo "***"
     echo "*** If you have GCJ installed and it is a newer version than $min_java_version, either set"
     echo "*** the GCJ_HOME variable or add the top directory where the GCJ binaries are to"
     echo "*** the PATH.  Alternatively try \"./configure --with-gcj-prefix=<java_home>\","
     echo "***"
     echo "*** Also make sure that configure does not find the wrong version of GCJ by"
     echo "*** looking at the output of \"which gcj\"."
     echo "***"
     ifelse([$3], , :, [$3])
  fi
])

