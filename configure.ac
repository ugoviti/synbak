# process this file with autoconf to produce a configure script.

AC_INIT([synbak], [3.8.0], [opensource@initzero.it])
AC_CONFIG_SRCDIR([src])
AM_INIT_AUTOMAKE
VERSION_DATE="20200803"
RELEASE="1"

AC_SUBST(VERSION_DATE)
AC_SUBST(RELEASE)

# Checks for programs.
AC_PROG_EGREP

AC_CHECK_PROGS(LS, ls)
AC_CHECK_PROGS(CAT, cat)
AC_CHECK_PROGS(NC, nc)

AM_GNU_GETTEXT([external]) 
AM_GNU_GETTEXT_VERSION([0.19.4])

AC_CONFIG_FILES([
Makefile
synbak.spec
src/Makefile
src/method/Makefile
src/method/dar/Makefile
src/method/laserdisc/Makefile
src/method/ldap/Makefile
src/method/mysql/Makefile
src/method/pgsql/Makefile
src/method/oracle/Makefile
src/method/rsync/Makefile
src/method/scp/Makefile
src/method/tape/Makefile
src/method/tar/Makefile
src/method/wget/Makefile
src/report/Makefile
src/report/email/Makefile
src/report/html/Makefile
src/report/html/images/Makefile
src/report/html/js/Makefile
src/report/html/calendar/Makefile
m4/Makefile
po/Makefile.in
])

AC_OUTPUT

