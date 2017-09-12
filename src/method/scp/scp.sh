#!/bin/sh
#
#   scp - scp backup method handler
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


# variables useful to this method
backup_method_cmd="scp"
backup_method_opts_default=""

#backup_method_opts=""
backup_name_prefix="backup"
backup_name_suffix="$(show_time_human ${time_begin} backup)"
backup_name="${backup_name_prefix}-${system}"
backup_destination_latest="${backup_destination}/${backup_name}"
backup_destination_step="${backup_destination_latest}-${backup_name_suffix}"


# define the right destination paths based on backup type
method_manage_latest_backup() {
    current_dir="${PWD}"
    cd "$(dirname "${backup_destination_latest}")"

    # remove the backup_destination_latest if it'is not a link or a directory
    [ -f "${backup_destination_latest}" ] && rm -f "${backup_destination_latest}"

    # if backup_destination_latest is a directory move it to the backup_destination_step directory (used when converting an differential backup to total backup with hard links system)
    if [[ -d "${backup_destination_latest}" && ! -L "${backup_destination_latest}" ]]
      then
        mv    "$(basename "${backup_destination_latest}")" "$(basename "${backup_destination_step}")"
        ln -s "$(basename "${backup_destination_step}")"   "$(basename "${backup_destination_latest}")"
    fi

    # if not exist the backup_destination_latest, link it to the current backup
    if [ ! -e "${backup_destination_latest}" ]; then
       [ -L "${backup_destination_latest}" ] && rm -f "${backup_destination_latest}"
       ln -s "$(basename "${backup_destination_step}")" "$(basename "${backup_destination_latest}")"
    fi

    # return to the initial working directory
    cd "${current_dir}"
}



# set the differential destionation name if method_rsync_differential=yes in the config file
if [[ -e "${backup_destination}" && "${method_rsync_differential}" != "yes" ]]
  then
    # manage latest backup made, used for hardlinking new backup against previous backup (with hard links the used space is equal to the backed up file sizes)
    [ "${backup_destination_prefix}" != "no" ] && method_manage_latest_backup
    [[ "${backup_schedule}" != "yes" && "${backup_destination_prefix}" = "yes" ]] && backup_method_opts="${backup_method_opts} --link-dest=${backup_destination_latest}"

  else
    backup_destination_step="${backup_destination_latest}"
    backup_destination_differential="${backup_destination_latest}-${backup_name_suffix}"
    # revert a total backup to an differential backup
    if [ -L "${backup_destination_latest}" ]; then
      backup_destination_previous="$(dirname "${backup_destination_latest}")/$(readlink "${backup_destination_latest}")"
      rm -f "${backup_destination_latest}"
      mv "${backup_destination_previous}" "${backup_destination_latest}"
    fi
fi

# if backup_destination_prefix=no then doesn't create any destination directory and don't use backup prefix and suffix
if [ "${backup_destination_prefix}" = "no" ]
  then
    backup_keep="0"
    backup_destination_step="${backup_destination}"
fi


# set the real destination of this backup method
backup_destination_real="${backup_destination_step}"


method_stats() {
            save_stats_backup size_backup  "${file_log_stats_step}" "${file_size_backup}"        "Total transferred file size:"
            save_stats_backup files_backup "${file_log_stats_step}" "${file_stats_files_backup}" "Number of files transferred:"
            save_stats_backup files_total  "${file_log_stats_step}" "${file_stats_files_total}"  "Number of files:"
}


method_init(){
 # if the backup_source_uri field is not set, set this method to make a local backup
 [ -z "${backup_source_uri}" ] && backup_source_uri="sftp://"

 # if is given a URI then check first if the remote host is reachable 
 check_status_host "${backup_source_uri}"
 save_status_host
 #echo status_host = $status_host

 # import the variables used to connect to remote server and hide the password from the uri
 import_backup_source_uri_variables "${backup_source_uri}"
 method_option="${backup_source_uri_protocol}"

 # supported scp method protocols
 case ${backup_source_uri_protocol} in
  sftp)
	local backup_method_opts_scp=""

	[ ! -z "${backup_source_uri_port}" ] && backup_method_opts_scp="${backup_method_opts_scp} -P ${backup_source_uri_port}"

	# finalyze the passed options to scp command
	backup_method_opts_default="${backup_method_opts_default} ${backup_method_opts_scp}"
	;;
  *)
	report_text uri_unsupported
	report_text protocol_unsupported
	return 1;
	;;
 esac
 save_method_info 
}



