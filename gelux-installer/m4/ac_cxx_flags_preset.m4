
dnl Compiler flags preset
AC_DEFUN([AC_CXX_FLAGS_PRESET],[

dnl Declare variables which we want substituted in the Makefile.in's

dnl 
AC_SUBST(CFLAGS)
AC_SUBST(C_OPTIMIZE_FLAGS)
AC_SUBST(C_DEBUG_FLAGS)
AC_SUBST(C_PROFIL_FLAGS)
AC_SUBST(CXXFLAGS)
AC_SUBST(CXX_OPTIMIZE_FLAGS)
AC_SUBST(CXX_DEBUG_FLAGS)
AC_SUBST(CXX_PROFIL_FLAGS)
AC_SUBST(CXX_LIBS)
AC_SUBST(AR)
AC_SUBST(AR_FLAGS)
AC_SUBST(LDFLAGS)
AC_SUBST(RANLIB)

dnl Set default values
AR_FLAGS="-cru"
LDFLAGS=


AC_MSG_CHECKING([whether using $CC/$CXX preset flags])
AC_ARG_ENABLE(cxx-flags-preset,
AS_HELP_STRING([--enable-cxx-flags-preset],
[Enable C/C++ compiler flags preset @<:@default yes@:>@]),[],[enableval='yes'])

if test "$enableval" = yes ; then

	ac_cxx_flags_preset=yes

	case "$CXX" in
	g++) dnl GNU C++  http://gcc.gnu.org/
		CXX_VENDOR="GNU" 
		GCC_V=`g++ --version`
		gcc_version=`expr "$GCC_V" : '.* \(@<:@0-9@:>@\)\..*'`
		gcc_release=`expr "$GCC_V" : '.* @<:@0-9@:>@\.\(@<:@0-9@:>@\).*'`
		if test $gcc_version -lt "3" ; then
			CXXFLAGS="-ftemplate-depth-40 -pipe "
			CXX_OPTIMIZE_FLAGS="-O2 -funroll-loops -fstrict-aliasing -fno-gcse"  
		else
			CXXFLAGS="-pipe "
			CXX_OPTIMIZE_FLAGS="-O3 -funroll-loops -fomit-frame-pointer -ffast-math $ARCHFLAGS"
		fi
		CXX_DEBUG_FLAGS="-g -O0 -DDEBUG $ARCHFLAGS"
		CXX_PROFIL_FLAGS="-pg"
	;;
	icpc|icc) dnl Intel icc http://www.intel.com/
		CXX_VENDOR="Intel"
		CXXFLAGS="-wr1287"
		CXX_OPTIMIZE_FLAGS="-O3 -Zp16 -ansi_alias -i_dynamic -xW -ipo"
		CXX_DEBUG_FLAGS="-g -O0 -C -DDEBUG "
		CXX_PROFIL_FLAGS="-p"
	;;
	*) 
		ac_cxx_flags_preset=no
	;;
	esac
	case "$CC" in
	gcc) dnl GNU C++  http://gcc.gnu.org/
		CC_VENDOR="GNU" 
		GCC_V=`gcc --version`
		gcc_version=`expr "$GCC_V" : '.* \(@<:@0-9@:>@\)\..*'`
		gcc_release=`expr "$GCC_V" : '.* @<:@0-9@:>@\.\(@<:@0-9@:>@\).*'`
		if test $gcc_version -lt "3" ; then
			CFLAGS="-pipe "
			C_OPTIMIZE_FLAGS="-O2 -funroll-loops -fstrict-aliasing -fno-gcse"  
		else
			CFLAGS="-pipe "
			C_OPTIMIZE_FLAGS="-O3 -funroll-loops -fomit-frame-pointer -ffast-math $ARCHFLAGS"
		fi
		C_DEBUG_FLAGS="-g -O0 -DDEBUG $ARCHFLAGS"
		C_PROFIL_FLAGS="-pg"
	;;
	*)
		ac_cxx_flags_preset=no
	;;
	esac
	AC_MSG_RESULT([yes])
else
	AC_MSG_RESULT([no])
fi

if test "$ac_cxx_flags_preset" = yes ; then
	if test "$CXX_VENDOR" = GNU ; then
		AC_MSG_NOTICE([Setting compiler flags for $CXX_VENDOR $CXX, $CC_VENDOR $CC (wahoo!)])
	else
		AC_MSG_NOTICE([Setting compiler flags for $CXX_VENDOR $CXX])
	fi
else

	AC_MSG_NOTICE([No flags preset found for $CXX, $CC])
fi

])
