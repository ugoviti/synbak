#!/bin/sh
#
#   email.sh - email report handler
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
#config_field_import report_email                text    null "${usr_file_conf}" keep
#config_field_import report_email_on_errors      text    null "${usr_file_conf}" keep
#config_field_import report_email_rcpt           text    null "${usr_file_conf}" keep


report_email() {
  case $1 in
        email_subject) msg "[\${synbak_package}] server:[\${synbak_server}] system:[\${system}] method:[\${method}] result:" ; echo -n "[$(check_status_backup)]" ;;
  esac
}


report_make() {
  cat ${file_log_output} | mail -s "$(report_email email_subject)" "${report_email_rcpt}"
}


# parse the report input command and make the report
case $2 in
        backup)
		if [ "${report_email}" = "yes" ]
		  then
                    save_time_begin_step
                    report_text report_step
                    report_make > ${file_log_errors} 2>&1
                    save_time_end_step
                    check_status_step
		  else
		    check_status_backup 2>&1 > /dev/null
		    if [[ $? -eq 1 && "${report_email_on_errors}" = "yes" ]]
		      then
                        save_time_begin_step
                        report_text report_step
                        report_make > ${file_log_errors} 2>&1
                        save_time_end_step
                        check_status_step
		    fi
		fi
                ;;
esac


