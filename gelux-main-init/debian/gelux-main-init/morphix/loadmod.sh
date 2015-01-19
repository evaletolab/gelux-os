#!/bin/sh
# Minimodule loading has been moved to the base module,
# so now all this script does is execute the init.sh script in the 
# chroot-fs that's all ready for use...
#
# $Id: loadmod.sh,v 1.1.1.1 2005/01/19 16:56:14 evaleto Exp $
#
echo "Chrooting to MainModule"
chroot /mnt/main bash /morphix/init.sh 
#
