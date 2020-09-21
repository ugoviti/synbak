#!/bin/sh
#
#   functions.sh - main synbak core functions provider
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

#      desc: show and save the stdout messages
#      args: none
# args desc: none
#    return: none
save_output () {
  tee "${file_log_output}"
}


#      desc: print localized synbak messages
#      args: $1
# args desc: 'message type'
#    return: translated text
report_text() {
  local type=$1

  case ${type} in
	system)			msg "             System: " ; echo "${system}" ;;
	method)			msg "             Method: " ; echo "${method}" ;;
	method_option)		msg "             Option: " ; echo "${method_option}" ;;
	method_type)		msg "               Type: " ; echo "${method_type}" ;;
	backup_source_uri)		msg "           Base URI: " ; echo "${backup_source_uri}" ;;
	backup_source)		msg "             Source: " ; echo "${backup_source}" ;;
	backup_step)		msg "         Backing up: " ; echo -n "[${backup_source_step}] " ;;
	backup_destination)	msg "        Destination: " ; echo "${backup_destination}" ;;
	backup_destination_step)msg "   Real destination: " ; echo "${backup_destination_step}" ;;
	backup_exclude)		msg "          Exclusion: " ; echo "${backup_exclude}" ;;
        backup_keep)		msg "       Keep backups: " ; echo "$(show_backup_keep ${backup_keep})" ;;
	backup_method_opts)	msg "     Method options: " ; echo "${backup_method_opts}";;
	backup_verify)		msg "    Veryfing backup: " ; echo -e "\n";;
	synbak_version)		msg "     ${synbak_package} version: " ; echo "${synbak_version}" ;;
	synbak_version_full)	msg "     ${synbak_package} version: " ; echo "${synbak_version} - ${synbak_version_date}" ;;
	synbak_server)		msg "      ${synbak_package} server: " ; echo "${synbak_server}" ;;
	synbak_server_kernel)	msg "     Kernel version: " ; echo "${synbak_server_kernel}" ;;
	method_rsync_differential)	msg "       Differential: " ; echo "${method_rsync_differential}" ;;
	technical_support)	msg "  Technical support: " ; echo "${report_info_support}" ;;
	time_start)		msg "       Backup begin: " ; echo "$(show_time_human ${time_begin} full)" ;;
	time_end)		msg "         Backup end: " ; echo "$(show_time_human ${time_end} full)" ;;
	time_duration)		msg "    Backup duration: " ; echo "$(show_time_duration_human ${time_begin} ${time_end})" ;;
	backup_erase)		msg "    Keeping backups: " ; echo "[$(cat ${file_list_backup_keep} | tr -s "\n" " " | sed 's/^ *//g' | sed 's/ *$//g')]"
				msg "    Erasing backups: " ; echo -n "[$(cat ${file_list_backup_erase} | tr -s "\n" " " | sed 's/^ *//g' | sed 's/ *$//g')] " ;;
	load_tape_step)		msg "       Loading tape: number " ; echo -n "[${tape}] " ; msg "on" ; echo -n " [${method_tape_device_changer}] " ;;
	unload_tape_step)	msg "     Unloading tape: from " ; echo -n "[${backup_device_changer}] " ;;
	eject_device_step)	msg "    Ejecting device: " ; echo -n "[${backup_destination}] " ;;
	blank_device_step)	msg "    Blanking device: " ; echo -n "[${backup_destination}] " ;;
	generate_databases_list)msg "Gen. databases list: " ; echo -n "[$(echo ${backup_source} | tr -s "\n" " " | sed 's/^ *//g' | sed 's/ *$//g')] " ;;
	mount_step)		msg "           Mounting: " ; echo -n "[${backup_source_uri}] " ; msg "on" ; echo -n " [${dir_mnt}] " ;;
	umount_step)		msg "         Unmounting: " ; echo -n "[${dir_mnt}] " ;;
	files_total)		msg " Total source files: " ; echo "$(show_files ${files_total})" ;;
	files_backup)		msg "       Backup files: " ; echo "$(show_files ${files_backup})" ;;
	size_backup)		msg "        Backup size: " ; echo "$(show_size ${size_backup})" ;;
	size_destination)	msg "   Destination size: " ; echo "$(show_size ${size_destination})" ;;
	size_source)		msg "        Source size: " ; echo "$(show_size ${size_source})" ;;
	speed_backup)		msg "       Backup speed: " ; echo "$(show_speed ${size_backup} ${time_begin} ${time_end})" ;;
	report_step)		msg "  Generating report: " ; echo -n "[$(basename $report)] " ;;
	status_backup)		msg "      Backup result: " ; echo "$(check_status_backup)" ;;
	info_files)		msg "Files:"    ; echo -n "[$(show_files ${files_backup})] " ;;
	info_size)		msg "Size:"     ; echo -n "[$(show_size ${size_backup})] " ;;
	info_speed)		msg "Speed:"    ; echo -n "[$(show_speed ${size_backup} ${time_step_begin} ${time_step_end})] " ;;
	info_duration)		msg "Duration:" ; echo -n "[$(show_time_duration_human ${time_step_begin} ${time_step_end})] ";;
	info_status)		msg "Status:"   ; echo -n "[${step_status}] ";;
	backup_step_info)	[ -n "${files_backup}" ] && report_text info_files ; report_text info_size ; report_text info_speed ; report_text info_duration ; report_text info_status ; echo ;;
	step_info)		report_text info_duration ; report_text info_status ; echo ;;
	step_info_error)	msg "ERROR: an error is occurred in this step, follow error details:" >&2 ;;
	status_host_down)	msg "ERROR: the remote host '\${backup_source_uri_host}' is down" ; echo ;;
	dir_not_exist)		msg "ERROR: '\$dir' directory doesn't exist or it isn't accessible" >&2 ; echo >&2 ;;
	file_not_exist)		msg "ERROR: '\$file' file doesn't exist or it isn't accessible" >&2 ; echo >&2 ;;
	device_not_exist)	msg "ERROR: '\$file' file doesn't exist, isn't writable or it's not a character device" >&2 ; echo >&2 ;;
	field_empty)		msg "ERROR: in file '\${usr_file_conf}' the mandatory '\${field}' field is empty" >&2 ; echo >&2 ;;
	field_wrong)		msg "ERROR: in file '\${usr_file_conf}' the field '\${field}' contains invalid data: '\${value}'" >&2 ; echo >&2 ;;
	backup_erase_error)	msg "ERROR: not erasing old backups because an ERROR is occurred" ;;
	uri_unsupported)	msg "ERROR: the specified base URI '\${backup_source_uri}' is not valid for the '\${method}' backup method" ; echo ;;
	protocol_unsupported)	msg "ERROR: the specified remote protocol '\${backup_source_uri_protocol}' is unsupported by '\${method}' backup method" ; echo ;;
	mount_unsupported)	msg "ERROR: unsupported remote mount share" ; echo ;;
	extra_option_required)	msg "ERROR: extra options are required, follow a list of usable extra options: \$extra_option_right" ; echo ;;
	extra_option_wrong)	msg "ERROR: the specified extra option '\$current_option' is invalid, follow a list of usable extra options: \$extra_option_right" ; echo ;;
	internal_error)		msg "ERROR: internal error, please report this to developers" ; echo ;;
	cuncurrent_limit)	msg "ERROR: cuncurrent backup job limit reached: \$method_concurrent_limit" ; echo ;;
	ok)			msg "OK" ;;
	error)			msg "ERROR" ;;
	unknow)			msg "unknow" ;;
	#separator_info1)	echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" ;;
	separator_info1)	echo "################################################################################" ;;
	separator_info2)	echo "================================================================================" ;;
	separator_info3)	echo "--------------------------------------------------------------------------------" ;;
	separator_info4)	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"	;;
	separator_stats)	echo "................................................................................"	;;
	separator_error)	echo "********************************************************************************"	;;
	system_info)
				msg "Backup informations: " ; echo
				echo
				#report_text separator_stats
				msg "Directory list of " ; echo "[${backup_destination}]:"
				ls -Al "${backup_destination}"/ | head -n 100 | grep -v ^total
				#report_text separator_stats
				echo
				msg "Free space and active mount points: " ; echo
				df -Tmh -x tmpfs -x devtmpfs
				#report_text separator_stats
				;;
esac
}


