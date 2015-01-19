#!/bin/sh
#
#  Copyright 2005 Olivier Evalet
#  This file is part of gelux-livecd.
#
#  gelux is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as
#  published by the Free Software Foundation; either version 2 of the
#  License, or (at your option) any later version.
#
#  gelux is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
#  License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with gelux; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
#  USA.

#ge_destdir=/initrd-gentoo
ge_spec_file="$PWD/specs/gelux-live.spec"
ge_prefix="/home/devel/gelux/cd7"
help=""
verbose=""
emerge=""
emergeopts=""
build=""
make=""
install=""
build_dir=/tmp/gelux.build
initrd_sz=18

install_files="./bootsplash  ./etc ./usr ./linuxrc ./nfsrc" 
mkdirs="./cdrom ./proc ./sys ./lib/modules"

arg="$1"
[ -z "$arg" ] && help=yes
while [ -n "$arg" ]; do
 case "$arg" in
  -h*) help="yes" ;;
  -v*) verbose="yes" ;;
  -b*) build="yes" ;;
  -c*) copy="yes" ;;
  -e*) shift;emerge="$1" ;;
  --emerge-options=*) shift;emergeopts="$1" ;;
  -m*) make="yes" ;;
  -i*) install="yes" ;;
  -s*) shift;ge_spec_file="$1" ;;
  *) help="yes";;
 esac
 shift
 arg="$1"
done

if [ -n "$help" ];then
  echo    "Use $0 to maintain a gelux live initrd"
  echo "  [-h|-help]                      print this help"
  echo "  [-e|-emerge \"packages\"]       emerge packages on image"
  echo "  [-c|-copy]                      copy image on /tmp/\$prefix"
  echo "  [-i|-install]                   install image on prefix"
  echo "  [-b|-build]                     copy scripts and build a new initrd.img.gz "
  echo "  [-m|-make]                      make a gentoo embedded from specs"
  echo "  [-s|-spec-file '/path/to/spec'] specify a spec file,"
  echo "                                  [$ge_spec_file]"
  echo "  [-v|-verbose]                   print extra messages"
  echo
  exit
fi

ge_compress=$(grep -o "compress:.*" $ge_spec_file|sed  -e 's/.*:[ ]\?\(.*\)/\1/g')
ge_destdir=$(grep -o "destdir:.*" $ge_spec_file|sed  -e 's/.*:[ ]\?\(.*\)/\1/g')
USE="$(sed -n  -e "/use:$/,/^$/p" $ge_spec_file |tr -d "\n" |sed -e "s|.*:||g")"
PACKAGES="$(sed -n  -e "/packages:$/,/^$/p" $ge_spec_file |tr -d "\n" |sed -e "s|.*:||g")"

gelux_squash_mount(){
  [ -d $build_dir ] || mkdir -p $build_dir 2>/dev/null
  [ -d $build_dir/initrd ] || mkdir $build_dir/initrd 2>/dev/null
}

