# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# 
# $Header: /cvsroot/gelux/gelux-live/etc/gelux.d/functions.sh,v 1.1.1.1 2006/05/13 10:47:39 evaleto Exp $

#
# Modified for the Morphix and gelux project
#

# Functions in use:
# ebegin - show a message indicating the start of a process
# eend   - indicate the completion of process (or error)
# einfo  - show an informative message (with a newline)
# eerror 
# ewarn
# and all general knoppix/morphix functions at the end of this file



# Check /etc/conf.d/rc for a description of these ...
svcdir="/var/lib/init.d"
svclib="/lib/rcscripts"
svcmount="no"


#
# Internal variables
#

# Dont output to stdout?
RC_QUIET_STDOUT="no"
RC_VERBOSE=${RC_VERBOSE:-no}

# Should we use color?
RC_NOCOLOR=${RC_NOCOLOR:-no}
# Can the terminal handle endcols?
RC_ENDCOL="yes"

#
# Default values for e-message indentation and dots
#
RC_INDENTATION=''
RC_DEFAULT_INDENT=2
#RC_DOT_PATTERN=' .'
RC_DOT_PATTERN=''


# void import_addon(char *addon)
#
#  Import code from the specified addon if it exists
#
import_addon() {
	local addon=${svclib}/addons/$1
	if [[ -r ${addon} ]] ; then
		source "${addon}"
		return 0
	fi
	return 1
}

import_env() {
  if [[ -e ${1} ]] ; then
    source "${1}"
    return 0
  fi
  return 1
}


# void esyslog(char* priority, char* tag, char* message)
#
#    use the system logger to log a message
#
esyslog() {
	local pri=
	local tag=

	if [ -x /usr/bin/logger ]
	then
		pri="$1"
		tag="$2"

		shift 2
		[[ -z "$*" ]] && return 0

		/usr/bin/logger -p "${pri}" -t "${tag}" -- "$*"
	fi

	return 0
}