#      desc: show a variable value by providing only a variable name
#      args: $1
# args desc: 'variable name'
#    return: print variable name
show_variable_value() {
  eval echo \$$1
}


#      desc: parse and import the user config file fields
#      args: $1 $2 $3 $4 $5
# args desc: 'field name' 'field type: bool, text, path, uri, int' 'null, notnull' 'user file config path' 'keep if the variable is already set'
#    return: none
config_field_import() {
  if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" ]]; then echo "$(report_text internal_error) \$@=$@"; exit 1; fi

  local field=$1
  local type=$2
  local null=$3
  local file_config=$4
  local keep=$5

  # automatically create a variable named like the field found in the config file, or doesn't override it if keep arg is found
  if [[ -z "$(show_variable_value ${field})" || "${keep}" != "keep" ]]; then
  eval $field=\""$(cat ${file_config} 		| \
			grep -v ^"#"	 	| \
			grep -w ^${field} 	| \
			tail -n 1 | grep "=" 	| \
			sed 's/=/==AWKFIELD==/'	| \
			awk -F "==AWKFIELD==" '{print $2}' | \
			awk -F "#" '{print $1}' | \
			tr -d [:cntrl:] 	| \
			sed 's/\"//g' 		| \
			sed 's/^ *//g' 		| \
			sed 's/ *$//g'		)"\"
  fi

  # verify if the imported field value is valid
  config_field_check ${field} ${type} ${null} $(show_variable_value ${field})
  save_status_config_field_import

  # exit if the field value is not valid
  [ $status_config_field_import -ne 0 ] && exit 1;
}


#      desc: check if a variable is empty or invalid, return 1 if the check gone wrong
#      args: $1 $2 $3 $4 
# args desc: 'check type' 'null' 'field name' 'field value'
#    return: none
config_field_check() {
  local field=$1
  shift
  local type=$1
  shift
  local null=$1
  shift
  local value=$@

  #echo type: $type
  #echo field: $field
  #echo value: $value

  case ${type} in
    bool)
      if [ -z "${value}" ] && [ "${null}" != "null"  ]
        then
          save_status_backup_error
          report_text field_empty
          return 1;
      elif [ -z ${value} ] || [ ${value} = yes ] || [ ${value} = no ] 
        then
          return 0
        else
          save_status_backup_error
          report_text field_wrong
          return 1
      fi
      ;;
    planning)
      #echo -e "DEBUG: FIELD=${field} VALUE=${value} NULL=${null}"
      if [ -z "${value}" ] && [ "${null}" != "null"  ]
        then
          save_status_backup_error
          report_text field_empty
          return 1;
      elif echo "${value}" | grep -q -w [d,w,m,y]
        then
          return 0
      elif [ -z "${value}" ] && [ "${null}" = "null"  ]
        then
          return 0;
        else
          save_status_backup_error
          report_text field_wrong
          return 1
      fi
      ;;
    text)
      if [ -z "${value}" ] && [ "${null}" != "null"  ]
        then
          save_status_backup_error
          report_text field_empty
          return 1
        else
          return 0
      fi
      ;;
    path)
      #echo -e ${field}: ${value} - ${null}
      if [ -z "${value}" ] && [ "${null}" != "null"  ]
        then
          save_status_backup_error
          report_text field_empty
          return 1
        else
          return 0
      fi
      ;;
    uri)
      #echo -e ${field}: ${value} - ${null}
      if [ -z "${value}" ] && [ "${null}" != "null"  ]
        then
          save_status_backup_error
          report_text field_empty
          return 1
        else
          parse_uri "${value}"
          [ $? -eq 1 ] && report_text field_wrong && parse_uri_unset_variables && return 1
          parse_uri_unset_variables
          return 0
      fi
      ;;
    int)
      if [ -z "${value}" ] && [ "${null}" != "null"  ]
        then
          save_status_backup_error
          report_text field_empty
          return 1;
        else
          [ -z "${value}" ] && value="0"
          echo ${value} | grep -q [^0-9]
          if [ $? -eq 0 ] || [ ${value} -lt 0 ]
            then
              save_status_backup_error
              report_text field_wrong
              return 1
            else
              return 0
          fi
      fi
      ;;
     ipv4)
      if [ -z "${value}" ] && [ "${null}" != "null"  ]
        then
          report_text field_empty
          return 1;
      elif [ -z ${value} ]
        then
          return 0
        else
          check_ipv4 "${value}"
          if [ $? -eq 0 ]
            then
              return 0
            else
              report_text field_wrong
              return 1
          fi
      fi
      ;;
  esac
}

#      desc: manage legacy and not more used config fields
#      args: none
# args desc: none
#    return: none
usr_config_field_legacy() {
        # pre synbak 3.2 compatibility variables
        if [ -z "${backup_schedule_planning}" ] ; then
	  backup_schedule_planning="d,w,m,y"
	fi

        # pre synbak 2.x compatibility variables
        if [ -z "${backup_source_uri}" ] ; then
	  config_field_import	backup_remote_uri		uri	null	"${usr_file_conf}" keep
	  backup_source_uri=${backup_remote_uri}
	fi

        if [ -z "${backup_keep}" ] ; then
	  config_field_import	backup_erase_after		int	notnull	"${usr_file_conf}" keep
	  backup_keep=${backup_erase_after}
	fi

        if [ -z "${backup_keep_on_errors}" ] ; then
	  config_field_import	backup_erase_always		bool	notnull	"${usr_file_conf}" keep
	  # revert logic for compatibility options
	  if [ "${backup_erase_always}" = "yes" ]
		then
           	  backup_keep_on_errors=no
		else
           	  backup_keep_on_errors=yes
          fi
	fi

        if [ -z "${backup_destination_prefix}" ] ; then
 	  config_field_import	backup_no_make_destdir		bool	notnull	"${usr_file_conf}" keep
	  # revert logic for compatibility options
	  if [ "${backup_no_make_destdir}" = "yes" ]
		then
           	  backup_destination_prefix=no
		else
           	  backup_destination_prefix=yes
          fi
	fi

        if [ -z "${method_rsync_differential}" ] ; then
	  config_field_import	backup_incremental		bool	null    "${usr_file_conf}" keep
          method_rsync_differential="${backup_incremental}"
	fi


        if [ -z "${method_tape_device_changer}" ] ; then
	  config_field_import	backup_device_changer		text	null    "${usr_file_conf}" keep
          method_tape_device_changer="${backup_device_changer}"
	fi


        if [ -z "${method_device_eject}" ] ; then
	  config_field_import	backup_device_eject		bool	null	"${usr_file_conf}" keep
          method_device_eject="${backup_device_eject}"
	fi


        if [ -z "${method_verify}" ] ; then
	  config_field_import	backup_verify			bool	null	"${usr_file_conf}" keep
          method_verify="${backup_verify}"
	fi
}

usr_config_field_default_values() {
  [ -z "${method_rsync_differential}" ] && method_rsync_differential=no
  [ -z "${method_concurrent_limit}" ] && method_concurrent_limit=1
}

