#!/bin/sh
# $Id: make_server_symlinks.sh,v 1.3 2005/11/20 14:42:01 evaleto Exp $
mkdir -p rc.m
#ln -s ../init.d/udev rc.m/S00udev
ln -s ../init.d/drm rc.m/S02drm
ln -s ../init.d/console rc.m/S03console
ln -s ../init.d/sudoers rc.m/S04sudoers
ln -s ../init.d/X11-setup rc.m/S04X11-setup
#ln -s ../init.d/X11-startx rc.m/S05X11-startx
ln -s ../init.d/hotplug rc.m/S05hotplug
ln -s ../init.d/dbus rc.m/S06dbus
ln -s ../init.d/cups rc.m/S07cups
ln -s ../init.d/ssh rc.m/S08ssh
ln -s ../init.d/X11-wait rc.m/S10wait
ln -s ../init.d/hald rc.m/S11hald
ln -s ../init.d/nis rc.m/S30nis

#ln -s ../init.d/exitshell rc.m/S99exitshell

