#!/bin/sh
# $Id: make_symlinks.sh,v 1.1.1.1 2004/09/24 15:27:16 mkalbere Exp $
mkdir -p rc.m
ln -s ../init.d/basemodule rc.m/S01basemodule
ln -s ../init.d/drm rc.m/S02drm
ln -s ../init.d/console rc.m/S03console
ln -s ../init.d/sudoers rc.m/S04sudoers
ln -s ../init.d/cups rc.m/S05cups
ln -s ../init.d/X11-setup rc.m/S08X11-setup
ln -s ../init.d/X11-wait rc.m/S20X11-wait
ln -s ../init.d/X11-shutdown rc.m/S90X11-shutdown
ln -s ../init.d/exitshell rc.m/S99exitshell