#      desc: import all default fields from user config file or override them from command line
#      args: none
# args desc: none
#    return: none
usr_config_field_import_default() {
	config_field_import	backup_source_uri			uri     null	"${usr_file_conf}" keep
	config_field_import	backup_source			path	null	"${usr_file_conf}" keep
	config_field_import	backup_destination		path	notnull "${usr_file_conf}" keep
	config_field_import	backup_exclude			path	null	"${usr_file_conf}" keep
	config_field_import	backup_keep			int	null	"${usr_file_conf}" keep
	config_field_import	backup_keep_on_errors		bool	null	"${usr_file_conf}" keep
 	config_field_import	backup_destination_prefix	bool	null	"${usr_file_conf}" keep
 	config_field_import	backup_destination_automake	bool	null	"${usr_file_conf}" keep
 	config_field_import	backup_method_opts		text	null	"${usr_file_conf}" keep

 	config_field_import	backup_schedule			bool	null	"${usr_file_conf}" keep
	# import subsequent variables if backup_schedule is set
        if [ "${backup_schedule}" = 'yes' ] ; then
	  config_field_import	backup_schedule_planning	planning null    "${usr_file_conf}" keep

	  config_field_import	backup_schedule_daily_keep	int     notnull "${usr_file_conf}" keep
	  config_field_import	backup_schedule_weekly_keep	int     notnull "${usr_file_conf}" keep
	  config_field_import	backup_schedule_monthly_keep	int     notnull "${usr_file_conf}" keep
	  config_field_import	backup_schedule_yearly_keep	int     notnull "${usr_file_conf}" keep

	  config_field_import	backup_schedule_daily_cron	text    notnull "${usr_file_conf}" keep
	  config_field_import	backup_schedule_weekly_cron	text    notnull "${usr_file_conf}" keep
	  config_field_import	backup_schedule_monthly_cron	text    notnull "${usr_file_conf}" keep
	  config_field_import	backup_schedule_yearly_cron	text    notnull "${usr_file_conf}" keep
	fi


	config_field_import	method_concurrent_limit		int	null    "${usr_file_conf}" keep

        # rsync method specific
	config_field_import	method_rsync_differential	bool	null    "${usr_file_conf}" keep
	config_field_import	method_rsync_sudo		bool	null    "${usr_file_conf}" keep

        # tape method specific
 	config_field_import	method_tape_device_changer	text	null	"${usr_file_conf}" keep

        # tape/laserdisc specific
	config_field_import	method_device_eject		bool	null	"${usr_file_conf}" keep

        # tar/tape/laserdisc specific
	config_field_import	method_verify			bool	null	"${usr_file_conf}" keep


	config_field_import	report_remote_uri_down		bool	null	"${usr_file_conf}" keep

 	config_field_import	report_info_support 		text	null	"${usr_file_conf}" keep

	config_field_import	report_stdout			bool	notnull "${usr_file_conf}" keep
 	config_field_import	report_stdout_on_errors		bool	notnull "${usr_file_conf}" keep

	config_field_import	report_email			bool	null	"${usr_file_conf}" keep
	config_field_import	report_email_on_errors		bool	null	"${usr_file_conf}" keep
	config_field_import	report_email_rcpt		text	null	"${usr_file_conf}" keep

	config_field_import	report_html			bool	null	"${usr_file_conf}" keep
	config_field_import	report_html_on_errors		bool	null	"${usr_file_conf}" keep
	config_field_import	report_html_uri			uri	null	"${usr_file_conf}" keep
	config_field_import	report_html_destination		path	null	"${usr_file_conf}" keep
 	config_field_import	report_html_logo		bool	null	"${usr_file_conf}" keep
	config_field_import	report_html_logo_image		text	null	"${usr_file_conf}" keep
	config_field_import	report_html_logo_link		uri	null	"${usr_file_conf}" keep

	# import and manage legacy and obsoleted synbak variables
        usr_config_field_legacy
	# set default values for not mandatory variables
        usr_config_field_default_values

  # always make the destination directory if backup_destination_automake=yes
  [ "${backup_destination_automake}" = 'yes' ] && mkdir -p "${backup_destination}"

  # make the destination directory only if exist the parent directory and the backup_destination_prefix is used
  #if [[ "${backup_destination_prefix}" != 'no' && -e "$(dirname "${backup_destination}")" && -w "$(dirname "${backup_destination}")" ]] ; then
  #  [ -e "${backup_destination}" ] || mkdir -p "${backup_destination}"
  #fi

  # check if the destination directory or device exist and is check_writable (not used anymore here, any backup method must verify that before start backup)
  #check_writable ${backup_destination} ; [ $? -ne 0 ] && exit 1;

  # stop running this backup set if the method_concurrent_limit is greater or equal to running backup (not used anymore here, any backup method must verify that before start backup)
  check_cuncurrent_limit

  # check if the destination html report directory or device exist
  if [ -n "${report_html_destination}" ]; then check_writable ${report_html_destination} ; [ $? -ne 0 ] && exit 1; fi

  # sanitize some paths
  parse_path "${backup_source}"		> "${file_list_source}"
  parse_path "${backup_destination}"	> "${file_list_destination}"
  parse_path "${backup_exclude}"	| sed 's/\\//g' > "${file_list_exclude}"
}


#      desc: create a formatted file text containing the specified paths
#      args: $1
# args desc: 'variable containing a list of paths'
#    return: print parsed paths
parse_path(){
    echo "$@" | sed 's/\\ /%20/g' | awk 'BEGIN { RS = " " } {print $0}' | sed 's/%20/\\ /g' | grep -v "^$"
}


check_cuncurrent_limit() {
  # stop running this backup set if the method_concurrent_limit is greater or equal to running backup
  if [ $(ps -u $USER u | grep -v grep | grep "${synbak_package}-${system}-${method}" | wc -l) -gt ${method_concurrent_limit} ]
	then
	  report_text cuncurrent_limit
	  return 1
	else
	  return 0
  fi
}

check_ipv4() {
        case "$*" in
        ""|*[!0-9.]*|*[!0-9]) return 1 ;;
        esac

        local IFS=.  ## local is bash-specific
        set -- $*

        [ $# -eq 4 ] &&
            [ ${1:-666} -le 255 ] && [ ${2:-666} -le 255 ] &&
            [ ${3:-666} -le 255 ] && [ ${4:-666} -le 254 ]
}



#      desc: check if a directory exist and it's accessible
#      args: $1
# args desc: 'directory path'
#    return: code 0 = ok, 1 = error
check_dir() {
  if [[ -d "$1" && -r "$1" && -x "$1" ]]
    then
      return 0;
    else
      local dir=$1
      report_text dir_not_exist
      return 1;
  fi
}


#      desc: check if a directory, file or device exist and it's writable
#      args: $1
# args desc: 'directory path'
#    return: code 0 = ok, 1 = error
check_writable() {
  if [[ -e "$1" && -r "$1" && -w "$1" ]]
    then
      return 0;
    else
      local dir=$1
      report_text dir_not_exist
      return 1;
  fi
}


#      desc: check if a file exist and it's accessible
#      args: $1
# args desc: 'file path'
#    return: code 0 = ok, 1 = error
check_file() {
  if [[ -e "$1" && -r "$1" ]]
    then
      return 0;
    else
      local file=$1
      report_text file_not_exist
      return 1;
  fi
}


#      desc: check if a file is a device and it's accessible
#      args: $1
# args desc: 'file path'
#    return: code 0 = ok, 1 = error
check_device() {
  if [[ -c "$1" && -w "$1" ]] || [[ -b "$1" && -w "$1" ]]
    then
      return 0;
    else
      local file=$1
      report_text device_not_exist
      return 1;
  fi
}


#      desc: show the available backup methods
#      args: none
# args desc: none
#    return: print available backup methods
show_available_methods() {
  for method in $(ls $sys_dir_method/)
    do
      echo $(basename $method) >&2
    done
}


#      desc: show the available backup reports
#      args: none
# args desc: none
#    return: print available backup reports
show_available_reports() {
  for report in $(ls $sys_dir_report/)
    do
      echo $(basename $report) >&2
    done
}


#      desc: show errors occurred during a backup step
#      args: none
# args desc: none
#    return: print errors occurred during a backup step
show_backup_errors_step() {
  cat "${file_log_errors_step}" | grep -v -f "${sys_file_method_nonerrors_strings}"
}


#      desc: save to file the status error (global)
#      args: none
# args desc: none
#    return: none
save_status_backup_error(){
      echo "1" > "${file_status_backup}"
}

#      desc: save to file the status ok (global)
#      args: none
# args desc: none
#    return: none
save_status_backup_ok(){
      echo "0" > "${file_status_backup}"
}


#      desc: check the status of last backup step
#      args: none
# args desc: none
#    return: code 0,1
check_status_backup_step() {
  if [ -n "$(show_backup_errors_step)" ]
    then
      save_status_backup_error
      local step_status="$(report_text error)"
      report_text backup_step_info
      echo
      report_text step_info_error
      echo
      report_text separator_error
      show_backup_errors_step
      report_text separator_error 

      # Make a backup of errors file
      #cp "${file_log_errors}" "${file_log_errors}.$(show_time_unix)"
      #touch "${file_log_errors}"
      return 1;
    else
      local step_status="$(report_text ok)"
      report_text backup_step_info

      # Make a backup of errors file
      #cp "${file_log_errors}" "${file_log_errors}.$(show_time_unix)"
      #touch "${file_log_errors}"
      return 0;
  fi
}

