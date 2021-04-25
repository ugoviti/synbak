## synbak - Universal Backup System
Author: Ugo Viti <ugo.viti@initzero.it>

## What is synbak?
synbak is an application designed to unify several backup methods. synbak provides a powerful reporting system and a very simple interface for configuration files.
synbak is a wrapper for several existing backup programs suppling the end user with common method for configuration that will manage the execution logic for every single backup and will give detailed reports of backups result.

### synbak can make backups using:
- RSync over ssh, rsync daemon, smb and cifs protocols (using internal automount functions)
- Tar archives (tar, tar.gz and tar.bz2)
- Tape devices (using multi loader changer tapes too)
- LDAP databases
- MySQL databases
- Oracle databases
- PostgreSQL databases
- CD-RW/DVD-RW
- Wget to mirror HTTP/FTP servers

### synbak can make reports using:
- EMail
- HTML pages
- RSS feeds

Moreover, if you are a developer and want to contribute, the modular nature of synbak will allow you to easly write new backup methods, reports, and translations.

Please read the FAQ file to discover many useful tips.


## Features
### Architecture
#### Miscellaneous Features
* useful to backup servers, workstations and also laptops (not always network connected computers)
* input and output strings on UTF-8 charset format only
* easy concept and structure
* system, method and report concept
* support many backup methods
* common config file interface for configuring every backup method
* fully multi users backup system, can run under normal user accounts or root user to keep all file permissions
* auto erase of old backups
* powerful reporting facility
* heasily understandable backup reports
* backup speed/size/time calculation
* provide many backup informations
* you can create exclusion filters using standard regexp expressions
* modular architecture for developers
* ALL remote backups can be specified using a standard URI (Uniform Resource Identifiers) format (ex. cifs://usr:pwd@host/share)
* auto mounting and umounting of remote cifs/smb shares
* fully localized using the standard GNU gettext framework

### Backup Methods
#### Rsync
* backup of local and remote files using the beautiful and super fast 'rsync' protocol
* incremental backups
* full backups (using rsync hard links method to made full backups and use the same space as an incremental backup)
* local backups (from local source directories to destination backup directory)
* remote backups via crypted ssh, rsync daemon and smb/cifs protocols
* auto mounting/umounting of remote smb/cifs shares

#### Tar
* backup of local files into flat tar archives
* optional support for bzip2 compression
* optional support for gzip compression
* optional support for archive verify

#### MySQL
* dumps of local or remote MySQL database servers
* on the fly bzip2 compression for sql dumps
* remote databases backup into single SQL bzip2 compressed dump file
* remote databases backup splitted into multiple SQL bzip2 compressed dump files (one for each database)
* database inclusion pattern
* database exclusion pattern 

#### PostgreSQL
* dumps of local or remote PostgreSQL database servers
* on the fly bzip2 compression for sql dumps
* remote databases backup into single SQL bzip2 compressed dump file
* remote databases backup splitted into multiple SQL bzip2 compressed dump files (one for each database)
* database inclusion pattern
* database exclusion pattern 

#### Oracle
* dumps of local or remote Oracle database servers
* bzip2 compression for sql dumps
* remote or local databases backup in a single SQL dump

#### LDAP
* backup dumps of local or remote LDAP (Light Weight Directory Access Protocol) directory servers
* on the fly bzip2 compression for ldif dumps
* ldif dump of remote LDAP servers 

#### Tape
* backup to tape archives (ex. DAT, DLT, etc...)
* multi loader support (device changer/loader)
* volume tag (BARCODE) reporting
* eject of tape at backup end
* tape backup verify 

#### LaserDisc
* backup to miscellaneous laser compact disks
* CD-RW
* DVD-RW/RAM
* eject of device at backup end 

#### Wget
* can make full automated mirrors of remote HTTP or FTP servers
* can download single file or a list of files from remote HTTP or FTP servers


### Report Methods
#### HTML
* a very friendly gui wil provide all infos that an administrator or an end user need 
* detailed reports view
* detailed calendar view for each year

#### RSS
* with the emerging RSS (Really Simple Syndication) protocol usage, you will find this report facility very useful, use it with your RSS aggregator 
* integration with enterprise network monitors like nagios and icinga

#### EMail
* receive via email the backup reports, the subject will describe if your backup gone well or not 

## Requirements
See [INSTALL](INSTALL) file for further information

## Installation
See [INSTALL](INSTALL) file for further information

## Release Notes
See [CHANGELOG](CHANGELOG.md) file for further information

## Future
See [TODO](TODO) file for further information

## License
See [COPYING](COPYING) file for further information

============  
Please report bugs and tell me what you like/dislike to <opensource@initzero.it>

Thanks for downloading and using synbak.
Ugo Viti <ugo.viti@initzero.it>
