##
##
##
## Automake build by evaleto
##

AUTOMAKE_OPTIONS = subdir-objects no-dependencies

SUBDIRS = data

if BUILD_GCJ
bin_PROGRAMS = gelux-installer
endif

gelux_installer_source_files = \
	src/org/programmers/installer/gui/NodeInstaller.java \
	src/org/programmers/installer/type/StatelessInstall.java \
	src/org/programmers/installer/InstallBase.java \
	src/org/programmers/installer/InstallListener.java \
	src/org/programmers/installer/FS.java \
	src/org/programmers/installer/InstallException.java \
	src/org/programmers/installer/Admin.java \
	src/org/programmers/installer/User.java \
	src/org/programmers/installer/DetectPartitions.java \
	src/org/programmers/installer/InstallRunner.java \
	src/org/programmers/installer/Grub.java


if BUILD_GCJ
gelux_installer_SOURCES = $(gelux_installer_source_files)

#
#nodist_gelux_installer_SOURCES = 
#

gelux_installer_GCJFLAGS =  -I$(srcdir)/src -Isrc --classpath=$(PARTEDJAR):$(GTKJAR):$(GNOMEJAR):$(GLADEJAR)
gelux_installer_LDFLAGS = $(PARTEDJAVA_LIBS) $(GTKJAVA_LIBS) $(GNOMEJAVA_LIBS) $(GLADEJAVA_LIBS)  -lgcj --main=org.programmers.installer.InstallBase

endif





# build api docs
apidir = $(datadir)/doc/geluxinstaller-java-$(VERSION)/api

if BUILD_JAVADOC
all-local: $(top_builddir)/doc-stamp
else
all-local:
endif

if BUILD_JAVADOC
doc-stamp: $(gelux_installer_source_files)
	$(JAVADOC) \
		-d doc/api \
		$(JAVADOC_OPTIONS) \
		-classpath $(PARTEDJAR):$(GTKJAR):$(GNOMEJAR):$(GLADEJAR) \
		-sourcepath $(srcdir)/src \
		-windowtitle "gelux-installer $(VERSION) API Reference" \
		-doctitle "gelux-installer $(VERSION) API Reference" \
		-footer "$(JAVADOC_FOOTER)" \
		org.programmers.installer \
		org.programmers.installer.type \
		org.programmers.installer.gui 
	touch doc-stamp
else
doc-stamp:
	touch doc-stamp
endif

# install other docs
docdir = $(datadir)/doc/geluxinstaller-java-$(VERSION)
if HAVE_DOCBOOK
doc_DATA = $(srcdir)/AUTHORS $(srcdir)/COPYING \
	$(srcdir)/NEWS $(srcdir)/README 
else
doc_DATA = $(srcdir)/AUTHORS $(srcdir)/COPYING \
	$(srcdir)/NEWS $(srcdir)/README 
endif



all_dest_geluxinstaller_javadoc_html_files = $(patsubst doc/api/%.html,%.html,$(shell find doc/api -name '*.html'))
dest_geluxinstaller_javadoc_dirs = $(patsubst doc/api/%,%,$(shell find doc/api -mindepth 1 -type d))


# install api documentation
if BUILD_JAVADOC
	$(mkinstalldirs) $(DESTDIR)$(apidir)
	@for dir in $(dest_geluxinstaller_javadoc_dirs); \
	do \
	   $(mkinstalldirs) $(DESTDIR)$(apidir)/$${dir}; \
	done
	@for file in $(all_dest_geluxinstaller_javadoc_html_files); \
	do \
	   $(INSTALL_DATA) doc/api/$${file} $(DESTDIR)$(apidir)/$${file}; \
	done
endif



uninstall-local:
	-rm -rf $(DESTDIR)$(datadir)/doc/geluxinstaller-$(VERSION)

##BUILT_SOURCES = \
##	gelux-installer-java.pc 

##EXTRA_DIST = \
##	m4/jg_parted_java.m4 \

# clean files and directories
CLEANFILES = \
	doc-stamp \
	$(all_gelux_installer_class_files) \
	$(shell find doc/api -name '*.html') \
	doc/api/package-list \
	doc/api/stylesheet.css \
	doc/api/resources/inherit.gif 

clean-local:
	-rm -rf doc/api

# distclean files and directories
DISTCLEANFILES = \
	$(srcdir)/aclocal.m4 \
	$(srcdir)/compile \
	$(srcdir)/config.guess \
	$(srcdir)/config.sub \
	$(srcdir)/depcomp \
	$(srcdir)/install-sh \
	$(srcdir)/ltmain.sh \
	$(srcdir)/missing

distclean-local:
	-rm -rf $(srcdir)/autom4te.cache