method_backup() {
 # the real backup method comand to run
 make_backup_step() {
   # if backup_destination_step dosn't exist, make it
   [ ! -e "${backup_destination_step}" ] && mkdir -p "${backup_destination_step}"

   # run the backup command
   eval ${backup_method_cmd} ${backup_method_opts_default} ${backup_method_opts} $([ ! -z "${backup_source_uri_username}" ] && echo ${backup_source_uri_username}@)${backup_source_step} ${backup_destination_step}/
 }


  # pre backup operations
  case ${backup_source_uri_protocol} in
	smb|cifs)
	    # mount remote host if the host is reachable
	       save_time_begin_step
	       report_text mount_step
               mount_host > ${file_log_errors_step} 2>&1
	       save_status_mount
	       save_time_end_step
	       check_status_step
	       report_text separator_info3
	       # exit if error on mount
               #[ ${status_mount} -gt 0 ] && return 1;
               [ $(check_status_step >/dev/null 2>&1 ; echo $?) -gt 0 ] && return 1;
	 ;;
  esac

  # real backup sequence
  set -f
  # check if file_list_source is not empty
  [ -z "$(cat ${file_list_source})" ] && echo "." > "${file_list_source}"
  cat "${file_list_source}" | while read -r backup_source_step ; do
    # remove the leading / from backup_source_step variable path
    #backup_source_step="$(echo ${backup_source_step} | sed 's/^\///')"

    case ${backup_source_uri_protocol} in
     sftp)
       # set the backup base if specified (with this method scp will prepend the base specified into uri for every entry into backup_source)
       [ ! -z "${backup_source_uri_path}" ] && backup_source_step="${backup_source_uri_path}/./${backup_source_step}"
      ;;
     # not useful right now
     #smb|cifs)
     #  # remove the share name from the path
     #  if [[ ! -z "${backup_source_uri_path}" && ! -z "$(echo ${backup_source_uri_path} | awk -F"/" '{print $2}')" ]]
     #    then
     #      local windows_share="$(echo ${backup_source_uri_path} | awk -F"/" '{print $1}')"
     #      backup_source_uri_path="$(echo ${backup_source_uri_path} | sed "s/$windows_share\///")"
     #      backup_source_step="${backup_source_uri_path}/./${backup_source_step}"
     #  fi
     # ;;
    esac

    case ${backup_source_uri_protocol} in
     sftp)
	backup_source_step="${backup_source_uri_host}:\"${backup_source_step}\""
	;;
     esac

     # and now run the backup step
     set +f
     save_time_begin_step
     report_text backup_step
     make_backup_step 2>${file_log_errors_step} 1>${file_log_stats_step}
     save_time_end_step
     method_stats
     check_status_backup_step
     report_text separator_info3
     set -f
   done

   unset backup_source_step
   set +f


   # post backup operations
   case ${backup_source_uri_protocol} in
	smb|cifs)
		cd "${dir_tmp}"
                save_time_begin_step
	        report_text umount_step
                umount_host > ${file_log_errors_step} 2>&1
	        save_status_mount
	        save_time_end_step
	        check_status_step
	        report_text separator_info3
	        # exit if error on method_init
                #[ ${status_mount} -gt 0 ] && return 1;
                [ $(check_status_step >/dev/null 2>&1 ; echo $?) -gt 0 ] && return 1;
	;;
   esac
}
	
method_erase() {
  # auto erasing old backups
  save_time_begin_step
  backup_erase_init "${backup_name_prefix}-${system}-" # with this path i can exclude from auto erase the differential backup
  report_text backup_erase
  backup_erase > ${file_log_errors_step} 2>&1
  save_time_end_step
  check_status_step
  report_text separator_info3
}



## This Method Backup and Text Reporting Procedure

## begin init
method_init
# exit if error on method_init
[ $? -eq 1 ] && exit 1;
## end init

save_time_begin		# save the begin time

report_text separator_info1
report_text system
report_text method
report_text method_option
report_text method_type
report_text backup_source_uri
report_text backup_source
# move backup_destination_real to the backup_destination var
backup_destination_orig="${backup_destination}"
backup_destination="${backup_destination_real}"
report_text backup_destination
# restore backup_destination var
backup_destination="${backup_destination_orig}"
report_text backup_exclude
report_text backup_method_opts
report_text method_rsync_differential
report_text backup_keep
report_text synbak_server
report_text synbak_server_kernel
report_text synbak_version
report_text technical_support
report_text time_start
report_text separator_info2

# before begin the backup check if the destination directory or device exist and is writable
if ! check_writable "${backup_destination}" 2>/dev/null
  then
    report_text separator_error
    check_writable "${backup_destination}"
    save_status_backup_error
    report_text separator_error
    report_text separator_info2
    save_time_end
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
elif [ ${status_host} != 0 ]
  then
    report_text separator_error
    report_text status_host_down
    save_status_backup_error
    report_text separator_error
  else
    ## begin backup
    method_backup
    #sleep 60
fi

sleep 1
set_stats_backup
save_size_destination "${backup_destination_real}"
## end backup

# check the global status of backup
check_status_backup 2>&1 > /dev/null ; local status_backup="$?"

# finalize a non differential backup
if [[ "${method_rsync_differential}" != "yes" && "${backup_destination_prefix}" != "no" && ${status_backup} -eq 0 ]]; then
    # set the new backup_destination_latest location, only if backup complete successful
    [ -L "${backup_destination_latest}" ] && rm -f "${backup_destination_latest}"
    method_manage_latest_backup
fi


## begin erasing old backups
method_erase
## end erasing old backups

report_text system_info

save_time_end		# save the end time
save_time_duration	# save the duration time

report_text separator_info2
report_text time_end
report_text files_backup
report_text size_backup
report_text speed_backup
#report_text files_total
report_text size_destination
report_text time_duration
report_text separator_info3
report_text status_backup
report_text separator_info1