gelux_squash_copy(){
  echo "rm -rf $build_dir/$ge_destdir "
  rm -rf $build_dir/$ge_destdir 
  echo "cp -ap $ge_destdir $build_dir/"
  cp -ap $ge_destdir $build_dir/
  rm -rf $build_dir/$ge_destdir/bin/find
  rm -rf $build_dir/$ge_destdir/var/db
  rm -rf $build_dir/$ge_destdir/usr/include
  rm -rf $build_dir/$ge_destdir/usr/qt/3/include 2>/dev/null
  rm -rf $build_dir/$ge_destdir/usr/qt/3/bin/  2>/dev/null
  rm -rf $build_dir/$ge_destdir/etc/bootsplash
  rm -rf $build_dir/$ge_destdir/usr/share/info
  rm -rf $build_dir/$ge_destdir/usr/share/bootsplash
  rm -rf $build_dir/$ge_destdir/usr/share/doc
  rm -rf $build_dir/$ge_destdir/usr/share/man
  rm -rf $build_dir/$ge_destdir/usr/src/*
  rm -f  $build_dir/$ge_destdir/usr/share/cursors/xorg-x11/handhelds
  rm -f  $build_dir/$ge_destdir/usr/share/cursors/xorg-x11/redglass
  rm -f  $build_dir/$ge_destdir/usr/share/cursors/xorg-x11/whiteglass
  rm -f  $build_dir/$ge_destdir/usr/share/cursors/xorg-x11/gentoo-*
  rm -f  $build_dir/$ge_destdir/usr/bin/xv
  rm -f  $build_dir/$ge_destdir/usr/bin/Xvfb
  rm -f  $build_dir/$ge_destdir/usr/bin/xorgcfg
  rm -f  $build_dir/$ge_destdir/usr/bin/xedit
  rm -f  $build_dir/$ge_destdir/sbin/debugfs 2>/dev/null
  find   $build_dir/$ge_destdir -name "*.a" -or -name "*.m4" -or -name "*.static" -or -name "*.old"|grep -v "lib/module" |xargs rm
}


gelux_initrd_mount(){
  [ -d $build_dir ] || mkdir -p $build_dir 2>/dev/null
  [ -d $build_dir/initrd ] || mkdir $build_dir/initrd 2>/dev/null
  umount $build_dir/initrd 2>/dev/null
  dd if=/dev/zero of=$build_dir/initrd.img bs=1MB count=$initrd_sz
  mke2fs -N 8192 -m 0 -F $build_dir/initrd.img
  mount -o loop $build_dir/initrd.img $build_dir/initrd
}

gelux_initrd_copy(){
  rm -rf $build_dir/$ge_destdir 2>/dev/null
  cp -ap $ge_destdir $build_dir/
  rm -rf $build_dir/$ge_destdir/var/db
  rm -rf $build_dir/$ge_destdir/usr/include
  rm -rf $build_dir/$ge_destdir/etc/bootsplash
  rm -rf $build_dir/$ge_destdir/etc/init.d
  rm -rf $build_dir/$ge_destdir/usr/share/bootsplash
  rm -f  $build_dir/$ge_destdir/sbin/fbmngplay.static
  rm -f  $build_dir/$ge_destdir/sbin/insmod.static.old
  rm -f  $build_dir/$ge_destdir/sbin/insmod.old
  rm -f  $build_dir/$ge_destdir/sbin/fbtruetype.static
  rm -f  $build_dir/$ge_destdir/usr/bin/tack
  rm -f  $build_dir/$ge_destdir/usr/bin/pgawk-3.1.4
  rm -f  $build_dir/$ge_destdir/sbin/fdisk
  rm -f  $build_dir/$ge_destdir/sbin/depmod.old
  rm -f  $build_dir/$ge_destdir/sbin/debugfs
  rm -f  $build_dir/$ge_destdir/sbin/splash-functions.sh
  if $build_dir/$ge_destdir/usr/share/hwdata/*.ids 2>/dev/null;then
    rm -f  $build_dir/$ge_destdir/usr/share/misc/*.ids
    cd $build_dir/$ge_destdir/usr/share/misc
    cp -s  ../hwdata/*.ids  .
    cd -
  fi
  find   $build_dir/$ge_destdir -name "*.a" -or -name "*.m4" -or -name "*.static" -or -name "*.old"|xargs rm

  mksquashfs $build_dir/$ge_destdir/usr $build_dir/$ge_destdir/modules/usr.squashfs -noappend &>/dev/null
  rm -rf $build_dir/$ge_destdir/usr/*

  rm -rf $build_dir/initrd/* 2>/dev/null
  cp -ap $build_dir/$ge_destdir/* $build_dir/initrd/
}

gelux_initrd_make(){
  if umount $build_dir/initrd;then
    cd $build_dir/
    rm initrd.img.gz 2>/dev/null
    gzip -q -9 initrd.img
    du -hs initrd.img.gz
    cd -
  fi
}

[ -e "linuxrc" -a -e "etc/gelux.d/functions.sh" ] && . etc/gelux.d/functions.sh ||{
  echo "You should run the script at the root of the package gelux-livecd"
  exit 1
}

[ -e /etc/gentoo-release ] ||{
  eerror "$0 should be run on a gentoo subsystem"
  exit 1
}

einfo "starting gelux live functions with: $ge_spec_file"


if [ -n "$build" ];then
  [ -d $ge_destdir ]||{
    echo "ERROR: Could not find gentoo embedded system at $ge_destdir"
    exit 1
  }
  mkdir -p ${ge_destdir}${mkdirs}
  cp -ap $install_files $ge_destdir
  echo " * mount initrd image $initrd_sz Mb"
  gelux_initrd_mount
  echo " * copy files on $build_dir/$ge_destdir"
  gelux_initrd_copy
  echo " * compress image $build_dir/initrd.img "
  gelux_initrd_make
  exit
fi

[ -n "$install" ] && {
  echo " * Installing boot image on $ge_prefix/boot/"
  cp -a $build_dir/initrd.img.gz $ge_prefix/boot/
}

if [ -n "$make" ];then
  [ -d $ge_destdir ]&&{
    echo "WARING: $ge_destdir exist would you like to continue (Ctrl+C)"
    read
  }

  echo "build a new gentoo embedded"
  echo "ROOT=\"$ge_destdir\" USE=\"$USE\" emerge -av $PACKAGES"
  ROOT="$ge_destdir" USE="$USE" emerge -akv $PACKAGES
  exit
fi

if [ -n "$emerge" ];then
  echo "emerge package on $ge_destdir"
  echo "ROOT=\"$ge_destdir\" USE=\"$USE\" emerge -av $emerge"
  ROOT="$ge_destdir" USE="$USE" emerge -akv $emerge $emergeopts
fi

if [ -n "$stdcpp" ];then
  mkdir -p /gelux-media/usr/lib/libstdc++/
#  cp -a $(gcc-config -L)/libg2c.so* /gelux-media/usr/lib/libstdc++/
  GCC_CONFIG=$(gcc-config -L)
  cp -a $GCC_CONFIG/lib*.so* /gelux-media/usr/lib/libstdc++/

  grep -q "/usr/lib/libstdc++" /gelux-media/etc/ld.so.conf || {
    echo "/usr/lib/libstdc++" >> /gelux-media/etc/ld.so.conf
    chroot /gelux-media ldconfig
  }
fi

if [ -n "$copy" ];then
  echo "preparing image..."
  gelux_squash_mount
  gelux_squash_copy
  echo " done --> $build_dir/$ge_destdir"
fi

