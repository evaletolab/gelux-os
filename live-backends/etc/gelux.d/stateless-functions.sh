#  Copyright 2005 Olivier Evalet evaleto@gelux.ch
#  This file is part of gelux-live project.
#
#  Parts of this file have been copied from :
#    Morphix scripts  (C) Alex de Landgraaf <alex at delandgraaf dot com>
#    knoppix-autoconfig (C) Klaus Knopper <knopper@knopper.net> 2001
#
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

# char *gelux_get_base_ver()
#
#    get the version of baselayout that this system is running
#
GELUX_LOG=/var/log/gelux-boot

gelux_get_base_ver() {
	[[ ! -r /etc/gelux-release ]] && return 0
	local ver=$(</etc/gelux-release)
	echo ${ver##* }
}

gelux_create_ramdisk(){
# We check for available memory anyways and limit the ramdisks
# to a reasonable size.
  FOUNDMEM="$(awk '/MemTotal/{print $2}' /proc/meminfo)"
  TOTALMEM="$(awk 'BEGIN{m=0};/MemFree|Cached/{m+=$2};END{print m}' /proc/meminfo)"
 
# Be verbose
  einfo "${BLUE}Total memory found: ${YELLOW}${FOUNDMEM}${BLUE} kB${NORMAL}"

# Now we need to use a little intuition for finding a ramdisk size
# that keeps us from running out of space, but still doesn't crash the
# machine due to lack of Ram

# Minimum size of additional ram partitions
  MINSIZE=2000
# At least this much memory minus 30% should remain when home and var are full.
  MINLEFT=16000
# Maximum ramdisk size
  MAXSIZE="$(expr $TOTALMEM - $MINLEFT)"
# Default ramdisk size for ramdisk
  RAMSIZE="$(expr $TOTALMEM / 5)"

# Check for sufficient memory to mount extra ramdisk for /home + /var
  if test -n "$TOTALMEM" -a "$TOTALMEM" -gt "$MINLEFT"; then
    test -z "$RAMSIZE" && RAMSIZE=1000000
    mkdir -p /ramdisk

# tmpfs/varsize version, can use swap
    RAMSIZE=$(expr $RAMSIZE \* 4)
    ebegin  "${BLUE}Creating ${YELLOW}/ramdisk${BLUE} (dynamic size=${RAMSIZE}k) on ${MAGENTA}/dev/shm${BLUE}...${NORMAL}"
# We need /bin/mount here for the -o size= option
    /bin/mount -n -t tmpfs -o "size=${RAMSIZE}k" /dev/shm /ramdisk 
    eend  $?
  else
    eerror "Insufficient memory to create ramdisk."
  fi
}




gelux_detect_cpu(){

# CPU info
  einfo "${BLUE}$(awk -F: '/^processor/{printf "Processor"$2" is "};/^model name/{printf $2};/^vendor_id/{printf vendor};/^cpu MHz/{printf " %dMHz",int($2)};/^cache size/{printf ","$2" Cache"};/^$/{print ""}' /proc/cpuinfo 2>>/etc/sysconfig/stderr)${NORMAL}"
#Trying to manage CPU scaling ondemand
  [ ! -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor -a -n "$P4CLOCK" ] && modprobe p4-clockmod 2>/dev/null
  if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ];then
    ebegin "${BLUE}Setting CPU scaling governor : ${GREEN}ondemand${NORMAL}"
    echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    eend 0
  fi 

}

gelux_detect_acpi(){
  if [ -d /proc/acpi ]; then
  # ACPI
    if checkbootparam "noacpi"; then
      einfo "Skipping ACPI Bios detection as requested on boot commandline.${NORMAL}"
    else
      found=""
      ebegin "${BLUE}ACPI power management functions enabled${NORMAL}"
      for a in /lib/modules/`uname -r`/kernel/drivers/acpi/*; do
        basename="${a##*/}"
        basename="${basename%%.*}"
        case "$basename" in *_acpi)
            egrep -qi "${basename%%_acpi}" /proc/acpi/dsdt 2>/dev/null || continue ;;
        esac
        modprobe $basename >>/etc/sysconfig/stderr 2>&1 && found="yes"
      done
      test -z "$found"
      eend $?
    fi
  fi
}

