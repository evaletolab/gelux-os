#! /bin/bash

# You shouldn't need to change anything below this line

PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/usr/local/bin:."
CMDLINE="$(cat /proc/cmdline)"
WINDOWMANAGER=gnome-session
USER=morph
BGIMAGE=/morphix/background.png
XServer=XFree86

stringinstring(){
  case "$2" in *$1*) return 0;; esac
  return 1
}

getbootparam(){
  stringinstring " $1=" "$CMDLINE" || return 1
  result="${CMDLINE##*$1=}"
  result="${result%%[         ]*}"
  echo "$result"
  return 0
}

if [ -e "/cdrom/background.png" ]; then
        BGIMAGE="/cdrom/background.png"
fi

if [ -n "$(getbootparam wm)" ]; then
        WINDOWMANAGER="$(getbootparam wm)"
fi                                                                              

if [ -n "$(getbootparam background)" ]; then 
        BGIMAGE="$(getbootparam background)"
fi

if [ -n "$(getbootparam username)" ]; then
	USER="$(getbootparam username)"
fi
