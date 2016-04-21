SUBDIRS = method report

WRAPPER_SED = sed                                       \
        -e "s|\@prefix\@|$(prefix)|g"                   \
        -e "s|\@pkglibdir\@|$(pkglibdir)|g"             \
        -e "s|\@libdir\@|$(libdir)|g"                   \
        -e "s|\@datadir\@|$(datadir)|g"                 \
        -e "s|\@pkgdatadir\@|$(pkgdatadir)|g"           \
        -e "s|\@localedir\@|$(datadir)/locale|g"        \
        -e "s|\@docdir\@|$(datadir)/doc/$(PACKAGE)-$(VERSION)|g" \
        -e "s|\@libexecdir\@|$(libexecdir)|g"           \
        -e "s|\@bindir\@|$(bindir)|g"                   \
        -e "s|\@sbindir\@|$(sbindir)|g"                 \
        -e "s|\@sysconfdir\@|$(sysconfdir)|g"           \
        -e "s|\@localstatedir\@|$(localstatedir)|g"     \
        -e "s|\@gacprefix\@|$(GAC_PREFIX)|g"            \
        -e "s|\@VERSION\@|$(VERSION)|g"                 \
        -e "s|\@VERSION_DATE\@|$(VERSION_DATE)|g"	\
        -e "s|\@PACKAGE\@|$(PACKAGE)|g"                 \
        -e "s|\@bash\@|$(BASH)|g"


bin_SCRIPTS = $(PACKAGE) 

synbakfunctiondir = $(pkgdatadir)
synbakfunction_SCRIPTS = functions.sh

$(PACKAGE): $(PACKAGE).sh.in
	$(WRAPPER_SED) < $(srcdir)/$(PACKAGE).sh.in > $@
	chmod a+x $(PACKAGE)

EXTRA_SCRIPTS = none

EXTRA_DIST = $(PACKAGE).sh.in $(synbakfunction_SCRIPTS)

CLEANFILES = $(PACKAGE)