gelux_detect_pcmcia(){
  if checkbootparam "nopcmcia"; then
      echo "Skipping PCMCIA detection as requested on boot commandline.${NORMAL}"
  else
    modprobe pcmcia_core >/dev/null 2>&1
    modrobe yenta_socket >/dev/null 2>&1 && HOTPLUG="yes" || modrobe i82365 >/dev/null 2>&1 || modrobe tcic >/dev/null 2>&1
    if [ "$?" != "0" ];then
      # No PCMCIA Bus present.
      [ -n "$HOTPLUG" ] || rmmod pcmcia_core 2>/dev/null
    else
      ebegin "PCMCIA found, starting cardmgr.${NORMAL}"
      insmod ds >/dev/null 2>&1
      cardmgr >/dev/null 2>&1 && sleep 4
      eend $?
    fi
  fi
}

gelux_detect_usb(){
    # FIXME it should only write the configuration on the mainmod
    modprobe uhci_hcd 2>/dev/null
    modprobe usbhid   2>/dev/null
    modprobe usbmouse 2>/dev/null
}

gelux_detect_firewire(){
  # Firewire enable
  if checkbootparam "nofirewire"; then
    ebegin "Skipping Firewire detection as requested on boot commandline.${NORMAL}"
    eend 0
  else
  # We now try to load the firewire module
    insmod ieee1394 >/dev/null 2>&1
    FOUNDFIREWIRE=""
    FIREWIREREINIT="yes"
    if stringinfile ohci1394 /proc/modules; then
      FOUNDFIREWIRE="yes"
      FIREWIREREINIT="yes"
    elif modprobe ohci1394 >/dev/null 2>&1; then
      FOUNDFIREWIRE="yes"
      FIREWIREREINIT=""
    fi
    if [ -n "$FOUNDFIREWIRE" ]; then
      HOTPLUG="yes"
      if [ -n "$FIREWIREREINIT" -a -x /etc/hotplug.d/ieee1394/rescan-scsi-bus.sh ]; then
        ebegin "(Re-)scanning firewire devices...${NORMAL} "
        /etc/hotplug.d/ieee1394/rescan-scsi-bus.sh >/dev/null 2>&1
        eend $?
      fi
      echo -n "${NORMAL}"
      eend 0
    fi
  fi
}

gelux_detect_hdparm(){
# We now enable DMA right here, for faster reading/writing from/to IDE devices
# in NOCD mode
if test -n "$DMA" ; then
  for d in $(cd /sys/block  >/dev/null && echo [sh]d[a-z]); do
    if test -d /sys/block/$d; then
      MODEL="$(cat /proc/ide/$d/model 2>/dev/null)"
      [ -z "$MODEL" ] && MODEL="$(cat /sys/block/$d/device/vendor 2>/dev/null)$(cat /sys/block/$d/device/model 2>/dev/null)"
      [ -z "$MODEL" ] && MODEL="[GENERIC DEVICE]"
      einfo "${BLUE}Enabling DMA acceleration for: ${MAGENTA}$d 	${YELLOW}[${MODEL}]${NORMAL}"
      hdparm -d1 -c3 -u1 /dev/$d  &>/dev/null
      #echo "using_dma:1" >/proc/ide/$d/settings
    fi
  done
fi
}

gelux_detect_alsa_sound(){
  DRIVERS="$SOUND_DRIVER" alsasound
  
  # This should be in morphix-alsasound script
  #
  if [ -n "$SOUND_FULLNAME" -o -n "$SOUND_DRIVER" -o -z "$NOAUDIO" ]
      then
      count=0
  # Setting micro input to zero to avoid subsonic disaster
  # if using alsa, this leads to error-messages
      [ -z "$NOAUDIO" ] && ( exec aumix -m 0 >/dev/null 2>&1 & )
      # Added $DRIVER from /etc/sysconfig/sound
      SOUNDCARD="$SOUND_DRIVER $DRIVER"
      for i in $SOUNDCARD;do
        echo -n ""
        [ -n "${SOUND_FULLNAME[count]}" ] && einfo "Soundcard: ${YELLOW}${SOUND_FULLNAME[count]}${NORMAL}"
        count=$((count+1))
      done
  fi
}

