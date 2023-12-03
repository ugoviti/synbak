#!/bin/sh
#
#   tar.sh - tar backup method handler
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


method_init(){
  local extra_option_right="tar, gz, bz2, lzo, xz"
  local current_option="${method_option}"

  [ -z "${current_option}" ] && report_text extra_option_required && exit 1

  case $current_option in
	tar)	backup_method_opts_default="--totals -cpf"  ; backup_name_extension="tar" ;;
	gz)	backup_method_opts_default="--totals -zcpf" ; backup_name_extension="tar.gz" ;;
	bz2)	backup_method_opts_default="--totals -jcpf" ; backup_name_extension="tar.bz2" ;;
        lzo)    backup_method_opts_default="--use-compress-program=lzop --totals -cpf" ; backup_name_extension="tar.lzo" ;;
        xz)     backup_method_opts_default="--use-compress-program=xz --totals -cpf" ; backup_name_extension="tar.xz" ;;
	*)	report_text extra_option_wrong && exit 1 ;;
  esac

  method_option="$current_option"
  save_method_info
}
method_init
# exit if error on method_init
[ $? -eq 1 ] && exit 1;

# variables useful to this method
backup_method_cmd="tar"
#backup_method_opts=""

backup_name_prefix="backup"
#backup_name_suffix="$(show_time_human ${time_begin} date)"
backup_name_suffix="$(show_time_human ${time_begin} backup)"
backup_name="${backup_name_prefix}-${system}-${backup_name_suffix}.${backup_name_extension}"

# set the new destination, because the real destination is a file
backup_destination_real=${backup_destination}/${backup_name}

method_stats() {
            save_stats_backup size_backup "${file_log_errors_step}" "${file_size_backup}" "Total bytes written:"
}

# the real backup method comand to run
method_backup()
{
  eval ${backup_method_cmd} --exclude-from=${file_list_unbackable} --exclude-from=${file_list_exclude} ${backup_method_opts} ${backup_method_opts_default} ${backup_destination_real} ${backup_source_step}
}

# import config fields
config_field_import backup_verify bool null "${usr_file_conf}" keep

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

## begin backup step
backup_source_step="${backup_source}"
report_text backup_step

save_time_begin_step

# Workaround to parse only english text output
ORIG_LANG=$LANG
LANG=C


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
    method_backup 2> "${file_log_errors_step}" 1> "${file_log_stats_step}"
fi


# Restore original system language
LANG=$ORIG_LANG

save_time_end_step

method_stats
check_status_backup_step
report_text separator_info3
set_stats_backup
save_size_destination "${backup_destination_real}"
unset backup_source_step
## end backup step

## begin backup verify
if [ "${backup_verify}" = "yes" ]
  then
    report_text backup_verify
    save_time_begin_step
    backup_verify "${method_option}" "${backup_destination_real}"
    save_time_end_step
    check_status_step
    report_text separator_info3
fi
## end backup verify

sleep 1

save_time_begin_step
backup_erase_init "${backup_name_prefix}-${system}-"
report_text backup_erase
backup_erase 2>&1 > "${file_log_errors_step}"
save_time_end_step
check_status_step
report_text separator_info3

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

