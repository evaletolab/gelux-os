dnl Process this file with autoconf to produce a configure script.
dnl
dnl This file is part of gelux-installer.
dnl
dnl gelux-installer is free software; you can redistribute it and/or modify it
dnl under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2, or (at your option)
dnl any later version.
dnl
dnl gelux-installer is distributed in the hope that it will be useful, but
dnl WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with Jade; see the file COPYING.  If not, write to
dnl the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

AC_INIT(src/org/programmers/installer/InstallBase.java)
AC_CONFIG_AUX_DIR(.)
AM_INIT_AUTOMAKE(gelux-installer, 1.0.0)

AM_PROG_GCJ

AC_DISABLE_STATIC
AC_PROG_LIBTOOL


INSTALLED_CLASSPATH=\${prefix}/share/java/gelux-installer-${VERSION}.jar 
INSTALLED_JNI_DIR=\${prefix}/lib/
INSTALLED_MACRO_DIR=\${prefix}/share/gelux-java/macros/
AC_SUBST(INSTALLED_CLASSPATH)
AC_SUBST(INSTALLED_JNI_DIR)
AC_SUBST(INSTALLED_MACRO_DIR)

BUILDDIR=`pwd`

INSTALLED_CLASSPATH_BUILDPLACE=$BUILDDIR/lib/gelux-installer-${VERSION}.jar 
INSTALLED_JNI_DIR_BUILDPLACE=$BUILDDIR/lib/
INSTALLED_MACRO_DIR_BUILDPLACE=$BUILDDIR/macros/
AC_SUBST(INSTALLED_CLASSPATH_BUILDPLACE)
AC_SUBST(INSTALLED_JNI_DIR_BUILDPLACE)
AC_SUBST(INSTALLED_MACRO_DIR_BUILDPLACE)

JG_COMMON

JG_GTK_JAVA(2.4.0)
JG_GNOME_JAVA(2.8.0)
JG_GLADE_JAVA(2.8.0)
JG_PARTED_JAVA(1.0)
AM_PROG_CC_C_O
GCJFLAGS="-O3 -pipe"


AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([data/Makefile])
AC_OUTPUT