gelux_detect_xorg(){
  if checkbootparam noagp; then
      einfo "${BLUE}Skipping AGP detection as requested on boot commandline.${NORMAL}"
  else
      stringinfile "AGP" "/proc/pci" 2>/dev/null && modprobe agpgart agp_try_unsupported=1 >/dev/null 2>&1
  fi
  
  # KNOPPIX/Morphix automatic XFree86 Setup
  # now uses Fabians/Kano's ddcx patch
  if ! checkbootparam "nomkxf86config"; then
      mkxf86config
  fi
  
  # Read in changes
  [ -f /etc/sysconfig/gelux ] && . /etc/sysconfig/gelux
  
  if [ -n "$INTERACTIVE" ]
      then
      echo -n "${CYAN}Do you want to (re)configure your graphics (X11) subsystem? (not currently working in Morphix)${NORMAL} [Y/n] "
      read a
      [ "$a" != "n" ] && xf86cfg -textmode -xf86config /etc/X11/XF86Config-4 >/dev/console 2>&1 </dev/console
      echo " ${GREEN}Interactive configuration finished. Everything else should be fine for now.${NORMAL}"
  fi
}

# Check for blind option or brltty
gelux_detect_braille(){
  if [ -n "$BLIND" -o -n "$BRLTTY" ]; then
      if [ -x /sbin/brltty ]; then
  # Blind option detected, start brltty now.
    CMD=brltty
    BRLTYPE=""
    BRLDEV=""
    BRLTEXT=""
    if [ -n "$BRLTTY" ]; then
  # Extra options
        BRLTYPE="${BRLTTY%%,*}"
        R="${BRLTTY#*,}"
        if [ -n "$R" -a "$R" != "$BRLTTY" ]; then
      BRLTTY="$R"
      BRLDEV="${BRLTTY%%,*}"
      R="${BRLTTY#*,}"
      if [ -n "$R" -a "$R" != "$BRLTTY" ]; then
          BRLTTY="$R"
          BRLTEXT="${BRLTTY%%,*}"
          R="${BRLTTY#*,}"
      fi
        fi
    fi
    [ -n "$BRLTYPE" ] && CMD="$CMD -b $BRLTYPE"
    [ -n "$BRLDEV" ] && CMD="$CMD -d $BRLDEV"
    [ -n "$BRLTEXT" ] && CMD="$CMD -t $BRLTEXT"
    echo " ${BLUE}Starting braille-display manager: ${GREEN}${CMD}${BLUE}.${NORMAL}"
    ( exec $CMD & )
    sleep 2
      fi
  fi
}