#      desc: check the status of last step (nb. not a backup step)
#      args: none
# args desc: none
#    return: code 0,1
check_status_step() {
  if [ -n "$(show_backup_errors_step)" ]
    then
      save_status_backup_error
      local step_status="$(report_text error)"
      report_text step_info
      echo
      report_text step_info_error
      echo
      report_text separator_error
      show_backup_errors_step
      report_text separator_error 

      # Make a backup of errors file
      #cp "${file_log_errors}" "${file_log_errors}.$(show_time_unix)"
      #touch "${file_log_errors}"
      return 1;
    else
      local step_status="$(report_text ok)"
      report_text step_info

      # Make a backup of errors file
      #cp "${file_log_errors}" "${file_log_errors}.$(show_time_unix)"
      #touch "${file_log_errors}"
      return 0;
  fi
  # Make a backup of errors file
  #cp "${file_log_errors}" "${file_log_errors}.$(show_time_unix)"
  #touch "${file_log_errors}"
}


#      desc: check the final backup status
#      args: none
# args desc: none
#    return: code 0,1
check_status_backup() {
  if [ "$(cat ${file_status_backup})" = "1" ]
    then
      report_text error
      echo
      return 1;
    else
      save_status_backup_ok
      report_text ok
      echo
      return 0;
  fi
}

#      desc: save to file the current method option and type
#      args: none
# args desc: none
#    return: none
save_method_info() {
  [ -n "${method_option}" ] && echo "${method_option}" > "${file_method_option}"
  [ -n "${method_type}" ]   && echo "${method_type}"   > "${file_method_type}"
}


#      desc: save to file the backup begin in unix time
#      args: none
# args desc: none
#    return: none
save_time_begin() {
  time_begin=$(show_time_unix)
  echo ${time_begin} > ${file_time_begin}
}


#      desc: save to file the backup end in unix time
#      args: none
# args desc: none
#    return: none
save_time_end() {
  time_end=$(show_time_unix)
  echo ${time_end} > ${file_time_end}
}


#      desc: save to file and calc the duration of backup in unix time
#      args: none
# args desc: none
#    return: none
save_time_duration() {
  time_duration=$(expr ${time_end} - ${time_begin})
}


#      desc: set backup step begin time and prepare useful variables
#      args: none
# args desc: none
#    return: none
save_time_begin_step() {
  time_step_begin=$(show_time_unix)
  RANDOM_NUMBER="${RANDOM}"
  file_log_errors_step="${file_log_errors}.${time_step_begin}.${RANDOM_NUMBER}"
  file_log_stats_step="${file_log_stats}.${time_step_begin}.${RANDOM_NUMBER}"
  touch ${file_log_errors_step} ${file_log_stats_step}
}


#      desc: set backup step end time
#      args: none
# args desc: none
#    return: none
save_time_end_step() {
  time_step_end=$(show_time_unix)
}


#      desc: show current time in the unix format
#      args: none
# args desc: none
#    return: print unix time
show_time_unix() {
 date +%s
}


#      desc: save to file the status of remote host (0=reachable, 1=unreachable)
#      args: none
# args desc: none
#    return: none
save_status_host() {
  status_host="$?"
  echo "${status_host}" > "${file_status_host}"
  #echo status_host=$status_host
}


#      desc: save to file the status config file import (0=no errors, 1=errors occurred)
#      args: none
# args desc: none
#    return: none
save_status_config_field_import() {
  status_config_field_import="$?"
  file_status_config_field_import="${file_status_config_field_import:-/dev/null}"
  echo "${status_config_field_import}" > "${file_status_config_field_import}"
}


#      desc: set the remote mount procedure status
#      args: none
# args desc: none
#    return: none
save_status_mount() {
  status_mount="$?"
  #echo ${status_mount} >${file_status_mount}
  #echo status_mount=$status_mount
}


#      desc: convert unix time to human readable date format
#      args: $1 $2
# args desc: 'int: seconds in unix date format' 'type: backup, full, fullnew, date, year, month, day, hour, minute, second, rss, time'
#    return: print human readable date format
show_time_human(){
 local time_unix=$1
 local type=$2

 [ -n "$(echo "${time_unix}" | grep [^0-9])" ] && report_text unknow && return 1

 case ${type} in
	backup)	date --date="1970-01-01 00:00:00 UTC ${time_unix} seconds" +"%Y%m%d-%H%M%S" ;;
	full)	date --date="1970-01-01 00:00:00 UTC ${time_unix} seconds" +"%Y-%m-%d %H:%M:%S %Z" ;;
	fullnew)date --date=@${time_unix} +'%Y-%m-%d %H:%M:%S %Z' ;;
	log)	date --date="1970-01-01 00:00:00 UTC ${time_unix} seconds" +"%d/%b/%Y:%H:%M:%S" ;;
	date)	date --date="1970-01-01 00:00:00 UTC ${time_unix} seconds" +"%Y%m%d" ;;
	year)	date --date="1970-01-01 00:00:00 UTC ${time_unix} seconds" +"%Y" ;;
	month)	date --date="1970-01-01 00:00:00 UTC ${time_unix} seconds" +"%m" ;;
	day)	date --date="1970-01-01 00:00:00 UTC ${time_unix} seconds" +"%d" ;;
	hour)	date --date="1970-01-01 00:00:00 UTC ${time_unix} seconds" +"%H" ;;
	minute)	date --date="1970-01-01 00:00:00 UTC ${time_unix} seconds" +"%M" ;;
	second)	date --date="1970-01-01 00:00:00 UTC ${time_unix} seconds" +"%S" ;;
	rss)	LANG_ORIG=$LANG ; LANG=en ; date --date="1970-01-01 00:00:00 UTC ${time_unix} seconds" +"%a, %e %b %Y %H:%M:%S %Z" -u ; LANG=$LANG_ORIG ;;
	*|time)	date --date="1970-01-01 00:00:00 UTC ${time_unix} seconds" +"%H:%M:%S" ;;
 esac
}


#      desc: calc and convert unix time duration to human readable date format
#      args: $1 $2
# args desc: 'start time in seconds from UNIX epoch' 'end time in seconds from UNIX epoch'
#    return: print human readable date format HH:MM:SS
show_time_duration_human() {
 [[ -n "$(echo "$1" | grep [^0-9])" || -n "$(echo "$2" | grep [^0-9])" ]] && report_text unknow && return 1

 local time_duration_seconds="$(expr $2 - $1)"

 if [ ${time_duration_seconds} -ge 86400 ]
   then
     days="$(echo "scale=0; ${time_duration_seconds} / 86400" | bc)"
     date -u --date="1970-01-01 00:00:00 UTC ${time_duration_seconds} seconds" +"${days} day %H:%M:%S"
   else
     date -u --date="1970-01-01 00:00:00 UTC ${time_duration_seconds} seconds" +"%H:%M:%S"
 fi
}


#      desc: verify if the given argument is a int number, else and 'unknow' text message
#      args: $1
# args desc: 'int number"
#    return: print the given number else print a 'unknow' text message
show_files() {
 local files=$1
 [ -z "${files}" ] || [ -n "$(echo "${files}" | grep [^0-9])" ] && report_text unknow && return 1 || echo ${files}
}


#      desc: convert in a human form the given bytes
#      args: $1
# args desc: 'bytes"
#    return: print backup size in a human form
show_size() {
 local fsize=$1

 # 1 MB   = 1024000 Bytes
 # 10 MB  = 10240000 Bytes
 # 100 MB = 102400000 Bytes
 # 1 GB   = 1024000000 Bytes
 # 10 GB  = 10240000000 Bytes
 # 100 GB = 102400000000 Bytes
 # 1 TB   = 1024000000000 Bytes
 # 10 TB  = 10240000000000 Bytes
 # 100 TB = 102400000000000 Bytes

 #echo fsize=\"$fsize\" ftime_begin=\"$ftime_begin\" ftime_end=\"$ftime_end\"

 [ -z "${fsize}" ] || [ -n "$(echo "${fsize}" | grep [^0-9])" ] && report_text unknow && return 1

 [ "${fsize}" -lt 1024  ] && echo "${fsize} B" && return 1

  if   [ ${fsize} -ge 1024000000000 ]
    then
      echo $(echo "scale=2; ${fsize} / 1024000000000" | bc) TB
  elif [ ${fsize} -ge 1024000000 ]
    then
      echo $(echo "scale=2; ${fsize} / 1024000000" | bc) GB
  elif [ ${fsize} -ge 1024000 ]
    then
      echo $(echo "scale=2; ${fsize} / 1024000" | bc) MB
  elif [ ${fsize} -ge 1024 ]
    then
      echo $(echo "scale=2; ${fsize} / 1024" | bc) KB
    else
      echo ${fsize} B
  fi
}


