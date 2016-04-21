#!/bin/sh
#
#   tape.sh - tape backup method handler
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
config_field_import backup_verify	bool null	"${usr_file_conf}" keep
config_field_import backup_device_eject	bool notnull	"${usr_file_conf}" keep

method_init(){
  local extra_option_right="<tape number>"
  local current_option="${method_option}"

  [ -n "$(echo "${current_option}" | grep [^0-9])" ] && report_text extra_option_wrong && exit 1

  check_device "${backup_destination}" ; [ $? -eq 1 ] && exit 1;

  # if is specified a tape number, then configure the device changer
  if [ -n "${current_option}" ]
    then
     config_field_import backup_device_changer text notnull "${usr_file_conf}" keep
     tape="${current_option}"
     method_option="SE:[${current_option}]"
     check_device "${backup_device_changer}" ; [ $? -eq 1 ] && exit 1;

     # Export BarCode label if the device changer support this
     local barcode="$(eval "${changer_cmd}" -f "${backup_device_changer}" status 2>/dev/null | grep "Storage Element $tape:" | grep "VolumeTag" | awk -F= '{print $2}' | tr -d [:space:])"
     [ -n "${barcode}" ] && method_option="${method_option} BC:[${barcode}]"
  fi

  save_method_info
}

# variables useful to this method
backup_method_cmd="tar"
changer_cmd="mtx"
backup_method_opts_default="--totals -cpf"
#backup_method_opts_default="--totals -b 128 -cpf" # there are some problem using block size 128 on some systems

method_init
# exit if error on method_init
[ $? -eq 1 ] && exit 1;

method_stats() {
            save_stats_backup size_backup "${file_log_errors_step}" "${file_size_backup}" "Total bytes written:"
}

# the real backup method comand to run
method_backup() {
  make_backup_step(){
   eval ${backup_method_cmd} --exclude-from=${file_list_unbackable} --exclude-from=${file_list_exclude} ${backup_method_opts} ${backup_method_opts_default} ${backup_destination} ${backup_source_step}
  }

  # if this is a multi loader backup, then load the specified tape in the changer
  unload_tape() {
      eval "${changer_cmd}" -f "${backup_device_changer}" unload 2>&1 | grep -v "is Already Full" | grep -v "...done"
      sleep 10
  }
  load_tape() {
      eval "${changer_cmd}" -f "${backup_device_changer}" load "${tape}"
      sleep 20
  }
  
  if [ -n "${tape}" ]
    then
      save_time_begin_step
      report_text unload_tape_step
      unload_tape 1>/dev/null 2>${file_log_errors_step}
      save_time_end_step
      check_status_step

      save_time_begin_step
      report_text load_tape_step
      load_tape 1>/dev/null 2>${file_log_errors_step}
      save_time_end_step
      check_status_step
      report_text separator_info3
  fi

  backup_source_step=${backup_source}
  save_time_begin_step
  report_text backup_step

  # Workaround to parse only english text output
  ORIG_LANG=$LANG
  LANG=en

  make_backup_step > ${file_log_errors_step} 2>&1

  # Restore original system language
  LANG=$ORIG_LANG

  method_stats
  save_time_end_step
  check_status_backup_step
  report_text separator_info3

  unset backup_source_step

  ## begin backup verify
  if [ "${backup_verify}" = "yes" ]
    then
      report_text backup_verify
      save_time_begin_step
      backup_verify tape "${backup_destination}"
      save_time_end_step
      check_status_step
      report_text separator_info3
  fi
  ## end backup verify

  # Eject the device if the user required this
  if [ "${backup_device_eject}" = "yes" ]
    then
      save_time_begin_step
      report_text eject_device_step
      mt -f "${backup_destination}" eject > ${file_log_errors_step} 2>&1
      save_time_end_step
      check_status_step
      report_text separator_info3
  fi

  # if this is a multi loader backup, then unload the specified tape in the changer
  if [ -n "${tape}" ]
    then
      save_time_begin_step
      report_text unload_tape_step
      unload_tape 1>/dev/null 2>${file_log_errors_step}
      save_time_end_step
      check_status_step
      report_text separator_info3
  fi
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
    save_size_source "${backup_source}"
    size_destination="${size_backup}"
    echo "${size_destination}" > "${file_size_destination}"
    set_stats_backup
    ## end backup step
fi

save_time_end		# save the end time
save_time_duration	# save the duration time

report_text separator_info2
report_text time_end
report_text size_backup
report_text speed_backup
report_text size_source
report_text time_duration
report_text status_backup

report_text separator_info1