gelux_detect_identity(){
  LANGUAGE="$(getbootparam lang)"
  MHOSTNAME="$(getbootparam hostname)"
  USERNAME="$(getbootparam username)"
  [ -z "$MHOSTNAME" ] && MHOSTNAME=gelux
  ### localization
  # Allow language specification via commandline. The default language
  # will be overridden via "lang=de" boot commandline
  [ -n "$LANGUAGE" ] || LANGUAGE="fr_CH"
  
  # Source the locales, which have been placed in a separate file
  
  . /etc/gelux.d/locales.sh
  
  # Export it now, so error messages get translated, too
  export LANG COUNTRY CHARSET

  # Set hostname
  echo $MHOSTNAME > $G_ROOTFS_RW/etc/hostname
  hostname $MHOSTNAME
  sed -e "s|[Gg]elux|$MHOSTNAME|g" /etc/hosts >$G_ROOTFS_RW/etc/hosts
  
  
  if [ -z $USERNAME ]; then
      USERNAME="demo"
  fi
  
  
  [ -f "$G_ROOTFS_RW/usr/share/zoneinfo/$KTZ" ] && TZ="$KTZ"
  if [ -f "$G_ROOTFS_RW/usr/share/zoneinfo/$TZ" ]; then
    rm -f $G_ROOTFS_RW/etc/localtime
    rm -f $G_ROOTFS_RW/etc/timezone
    cp "$G_ROOTFS_RW/usr/share/zoneinfo/$TZ" $G_ROOTFS_RW/etc/localtime
    echo $TZ >$G_ROOTFS_RW/etc/timezone
  fi
  
  
  # Write Morphix config files for other scripts to parse
  # Standard variables/files
  echo "LANG=\"$LANG\""                 >> /etc/sysconfig/i18n
  echo "COUNTRY=\"$COUNTRY\""           >> /etc/sysconfig/i18n
  echo "LANGUAGE=\"$LANGUAGE\""         >> /etc/sysconfig/i18n
  echo "CHARSET=\"$CHARSET\""           >> /etc/sysconfig/i18n
  echo "XMODIFIERS=\"$XMODIFIERS\""     >> /etc/sysconfig/i18n
  echo "TZ=\"$TZ\""                     >> /etc/sysconfig/i18n
  
  # Default Keyboard layout for console and X
  echo "KEYTABLE=\"$KEYTABLE\""         >> /etc/sysconfig/keyboard
  echo "KEYTABLEFILE=\"$KEYTABLEFILE\"" >> /etc/sysconfig/keyboard
  echo "XKEYBOARD=\"$XKEYBOARD\""       >> /etc/sysconfig/keyboard
  echo "KDEKEYBOARD=\"$KDEKEYBOARD\""   >> /etc/sysconfig/keyboard
  echo "KDEKEYBOARDS=\"$KDEKEYBOARDS\"" >> /etc/sysconfig/keyboard
  echo "CONSOLEFONT=\"$CONSOLEFONT\""   >> /etc/sysconfig/keyboard
  echo "CHARSET_MAP=\"$CHARSET_MAP\""   >> /etc/sysconfig/keyboard
  
  # Desired desktop
  echo "DESKTOP=\"$DESKTOP\""           >> /etc/sysconfig/desktop
  echo "USERNAME=\"$USERNAME\""         >> /etc/sysconfig/desktop

# Write all, including non-standard variables, to /etc/sysconfig/morphix-all
  echo "LANG=\"$LANG\""                 >> /etc/sysconfig/gelux
  echo "COUNTRY=\"$COUNTRY\""           >> /etc/sysconfig/gelux
  echo "LANGUAGE=\"$LANGUAGE\""         >> /etc/sysconfig/gelux
  echo "CHARSET=\"$CHARSET\""           >> /etc/sysconfig/gelux
  echo "KEYTABLE=\"$KEYTABLE\""         >> /etc/sysconfig/gelux
  echo "KEYTABLEFILE=\"$KEYTABLEFILE\"" >> /etc/sysconfig/gelux
  echo "XKEYBOARD=\"$XKEYBOARD\""       >> /etc/sysconfig/gelux
  echo "KDEKEYBOARD=\"$KDEKEYBOARD\""   >> /etc/sysconfig/gelux
  echo "KDEKEYBOARDS=\"$KDEKEYBOARDS\"" >> /etc/sysconfig/gelux
  echo "CONSOLEFONT=\"$CONSOLEFONT\""   >> /etc/sysconfig/gelux
  echo "CHARSET_MAP=\"$CHARSET_MAP\""   >> /etc/sysconfig/gelux
  echo "DESKTOP=\"$DESKTOP\""           >> /etc/sysconfig/gelux
  echo "TZ=\"$TZ\""                     >> /etc/sysconfig/gelux

  ebegin "${BLUE}Setting localisation to : ${GREEN}${LANG}, ${CHARSET}, ${KEYTABLE} and ${TZ}${NORMAL}"
  eend $?
  ebegin "${BLUE}Setting hostname $(hostname)${BLUE} and default user to ${GREEN}${USERNAME}${NORMAL}"
  eend $?
}

gelux_detect_fstab(){
  # Start creating /etc/fstab with HD partitions and USB SCSI devices now
  ebegin "${BLUE}Scanning for Harddisk partitions and creating ${YELLOW}/etc/fstab${NORMAL}"
  rebuildfstab -r -u $USERNAME >/dev/null 2>>/etc/sysconfig/stderr
  val=$?
  if [ -e /var/run/rebuildfstab.pid ]; then
  # Another instance of rebuildfstab, probably from hotplug, is still running, so just wait.
      sleep 8
  fi
  eend $val
  cp /etc/fstab $G_ROOTFS_RW/etc/fstab
}

