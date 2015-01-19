
SUBDIRS = 

#if USE_FULLINSTALL
#EXTRA_DIST = \
#	debian-post-install.sh \
#	debian-installer.glade \
#	debian-installer.desktop
#else
EXTRA_DIST = \
	node-post-install.sh \
	node-installer.glade \
	node-installer.desktop
#endif

desktopdir=$(datadir)/applications
desktop_DATA=node-installer.desktop

gladedir = $(datadir)/gelux-installer
#if USE_FULLINSTALL
#glade_DATA = debian-installer.glade
#else
glade_DATA = node-installer.glade node-post-install.sh
#endif
