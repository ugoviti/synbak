#!/bin/sh
#
#   laserdisc.sh - laserdisc backup method handler
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
config_field_import ${usr_file_conf} backup_verify		bool null keep
config_field_import ${usr_file_conf} backup_device_eject	bool null keep

method_init(){

  check_device "${backup_destination}" ; [ $? -eq 1 ] && exit 1;
  save_method_info
}
method_init
# exit if error on method_init
[ $? -eq 1 ] && exit 1;

# variables useful to this method
backup_method_cmd="cdrecord"
mkiso_cmd="mkisofs"
mkiso_opts="-l -r -D -J"
backup_method_opts_default="-pad -dao $([ "${backup_device_eject}" = "yes" ] && echo "-eject")"

# the real backup method comand to run
method_backup() {
  burnbabyburn(){
    eval ${mkiso_cmd} ${mkiso_opts} -exclude-list=${file_list_exclude} ${backup_source_step} 2>/dev/null | ${backup_method_cmd} ${backup_method_opts_default} tsize=${iso_size}s dev=${backup_destination} - 1>/dev/null
  }

  blank_device(){
    eval ${backup_method_cmd} blank=fast dev=${backup_destination}
  }

  iso_size=$(mkisofs -quiet -print-size ${backup_source} 2>&1 | tail -n1 | sed -e 's/^.*\ =\ //')

  if [ -z "$(echo ${iso_size} | tr -d [:digit:])" ]
    then
      # Blank the destination media
      save_time_begin_step
      report_text blank_device_step
      blank_device 1>/dev/null 2>${file_log_errors_step}
      save_time_end_step
      check_status_step

      # continue or exit if an error occour in the last step
      if [ $(check_status_step >/dev/null 2>&1 ; echo $?) -gt 0 ]
	then
	  return 1
	else
          report_text separator_info3
          backup_source_step=${backup_source}
          save_time_begin_step
          report_text backup_step

          burnbabyburn > ${file_log_errors_step} 2>&1

          # Save the backup size converting the mkisofs size (chunks of 2048 blocks) to bytes
          save_size_backup "$(echo "${iso_size} * 2048" | bc)"

          save_time_end_step
          check_status_backup_step
          report_text separator_info3
          unset backup_source_step
      fi

    else
      echo "iso_size = ${iso_size}"
  fi

  size_destination="${size_backup}"
  echo "${size_destination}" > "${file_size_destination}"
}

# exclude from this method all unbackable files (ex. socket files)
#for field in ${backup_source}; do
#  find_socket_files $field
#done >> ${file_list_unbackable}

## Backup and Text Reporting Procedure

save_time_begin		# save the begin time

report_text separator_info1
report_text system
report_text method
report_text method_option
report_text method_type
report_text backup_source
report_text backup_destination
report_text backup_exclude
report_text backup_method_opts
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
    ## end backup step
fi

## begin backup verify
if [ "${backup_verify}" = "yes" ]
  then
    report_text backup_verify
    save_time_begin_step
    backup_verify cdrecord "${backup_destination}"
    save_time_end_step
    check_status_backup_step
    report_text separator_info3
fi
## end backup verify

#report_text system_info

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