gelux_detect_swap(){
  while read p m f relax; do
    case "$p" in *fd0*|*proc*|*\#*) continue;; esac
    options="users,exec"
    fnew=""
    case "$f" in swap)
      if [ -n "$NOSWAP" ]; then
          einfo "${BLUE}Ignoring swap partition ${MAGENTA}$p${BLUE} as requested.${NORMAL}"
      else
          einfo "${BLUE}Using swap partition ${MAGENTA}$p${BLUE}.${NORMAL}"
          swapon $p 2>>/etc/sysconfig/stderr
      fi
      continue
      ;;
    esac
    case "$f" in vfat|msdos)
      if [ -z "$NOSWAP" ] && mount -o uid=$USERNAME,gid=users,ro -t $f $p $d 2>/dev/null; then
        for swapfile in "morphix.swp $DERIVATE.swp gelux.swp knoppix.swp ";do
          if [ -f $d/$swapfile ]; then
            mount -o remount,rw $d
            if swapon $d/$swapfile 2>>/etc/sysconfig/stderr; then
              einfo "${BLUE}Using $DERIVATE swapfile ${MAGENTA}$d/$swapfile${BLUE}.${NORMAL}"
              mount -o remount,ro $d 2>/dev/null
              fnew="$d/$swapfile swap swap defaults 0 0"
              stringinfile "$fnew" "/etc/fstab" || echo "$fnew" >> /etc/fstab
              FIND_SWAP=yes
              break;
            fi
          fi
        done
        [ -z "$FIND_SWAP" ] &&  umount $d
      fi
      ;;
    esac
  done </etc/fstab
  cp /etc/fstab $G_ROOTFS_RW/etc/fstab
}