#      desc: show the speed of a transfer
#      args: $1 $2 $3
# args desc: 'backup size in bytes' 'unix time of backup begin' 'unix time of backup end'
#    return: print the speed in a human form
show_speed(){
 local fsize=$1
 local ftime_begin=$2
 local ftime_end=$3

 #echo fsize=\"$fsize\" ftime_begin=\"$ftime_begin\" ftime_end=\"$ftime_end\"

 [ -z "${fsize}" ] || [ -z "${ftime_begin}" ] || [ -z "${ftime_end}" ] || [ -n "$(echo "${fsize}" | grep [^0-9])" ] || [ -n "$(echo "${ftime_begin}" | grep [^0-9])" ] || [ -n "$(echo "${ftime_end}" | grep [^0-9])" ] && report_text unknow && return 1
 
 [ "${fsize}" -lt 1024  ] && echo "${fsize} B/Sec" && return 1
 [ "${ftime_end}" -lt "${ftime_begin}"  ] && report_text unknow && return 1

 local fduration=$(expr ${ftime_end} - ${ftime_begin})

 [ "${ftime_end}" -le "${ftime_begin}"  ] && fduration=1

 local fsize_sec=$(echo $(echo "${fsize} / ${fduration}" | bc))

  if   [ ${fsize_sec} -ge 1024000000000 ]
    then
      echo $(echo "scale=2; ${fsize_sec} / 1024000000000" | bc) TB/Sec
  elif [ ${fsize_sec} -ge 1024000000 ]
    then
      echo $(echo "scale=2; ${fsize_sec} / 1024000000" | bc) GB/Sec
  elif [ ${fsize_sec} -ge 1024000 ]
    then
      echo $(echo "scale=2; ${fsize_sec} / 1024000" | bc) MB/Sec
  elif [ ${fsize_sec} -ge 1024 ]
    then
      echo $(echo "scale=2; ${fsize_sec} / 1024" | bc) KB/Sec
    else
      echo ${fsize_sec} B/Sec
  fi
}


#      desc: show how many backups to keep
#      args: $1 
# args desc: 'backup days to keep'
#    return: print the how many backups to keep
show_backup_keep(){
 if [ $1 -eq 0 ]
   then
     #msg "never"
     #echo -n "1 backup"
     echo -n "0 backups"
   else
     echo -n "$1 " ; msg "backups"
 fi
}


#      desc: calc and save the backup destination size
#      args: $1
# args desc: 'backup destination path'
#    return: save the backup destination size
save_size_destination() {
  local destination="$1"

  check_file ${destination} 2>/dev/null
  if [ $? -eq 0 ]
   then 
     # from fedora 17 du -csxb is not working
     size_destination=$(du -csb ${destination} | tail -n 1 | awk '{print $1}')
     echo "${size_destination}" > "${file_size_destination}"
   else
     size_destination="$(report_text unknow)"
     echo "${size_destination}" > "${file_size_destination}"
  fi
}

#      desc: calc and save the backup source size
#      args: $1
# args desc: 'backup source path'
#    return: none
save_size_source() {
  local source=$1

  check_file ${source} 2>/dev/null
  if [ $? -eq 0 ]
   then 
     size_source=$(du -csb ${source} | tail -n 1 | awk '{print $1}')
     echo ${size_source} > ${file_size_source}
   else
     size_source="$(report_text unknow)"
     echo ${size_source} > ${file_size_source}
  fi
}


#      desc: save the current backup step size
#      args: $1
# args desc: 'backup step size' 'type of variable replacement'
#    return: none
save_size_backup() {
  local value=$1
  local option=$2
  local value_old=$(cat ${file_size_backup})

  case $option in
	varreplace)	size_backup="${value}"		; echo "$(count_ints)"	> "${file_size_backup}" ;; # display current backup_size but save the sum of old backups size
	allreplace)	size_backup="${value}"		; echo "${value}"		> "${file_size_backup}" ;; # display current backup_size and don't sum old backups size
	*)		size_backup="$(count_ints)"	; echo "${size_backup}"		> "${file_size_backup}" ;; # display and save the sum of old backups size variables
  esac
}


# FIXME very bad function
#      desc: summarize ints numbers (value_old + value new)
#      args: none
# args desc: none
#    return: none
count_ints(){
  if [ -n "${value_old}" ] && [ -z "$(echo "${value}" | grep [^0-9])" ]
    then
      if [ -z "${value}" ]
        then
          echo "${value_old}"
        else
          echo "$(expr ${value_old} + ${value})"
      fi
    else
      if [ -z "$(echo "${value}" | grep [^0-9])" ]
        then
          echo "${value}"
        else
          report_text unknow
          return 1
      fi
  fi
}


#      desc: set some useful backup info
#      args: none
# args desc: none
#    return: none
set_stats_backup() {
  #touch "${file_size_backup}" "${file_stats_files_backup}" "${file_stats_files_total}"
  size_backup=$(cat "${file_size_backup}")
  files_backup=$(cat "${file_stats_files_backup}")
  files_total=$(cat "${file_stats_files_total}")
}


#      desc: save some useful backup info
#      args: $1 $2 $3
# args desc: 'type of info' 'file containing the info' 'output of file containing the calculated info'
#    return: none
save_stats_backup(){
  local type="$1"
  shift
  local file_stats="$1"
  shift
  local file_output="$1"
  shift
  local string=$@

  [ ! -f "${file_stats}" ]  && report_text internal_error && return 1
  [ ! -f "${file_output}" ] && report_text internal_error && return 1

  case $type in
	files_backup|files_total|size_backup)
		local value=$(cat ${file_stats} | grep ^"${string}" | awk -F: '{print $2}' | awk '{print $1}' | tr -d [:alpha:] | tr -d [:blank:] | tr -d [:cntrl:] | tr -d [:punct:])
		local value_old=$(cat $file_output)

                count_ints > "${file_output}"
                eval $type="\"${value}\""

		# Make a backup of stats file
                #cp "${file_stats}" "${file_stats}.$(show_time_unix)"
		;;
	*)	report_text internal_error ;;
  esac
}


#      desc: find all socket files in path
#      args: $1
# args desc: 'directory path'
#    return: print a list of socket files found in path
find_socket_files() {
  find $1 -type s 2>/dev/null
}


#      desc: init the backup erase procedure
#      args: $1
# args desc: 'pattern name of backup destination'
#    return: none
backup_erase_init() {
    local pattern="$1"
    local previous_dir="${PWD}"
    local usr_file_list_backup_failed="${backup_destination}/${usr_file_backup_failed_log}"

    make_list_backup() {
      ls -1 | grep ^"${pattern}" | sort
    }

    cd "${backup_destination}"

    # tmp: be sure to use the default value of backup_keep variable
    #config_field_import ${usr_file_conf} backup_keep int notnull

    # check the global status of backup
    check_status_backup 2>&1 > /dev/null ; local status_backup="$?"

    # increment by one the value to be sure to keep the current day if the backup_keep <= 0
    #[ ${backup_keep} -le 0 ] && backup_keep=1

    # reassign the backup_keep variable to this step
    local backup_keep_step="${backup_keep}"

    # reorder from the list the latest good rsync backup (find it bacause it's symlinked)
    if [ $(find -maxdepth 1 -type l) ]
      then
       # never erase the latest good backup
       local last_good_backup="$(readlink $(find -maxdepth 1 -type l | tail -n1))"
       # append after last good backup the backup list
       make_list_backup | grep -v "${last_good_backup}" > "${file_list_backup}"
       # place the good backup in the high priority keep
       echo "${last_good_backup}" >> "${file_list_backup}"
      else
       # extract the total backup list
       make_list_backup > "${file_list_backup}"
    fi

    # save into destination log file the name of this backup if the result is error
    if [ ${status_backup} -eq 1 ]; then
      # increase by 1 the backup_keep variable, useful to resolve one time problems
      let backup_keep_step=$backup_keep_step+1
      echo "$(basename ${backup_destination_step})" >> "${usr_file_list_backup_failed}"
    fi

    #set -x
    # give the previous failed backups a major priority against good backups (erase first bad backups than good backups)
    if [[ -e "${usr_file_list_backup_failed}" && ! -z "$(cat "${usr_file_list_backup_failed}")" ]]
      then
	# extract failed backup list
        cat "${usr_file_list_backup_failed}" | sort  > "${file_list_backup_failed}"

	# extract good backup list
        cat "${file_list_backup}" | grep -v -f "${file_list_backup_failed}" > "${file_list_backup_good}"

	# make the new backup list in reverse order
	cat "${file_list_backup_failed}" "${file_list_backup_good}" > "${file_list_backup}"
    fi

    # make a list of backup to keep
    cat "${file_list_backup}" | tail -n "${backup_keep_step}" > "${file_list_backup_keep}"

    # make the erasable backups list (WARNING: this is the list of backups that will be erased!!!)
    cat "${file_list_backup}" | grep -v -f "${file_list_backup_keep}" | sort | uniq > "${file_list_backup_erase}"

    #set +x

    # debug
    #echo "usr_file_list_backup_failed = $usr_file_list_backup_failed" ; [ -e "${usr_file_backup_failed_log}" ] && cat "${usr_file_backup_failed_log}"
    #echo
    #echo "           file_list_backup = $file_list_backup" ; cat "${file_list_backup}"
    #echo
    #echo "      file_list_backup_good = $file_list_backup_good" ; cat "$file_list_backup_good"
    #echo
    #echo "    file_list_backup_failed = $file_list_backup_failed" ; cat "${file_list_backup_failed}"
    #echo
    #echo "      file_list_backup_keep = $file_list_backup_keep" ; cat "${file_list_backup_keep}"
    #echo
    #echo "     file_list_backup_erase = $file_list_backup_erase" ; cat "${file_list_backup_erase}"
    #echo
    #echo "           backup_keep_step = $backup_keep_step"

    cd "${previous_dir}"
}


