# General automake options.
AUTOMAKE_OPTIONS = foreign
ACLOCAL_AMFLAGS = -I m4

# The list of subdirectories containing Makefiles.
#SUBDIRS = src po examples
SUBDIRS = m4 src po

docdir = $(datadir)/doc/@PACKAGE@-@VERSION@
doc_DATA = AUTHORS CHANGELOG.md COPYING INSTALL NEWS README.md THANKS TODO BUGS FAQ README.fedora

#exampledir = $(datadir)/doc/@PACKAGE@-@VERSION@/examples
#example_DATA = example.conf
#EXTRA_DIST = $(example_DATA)

templatedir = $(pkgdatadir)
template_DATA = template.conf


# Define a C macro LOCALEDIR indicating where catalogs will be installed.
localedir = $(datadir)/locale
DEFS = -DLOCALEDIR=\"$(localedir)\" @DEFS@

release: dist rpm 
	mkdir -p release
	rm -rf release/*
	mv -f rpmbuild/RPMS/*/*		release/
	mv -f rpmbuild/SRPMS/*		release/
	mv -f rpmbuild/SOURCES/*	release/
	rm -rf rpmbuild

pot:
	make -C po update-po

rpm: build-rpm

build-rpm:
	$(MAKE) $(PACKAGE).spec $(PACKAGE).spec.in
	$(MAKE) dist
	mkdir -p rpmbuild/{BUILD,RPMS/{noarch,athlon,i386,i486,i588,i686,x86_64},SOURCES,SPECS,SRPMS}
	mv @PACKAGE@-@VERSION@.tar.gz rpmbuild/SOURCES/
	unset MAKEFLAGS ; test ! -f $$HOME/.bashrc || . $$HOME/.bashrc; \
	rpmbuild --define "_topdir $(PWD)/rpmbuild" \
	--define "debug_package %{nil}" \
	--define "_source_filedigest_algorithm 1" \
        --define "_binary_filedigest_algorithm 1" \
        --define "_binary_payload w9.gzdio" \
        --define "_source_payload w9.gzdio" \
        --define "_default_patch_fuzz 2" \
	-ba @PACKAGE@.spec
	
# Not working in Fedora Core 6?
#unset MAKEFLAGS ; test ! -f $$HOME/.bashrc || . $$HOME/.bashrc; rpmbuild --define "_topdir $(PWD)/rpmbuild" --define "debug_package %{nil}" -ta @PACKAGE@-@VERSION@.tar.gz

# to make rpm with md5 payload
# rpmbuild -bs --define "_source_filedigest_algorithm 0" --define "_binary_filedigest_algorithm 0"

# Source dir rebuild
#rpmbuild --define "_topdir $PWD" --define "_sourcedir $PWD" -ba package.spec

# Source dir rebuild in the same directory
#rpmbuild --define "_sourcedir $PWD" -ba package.spec

# Additional files to be distributed.
EXTRA_DIST = config.rpath  config.rpath config.rpath config.rpath config.rpath config.rpath config.rpath \
		autoclean.sh	\
		autogen.sh	\
		synbak.spec.in	\
		synbak.spec	\
		BUGS		\
		FAQ		\
		README.fedora	\
		README.md	\
		CHANGELOG.md	\
		$(template_DATA)

DISTCLEANFILES = 