gelux_install_bindhome(){
  ebegin "${BLUE}Creating directories ${NORMAL}"

  BIND_RAMFS="yes"
  if test -n "$BINDHOME" ; then
    ebegin "${BLUE}Mounting persistant data on $BINDHOME ${NORMAL}"
    mkdir /mnt/persistant 2>/dev/null
    if  mountit $BINDHOME /mnt/persistant 1>/dev/null 2>>/etc/sysconfig/stderr;then
      mkdir /mnt/persistant/home  2>/dev/null
      mkdir /mnt/persistant/root  2>/dev/null
      mkdir -p /mnt/persistant/tmp 2>/dev/null
      mkdir -p /mnt/persistant/var/tmp 2>/dev/null
      mount --bind /mnt/persistant/home $G_ROOTFS_RW/home
      mount --bind /mnt/persistant/root $G_ROOTFS_RW/root
      mount --bind /mnt/persistant/tmp  $G_ROOTFS_RW/tmp
      mount --bind /ramdisk/tmp         $G_ROOTFS_RW/var/tmp
      rm -rf $G_ROOTFS_RW/tmp/*
      eend 0
      BIND_RAMFS=""
    else
      eend 1
    fi
  fi
  if test -n "$BIND_RAMFS";then
      mount --bind /ramdisk/home $G_ROOTFS_RW/home
      mount --bind /ramdisk/root $G_ROOTFS_RW/root
      mount --bind /ramdisk/vartmp $G_ROOTFS_RW/var/tmp
      mount --bind /ramdisk/tmp $G_ROOTFS_RW/tmp
  fi
  mkdir $G_ROOTFS_RW/mnt 2>/dev/null
  mount --bind /ramdisk/mnt $G_ROOTFS_RW/mnt
  mount --bind /dev $G_ROOTFS_RW/dev
  mount --bind /proc $G_ROOTFS_RW/proc
  eend $?
}

gelux_install_varlib(){
  if [ -n "$PERSISTENT_VARLIB" ];then
    ebegin "${BLUE}Synchronising persistent var/lib"
    mkdir /mnt/persistant/varlib  2>/dev/null
    if unison -batch -auto -ui text $G_ROOTFS_RO/var/lib /mnt/persistant/varlib 2>>/etc/sysconfig/stderr;then
      mount --bind /mnt/persistant/varlib $G_ROOTFS_RW/var/lib 2>/dev/null
      eend 0
    else
      eend 1
    fi
  fi
}

# current distrib backends debian/ubuntu, suse, gentoo, redhat, archlinux 
gelux_detect_backend(){
  if [ -e $G_ROOTFS_RO/etc/debian_version ];then
    G_DIST_BACKEND="debian"
  elif [ -e $G_ROOTFS_RO/etc/SuSE-release ];then
    G_DIST_BACKEND="suse"
  elif [ -e $G_ROOTFS_RO/etc/gentoo-release ];then
    G_DIST_BACKEND="gentoo"
  elif [ -e $G_ROOTFS_RO/etc/redhat-release ];then
    G_DIST_BACKEND="redhat"
  elif [ -e $G_ROOTFS_RO/etc/arch-release ];then
    G_DIST_BACKEND="archlinux"
  else
    einfo "Could not detect backend using default ${GREEN}$G_DIST_BACKEND"
  fi
  export G_DIST_BACKEND
}

gelux_install_backend_env(){
  mkdir $G_ROOTFS_RW/selinux
  cp -a /etc/gelux.d $G_ROOTFS_RW/etc/ 2>>/etc/sysconfig/stderr
  cp -a /usr/share/gelux-backend/common/conf.d/* $G_ROOTFS_RW/etc/gelux.d/ 2>>/etc/sysconfig/stderr
  cp -a /usr/share/gelux-backend/$G_DIST_BACKEND/conf.d/* $G_ROOTFS_RW/etc/gelux.d 2>>/etc/sysconfig/stderr
  source /usr/share/gelux-backend/common/common.include 2>>/etc/sysconfig/stderr
  source /usr/share/gelux-backend/$G_DIST_BACKEND/backend.include 2>>/etc/sysconfig/stderr
  source /usr/share/gelux-backend/$G_DIST_BACKEND/update-env 2>>/etc/sysconfig/stderr
}

gelux_install_firmware(){
  mkdir -p $G_ROOTFS_RW/$G_BACKEND_FIRMWARE
  mount --bind /lib/firmware/ $G_ROOTFS_RW/$G_BACKEND_FIRMWARE

  # I dont know where to put the alsa firmaware
  #mount --bind /usr/share/alsa/firmware/ $G_ROOTFS_RW/usr/share/hotplug/firmware/
}

gelux_mount_modules() {
  MODS="$(ls $1/modules/*.mod 2>/dev/null )"
  MODS_COUNT="$(ls -1 $1/modules/*.mod 2>/dev/null | wc -l)"
  for module in $MODS; do
    SHORTNAME=$(basename $module)
    mount-module $module /mnt/$SHORTNAME
    echo "/mnt/$SHORTNAME" >>/etc/sysconfig/mounts
  done
}

gelux_install_modules() {
  chroot . /bin/sh -c 'for mods in $(ls -1d /mnt/.hidden_base/mnt/*.mod 2>/dev/null );do [ -e $mods/gelux/loadmod.sh ] && sh $mods/gelux/loadmod.sh $mods 2>>/etc/sysconfig/stderr;done'  
}

gelux_install_packages() {
  USEDIR=$1
# Deb-morph, install all debian packages in /deb on the cdrom
  DEBS="$(ls -1 $1/extra/$PKG_EXT/*.$PKG_EXT 2>/dev/null | wc -l )"
  if [ $DEBS -gt 0 ]; then
    # done anyways
    # touch /var/lib/dpkg/status
    chroot . $PKG_CMD $1/extra/$PKG_EXT/*.$PKG_EXT 1>/dev/null 2>>/etc/sysconfig/stderr
  fi
}

gelux_install_main_module(){
  mkdir -p /usr/share/gelux 2>/dev/null
  touch /usr/share/gelux/geluxmainconf
  chroot . /bin/sh -c 'for file in $(ls -1 /etc/gelux.d/[0-9]*.default);do source $file 2>>/etc/sysconfig/stderr;done'
}


# vim:ts=4