#      desc: erase all old backup by using the backup config file variable backup_keep
#      args: none
# args desc: none
#    return: none
backup_erase() {
  previous_dir="${PWD}"
  cd "${backup_destination}"

  check_status_backup 2>&1 > /dev/null
  if [[ $? -eq 0 || "${backup_keep_on_errors}" = "no" ]] && [ "${backup_keep}" -ge "0" ]
    then
      # erasing old backups
      #echo "        giorni da mantenere:" $backup_keep
      #echo "         directory corrente:" ${PWD}
      #echo "    lista di tutti i backup:" *$system*
      #echo "         lista da mantenere:" $(cat ${file_list_backup_keep})
      #echo "lista da mantenere cmd find:" $(cat ${file_list_backup_keep_find})
      #echo
      #find -maxdepth 1 -name "*${system}*" $(cat ${file_list_backup_keep_find}) | xargs -r rm -rf
      #find -maxdepth 1 -name "*${system}*" $(cat ${file_list_backup_keep_find}) | xargs -r echo "rm -rf"

      # this is the most dangerous command of synbak ;-)
      #xargs -n1 -r -I '{}' sh -c 'rm -rf {} ; echo "sed -i /{}/d $usr_file_backup_failed_log'
      #cat "${file_list_backup_erase}" | xargs -n1 -r rm -rf

      # remove from the usr_file_backup_failed_log the erased backup
      cat "${file_list_backup_erase}" | while read bck
	do
	  #echo erasing backup "${bck}"

          # using rm (with some nfs connected server, this can be problematic)
	  #rm -rf "${bck}"
          # nfs qnap crap!
          rm -rf "${bck}" >/dev/null 2>&1 

          # using find
          #if [ -d "${bck}" ]
	  #  then
          #    find "${bck}" -type f | xargs -r rm -f
          #    find "${bck}" -type d | xargs -r rm -rf
          #  else
	  #    rm -f "${bck}"
          #fi

	  if [ -e "${backup_destination}"/"${usr_file_backup_failed_log}" ]
            then
              # remove from synbak-failed.log file the erased backup
              sed -i /$bck/d "${usr_file_backup_failed_log}"
              # if there aren't failed backups anymore, then erase the synbak-failed.log too
              [ -z "$(cat "${usr_file_backup_failed_log}")" ] && rm -f "${usr_file_backup_failed_log}"
          fi
	done
    else
      report_text backup_erase_error
  fi
  cd "${previous_dir}"
}


#      desc: unset all used variables by parse_uri function
#      args: none
# args desc: none
#    return: none
#     FIXME: because this function must be used outside the parse_uri function, it must be duplicated here
parse_uri_unset_variables() {
	unset protocol username password host port path
}


#      desc: set/check/sanitize/validate a URI and the gained variables
#      args: $1
# args desc: 'URI'
#    return: misc variables containing the URI data
parse_uri() {
  #      desc: set in the uritmp variable the URI given
  #      args: $1
  # args desc: 'URI'
  #    return: none
  parse_uri_set_uritmp() {
	uritmp="$(echo ${uritmp} | awk -F "$1" '{print $2}')"
  }

  #      desc: check if the uri contain invalid character
  #      args: $1
  # args desc: 'URI'
  #    return: print the sanitized version of the given uri
  parse_uri_check_uri() {
	echo $1 | tr -d [:alnum:] | tr -d "." | tr -d "-" | tr -d "_" | tr -d ":" | tr -d "/" | tr -d "@" | tr -d "$" | tr -d "~"
  }

  #      desc: check if the host contain invalid characters and print a sanitized version
  #      args: $1
  # args desc: 'URI'
  #    return: print the sanitized hostname given
  parse_uri_check_host() {
	echo $1 | tr -d [:alnum:] | tr -d "." | tr -d "-" | tr -d ":" | tr -d "/"
  }

  #      desc: unset all used variables by parse_uri function
  #      args: none
  # args desc: none
  #    return: none
  parse_uri_unset_variables() {
	unset protocol username password host port path
  }

  # copy to uritmp variable the given URI string
  local uritmp=$1

  # assure that doesn't exist already variables used by this function
  parse_uri_unset_variables

  # set the standard RFC URI delimiters
  local uri_delimiter="://"
  local username_delimiter="@"
  local password_delimiter=":"
  local port_delimiter=":"
  local path_delimiter="/"

  # return 0 if no uri is passed to this function
  [ -z "$(echo ${uritmp})" ] && parse_uri_unset_variables && return 0
  # return 1 if the uri doesn't contain the standard uri delimiter
  [ -z "$(echo ${uritmp} | grep ${uri_delimiter})" ] && parse_uri_unset_variables && return 1

  # set the used protocol
  protocol="$(echo ${uritmp} | awk -F "${uri_delimiter}" '{print $1}')" ; parse_uri_set_uritmp "${protocol}${uri_delimiter}"

  # file:// uri workaround
  # because this special uri doesn't contain a host declaration, modify the uri before parsing it
  [ "${protocol}" = "file" ] && uritmp="localhost/${uritmp}"

  # check if the server uri contain a username or password
  if [ -n "$(echo ${uritmp} | grep "${username_delimiter}")" ]
    then
      username="$(echo ${uritmp} | sed "s/${username_delimiter}.*//g")" ; parse_uri_set_uritmp "${username}${username_delimiter}"

      # check if the uri contain the password
      if [ -n "$(echo "${username}" | grep "${password_delimiter}")" ]
        then
          password="$(echo "${username}" | awk -F "${password_delimiter}" '{print $2}')"
          username="$(echo "${username}" | awk -F "${password_delimiter}" '{print $1}')"
          # normalize password if problematic characters are found
          password="$(echo "${password}" | sed s/\!/\\"\!"/g | sed s/\'/\\"\'"/g | sed s/\*/\\"\*"/g)"
      fi

      # stop if no username is set, like wrong written uri with multiple "@" or ":" 
      [ -z "${username}" ] && parse_uri_unset_variables && return 1
  fi

  # stop if the uri contain invalid caracters
  [ -n "$(parse_uri_check_uri "${uritmp}")" ] && parse_uri_unset_variables && return 1

  # check if the uri contain a port number
  if [ -n "$(echo ${uritmp} | grep "${port_delimiter}")" ]
    then
     host="$(echo ${uritmp} | awk -F "${port_delimiter}" '{print $1}')" ; parse_uri_set_uritmp "${host}"
     port="$(echo ${uritmp} | awk -F "${port_delimiter}" '{print $2}' | awk -F "${path_delimiter}" '{print $1}')" ; parse_uri_set_uritmp "${port_delimiter}${port}${path_delimiter}"
     path="$(echo ${uritmp})" ; parse_uri_set_uritmp "${path}"
    else
     host="$(echo ${uritmp} | sed 's/^\/*//g' | awk -F "${path_delimiter}" '{print $1}')" ; parse_uri_set_uritmp "${host}${path_delimiter}"
     path="$(echo ${uritmp})" ; parse_uri_set_uritmp "${path}"
  fi

  # stop if the host contain invalid caracters
  [ -n "$(parse_uri_check_host "${host}")" ] && parse_uri_unset_variables && return 1

  # hide the user password in the uri variable
  if   [[ -n "${password}" && -n "${port}" ]]
    then
     uri="${protocol}${uri_delimiter}${username}${password_delimiter}xxxxxxxx${username_delimiter}${host}${port_delimiter}${port}${path_delimiter}${path}"
  elif [[ -n "${password}" && -z "${port}" ]]
    then
     uri="${protocol}${uri_delimiter}${username}${password_delimiter}xxxxxxxx${username_delimiter}${host}${path_delimiter}${path}"
  elif [ -z "${password}" ]
    then
     uri=$1
  fi

  # print the parsed fields
  #echo "          URI:" $uri
  #echo "   Protocollo:" $protocol
  #echo "     Username:" $username
  #echo "     Password:" $password
  #echo "         Host:" $host
  #echo "         Port:" $port
  #echo "         Path:" $path
  #echo "URI rimanente:" $uritmp

  unset uritmp
}