# void eindent(int num)
#
#    increase the indent used for e-commands.
#
eindent() {
	local i=$1
	(( i > 0 )) || (( i = RC_DEFAULT_INDENT ))
	esetdent $(( ${#RC_INDENTATION} + i ))
}

# void eoutdent(int num)
#
#    decrease the indent used for e-commands.
#
eoutdent() {
	local i=$1
	(( i > 0 )) || (( i = RC_DEFAULT_INDENT ))
	esetdent $(( ${#RC_INDENTATION} - i ))
}

# void esetdent(int num)
#
#    hard set the indent used for e-commands.
#    num defaults to 0
#
esetdent() {
	local i=$1
	(( i < 0 )) && (( i = 0 ))
	RC_INDENTATION=$(printf "%${i}s" '')
}

# void einfo(char* message)
#
#    show an informative message (with a newline)
#
einfo() {
	einfon "$*\n"
	LAST_E_CMD=einfo
	return 0
}

# void einfon(char* message)
#
#    show an informative message (without a newline)
#
einfon() {
	[[ ${RC_QUIET_STDOUT} == yes ]] && return 0
	[[ ${RC_ENDCOL} != yes && ${LAST_E_CMD} == ebegin ]] && echo
	echo -ne " ${GOOD}*${NORMAL} ${RC_INDENTATION}$*"
	LAST_E_CMD=einfon
	return 0
}

# void ewarn(char* message)
#
#    show a warning message + log it
#
ewarn() {
	if [[ ${RC_QUIET_STDOUT} == yes ]]; then
		echo " $*"
	else
		[[ ${RC_ENDCOL} != yes && ${LAST_E_CMD} == ebegin ]] && echo
		echo -e " ${WARN}*${NORMAL} ${RC_INDENTATION}$*"
	fi

	# Log warnings to system log
	esyslog "daemon.warning" "rc-scripts" "$*"

	LAST_E_CMD=ewarn
	return 0
}

# void eerror(char* message)
#
#    show an error message + log it
#
eerror() {
	if [[ ${RC_QUIET_STDOUT} == yes ]]; then
		echo " $*" >/dev/stderr
	else
		[[ ${RC_ENDCOL} != yes && ${LAST_E_CMD} == ebegin ]] && echo
		echo -e " ${BAD}*${NORMAL} ${RC_INDENTATION}$*"
	fi

	# Log errors to system log
	esyslog "daemon.err" "rc-scripts" "$*"

	LAST_E_CMD=eerror
	return 0
}

# void ebegin(char* message)
#
#    show a message indicating the start of a process
#
ebegin() {
	local msg="$*" dots spaces=${RC_DOT_PATTERN//?/ }
	[[ ${RC_QUIET_STDOUT} == yes ]] && return 0

	if [[ -n ${RC_DOT_PATTERN} ]]; then
		dots=$(printf "%$(( COLS - 3 - ${#RC_INDENTATION} - ${#msg} - 7 ))s" '')
		dots=${dots//${spaces}/${RC_DOT_PATTERN}}
		msg="${msg}${dots}"
	else
		msg="${msg} ..."
	fi
	einfon "${msg}"
	[[ ${RC_ENDCOL} == yes ]] && echo

	LAST_E_LEN=$(( 3 + ${#RC_INDENTATION} + ${#msg} ))
	LAST_E_CMD=ebegin
	return 0
}

# void _eend(int error, char *efunc, char* errstr)
#
#    indicate the completion of process, called from eend/ewend
#    if error, show errstr via efunc
#
#    This function is private to functions.sh.  Do not call it from a
#    script.
#
_eend() {
	local retval=${1:-0} efunc=${2:-eerror} msg
	shift 2

	if [[ ${retval} == 0 ]]; then
		[[ ${RC_QUIET_STDOUT} == yes ]] && return 0
		msg="${BRACKET}[ ${GOOD}ok${BRACKET} ]${NORMAL}"
	else
		if [[ -c /dev/null ]]; then
			rc_splash "stop" &>/dev/null &
		else
			rc_splash "stop" &
		fi
		if [[ -n "$*" ]]; then
			${efunc} "$*"
		fi
		msg="${BRACKET}[ ${BAD}!!${BRACKET} ]${NORMAL}"
	fi

	if [[ ${RC_ENDCOL} == yes ]]; then
		echo -e "${ENDCOL}  ${msg}"
	else
		[[ ${LAST_E_CMD} == ebegin ]] || LAST_E_LEN=0
		printf "%$(( COLS - LAST_E_LEN - 6 ))s%b\n" '' "${msg}"
	fi

	return ${retval}
}

# void eend(int error, char* errstr)
#
#    indicate the completion of process
#    if error, show errstr via eerror
#
eend() {
	local retval=${1:-0}
	shift

	_eend ${retval} eerror "$*"

	LAST_E_CMD=eend
	return $retval
}

# void ewend(int error, char* errstr)
#
#    indicate the completion of process
#    if error, show errstr via ewarn
#
ewend() {
	local retval=${1:-0}
	shift

	_eend ${retval} ewarn "$*"

	LAST_E_CMD=ewend
	return $retval
}



# char *KV_major(string)
#
#    Return the Major (X of X.Y.Z) kernel version
#
KV_major() {
	[[ -z $1 ]] && return 1

	local KV=$@
	echo ${KV%%.*}
}

# char *KV_minor(string)
#
#    Return the Minor (Y of X.Y.Z) kernel version
#
KV_minor() {
	[[ -z $1 ]] && return 1

	local KV=$@
	KV=${KV#*.}
	echo ${KV%%.*}
}

# char *KV_micro(string)
#
#    Return the Micro (Z of X.Y.Z) kernel version.
#
KV_micro() {
	[[ -z $1 ]] && return 1

	local KV=$@
	KV=${KV#*.*.}
	echo ${KV%%[^[:digit:]]*}
}

# int KV_to_int(string)
#
#    Convert a string type kernel version (2.4.0) to an int (132096)
#    for easy compairing or versions ...
#
KV_to_int() {
	[[ -z $1 ]] && return 1

	local KV_MAJOR=$(KV_major "$1")
	local KV_MINOR=$(KV_minor "$1")
	local KV_MICRO=$(KV_micro "$1")
	local KV_int=$(( KV_MAJOR * 65536 + KV_MINOR * 256 + KV_MICRO ))

	# We make version 2.2.0 the minimum version we will handle as
	# a sanity check ... if its less, we fail ...
	if [[ ${KV_int} -ge 131584 ]] ; then
		echo "${KV_int}"
		return 0
	fi

	return 1
}

# int get_KV()
#
#    Return the kernel version (major, minor and micro concated) as an integer.
#    Assumes X and Y of X.Y.Z are numbers.  Also assumes that some leading
#    portion of Z is a number.
#    e.g. 2.4.25, 2.6.10, 2.6.4-rc3, 2.2.40-poop, 2.0.15+foo
#
get_KV() {
	local KV=$(uname -r)

	echo $(KV_to_int "${KV}")

	return $?
}


# void save_options(char *option, char *optstring)
#
#    save the settings ("optstring") for "option"
#
save_options() {
	local myopts="$1"

	shift
	if [ ! -d "${svcdir}/options/${myservice}" ]
	then
		mkdir -p -m 0755 "${svcdir}/options/${myservice}"
	fi

	echo "$*" > "${svcdir}/options/${myservice}/${myopts}"

	return 0
}

# char *get_options(char *option)
#
#    get the "optstring" for "option" that was saved
#    by calling the save_options function
#
get_options() {
	if [ -f "${svcdir}/options/${myservice}/$1" ]
	then
		echo "$(< ${svcdir}/options/${myservice}/$1)"
	fi

	return 0
}


# char *get_base_ver()
#
#    get the version of baselayout that this system is running
#
get_base_ver() {
	[[ ! -r /etc/gelux-release ]] && return 0
	local ver=$(</etc/gelux-release)
	echo ${ver##* }
}

# Network filesystems list for common use in rc-scripts.
# This variable is used in is_net_fs and other places such as
# localmount.
NET_FS_LIST="afs cifs coda davfs gfs ncpfs nfs nfs4 shfs smbfs"

# bool is_net_fs(path)
#
#   return 0 if path is the mountpoint of a networked filesystem
#
#   EXAMPLE:  if is_net_fs / ; then ...
#
is_net_fs() {
	local fstype
	# /proc/mounts is always accurate but may not always be available
	if [[ -e /proc/mounts ]]; then
		fstype=$( sed -n -e '/^rootfs/!s:.* '"$1"' \([^ ]*\).*:\1:p' /proc/mounts )
	else
		fstype=$( mount | sed -n -e 's:.* on '"$1"' type \([^ ]*\).*:\1:p' )
	fi
	[[ " ${NET_FS_LIST} " == *" ${fstype} "* ]]
	return $?
}

# bool is_uml_sys()
#
#   return 0 if the currently running system is User Mode Linux
#
#   EXAMPLE:  if is_uml_sys ; then ...
#
is_uml_sys() {
	grep -qs 'UML' /proc/cpuinfo
	return $?
}

# bool is_vserver_sys()
#
#   return 0 if the currently running system is a Linux VServer
#
#   EXAMPLE:  if is_vserver_sys ; then ...
#
is_vserver_sys() {
	grep -qs '^s_context:[[:space:]]*[1-9]' /proc/self/status
	return $?
}

# bool is_xenU_sys()
#
#   return 0 if the currently running system is an unprivileged Xen domain
#
#   EXAMPLE:  if is_xenU_sys ; then ...
#
is_xenU_sys() {
	[[ -d /proc/xen && ! -f /proc/xen/privcmd ]]
}

# bool get_mount_fstab(path)
#
#   return the parameters to pass to the mount command generated from fstab
#
#   EXAMPLE: cmd=$( get_mount_fstab /proc )
#            cmd=${cmd:--t proc none /proc}
#            mount -n ${cmd}
#
get_mount_fstab() {
	awk '$1 ~ "^#" { next }
	     $2 == "'$*'" { if (found++ == 0) { print "-t "$3,"-o "$4,$1,$2 } }
	     END { if (found > 1) { print "More than one entry for '$*' found in /etc/fstab!" > "/dev/stderr" } }
	' /etc/fstab
}

# char *reverse_list(list)
#
#   Returns the reversed order of list
#
reverse_list() {
	for (( i = $# ; i > 0 ; --i )); do
		echo -n "${!i} "
	done
}



# bool is_older_than(reference, files/dirs to check)
#
#   return 0 if any of the files/dirs are newer than
#   the reference file
#
#   EXAMPLE: if is_older_than a.out *.o ; then ...
is_older_than() {
	local x=
	local ref="$1"
	shift

	for x in "$@" ; do
		[[ ${x} -nt ${ref} ]] && return 0

		if [[ -d ${x} ]] ; then
			is_older_than "${ref}" "${x}"/* && return 0
		fi
	done

	return 1
}

#
# gelux / morphix functions / variables
#
docmd() {
        ebegin "$1: "
        shift
        CMD="($1)"
        shift
        while [ $# -gt 0 ]; do
                CMD="$CMD && ($1)"
                shift
        done
        (eval "$CMD") 2>&1 >/dev/null && eend 0 || eend 1
}

CMDLINE="$(cat /proc/cmdline)"

#
#
#
# Simple shell grep
stringinfile(){
    case "$(cat $2)" in *$1*) return 0;; esac
    return 1
}

fistringinfile(){
    case "$(cat $2)" in *$1*) return 0;; esac
    return 1
}

# same for strings
stringinstring(){
    case "$2" in *$1*) return 0;; esac
    return 1
}

# Reread boot command line; echo last parameter's argument or return false.
getbootparam(){
    stringinstring " $1=" "$CMDLINE" || { echo "$2" ; return 1; }
    result="${CMDLINE##*$1=}"
    result="${result%%[   ]*}"
    echo "$result"
    return 0
}

# Check boot commandline for specified option
checkbootparam(){
    stringinstring " $1" "$CMDLINE"
    return "$?"
}

getconfigparam(){
  local conf=$(getbootparam config)
  stringinstring "$1" "$conf"
  return "$?"
}

addmount(){
    d="${1##*/}"
    [ ! -d $MNTPOINT/$d ] && mkdir -p $MNTPOINT/$d
    new="$1 $MNTPOINT/$d  auto   users,noauto,exec,$2 0 0"
    stringinfile "$new" "/etc/fstab" || echo "$new" >> /etc/fstab
}

# Reinit USB devices that could not be started from linuxrc
# Adopted from /etc/hotplug/usb.rc with some changes.
# Calling /etc/hotplug/usb.rc directly can result in crashes due
# to quite cautiousless module probing there. -KK
usbreinit(){
    LISTER=/usr/sbin/usbmodules
    test -x $LISTER || LISTER="$(type -p usbmodules 2>/dev/null)"
    [ -z "$LISTER" -o ! -f /proc/bus/usb/devices ] && return 1
# make sure the usb agent will run
    ACTION="add" ; PRODUCT="0/0/0" ; DEVFS="/proc/bus/usb" ; DEVICE= ; DEVPATH=
    export ACTION PRODUCT DEVFS DEVICE DEVPATH
    echo -n "sync:["
    if [ -d /sys/bus/usb/devices ]; then
# Kernel 2.6
  for device in /sys/bus/usb/devices/*; do
      DEVPATH="${device#/sys/}"
      echo -n "${DEVPATH##*/}" " "; /etc/hotplug/usb.agent >/dev/null 2>&1
  done
    else
# Kernel 2.4
  for DEVICE in /proc/bus/usb/*/*; do
      echo -n ${DEVICE##*/} " "; /etc/hotplug/usb.agent >/dev/null 2>&1
  done
    fi
    echo -n "] "
    return 0
}

fstype(){
    case "$(file -s $1)" in
  *[Ff][Aa][Tt]*|*[Xx]86*) echo "vfat"; return 0;;
*[Rr][Ee][Ii][Ss][Ee][Rr]*)  echo "reiserfs"; return 0;;
*[Xx][Ff][Ss]*)  echo "xfs"; return 0;;
*[Ee][Xx][Tt]3*) echo "ext3"; return 0;;
*[Ee][Xx][Tt]2*) echo "ext2"; return 0;;
*data*)          echo "invalid"; return 0;;
*) echo "auto"; return 0;;
esac
}

mountit(){
# Usage: mountit src dst "options"
# Uses builtin mount of ash.knoppix
# Builin filesystems
#  BUILTIN_FS="auto iso9660 ext3 ext2 reiserfs fat16 vfat ntfs"
  BUILTIN_FS="auto fat16 vfat ntfs"
  for fs in $BUILTIN_FS; do
    test -b $1 && mount -t $fs $3 $1 $2 >/dev/null 2>&1 && return 0
  done
  return 1
}

sed_variable(){
    sed -i -e "s/#\?$1\([= ]\).*/$1\1$2/g"  $3
}

# usage: rc_splash "string" max_progress
gelux_splash(){
  local max=$2
  
  [ "$runlevel" = "S" ] && runlevel=-1
  
  [ $runlevel -ne 0 ] && [ $runlevel -ne 6 ] && \
  [ -x /sbin/progress -a -x /sbin/fbtruetype ] && /sbin/progress 0 1 1023 56 0 && \
  /sbin/fbtruetype -S -a 75 -t FFFFFF -x 10 -y 10 "$1"
  
  local increment=$(( 150 / $max ))
  
  local progress=$(( $progress + $increment ))
  
  [ $progress -gt 100 ] && progress=100
  
  echo "show $(( 65534 * $progress / 100 ))" > /proc/splash
}

gelux_debug_shell(){
  if test -n "$DEBUGMINIROOT"; then
    einfo "Dropping to shell for debugging"
    sh
  fi
}

gelux_start_shell(){
    einfo "${CRE}${RED}Can't continue on ${DERIVATE}, sorry${NORMAL}"
    einfo "${RED}Dropping you to a bash shell${NORMAL}"
    einfo "${RED}Make sure you have a ${DERIVATE} image on your device"
    einfo "${RED}Press reset button to quit.${NORMAL}"
    echo ""
    echo ""
    PS1="gelux# "
    export PS1
    echo "6" > /proc/sys/kernel/printk
# Allow signals
    trap 1 2 3 15
    exec bash
}
##############################################################################
#                                                                            #
# This should be the last code in here, please add all functions above!!     #
#                                                                            #
# *** START LAST CODE ***                                                    #
#                                                                            #
##############################################################################

if [ -z "${EBUILD}" ] ; then


	if [ "$(/sbin/consoletype 2> /dev/null)" = "serial" ] ; then
		# We do not want colors/endcols on serial terminals
		RC_NOCOLOR="yes"
		RC_ENDCOL="no"
	fi

	for arg in "$@" ; do
		case "${arg}" in
			# Lastly check if the user disabled it with --nocolor argument
			--nocolor|-nc)
				RC_NOCOLOR="yes"
				;;
		esac
	done

else
	# Should we use colors ?
	if [[ $* != *depend* ]]; then
		# Check user pref in portage
		RC_NOCOLOR="$(portageq envvar NOCOLOR 2>/dev/null)"
		[ "${RC_NOCOLOR}" = "true" ] && RC_NOCOLOR="yes"
	else
		# We do not want colors during emerge depend
		RC_NOCOLOR="yes"
		# No output is seen during emerge depend, so this is not needed.
		RC_ENDCOL="no"
	fi
fi

if [[ -n ${EBUILD} && $* == *depend* ]]; then
	# We do not want stty to run during emerge depend
	COLS=80
else
	# Setup COLS and ENDCOL so eend can line up the [ ok ]
	COLS=${COLUMNS:-0}		# bash's internal COLUMNS variable
	(( COLS == 0 )) && COLS=$(stty size 2>/dev/null | cut -d' ' -f2)
	(( COLS > 0 )) || (( COLS = 80 ))	# width of [ ok ] == 7
fi

if [[ ${RC_ENDCOL} == yes ]]; then
	ENDCOL=$'\e[A\e['$(( COLS - 7 ))'G'
else
	ENDCOL=''
fi

# Setup the colors so our messages all look pretty
if [[ ${RC_NOCOLOR} == yes ]]; then
	unset GOOD WARN BAD NORMAL HILITE BRACKET
else
	GOOD=$'\e[32;01m'
	WARN=$'\e[33;01m'
	BAD=$'\e[31;01m'
	NORMAL=$'\e[0m'
	HILITE=$'\e[36;01m'
	BRACKET=$'\e[34;01m'
fi

# vim:ts=4
