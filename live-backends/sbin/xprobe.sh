#!/bin/sh
# usage: xprobe.sh driver
# Copyright (C) 2004 Canonical Ltd.
# Author: Daniel Stone <daniel.stone@ubuntu.com>
# 
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; version 2 of the License.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License with
#  the Debian GNU/Linux distribution in file /usr/share/common-licenses/GPL-2;
#  if not, write to the Free Software Foundation, Inc., 59 Temple Place,
#  Suite 330, Boston, MA  02111-1307  USA
#
# On Debian systems, the complete text of the GNU General Public
# License, version 2, can be found in /usr/share/common-licenses/GPL-2.

DATAPATH="/usr/share/gelux-backend"

DRIVER="$1"
if [ -z "$DRIVER" ]; then
  echo "Driver name must be specified on the command line."
  exit 1
fi

set -e
if [ -z "$TMPDIR" ]; then
	TMPDIR="/tmp"
fi
XDIR="$TMPDIR/xprobe.$$"
TMPCONF="$XDIR/xprobe.conf"
TMPLOG="$XDIR/xprobe.log"
TMPOUT="$XDIR/xorg-stdout.log"
TMPERR="$XDIR/xorg-stderr.log"

mkdir -m700 "/$G_ROOTFS_RW/$XDIR"
sed -e "s/::DRIVER::/$DRIVER/;" < "$DATAPATH/etc/X11/xprobe.conf" > "/$G_ROOTFS_RW/$TMPCONF"
set +e

#xfree 4.3 use different option
if chroot $G_ROOTFS_RW /etc/X11/X -version 2>&1 |grep -q XFree86 ;then
  chroot $G_ROOTFS_RW /etc/X11/X :67 -ac -probeonly -logfile "$TMPLOG" -xf86config "$TMPCONF" > $G_ROOTFS_RW/$TMPOUT 2> $G_ROOTFS_RW/$TMPERR
else
  chroot $G_ROOTFS_RW /etc/X11/X :67 -ac -probeonly -logfile "$TMPLOG" -config "$TMPCONF" > $G_ROOTFS_RW/$TMPOUT 2> $G_ROOTFS_RW/$TMPERR
fi
echo "/$G_ROOTFS_RW/$XDIR"
exit 0
