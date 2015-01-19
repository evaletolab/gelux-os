#!/bin/sh
# $Id: make_worstation_symlinks.sh,v 1.5 2005/11/21 12:32:16 evaleto Exp $
mkdir -p rc.m
#ln -s ../init.d/udev rc.m/S00udev
ln -s ../init.d/networkd rc.m/S01networkd
ln -s ../init.d/drm rc.m/S02drm
ln -s ../init.d/console rc.m/S03console
ln -s ../init.d/sudoers rc.m/S04sudoers
ln -s ../init.d/X11-setup rc.m/S04X11-setup
ln -s ../init.d/gdm rc.m/S05gdm
ln -s ../init.d/hotplug rc.m/S06hotplug
ln -s ../init.d/gelux-daemon rc.m/S07geluxd
ln -s ../init.d/ssh rc.m/S07ssh
ln -s ../init.d/cups rc.m/S09cups
ln -s ../init.d/famd rc.m/S10famd
