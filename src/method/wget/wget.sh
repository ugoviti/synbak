#!/bin/sh
#
#   wget.sh - wget backup method handler
#
#   Copyright (C) 2003-2008 InitZero S.r.l.
#   Written by: Ugo Viti <ugo.viti@initzero.it>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#


# import config fields
config_field_import backup_source_uri uri  notnull	"${usr_file_conf}" keep

# variables useful to this method
backup_method_cmd="wget"
backup_method_opts_default="-nv -N -t3 -m -e robots=off"
#backup_method_opts=""

backup_name_prefix="backup"
backup_name_suffix="$(show_time_human ${time_begin} backup)"
#backup_name_suffix="$(show_time_human ${time_begin} date)-$(show_time_human ${time_begin} hour)"
#backup_name_extension="ldif"
backup_name="${backup_name_prefix}-${system}-${backup_name_suffix}"

# set the destination of this backup method
backup_destination_step="${backup_destination}/${backup_name}"
# set the default destination to destination_step
backup_destination_real="${backup_destination_step}"

method_init(){
 # if the backup_source_uri field contain a URI set this method to make a remote backup
 if [ -n "${backup_source_uri}" ]
  then
    import_backup_source_uri_variables "${backup_source_uri}"

    # If is given a URI then check first if the remote host is reachable
    check_status_host "${backup_source_uri}"
    save_status_host

    # adapt the backup method to protocol used
    case "${backup_source_uri_protocol}" in
	http|ftp)
		mkdir -p "${backup_destination_step}"
 		method_option="${backup_source_uri_protocol}"
		;;
	*)
		report_text uri_unsupported
		report_text protocol_unsupported
		return 1
		;;
    esac
 fi
 save_method_info
}
method_init ; [ $? -eq 1 ] && exit 1; # exit if error on method_init

# the real backup method comand to run
method_backup()
{
 make_backup_step(){
   cd ${backup_destination_step}/
   LANG=en eval ${backup_method_cmd} ${backup_method_opts_default} ${backup_source_step_original}

   save_size_destination "${backup_destination_step}"
   save_size_backup "${size_destination}"
 }

 make_backup_step_init() {
            save_time_begin_step
            report_text backup_step
            make_backup_step 2>"${file_log_errors_step}" 1>"${file_log_stats_step}"
            save_time_end_step
            check_status_backup_step
            report_text separator_info3
 }

        if [ ${status_host} = 0 ]
          then
            [ "${backup_source}" = "*" ] && backup_source=""
	    if [ -z "${backup_source}" ] 
              then
		backup_source_step_full="${backup_source_uri_original}"
		backup_source_step="${backup_source_uri}"
		make_backup_step_init
               else
		for backup_source_step in ${backup_source}
		  do
			backup_source_step_full="${backup_source_uri_original}${backup_source_step}"
			backup_source_step="${backup_source_uri}${backup_source_step}"
			make_backup_step_init
			unset backup_source_step
			unset backup_source_step_full
		  done
            fi
          else
            report_text separator_info4
            report_text status_host_down
            save_status_backup_error
            report_text separator_info4
        fi
}


method_erase() {
  # auto erasing old backups
  save_time_begin_step
  backup_erase_init "${backup_name_prefix}-${system}-"
  report_text backup_erase
  backup_erase > ${file_log_errors_step} 2>&1
  save_time_end_step
  check_status_step
  report_text separator_info3
}



## backup and text reporting procedure
save_time_begin		# save the begin time

report_text separator_info1
report_text system
report_text method
report_text method_option
report_text method_type
[ -n "${backup_source_uri}" ] && report_text backup_source_uri
report_text backup_source
# move backup_destination_real to the backup_destination var
backup_destination_orig="${backup_destination}"
backup_destination="${backup_destination_real}"
report_text backup_destination
# restore backup_destination var
backup_destination="${backup_destination_orig}"
report_text backup_exclude
report_text backup_method_opts
report_text backup_keep
report_text synbak_server
report_text synbak_server_kernel
report_text synbak_version
report_text technical_support
report_text time_start
report_text separator_info2

if ! check_writable "${backup_destination}" 2>/dev/null
  then
    report_text separator_error
    check_writable "${backup_destination}"
    save_status_backup_error
    report_text separator_error
    report_text separator_info2
    save_time_end       # save the end time
    report_text time_end
    report_text status_backup
    report_text separator_info1
    return 1
elif ! check_cuncurrent_limit >/dev/null 2>&1
  then
    report_text separator_error
    check_cuncurrent_limit
    save_status_backup_error
    report_text separator_error
    report_text separator_info2
    save_time_end
    report_text time_end
    report_text status_backup
    report_text separator_info1
    return 1
  else
    ## begin backup step
    method_backup
    sleep 1
    save_size_destination "${backup_destination_step}*"
    set_stats_backup
    ## end backup step
fi


## begin erasing old backups
method_erase
## end erasing old backups

report_text system_info

save_time_end		# save the end time
save_time_duration	# save the duration time

report_text separator_info2
report_text time_end
report_text size_backup
report_text speed_backup
report_text size_destination
report_text time_duration
report_text status_backup

report_text separator_info1

