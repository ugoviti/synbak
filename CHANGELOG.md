# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.8.5] - 2023-12-03
### Fixed
- change default LANG=en to LANG=C

## [3.8.4] - 2023-02-11
### Fixed
- removed the '-C' (compression) option from mysql method because was deprecated since MySQL 8.0.32

## [3.8.3] - 2021-11-17
### Fixed
- fixed current USER detection in check_cuncurrent_limit function

## [3.8.2] - 2021-07-01
### Fixed
- mysql method erase of old dumps: after a error during backup step, subsequent good database dumps will be removed also

## [3.8.1] - 2020-10-01
### Added
- Added new fields on RSS backup report in preparation of synbak zabbix template
### Fixed
- Resolved some issues when using special characters in passwords (like '!' symbol) and cifs/smb mounts

## [3.8.0] - 2020-08-03
### Added
- Added Drone CI build support for automatic rpmbuild support
### Changed
- Come back to semantic versioning (https://semver.org/)
- Switched Changelog to CHANGELOG.md (https://changelog.md/)
### Removed
- Removed dangerous "--add-drop-database" option from mysql method

## [3.7] - 2018-10-06
- added -H (preserve hard links) and -S (manage sparse files) default options to rsync method (thanks to Bakaras)

## [3.6] - 2018-03-14
- Fixed method_rsync_differential using --link-dest not needed
- Fixed mount cifs when specifing domain into username field, ex: cifs://DOMAIN/username:password@host
- Fixed service port testing on debian systems (Thanks ehabheikal)
- Added new method: scp
- Added new default options for mysql backup: -C --force --databases --add-drop-database --opt --quote-names --events --routines --triggers --hex-blob

## [3.5] - 2017-01-03
- Fixed yearly backups

## [3.4] - 2016-02-17
- Fixed html report display wrong year and month in the bottom of the report

## [3.3] - 2015-12-29
- Fixed last day month backup
- Fixed when backup_schedule_planning is missed from configuration file

## [3.2] - 2015-09-10
- Another netcat change (preparation to make synbak usable directly into QNAP NAS)
- added new variable: 'backup_schedule_planning' to handle more easily the
   scheduled backups
- mysql method: make '-M split' the default behavior instead of '-M all'
   from now on, if you want make the all-database backup, you must provide '-M all' option to mysql method

## [3.1] - 2014-09-04
- Fixed a bug into autoerase function of mysql and pgsql backup methods.
   When two mysql backup has the same base name (ex, database, and database-old),
   autoerase always erase only the shorter name.
- Enabled method_concurrent_limit function
- generating status.xml file as rss page feed for the html report, this rss
   feed contain an overall state for the today backups. Very useful when used with
   network monitoring software like nagios or icinga with the plugin check_rss:
   https://github.com/denisbr/nagios-plugins/blob/master/check_rss
   ex. check_rss -H http://synbakserver/admin/log/backup/status.xml -p -v2 -I -U -T 24 -c "Successful:[0],Riusciti:[0]" -w ":[ERROR"
- Updated FAQ file about integrating synbak with nagios and icinga


## [3.0] - 2013-10-12
- new restructuration of template.conf
   RELOAD THE CONFIGURATION FROM SCRATCH IF YOU WANT USE THE NEW 3.0 FEATURES FOR YOUR BACKUPS
- renamed variable backup_device_eject to method_device_eject
- renamed variable backup_verify to method_verify
- renamed variable backup_incremental to method_rsync_differential
- renamed variable backup_remote_uri to backup_source_uri
- added new option: method_concurrent_limit
   this avoid to run concurrent more synbak jobs than specified value
- fixed a bug when backup_source variable is empty
- revamped the tmp_name variable to:
   /tmp/synbak-system-method-YYYYMMDD-HHMMSS.NANOSECONDS
- now when backup_destination doesn't exist synbak will not report that on
   stdout, but only on full html and email reports (this is useful to
   standardize cron and synbak mail reports)
- added Polish translation (many thanks to Piotr Smalira <p.smalira@g16-lublin.eu>)
- fixed rsync automatic hard linking across multiple destination devices
- implemented new URI: file:// (this is optional for local backups, but
   useful to use as base path for the backup_source paths)
- major restructuration of rsync method when using backup_source_uri=file://
- updated FAQ file with synbak 3.0 config file modifications
- fixes when using nmap-ncat instead standard netcat to check hosts reachability
- implemented the base_dir prefix path when using backup_source_uri
- some backup report refactoring
- new rewrite of autoerase function, now is more smart when erasing and keeping backups
- added new variable: 'method_rsync_sudo' synbak will connect to the remote
   host and will run rsync daemon via sudo command (you must add the specified
   user into remote sudoers file. this greatly enhance security, see the FAQ)
   many thanks to Tim Schaller <tim@torzo.com> for the suggestion
- mysql method: added --events option to backup_method_opts_default
- fixed a bug when using backup_destination_prefix = yes

## [2.1] - 2013-01-08
- added failed backups lists into $backup_destination/synbak-failed.log file
   (this failed backups will be erased before good backups)
- fixed a bug into new backups_schedule function (in some days of the month,
   synbak will run monthly backup and not daily)
- updated FAQ file with answer about using synbak with automatic
   daily/weekly/monthly/yearly mode
- modified default synbak template.conf (generally /usr/share/synbak/template.conf),
   you must manually add new configuration directives to your old configs files

## [2.0] - 2012-12-31
- changed synbak version numbering
- added "-E pr=100/noprompt" to the ldap internal export command
- added support for lzo and xz compression into tar method
- removed -x option to du command, because from fedora 17 it's not working as
   expected
- renamed variable 'backup_erase_after' to 'backup_keep'
- renamed variable 'backup_erase_always' to 'backup_keep_on_errors' and inverted
   the boolean operator
- renamed variable 'backup_no_make_destdir' to 'backup_destination_prefix' and inverted
   the boolean operator
- implemented the 'backup_shedule' function to automate and simplify the
   daily/weekly/monthly/yearly backups
- new variable 'backup_destination_automake' to automake the destination dir
   if not exist
- rewritten the erase function to be more smart

## [1.4.0] - 2011-01-05
- changed many report messages (html and email reports)
- fixed a bug with calculating destination size when backup_no_make_destdir=yes is used
- fixed a bug on short open tag in php calendar report
- fixed a bug when erasing old backups when backup_erase_always was used

## [1.3.2] - 2010-08-14
- added a trailing slash into backup destination path used by rsync method command to avoid problems when
   backing up to a full hard disk
- in parse_uri function normalize the password variable with escape keys if problematic characters are found (',!,*)

## [1.3.1] - 2010-06-30
- fixed a bug into rsync method when used with external -o variables override
- updated FAQ file with suggestions to make daily/weekly/monthly/yearly
   backups using a single config file

## [1.3.0] - 2010-06-08
- fixed a bug into tape method when using backup_method_opts
- fixed pgsql password management (thanks to Phillip Smith for the patch)
- fixed pgsql databases listing  (thanks to Phillip Smith for the patch)
- fixed backup_no_make_destdir directive (thanks to Phillip Smith for the patch)
- auto make the destination directory only if exist the parent directory and the backup_no_make_destdir is not used
- added -d command switch to enable debug (aka. report_stdout=yes)
- added -o command switch to override every config file variables from the command line
   example: synbak -s system -m method -o "backup_source=/tmp /var" -o "backup_destination=/srv/backup/daily"
   you can use multiple -o switches as you want. this features is very useful when used into cron jobs
- rsync method: FINALLY implemented the hard links system when using
   backup_incremental=no, this option is very very useful, because let's
   synbak to use the same disk space as a classic incremental backup,
   but every backup destination will contain all files as a total backup but using
   the disk space of an incremental backup!!!
   NB. the hard links system works only when the backup destination is a linux native file systems!
- changed backup_incremental=no as default template.conf behavior

## [1.2.2] - 2008-09-22
- switched synbak license from GPLv2 to GPLv3
- more synbak.spec fixes needed for fedora repository inclusion
- renamed example.conf to template.conf and moved from docs dir to synbak
   share dir: /usr/share/synbak/template.conf
- template.conf cleanups
- some fixes to the functions.sh file (thanks to Vitaly Ostanin)
- new backup method: dar
   now synbak can make backups using the 'dar' utility (http://dar.linux.free.fr/)
   nb. this is an initial dar support, and it's almost untested, please reports bugs
- new backup method: pgsql
   now synbak can make dumps of PostgreSQL databases
   as backup_remote_uri use "pgsql://", ex. backup_remote_uri = pgsql://postgres@localhost
   TODO: because the commands pg_dump and pg_dumpall can't manage password
   prompts from stdin, right now you must configure your pg_hba.conf and
   pg_ident.conf to accept connection from the user running synbak command
   without password prompt (i apologize for that, but this is a limitation of
   pg_dump)
- some fixes to mysql, oracle and ldap methods: the dumps now are compressd on the fly into bzip2
   format, reducing cpu usage and processing time

## [1.2.1] - 2008-02-19
- Use the ISO-8601 date format into reports details
- Some fixes to the nonerrors.strings files used by method scripts to exclude non errors messages
- Some fixes to the autoconf files
- Reworked synbak spec file for inclusion into official Fedora repository, using the Fedora Packaging Guidelines

## [1.2.0] - 2008-01-13
- New backup method: wget
   now you can use the wget method to make full remote mirrors or single/multiple
   files retrieval from ftp and http servers
- Many sanity checks and fixes to the mysql method
- Many enhancements to the appearance of html reports
- Created the synbak logo and made them the default for the new backups
- Major refactoring of html report code and css file structure, now the html
   reports appearance is fully customizable via the external synbak.css file,
   and the html pages are now fully CSS 2.0 compliant (because of this major
   change, you must rebuild all html indexes if you want correctly see the old
   reports, use this command: synbak -s system -m method -r html -R ria)
- HTML reports are now validated to the W3C XHTML 1.0 Strict standard
- Integrated the tablesort.js javascript library to the html reports, so is now
   possibile to do realtime sorting and reordering of the synbak reports tables.
   Many thanks to frequency-decoder.com by releasing this cool library (nb.
   the license of tablesort.js is not GPL but Creative Commons
   Attribution-ShareAlike 2.5 license)
- Updated the FAQ file

## [1.1.0] - 2007-12-12
 - Internal development release

## [1.0.12] - 2007-11-29
- Almost complete mysql method rewrite with a lot of useful features:
   now you can use the -M switch to make splitted database dumps (each db in a
   separate dump file). ex. synbak -s dbserver -m mysql -M split
   however the default beaviour is always to make --all-databases dumps (all db in a single file)
- Italian translation fixes
- Added Volume Tag (BARCODE) reporting for tape media changers that support this
- Added a text string to exclude databases from oracle's backups
- Fixed the cifs umount function (thanks to Robby Pedrica)
- Cleanups in the calendar php extension (thanks to Federico Kereki)
- Removed the -S command option because it's unused right now
- Updates to the FAQ file

## [1.0.11] - 2006-10-30
- Fixed a bug in rsync method when 'backup_no_make_destdir' option is used
- Fixed another bug in the host check function, now remote backup should be run on SuSE Linux distro also
   explanation: the 'nc' command under SuSE is named 'netcat' and this prevent the 'host_check_port' function to works properly
   many thanks to Sascha Vogt and Nicolas Fischer for suggestions.
- Fixed a bug in the cifs umount function
- Updated FAQ file

## [1.0.10] - 2006-10-14
- Fixed an annoying bug in the 'host port check' function used in remote backups, causing remote host check always fail.
   synbak use 'nc' command for probing remote service ports and verify if the remote host is up or down.
   On some systems nc doesn't work as expected, returning error codes even if the command line options are corrects.
   for example, in working nc installations to verify if your mysql server is up, if you run 'nc -z localhost 3306', nc must
   return a 'success' message (with return code 0). In not working nc installations nc doesn't accept this command.
- Reworked autoconf files for better portability
- Added many comments to synbak functions source files
- Some code cleanup
- Many updates to FAQ file, please read this if you want know many useful tips about synbak

## [1.0.9] - 2006-09-14
- Added 'Operating System Kernel Version' to backup report
- Added 'Method command options' to backup report
- Added 'Calendar View', a new and very useful feature to HTML reports (many thanks to James Van't Slot of http://www.simple-reliable.com/ for the contrib)
   Rebuild your html indexes to update all reports
- Updated synbak.spec for auto rpm building
- Updated FAQ

## [1.0.8] - 2006-08-22
- Misc graphical enhancements to html and rss reports (if you want rebuild the indexes of your HTML report directory,
   launch synbak with the following command: synbak -s yoursystem -m yourmethod -r html -R ria)
- Because synbak is not arch (i386, x86_64, ppc, etc...) dependent, the methods, reports and functions files are
   moved from /usr/lib/synbak to /usr/share/synbak for better compatibility on multilib systems.
   (many thanks to Dag Wieers for the suggestion)
- Now html reports can be viewed correctly on terminal based browsers (like elinks, lynx, etc...)
- Added an initial FAQ (Frequently Asked Questions) text file to main synbak package

## [1.0.7] - 2006-08-19
- Added the synbak Server Hostname to the email report subject
- More robust smb/cifs mount procedure
- Failback to cifs mount if the current kernel doesn't support smbfs protocol
- Some minor bug fixes

## [1.0.6] - 2006-07-29
- Fixed a bug in the tar and tape backup verify
- Fixed a bug in the tar and tape total size and speed calculation
- Renamed the cdrw method to laserdisc
- Some fixes in the the laserdisc method (tested against Fedora Core 5 mkisofs and cdrecord commands)
- Added the "backup_exclude" option to laserdisc method

## [1.0.5] - 2006-07-12
- New backup method: oracle
   Now via oracle's "exp" command is possible to make a full dump of local or remote oracle database servers
- Added a new informational field to ASCII detailed report: synbak server hostname
- Fixed a bug in the MySQL local method
- Using a better way to manage temp directory on old systems
- Many fix in the cifs/smb mount and remote host checks

## [1.0.4] - 2006-06-02
- Now each backup step has an error.log and stats.log file created in the temp dir
- Some minor bug fixes

## [1.0.3] - 2006-05-20
- The rsync over SMB/CIFS protocol now should works better (Improved the remote
   host check and mount functions) 
- Many code cleanups

## [1.0.2] - 2006-03-24
- Show synbak version in the title of html reports
- Added some useful comments to example.conf file
- Added a new config directive. backup_no_make_destdir
   useful if you don't want create automatically the destination backupdir.
   this always assume backup_incremental=no and is useful on rsync backup only
- Now tar method can produce flat tar archives without compression

## [1.0.1] - 2006-03-18
- Fixed a bug in the auto erase routine that keeped too many days
- First version using GNU autotools for better portability

## [1.0.0] - 2006-02-18
- First public version, look into README file to find a list of supported features
