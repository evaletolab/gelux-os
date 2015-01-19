#!/bin/sh
# usage: lcdsize.sh driver logfile [stdout]
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
#  the Debian GNU/Linux distribution in file /usr/share/common-licenses/GPL;
#  if not, write to the Free Software Foundation, Inc., 59 Temple Place,
#  Suite 330, Boston, MA  02111-1307  USA
#
# On Debian systems, the complete text of the GNU General Public
# License, version 2, can be found in /usr/share/common-licenses/GPL-2.

getres () {
  RESLINE="$(egrep "$EGREPLINE" "$LOGFILE" | head -1)"
  RES="$(echo "$RESLINE" | sed -e "$SEDLINE")"
}

DRIVER="$1"
LOGFILE="$2"
# stdout is, for now, unused
STDOUT="$3"

if [ -z "$DRIVER" -o -z "$LOGFILE" ]; then
  echo "Driver name and logfile must be specified on the command line."
  exit 1
fi

# EGREPLINE must pull out only one line, which contains the res, from egrep.
# SEDLINE must print the resolution from that line.

if [ "$DRIVER" = "ati" -o "$DRIVER" = "atimisc" -o "$DRIVER" = "r128" -o \
     "$DRIVER" = "radeon" ]; then
  EGREPLINE="\(--\) ATI\(.*\): .* panel \(ID .*\) detected."
  SEDLINE="s/(--) ATI([^)]*): \([^ ]*\) panel (ID [^)]*) detected./\1/;"
  getres
  if [ -z "$RES" ]; then
    EGREPLINE="\(II\) RADEON\(.*\): Panel [Ss]ize .*from .*: .*"
    SEDLINE="s/(II) RADEON([^)]*): Panel [Ss]ize .*from [^:]*: \(.*\)/\1/;"
    getres
  fi
  if [ -z "$RES" ]; then
    EGREPLINE="\(WW\) RADEON\(.*\): Panel size .*x.* is derived, this may not be correct."
    SEDLINE="s/(WW) RADEON([^)]*): Panel size \([^x]*\)x\([^ ]*\) is derived, this may not be correct./\1x\2/;"
    getres
  fi
  if [ -z "$RES" ]; then
    EGREPLINE="\(II\) R128\(.*\): Panel size: .*x.*"
    SEDLINE="s/(II) R128([^)]*): Panel size: \(.*\)/\1/;"
    getres
  fi
elif [ "$DRIVER" = "i810" ]; then
  EGREPLINE="\(II\) I810\(.*\): Size of device LFP \(local flat panel\) is .* x .*"
  SEDLINE="s/(II) I810([^)]*): Size of device LFP (local flat panel) is \([^ ]*\) x \([^ ]*\)/\1x\2/;"
  getres
elif [ "$DRIVER" = "savage" ]; then
  EGREPLINE="\(--\) SAVAGE\(.*\): .*.* .* LCD panel detected.*"
  SEDLINE="s/(--) SAVAGE([^)]*): \([^x]*\)x\([^x]*\) [^ ]* LCD panel detected.*$/\1x\2/;"
  getres
elif [ "$DRIVER" = "neomagic" ]; then
  EGREPLINE="\(--\) NEOMAGIC\(.*\): Panel is a .*x.* .* .* display"
  SEDLINE="s/(--) NEOMAGIC(.*): Panel is a \([^x]*\)x\([^ ]*\) [^ ]* .* display/\1x\2/;"
  getres
elif [ "$DRIVER" = "nv" ]; then
  # the nv driver would ideally tell us this
  # ... and it does, when backported
  EGREPLINE="\(--\) NV\(.*\): Panel size is .* x .*"
  SEDLINE="s/(--) NV([^)]*): Panel size is \([^ ]*\) x \(.*\)/\1x\2/;"
  getres
  if [ -z "$RES" ]; then
    EGREPLINE="\(--\) NV\(.*\): Virtual size is .*x.* \(pitch .*\)"
    SEDLINE="s/(--) NV([^)]*): Virtual size is \([^x]*\)x\([^ ]*\) (pitch .*)/\1x\2/;"
    getres
  fi
elif [ "$DRIVER" = "siliconmotion" ]; then
  EGREPLINE="\(II\) Silicon MotionDetected panel size via BIOS: .* x .*"
  SEDLINE="s/(II) Silicon MotionDetected panel size via BIOS: \([^ ]*\) x \([^ ]*\)/\1x\2/;"
  getres
  if [ -z "$RES" ]; then
    EGREPLINE="\(II\) Silicon Motion.* Panel Size = .*x.*"
    SEDLINE="s/(II) Silicon Motion[^ ]* Panel Size = \([^x]*\)x\([^ ]*\)/\1x\2/;"
    getres
  fi
elif [ "$DRIVER" = "trident" ]; then
  EGREPLINE="\(--\) TRIDENT\(.*\): .* Panel .*x.* found"
  SEDLINE="s/(--) TRIDENT([^)]*): [^ ]* Panel \([^x]*\)x\([^ ]*\) found/\1x\2/;"
  getres
elif [ "$DRIVER" = "via" ]; then
  EGREPLINE="\(II\) VIA\(.*\): ViaPanelGetIndex: index: .* (.*x.*)"
  SEDLINE="s/(II) VIA([^)]*): ViaPanelGetIndex: index: [^ ]* (\([^x]*\)x\([^)]*\))/\1x\2/;"
  getres
  if [ -z "$RES" ]; then
    EGREPLINE="\(II\) VIA\(.*\): Selected Panel Size is .*x.*"
    SEDLINE="s/(II) VIA([^)]*): Selected Panel Size is \([^x]*\)x\([^ ]*\)/\1x\2/;"
    getres
  fi
elif [ "$DRIVER" = "chips" ]; then
  EGREPLINE="\(--\) CHIPS\(.*\): Display Size: x=.*; y=.*"
  SEDLINE="s/(--) CHIPS([^)]*): Display Size: x=\([^;]*\); y=\([^ ]*\)/\1x\2/;"
  getres
else
  exit 1
fi

echo "$RES"
