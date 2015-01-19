subarch: x86
version_stamp: 2005.1
target: live-stage1
rel_type: default
profile: default-linux/x86/2005.1
snapshot: official
source_subpath: default/stage3-x86-2005.1
kernel/use:
  minimal
  sdk 
  -pam
  -bitmap-fonts
  -truetype
  -truetype-fonts
  -type1-fonts
  -nls
  -crypt
  -opengl
  -xv
  -X

kernel/packages:
  cloop
  qc-usb
  usb-pwc-re
  acx
  lirc
  ati-drivers

kernel/masked:

# propriatary ati/nvidia drivers depends on hwdata-gentoo
kernel/blocked:
  lirc
  madwifi-driver
  nvidia-kernel
  nvidia-glx
  ati-gatos
  net-dialup/hcfusbmodem
  net-wireless/fwlanusb
  net-dialup/eagle-usb


kernel/extra-modules:
  unionfs
  usbvision