#      desc: import a URI variable into synbak usable variables
#      args: $1
# args desc: 'URI'
#    return: synbak variables containing the URI data
import_backup_source_uri_variables() {
  local uri="$1"
  # save the original imported URI to the 'backup_source_uri_original' variable, warning this uri contain the clear text password also
  backup_source_uri_original="$uri"

  # because the special uri file:// doesn t contain a host declaration, modify the uri before parsing it
  #[ $(echo "$uri" | grep ^"file://") ] && uri="$(echo "$uri" | sed 's/file:\/\//file:\/\/localhost\//')"

  parse_uri "$uri"

  # set reusability variables
  backup_source_uri="$uri"
  backup_source_uri_protocol="$protocol"
  backup_source_uri_username="$username"
  backup_source_uri_password="$password"
  backup_source_uri_host="$host"
  backup_source_uri_port="$port"
  backup_source_uri_path="$path"

  parse_uri_unset_variables
}


#      desc: verify if the remote host port is reachable (automatically obtained by URI protocol field)
#      args: $1
# args desc: 'URI'
#    return: return code 0 = reachable, 1 = unreachable
check_status_host() {
  #      desc: test reachability of remote netbios host using some samba commands
  #      args: $1 $2
  # args desc: 'host' 'port'
  #    return: return code 0 = reachable, 1 = unreachable
  host_check_netbios() {
        local t_username="$([ -n "${username}" ] && echo "-U ${username}")"
        local t_password="$([ -n "${password}" ] && echo "%${password}" || echo " -N")"
        local check1="$(eval smbclient -N -L "$1" >/dev/null 2>&1 ; echo $?)"
        local check2="$(eval smbclient -d 0 //${host}/${path} ${t_username}${t_password} -c quit >/dev/null 2>&1 ; echo $?)"
        #echo check1 = $check1
        #echo check2 = $check2
        if [[ "${check1}" = 0 || "${check2}" = 0 ]]
          then
            return 0
          else
            return 1
        fi
  }

  #      desc: test reachability of remote host using nc command
  #      args: $1 $2
  # args desc: 'host' 'port'
  #    return: return code 0 = reachable, 1 = unreachable
  #     FIXME: some broken 'nc' version require an option after '-z' option
  #            so I used -4 option to make this work on every machines, but this
  #            make synbak work with IPv4 address only
  #            --->   nc -z -4 "$1" "$2" >/dev/null 2>&1
  host_check_port()    {
        # because on some distributions 'nc' command is named 'netcat', we must manage that!
	if   [ $(which netcat >/dev/null 2>&1 ; echo $?) = 0 ]
          then
           #echo "we are using netcat!!!"
	   netcat -w 2 "$1" "$2" </dev/null >/dev/null 2>&1
          else
	   nc -w 2 "$1" "$2" </dev/null >/dev/null 2>&1
           # nmap-netcat from centos > 7 require option -4 ???
	   #nc -w 2 "$1" "$2" </dev/null >/dev/null 2>&1
        fi
        return $?
  }

  #      desc: testing reachability of remote host using standard ping
  #      args: $1 $2
  # args desc: 'host' 'port'
  #    return: return code 0 = reachable, 1 = unreachable
  host_check_ping()    {
	local check1=$(ping -c 3 "$1" 2>/dev/stdout 1>/dev/null)
	local check2=$(ping -c 3 "$1" 2>&1 | grep "100%")
	if [[ -n "${check1}" || -n "${check2}" ]]; then return 1 ; else return 0; fi
  }


  local uri="$1"
  parse_uri "$uri"

  case ${protocol} in
	file) return 0 ;; # always return true, because file:// URI is local
	smb|cifs) host_check_netbios "${host}" ;;
	netbios)[ -z "${port}" ] && port=139  ; host_check_port "${host}" "${port}" ;;
	rsync) 	[ -z "${port}" ] && port=873  ; host_check_port "${host}" "${port}" ;;
	ssh)	[ -z "${port}" ] && port=22   ; host_check_port "${host}" "${port}" ;;
	ftp)	[ -z "${port}" ] && port=21   ; host_check_port "${host}" "${port}" ;;
	http)	[ -z "${port}" ] && port=80   ; host_check_port "${host}" "${port}" ;;
	https)	[ -z "${port}" ] && port=443  ; host_check_port "${host}" "${port}" ;;
	ldap)	[ -z "${port}" ] && port=389  ; host_check_port "${host}" "${port}" ;;
	mysql)	[ -z "${port}" ] && port=3306 ; host_check_port "${host}" "${port}" ;;
	pgsql)	[ -z "${port}" ] && port=5432 ; host_check_port "${host}" "${port}" ;;
	oracle)	[ -z "${port}" ] && port=1521 ; host_check_port "${host}" "${port}" ;;
	*)	host_check_ping "${host}" ;; # if no protocol is supported, then revert to standard icmp protocol to verify if a host is up 
  esac

  return $?
}


#      desc: mount the specified remote share specified in the backup_source_uri synbak variable
#      args: none (internal synbak variables usage)
# args desc: none
#    return: return code 0 = mounted, 1 = failed to mount
mount_host(){
 # Create the temp mount directory
 #dir_mnt="${dir_mnt}/${backup_source_uri_path}"
 mkdir -p "${dir_mnt}"

 # fix domain into username
 if [ ! -z $(echo $backup_source_uri_username | grep -e '/' -e '\\') ]; then
     domain=$(echo $backup_source_uri_username | tr -s '/' ' ' | tr -s '\\' ' ' | awk '{print $1}')
   username=$(echo $backup_source_uri_username | tr -s '/' ' ' | tr -s '\\' ' ' | awk '{print $2}')
   backup_source_uri_username="$username,domain=$domain"
 fi

 mount_cifs(){
   eval mount.cifs "//${backup_source_uri_host}/${backup_source_uri_path}" "${dir_mnt}" -o ro$([ -n "${backup_source_uri_username}" ] && echo ",username=$backup_source_uri_username")$([ -n "${backup_source_uri_password}" ] && echo ",password=$backup_source_uri_password" || echo ",guest")
 }

 mount_smb(){
   eval smbmount "//${backup_source_uri_host}/${backup_source_uri_path}" "${dir_mnt}" -o ro$([ -n "${backup_source_uri_username}" ] && echo ",username=$backup_source_uri_username")$([ -n "${backup_source_uri_password}" ] && echo ",password=$backup_source_uri_password" || echo ",guest"),debug=0 | grep -v ^"opts:"
 }

 case "${backup_source_uri_protocol}" in
        cifs)
                mount_cifs
                ;;
        smb)
                # to fix an old Red Hat 9 bug when mounting uncomment the following line
                #export LD_ASSUME_KERNEL=2.2.5

		# Revert to standard unix mount.cifs command if smbmount doesn't exist
                if [ $(which smbmount >/dev/null 2>&1 ; echo $?) = 0 ]
                  then
                   mount_smb
                  else
                   mount_cifs
                fi
                ;;
        *)      report_text mount_unsupported
                ;;
 esac

 return $?
}


