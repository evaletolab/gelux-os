#tips 
#  ebuild digest hwsetup-1.1.ebuild 
#  cp /dev
#  cp modules/

subarch: x86
version_stamp: 2005.1
target: live-stage1
rel_type: default
profile: default-linux/x86/2005.1
snapshot: official
bootparams: ramdisk=20000 vga=791 selinux=0 fast root=/dev/ram0 init=/linuxrc rw
source_subpath: default/stage3-x86-2005.1
destdir: /initrd-gentoo
compress: img.gz
live/use:
  -*
  netboot 
  ipv6 
  opengl 
  png 
  truetype 
  unicode 
  nocxx	
  make-symlinks
  minimal

live/packages:
  baselayout-lite 
  uclibc
  busybox
  net-tools
  udhcp
  util-linux
  pciutils
  bash
  gawk
  module-init-tools
  hdparm
  portmap
  file
  read-edid
  hwdata-gentoo
  bootsplash
  zd1201-firmware 
  prism54-firmware 
  ipw2200-firmware 
  ipw2100-firmware 
  acx-firmware  
  bluez-firmware 

live/unstable:
  linux-wlan-ng-firmware

live/todo:
  net-misc/rsync
  gelux-hwsetup
  ddcxinfo-knoppix
  alsa-firmware
