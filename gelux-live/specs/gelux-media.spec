#tips 
#  ebuild digest hwsetup-1.1.ebuild 
#  cp /dev
#  cp modules/
# LIRC_OPTS="--with-driver=none"

# Important things
# 1) first you should update python : emerge python && python-update
# 2) beware with xorg USES options, ideal small and fast 
#    - with or whitout opengl? for freevo/mythtv its not needed
#    - without dmx dammage
#    - without bitmap fonts
# 3) the profile must be 2005.1-r1, if you want swith with uclib use an other spec
# 4) install libstdc++ in your destdir/ (options --install-stdcpp)
# 5) update opengl link if xyou need it

# workaround
# opengl could no be used!! opengl-update do not work

subarch: x86
version_stamp: 2005.1-r1
target: live-stage1
rel_type: default
profile: default-linux/x86/2005.1-r1
snapshot: unofficial
source_subpath: default/stage3-x86-2005.1-r1
destdir: /gelux-media
cflags:-Os -mcpu=i686 -pipe -fomit-frame-pointer 
compress: squashfs
live/use:
  -*
  -cpudetection 
  ssl
  netboot 
  ipv6 
  png 
  truetype 
  unicode 
  -nocxx	
  make-symlinks
  -minimal
  alsa
  lirc
  -uclibc
  X
  xv
  xvmc
  opengl
  -dmx
  -sdk
  -bitmap-fonts
  nls
  linuxthreads-tls
  nptl
  nptlonly
  insecure-drivers
  truetype-fonts
  alsa
  wordexp
  -mythtv
  ffmpeg
  win32codecs
  custom-cflags
  mp3
  rle
  theora
  vl4
  xvid
  dvd
  dvdread
  dv
  cdparanoia 
  encode 
  mad
  -mysql
  gif
  jpeg
  png
  ogg
  ipv6
  sdl
  vcd
  -svga
  pam
  

live/packages:
  baselayout
  busybox
  sysvinit
  shadow
  util-linux
  bash
  gawk
  findutils
  alsa-utils
  kbd
  ssh
  xorg-x11

live/unstable:

live/todo:
  init
  gelux-hwsetup
  ddcxinfo-knoppix
  alsa-firmware

#WARING do not use space in path!
live/postremove:
  var/db
  usr/include/*
  usr/share/man/*
  usr/share/info/*
  usr/share/doc/*
  usr/src/*
  usr/qt/3/include 
  usr/qt/3/bin/
  etc/bootsplash
  usr/share/bootsplash
  sbin/debugfs
  usr/share/cursors/xorg-x11/handhelds
  usr/share/cursors/xorg-x11/redglass
  usr/share/cursors/xorg-x11/whiteglass
  usr/share/cursors/xorg-x11/gentoo-*
  usr/bin/xv
  usr/bin/Xvfb
  usr/bin/xorgcfg
  usr/bin/xedit
  usr/lib/locale/kw_GB*
  usr/lib/locale/zh_TW*
  usr/lib/locale/ar_OM* 
  usr/lib/locale/ro_RO*
  usr/lib/locale/iw_IL*
  usr/lib/locale/sq_AL*
  usr/lib/locale/mt_MT*
  usr/lib/locale/fr_LU*
  usr/lib/locale/zh_SG*
  usr/lib/locale/tig_ER