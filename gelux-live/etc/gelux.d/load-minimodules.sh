#!/bin/sh
# 
# Module-dependent loadscript
#
# Feel free to change this file to adapt it to your main-module
# 
# copyleft 2003-2005, Alex de Landgraaf <alex at delandgraaf dot com>
# GPL, (www.gnu.org for details)
#
# $Id: load-minimodules.sh,v 1.1.1.1 2006/05/13 10:47:39 evaleto Exp $
#
# All linking/binding, copying /etc and /var etc is done
# in /etc/init.d/morphix-start on Morphix Base
# Could also be done here, but would be unneeded complexity
# (and modules should be loaded in a uniform matter)
# 
# MiniModules are loaded here, still a bit dirty for now,
# as we need a kernelmodule for each minimodule that we want to load
# Reread boot command line; echo last parameter's argument or return false.

. /etc/morphix.d/color.sh
. /etc/morphix.d/functions.sh

trymount(){
# Apparently, mount-aes DOES autodetect AES loopback files.
    [ -b "$1" ] && { mount -t auto -o ro "$1" "$2" 2>/dev/null; RC="$?"; }
# We need to mount crypto-loop files with initial rw support
    [ -f "$1" ] && { mount -t auto -o loop,rw "$1" "$2" 2>/dev/null; RC="$?"; }
    [ "$RC" = "0" ] && return 0
    echo ""
    einfo "Filesystem not autodetected, trying to mount $1 with AES256 encryption"
    a="y"
    while [ "$a" != "n" -a "$a" != "N" ]; do
# We need to mount crypto-loop files with initial rw support
	mount -t auto -o loop,rw,encryption=AES256 "$1" "$2" && return 0
	echo -n "${RED}Mount failed, retry? [Y/n] ${NORMAL}"
	read a
    done
    return 1
}

# Mounts a minimod to the directory appointed to the module
# first argument is the file seen from the mainmodule/chroot
# second argument is the number of the module
# also checks if there is a contraint, if the file isn't there, ignore it
# returns 0 on success, 1 on failure.

load_mini_module() {
    file="$1"
    countarg="$2"
    count=$(($countarg+2)) # we have a base module, and a mainmodule loaded

    # /etc/init.d/morphix-start will mount cdrom minimodules.
    # But just incase
    if [ ! -d /mnt/main/mnt/mini/mod$count ]; then
	chroot /mnt/main mkdir /mnt/mini/mod$count
	# this not chrooted, so mount_module only needs to be in base
	mount_module $file /mnt/main/mnt/mini/mod$count $count >/dev/null 2>&1
    fi
   
    MainTag=$(head -n 1 /mnt/main/morphix/main_module)
    MiniTag=$(head -n 1 /mnt/main/mnt/mini/mod$count/morphix/main_module 2>/dev/null)
    if [ -n "$MiniTag" -a -n "$MainTag" ]; then
	if [ "$MainTag" != "$MiniTag" ] && [[ $MiniTag != ALL* ]]; then
	    ewarn "${RED}MiniModule $file doesn't have the same tag as MainModule${NORMAL}"
	    einfo "${GREEN} Mini: $MiniTag"
	    einfo " Main: $MainTag${NORMAL}"
	    chroot /mnt/main umount /mnt/mini/mod$count
	    chroot /mnt/main rm /dev/cloop$count
	    chroot /mnt/main rm /mnt/mini/mod$count
	    return 1
	fi
    fi
    echo "$count" > /mnt/mini/num_loaded

    # Unionfs overlaying (only if unionctl exists and the root dir in the minimodule exists
    # Add the /root dir to be the unionfs branch after the first component (which should be 0 and rw...)
    if [ -x /sbin/unionctl -o -x /usr/bin/unionctl ];then
	if [ -d /mnt/mini/mod$count/root ]; then
	    unionctl /mnt/main --add --after 0 --mode ro /mnt/mini/mod$count/root
	fi
    else
	einfo "No unionctl found, not applying unionfs minimodule overlaying";
    fi

    if [ -e /mnt/main/mnt/mini/mod$count/morphix/loadmod.sh ]; then
	einfo "Starting /mnt/mini/mod$count/morphix/loadmod.sh"
	chroot /mnt/main sh /mnt/mini/mod$count/morphix/loadmod.sh /mnt/mini/mod$count
    else
	einfo "Not able to find /mnt/mini/mod$count/morphix/loadmod.sh, continuing"
    fi

    return 0
}