#      desc: umount the remote share mounted in the dir_mnt synbak variable
#      args: none (internal synbak variables usage)
# args desc: none
#    return: none
#     FIXME: must add a return code to verify if the umount success
umount_host() {
 case ${backup_source_uri_protocol} in
	smb)
		# Revert to standard unix umount command if smbumount doesn't exist
		if [ $(which smbumount >/dev/null 2>&1 ; echo $?) = 0 ]
                  then
                    smbumount "${dir_mnt}"
                  else
                    umount "${dir_mnt}" 
                fi
		;;
	cifs)
		# Revert to standard unix umount command if umount.cifs doesn't exist
		if [ $(which umount.cifs >/dev/null 2>&1 ; echo $?) = 0 ]
                  then
		    umount.cifs "${dir_mnt}" 
                  else
                    umount "${dir_mnt}" 
                fi
		;;
	*)	umount "${dir_mnt}" ;;
 esac
}


#      desc: verify the just made backup
#      args: '$1' '$2'
# args desc: 'type' 'file'
#    return: print the output of backup verify
backup_verify() {
  local type="$1"
  shift
  local file="$1"

  case "${type}" in
    dar)
      dar -t "$file"
      echo
      ;;
    tar)
      # print only directories of archive
      tar  tvf "$file" | grep ^d
      echo
      ;;
    tgz)
      # print only directories of archive
      tar ztvf "$file" | grep ^d
      echo
      ;;
    tbz2)
      # print only directories of archive
      tar jtvf "$file" | grep ^d
      echo
      ;;
    tape)
      # print only directories of archive
      tar  tvf "$file" | grep ^d
      echo
      ;;
  esac
}


###@@@
###@@@ backup procedures
###@@@

backup_schedule() {
 #set -x

 # what backup type must run today?
 # verify first the backup_schedule_planning before tring to run a scheduled backup
 # d=daily w=weekly m=monthly y=yearly

 if echo "${backup_schedule_planning}" | grep -q -w d 
   then local   run_daily="$(echo ${backup_schedule_daily_cron}   | grep -q -w $(date +"%u"); echo $?)"
   else local   run_daily=1
 fi
 if echo "${backup_schedule_planning}" | grep -q -w w
   then local  run_weekly="$(echo ${backup_schedule_weekly_cron}  | grep -q -w $(date +"%u"); echo $?)"
   else local  run_weekly=1
 fi
 if echo "${backup_schedule_planning}" | grep -q -w m
   then local run_monthly="$(echo ${backup_schedule_monthly_cron} | grep -q -w $(date +"%e" | tr -d [:space:]); echo $?)"
	# find the last day of current month, and if today is the last day, run monthly backup
	local monthly_lastday=$(date +%d -d "-$(date +%d) days +1 month")
	[[ $(date +"%e" | tr -d [:space:]) -eq ${monthly_lastday} && ${backup_schedule_monthly_cron} -gt ${monthly_lastday} ]] && local run_monthly=0
   else local run_monthly=1
 fi
 if echo "${backup_schedule_planning}" | grep -q -w y
   then local  run_yearly="$(echo ${backup_schedule_yearly_cron}  | grep -q -w $(date +"%m-%d"); echo $?)"
   else local  run_yearly=1
 fi

 find_good_rsync_backups() {
  # the readlink check is useful to not include invalid cross device links (hardlinking is not possible across different disks and partitions)
  [[ -e "${backup_destination}/yearly/backup-$system"  && "$(dirname $(readlink -f "${backup_destination}/${type}"))" = "$(dirname $(readlink -f "${backup_destination}/yearly"))" ]]  && backup_method_opts="${backup_method_opts} --link-dest=${backup_destination}/yearly/backup-$system"
  [[ -e "${backup_destination}/monthly/backup-$system" && "$(dirname $(readlink -f "${backup_destination}/${type}"))" = "$(dirname $(readlink -f "${backup_destination}/monthly"))" ]] && backup_method_opts="${backup_method_opts} --link-dest=${backup_destination}/monthly/backup-$system"
  [[ -e "${backup_destination}/weekly/backup-$system"  && "$(dirname $(readlink -f "${backup_destination}/${type}"))" = "$(dirname $(readlink -f "${backup_destination}/weekly"))" ]]  && backup_method_opts="${backup_method_opts} --link-dest=${backup_destination}/weekly/backup-$system"
  [[ -e "${backup_destination}/daily/backup-$system"   && "$(dirname $(readlink -f "${backup_destination}/${type}"))" = "$(dirname $(readlink -f "${backup_destination}/daily"))" ]]   && backup_method_opts="${backup_method_opts} --link-dest=${backup_destination}/daily/backup-$system"
 }

 # anyway execute the backups only if we can keep more than 0 backups of course :)
 if   [[ ${backup_schedule_yearly_keep} -gt 0 && ${run_yearly}  -eq 0 ]]
   then 
        local type=yearly
	[[ ${method_rsync_differential} != "yes" && ${method} = "rsync" ]] && find_good_rsync_backups
	backup_destination="${backup_destination}/${type}"
	backup_keep="${backup_schedule_yearly_keep}"
	method_type="$(msg yearly)"

 elif [[ ${backup_schedule_monthly_keep} -gt 0 && ${run_monthly} -eq 0 ]]
   then 
        local type=monthly
	[[ ${method_rsync_differential} != "yes" && ${method} = "rsync" ]] && find_good_rsync_backups
	backup_destination="${backup_destination}/${type}"
	backup_keep="${backup_schedule_monthly_keep}"
	method_type="$(msg monthly)"

 elif [[ ${backup_schedule_weekly_keep} -gt 0 && ${run_weekly} -eq 0 ]]
   then 
        local type=weekly
	[[ ${method_rsync_differential} != "yes" && ${method} = "rsync" ]] && find_good_rsync_backups
	backup_destination="${backup_destination}/${type}"
	backup_keep="${backup_schedule_weekly_keep}"
	method_type="$(msg weekly)"

 elif [[ ${backup_schedule_daily_keep} -gt 0 && ${run_daily} -eq 0 ]]
   then 
        local type=daily
	[[ ${method_rsync_differential} != "yes" && ${method} = "rsync" ]] && find_good_rsync_backups
	backup_destination="${backup_destination}/${type}"
	backup_keep="${backup_schedule_daily_keep}"
	method_type="$(msg daily)"

   else
	exit 0
 fi

  # make the destination directory only if exist the parent directory and the backup_destination_prefix is used
  if [[ -e "$(dirname "${backup_destination}")" && -w "$(dirname "${backup_destination}")" ]] ; then
    [ -e "${backup_destination}" ] || mkdir -p "${backup_destination}"
  fi

 #set +x
}



#      desc: begin the synbak backup procedure
#      args: none (internal synbak variables usage)
# args desc: none
#    return: synbak backup output
usr_make_backup() {
  # run backup schedule if set
  [[ "${backup_schedule}" = "yes" && "${backup_destination_prefix}" = "yes" ]] && backup_schedule
  # set backup method type
  [ -z "${method_type}" ] && method_type="$(msg single)"

  # run the backup
  . "${sys_file_method}"

  save_time_end
  save_time_duration
  usr_make_report
}



###@@@
###@@@ report procedures
###@@@


#      desc: begin the synbak report procedure
#      args: none (internal synbak variables usage)
# args desc: none
#    return: synbak report output
report_run() {
  check_file "${sys_dir_report}/$1/$1.sh"
  if [ $? -eq 0 ]
    then
      local sys_dir_report="${sys_dir_report}/$1"
      local sys_file_report="${sys_dir_report}/$1.sh"
      . "${sys_file_report}"
  fi
}

#      desc: before running report procedure check the state of the system
#      args: none (internal synbak variables usage)
# args desc: none
#    return: synbak report output
usr_make_report() {
  if [[ ${status_host} = 1 && "${report_remote_uri_down}" = "no" ]]
    then
      return 0
    else
      for report in $(find "${sys_dir_report}" -maxdepth 1 -type d | sed -e 's/^.\///' | grep -wv ^"." | grep -v "${sys_dir_report}"$)
        do
          check_file ${report}/$(basename ${report}).sh
          if [ $? -eq 0 ]
            then
              report_run $(basename ${report}) backup 
          fi
        done
  fi
}