# Hmm, dunno if it supports one...
MiniModulesMax=255
#
# Checking for MiniModules to load
#
MiniModulesCount=0
einfo "Starting MiniModule bootscript"

# copied from myhome, you can specify a device to load minimods from 
#using the mini= bootparameter. Modules would be in the root of the directory

MYMINIDIR="$(getbootparam mini)"
if [ -n "$MYINIDIR" ]; then
    case "$MYMINIDIR" in
	/dev/*)
	    MYMINIDEVICE="${MYMINIDIR##/dev/}"
	    MYMINIDEVICE="/dev/${MYMINIDEVICE%%/*}"
	    MYMINIMOUNTPOINT="/mnt/minimod}"
	    MYMINIDIR="/mnt/${MYMINIDIR##/dev/}"
	    ;;
	/mnt/*)
	    MYMINIDEVICE="${MYMINIDIR##/mnt/}"
	    MYMINIDEVICE="/dev/${MYMINIDEVICE%%/*}"
	    MYMINIMOUNTPOINT="/mnt/minimod}"
	    MYMINIDIR="$MYMINIDIR"
	    ;;
	*)
	    ewarn "Invalid ${CYAN}mini=${NORMAL} option '$MYMINIDIR' specified (must start with /dev/ or /mnt/)."
	    ewarn "Option ignored."
	    ;;
    esac
    if trymount "$MYMINIDEVICE" "$MYMINIMOUNTPOINT"; then
	MntMiniModules="$(ls /mnt/minimod/*.mod 2> /dev/null)"
	MntMiniModulesCount="$(ls /mnt/minimod/*.mod 2> /dev/null | wc -l)"
	for file in $MntMiniModules 
	  do
	  load_mini_module "$file" $MiniModuleCount
	  if [ $? -eq 0 ]; then
	      ((MiniModuleCount += 1))
	  fi
	done
	einfo "Device $MYMINIDEVICE will be used for the /mnt/minimod directory..."
    fi
fi

# checks for all minimodules on the usb device,
# unless nousb or usbboot is being used (the latter would mean that the
# minimodules are loaded from /cdrom instead...)

echo
USBSTORAGE="$(getbootparam nousb)"
USBBOOTING="$(getbootparam usbboot)"
if [ -z "$USBSTORAGE" -a -z "$USBBOOTING" ]; then
    einfo "Checking for MiniModules on USB device"
    modprobe usb-storage >/dev/null 2>&1
    mkdir /mnt/main/mnt/usb  >/dev/null 2>&1
    chroot /mnt/main mount /dev/sda1 /mnt/usb >/dev/null 2>&1
    UsbMiniModules="$(ls /mnt/usb/minimod/*.mod 2> /dev/null)"
    UsbMiniModulesCount="$(ls /mnt/usb/minimod/*.mod 2> /dev/null | wc -l)"
    for file in $UsbMiniModules 
      do
      load_mini_module "$file" $MiniModuleCount
      if [ $? -eq 0 ]; then
	  ((MiniModuleCount += 1))
      fi
    done
fi

# checks for all minimodules on /cdrom/minimod

echo 
einfo "Checking for MiniModules on CDROM"
CdromMiniModules="$(ls /cdrom/minimod/*.mod 2> /dev/null )"
CdromMiniModulesCount="$(ls /cdrom/minimod/*.mod 2> /dev/null | wc -l  )"
for file in $CdromMiniModules 
  do
  load_mini_module "$file" $MiniModuleCount
  if [ $? -eq 0 ]; then
      ((MiniModuleCount += 1))
  fi
done

# All changes have been made, ready to chroot to MainModule

