#!/bin/sh
#
#   html.sh - html report handler
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
#config_field_import report_html			bool	notnull	"${usr_file_conf}" keep
#config_field_import report_html_on_errors	bool	null	"${usr_file_conf}" keep
#config_field_import report_html_uri		uri	notnull	"${usr_file_conf}" keep
#config_field_import report_html_destination	text	notnull	"${usr_file_conf}" keep
#config_field_import report_html_logo		bool	null	"${usr_file_conf}" keep
#config_field_import report_html_logo_image	text	null	"${usr_file_conf}" keep
#config_field_import report_html_logo_link	uri	null	"${usr_file_conf}" keep

check_dir ${report_html_destination} ; [ $? -ne 0 ] && return 1; # check if the destination html report directory or device exist


# init local variables useful to this report
local year=$(show_time_human   ${time_begin} year)
local month=$(show_time_human  ${time_begin} month)
local day=$(show_time_human    ${time_begin} day)
local hour=$(show_time_human   ${time_begin} hour)
local minute=$(show_time_human ${time_begin} minute)
local second=$(show_time_human ${time_begin} second)
local file_cnt_ok="cnt.ok"	# file name containing the counter of 'OK' backups
local file_cnt_errors="cnt.err" # file name containing the counter of 'ERRORS' backups

local report_html_destination_year="${report_html_destination}/${year}"
local report_html_destination_month="${report_html_destination_year}/${month}"
local report_html_destination_day="${report_html_destination_month}/${day}"
local report_html_destination_backup="${report_html_destination_day}/${time_begin}-$RANDOM"
local report_html_file_index="index.html"
local report_html_file_css="synbak.css"
local report_html_file_image_logo="images/synbak-logo.png"
local report_html_file_image_author_logo="images/initzero-logo.png"
local report_html_file_image_synbak_logo="images/synbak-logo-small.png"
local report_html_file_image_calendar="images/calendar.png"
local report_html_file_image_detail="images/detail.png"
local report_html_file_image_next="images/go-next.png"
local report_html_file_image_previous="images/go-previous.png"
local report_rss_file_index="synbak.xml"
local report_rss_file_status="status.xml"
local report_html_file_calendar_config="calendar/config.inc.php"


report_html() {
  case $1 in
	dir_unwritable)	msg "ERROR: the html destination directory '\${report_html_destination_backup}' is not writable" ;;
	page_title_html)msg "${synbak_package} :: ${synbak_server} :: HTML report" ;;
        page_title_rss)	msg "${synbak_package} :: ${synbak_server} :: RSS report" ;;
	last_update_html)msg "last update made at" ; echo -n " $(show_time_human $(show_time_unix) full) " ; msg "by <a href='\${synbak_homepage}'>\${synbak_package}</a> v\${synbak_version}" ;;
	last_update_rss)msg "last update made at" ; echo -n " $(show_time_human $(show_time_unix) full) " ; msg "by \${synbak_package} v\${synbak_version}" ;;
	previous_page)	msg "Go to previous page" ;;
	year)		msg "Year" ;;
	month)		msg "Month" ;;
	day)		msg "Day" ;;
	system)		msg "System" ;;
	method)		msg "Method" ;;
	method_option)	msg "Option" ;;
	method_type)	msg "Type" ;;
	time_begin)	msg "Begin" ;;
	time_end)	msg "End" ;;
	time_duration)	msg "Duration" ;;
	size_backup)	msg "Bak. Size" ;;
	size_destination)msg "Tot. Size" ;;
	speed_backup)	msg "Speed" ;;
	status_backup)	msg "Result" ;;
	ok)		msg "OK" ;;
	error)		msg "ERROR" ;;
	oks)		msg "Ok" ;;
	errors)		msg "Errors" ;;
	totals)		msg "Totals" ;;
	rebuild_indexes)msg "Rebuilding indexes:" ;;
	unknow)		msg "unknow" ;;
	calendar_view)	msg "Calendar View" ;;
	detailed_view)	msg "Detailed View" ;;
	overall_state)	msg "Overall state" ;;
	last_backup)	msg "Last backup" ;;
	last_error)	msg "Last error" ;;
	successful)	msg "Successful" ;;
	failed)		msg "Failed" ;;
  esac
}

read_file(){
  if [ -f "$1" ]
    then
	cat "$1"
    else
	report_html unknow
	return 1
  fi
}

archive_logs() {
  echo "<pre>"			>	$1/${report_html_file_index}
  read_file ${file_log_output} >>	$1/${report_html_file_index}

  cp -f ${file_synbak_server}	$1/
  cp -f ${file_system}		$1/
  cp -f ${file_method}		$1/
  cp -f ${file_method_option}	$1/
  cp -f ${file_method_type}	$1/
  cp -f ${file_status_backup}	$1/
  cp -f ${file_size_backup}	$1/
  cp -f ${file_size_destination}	$1/
  cp -f ${file_time_begin}	$1/
  cp -f ${file_time_end}	$1/
}

# Create the config.inc.php of calendar extension
make_calendar_config(){
  echo "<?php
\$report_html_file_image_previous='../$report_html_file_image_previous';
\$report_html_file_image_next='../$report_html_file_image_next';
\$report_html_file_image_calendar='../$report_html_file_image_calendar';
\$report_html_file_image_detail='../$report_html_file_image_detail';
\$last_update=\"$(report_html last_update_html)\";
\$report_html_file_css='../$report_html_file_css';
\$synbak_description='$synbak_description';
\$synbak_copyright='$synbak_copyright';
\$synbak_homepage='$synbak_homepage';
\$synbak_package='$synbak_package';
\$report_html_logo_image_synbak='../$report_html_file_image_synbak_logo';
\$report_html_logo_image='$([ -n "$report_html_logo_image" ] && echo $report_html_logo_image || echo ../$report_html_file_image_logo )';
\$report_html_logo_link='$report_html_logo_link';
\$page_title_html='$(report_html page_title_html)';
\$page_title_rss='$(report_html page_title_rss)';
\$report_rss_file_index='../$report_rss_file_index';
\$file_cnt_ok='$file_cnt_ok';
\$file_cnt_errors='$file_cnt_errors';
\$txt_detailed_view='$(report_html detailed_view)';
?>"
}

  html_header() {
   find_relative_path(){
     case $1 in
       total)	relative_path="" ;;
       year)	relative_path="../" ;;
       month)	relative_path="../../" ;;
       day)	relative_path="../../../" ;;
     esac
   }

   css_mng() {
     echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"${relative_path}${report_html_file_css}\" />"
   }

   js_mng() {
     #echo "<script type=\"text/javascript\" src=\"${relative_path}js/prototype.js\"></script>
     # <script type=\"text/javascript\" src=\"${relative_path}js/tablesort.js\"></script>"
     echo "<script type=\"text/javascript\" src=\"${relative_path}js/tablesort.js\"></script>"
     echo "      <script type=\"text/javascript\" src=\"${relative_path}js/customsort.js\"></script>"
   }


   logo_mng() {
     if [ "${report_html_logo}" = "yes" ]
       then
         echo "<a href='${report_html_logo_link}'>"
         if [ -n "${report_html_logo_image}" ]
           then
             echo "      <img src='${report_html_logo_image}' title='${report_html_logo_link}' alt='' />"
             echo "      </a>"
           else
             #echo "<img src='${relative_path}${report_html_file_image_author_logo}' title='${report_html_logo_link}' />"
             echo "      <img src='${relative_path}${report_html_file_image_logo}' title='${report_html_logo_link}' alt='' />"
             echo "      </a>"
         fi
     fi
   }

   calendar_mng() {
     echo "<a href='${relative_path}calendar/'><img src='${relative_path}${report_html_file_image_calendar}' onmouseover=\"this.style.background='red';\" onmouseout=\"this.style.background=''\" title='$(report_html calendar_view)' alt='$(report_html calendar_view)' /></a>"
   }

   previous_page_mng() {
     echo "<span><a href='../'><img src='${relative_path}${report_html_file_image_previous}' onmouseover=\"this.style.background='red';\" onmouseout=\"this.style.background=''\" title='$(report_html previous_page)' alt='$(report_html previous_page)' /></a>&nbsp;</span>"
   }

   table_caption_mng() {
     case $1 in
       total)   caption="&nbsp;" ;;
       year)    caption="$(report_html year):<b>$(basename ${year})</b>" ;;
       month)   caption="$(report_html year):<b>$(basename ${year})</b> $(report_html month):<b>$(basename ${month})</b>" ;;
       day)     caption="$(report_html year):<b>$(basename ${year})</b> $(report_html month):<b>$(basename ${month})</b> $(report_html day):<b>$(basename ${day})</b>" ;;
     esac
     echo "<span class='right'>$(calendar_mng $1)</span>$([ "$1" != "total" ] && previous_page_mng $1)<span>${caption}</span>"
   }   

    find_relative_path $1

    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" 
\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
   <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">
    <head>
      <title>$(report_html page_title_html)</title>
      <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
      <link rel=\"alternate\" type=\"application/rss+xml\" title=\"$(report_html page_title_rss)\" href=\"${report_html_uri}/${report_rss_file_index}\" />
      <meta name=\"copyright\" content=\"${synbak_copyright} - ${synbak_author_homepage}\" />
      <meta name=\"author\" content=\"${synbak_author}\" />
      $(js_mng $1)
      $(css_mng $1)
      <link rel=\"shortcut icon\" href=\"${relative_path}favicon.ico\" />
    </head>
    <body>
      <div class='content'>
        $(logo_mng $1)
        <p>
	  <a href='${synbak_homepage}' title='${synbak_package} Home Page'><img src='${relative_path}${report_html_file_image_synbak_logo}' alt='' /></a>
          <span class='description'>${synbak_description}</span>
          <br />
          <span class='copyright'><a href='${synbak_author_homepage}' title='${synbak_author_homepage}'><b>${synbak_copyright}</b></a></span>
        </p>
    "
  } 

  # backup status counter function
  status_cnt(){
    local adir=$1
    local type=$2
    case $type in
	ok)
		read_file ${adir}/${file_cnt_ok} 2>/dev/null
		;;
	errors)
		read_file ${adir}/${file_cnt_errors} 2>/dev/null
		;;
	totals)
		let cnt=$(read_file ${adir}/${file_cnt_ok})+$(read_file ${adir}/${file_cnt_errors}) 2>/dev/null
                echo ${cnt}
                unset cnt
		;;
	cnt_days)
		find ${adir} -name $(basename ${file_status_backup}) | xargs -r cat | grep ^"0" | wc -l | awk '{print $1}' > ${adir}/${file_cnt_ok}     2>/dev/null
		find ${adir} -name $(basename ${file_status_backup}) | xargs -r cat | grep ^"1" | wc -l | awk '{print $1}' > ${adir}/${file_cnt_errors} 2>/dev/null
		;;
	cnt_all)
                cnt_func() {
		  local cnt=0
                  # $1 is a directory
                  # $2 is the dest file name
                  for file in $(find $1 -maxdepth 2 -type f -name $2 | sed -e 's/^.\///' | grep -wv ^"." | grep -v "$1/$2"$ | sort -r)
                    do
		      let cnt=$(read_file $file)+$cnt
		    done
		  echo "${cnt}"
                  unset cnt
                }
                
                cnt_func ${adir} ${file_cnt_ok}     > ${adir}/${file_cnt_ok}     2>/dev/null
                cnt_func ${adir} ${file_cnt_errors} > ${adir}/${file_cnt_errors} 2>/dev/null
		;;
    esac
  }

  # $1 = index description name
  # $2 = directory to indicize
  html_body() {
    make_page_table_list(){
        # don't count the status of backups in the total page, is not useful
        [ "$2" != "total" ] && status_cnt $1 cnt_all

        for dir in $(find $1/ -maxdepth 1 -type d | sed -e 's/^.\///' | grep -wv ^"." | grep -v "$1"/$ | sort -r)
          do
            local rdir=$(basename ${dir})
            local desc=${rdir}
            local oks="$(status_cnt $dir ok)"
            local errors=$(status_cnt $dir errors)
            if [ -z $(basename "${rdir}" | grep "[a-zA-Z]") ] # Don't include directories with alphabetic characters 
              then
            echo "     <tr>
         <td class='center'><a href=\"${rdir}/${report_html_file_index}\"><b>${desc}</b></a></td>
         <td class='right'>$([ "${oks}" = "0" ] && echo "<span>&nbsp;" || echo "<span class='TextOks'>${oks}")</span></td>
         <td class='right'>$([ "${errors}" = "0" ] && echo "<span>&nbsp;" || echo "<span class='TextErrors'>${errors}")</span></td>
         <td class='right'><span class='TextTotals'>$(status_cnt $dir totals)</span></td>
     </tr>"
            fi
          done

    }

   make_page_table_day(){
     # count all backup status on current day
     status_cnt $1 cnt_days
     local row=$(find $1 -maxdepth 1 -type d | sed -e 's/^.\///' | grep -wv ^"." | grep -v "$1"$ | wc -l | awk '{print $1}')

     # print a row for any backups found in the current day
     for dir in $(find $1 -maxdepth 1 -type d | sed -e 's/^.\///' | grep -wv ^"." | grep -v "$1"$ | sort -r)
       do
            local rdir=$(basename ${dir})
            local desc=${rdir}

            if [ "$(read_file ${dir}/$(basename ${file_status_backup}))" = "0" ]
              then
		local col_even="even"
		local col_odd="colodd"
		local col_status="col_status_ok"
                local status_backup=$(report_html ok)
              else
		local col_even="even"
		local col_odd="colodd"
		local col_status="col_status_error"
                local status_backup=$(report_html error)
            fi

            local method_option=$(read_file ${dir}/$(basename ${file_method_option}))

            echo "      <tr>
            <td class='right'><span class='TextRow'>&nbsp;$row&nbsp;</span></td>
            <td class='left'><b>$(read_file ${dir}/$(basename ${file_system}))</b></td>
            <td class='left'>$(read_file ${dir}/$(basename ${file_method}))</td>
            <td class='left'>$([ -n "${method_option}" ] && echo "${method_option}" || echo "&nbsp;")</td>
            <td class='left'>$(read_file ${dir}/$(basename ${file_method_type}))</td>
            <td class='center'>$(show_time_human $(read_file ${dir}/$(basename ${file_time_begin})))</td>
            <td class='center'>$(show_time_human $(read_file ${dir}/$(basename ${file_time_end})))</td>
            <td class='center'>$(show_time_duration_human $(read_file ${dir}/$(basename ${file_time_begin})) $(read_file ${dir}/$(basename ${file_time_end})))</td>
            <td class='right'>$(show_size $(read_file ${dir}/$(basename ${file_size_backup})))</td>
            <td class='right'>$(show_speed $(read_file ${dir}/$(basename ${file_size_backup})) $(read_file ${dir}/$(basename ${file_time_begin})) $(read_file ${dir}/$(basename ${file_time_end})))</td>
            <td class='right'>$(show_size $(read_file ${dir}/$(basename ${file_size_destination})))</td>
            <td class='${col_status} center'><a href=\"${rdir}/${report_html_file_index}\">${status_backup}</a></td>
      </tr>"
            let row=${row}-1
       done
   }

     case $1 in
       total)
	echo "
	<div class='center'>
        <table class='iztable sortable-onload-show-0 rowstyle-rowodd colstyle-colodd no-arrow'>
	<caption>$(table_caption_mng $1)</caption>
        <thead>
		<tr>
		<th class='sortable-numeric'>$(report_html year)</th>
		<th class='sortable-numeric'>$(report_html oks)</th>
		<th class='sortable-numeric'>$(report_html errors)</th>
		<th class='sortable-numeric'>$(report_html totals)</th>
		</tr>
	</thead>
	<tbody>
	$(make_page_table_list $2 $1)
	</tbody>
	</table>
        </div>"
	;;
       year)
	echo "
	<div class='center'>
        <table class='iztable sortable-onload-show-0 rowstyle-rowodd colstyle-colodd no-arrow'>
	<caption>$(table_caption_mng $1)</caption>
	<thead>
		<tr>
		<th class='sortable-numeric'>$(report_html month)</th>
		<th class='sortable-numeric'>$(report_html oks)</th>
		<th class='sortable-numeric'>$(report_html errors)</th>
		<th class='sortable-numeric'>$(report_html totals)</th>
		</tr>
	</thead>
	<tbody>
	$(make_page_table_list $2 $1)
	</tbody>
	</table>
	</div>"
	;;
       month)
	echo "
	<div class='center'>
        <table class='iztable sortable-onload-show-0 rowstyle-rowodd colstyle-colodd no-arrow'>
	<caption>$(table_caption_mng $1)</caption>
	<thead>
		<tr>
		<th class='sortable-numeric'>$(report_html day)</th>
		<th class='sortable-numeric'>$(report_html oks)</th>
		<th class='sortable-numeric'>$(report_html errors)</th>
		<th class='sortable-numeric'>$(report_html totals)</th>
		</tr>
	</thead>
	<tbody>
	$(make_page_table_list $2 $1)
	</tbody>
	</table>
	</div>"
	;;

       day)
	echo "
	<div class='center'>
	<table class='iztable sortable-onload-show-0 rowstyle-rowodd colstyle-colodd no-arrow'>
	<caption>$(table_caption_mng $1)</caption>
	<thead>
		<tr>
		<th class='sortable-numeric'>#</th>
		<th class='sortable-text'>$(report_html system)</th>
		<th class='sortable-text'>$(report_html method)</th>
		<th class='sortable-text'>$(report_html method_option)</th>
		<th class='sortable-text'>$(report_html method_type)</th>
		<th class='sortable-text'>$(report_html time_begin)</th>
		<th class='sortable-text'>$(report_html time_end)</th>
		<th class='sortable-text'>$(report_html time_duration)</th>
		<th class='sortable-sortFileSize'>$(report_html size_backup)</th>
		<th class='sortable-sortFileSize'>$(report_html speed_backup)</th>
		<th class='sortable-sortFileSize'>$(report_html size_destination)</th>
		<th class='sortable-text'>$(report_html status_backup)</th>
		</tr>
	</thead>
	<tbody>
	$(make_page_table_day $2 $1)
	</tbody>
	</table>
	</div>"
	;;
     esac
  }

  html_footer() {
    #$([ "$1" != "total" ] && echo "    <p><b><a href=\"../\">$(report_html previous_page)</a></b></br></p>" || echo "<p>&nbsp;</p>")
    echo "
     <p class='footer'><i>$(report_html last_update_html)</i></p>
     </div>
     </body>
</html>"
  }


  # rss reports functions
  rss_header() {
echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<rss version='2.0'>
<channel>
<title>$(report_html page_title_rss)</title>
<link>${report_html_uri}/${year}/${month}/${day}</link>
<copyright>${synbak_copyright} - ${synbak_author_homepage}</copyright>
<author>${synbak_author}</author>
<pubDate>$(show_time_human $(show_time_unix) rss)</pubDate>
<updated>$(show_time_human $(show_time_unix) rss)</updated>
<generator>${synbak_description} v.${synbak_version}</generator>
<ttl>60</ttl>
<description>$(report_html last_update_rss)</description>
<image>
  <title>${synbak_description}</title>
  <link>${report_html_uri}</link>
  <uri>${report_html_uri}/${report_html_file_image_logo}</uri>
</image>"
  }

  # rss index summay page
  rss_body() {
     local tdir="$1"
     # count all backup status on current day
     status_cnt ${cdir} cnt_days

     # print a row for any backups found in the current day
     for dir in $(find ${tdir} -maxdepth 1 -type d | sed -e 's/^.\///' | grep -wv ^"." | grep -v "${tdir}"$ | sort -r)
       do
            local rdir=$(basename ${dir})
            local desc=${rdir}
            local status_color="#000000"

            if [ $(read_file ${dir}/$(basename ${file_status_backup})) = 0 ]
              then
		local status_color="#00cc00"
                local status_backup="$(report_html ok)"
              else
		local status_color="#ff0000"
                local status_backup="$(report_html error)"
            fi

	echo "<item>
  <title>B:[$(show_time_human $(read_file ${dir}/$(basename ${file_time_begin})))] S:[$(read_file ${dir}/$(basename ${file_system}))] M:[$(read_file ${dir}/$(basename ${file_method}))] R:[${status_backup}]</title>
  <link>${report_html_uri}/${year}/${month}/${day}/${rdir}/${report_html_file_index}</link>
  <author>${report_info_support}</author>
  <description>
&lt;i&gt;$(report_html system)&lt;/i&gt;:[&lt;b&gt;$(read_file ${dir}/$(basename ${file_system}))&lt;/b&gt;]
&lt;i&gt;$(report_html method)&lt;/i&gt;:[&lt;b&gt;$(read_file ${dir}/$(basename ${file_method}))&lt;/b&gt;]
&lt;i&gt;$(report_html method_option)&lt;/i&gt;:[&lt;b&gt;$(read_file ${dir}/$(basename ${file_method_option}))&lt;/b&gt;]
&lt;i&gt;$(report_html method_type)&lt;/i&gt;:[&lt;b&gt;$(read_file ${dir}/$(basename ${file_method_type}))&lt;/b&gt;]
&lt;i&gt;$(report_html time_duration)&lt;/i&gt;:[&lt;b&gt;$(show_time_duration_human $(read_file ${dir}/$(basename ${file_time_begin})) $(read_file ${dir}/$(basename ${file_time_end})))&lt;/b&gt;]
&lt;i&gt;$(report_html size_backup)&lt;/i&gt;:[&lt;b&gt;$(show_size $(read_file ${dir}/$(basename ${file_size_backup})))&lt;/b&gt;]
&lt;i&gt;$(report_html speed_backup)&lt;/i&gt;:[&lt;b&gt;$(show_speed $(read_file ${dir}/$(basename ${file_size_backup})) $(read_file ${dir}/$(basename ${file_time_begin})) $(read_file ${dir}/$(basename ${file_time_end})))&lt;/b&gt;]
&lt;i&gt;$(report_html status_backup)&lt;/i&gt;:[&lt;b&gt;&lt;font color=$status_color&gt;${status_backup}&lt;/font&gt;&lt;/b&gt;]
  </description>
  <pubDate>$(show_time_human $(read_file ${dir}/$(basename ${file_time_begin})) rss)</pubDate>
</item>"
       done
}

  # rss status summary page
  rss_body_status() {
     local tdir="$1"
     # count all backup status on current day
     status_cnt ${cdir} cnt_days

     # set that all is OK by default
     local current_status=0
     local tot_ok=0
     local tot_error=0

     print_description() {
       echo "$(report_html time_begin):[$(show_time_human $(read_file ${dir}/$(basename ${file_time_begin})))] $(report_html time_end):[$(show_time_human $(read_file ${dir}/$(basename ${file_time_end})))] $(report_html system):[$(read_file ${dir}/$(basename ${file_system}))] $(report_html method):[$(read_file ${dir}/$(basename ${file_method}))]"
     }

     # print a row for any backups found in the current day
     for dir in $(find ${tdir} -maxdepth 1 -type d | sed -e 's/^.\///' | grep -wv ^"." | grep -v "${tdir}"$ | sort -n)
       do
            local rdir=$(basename ${dir})
            local desc=${rdir}

            # if status=0 (OK) then print gree color, else red color
            if [ $(read_file ${dir}/$(basename ${file_status_backup})) = 0 ]
              then
                local status_backup="$(report_html ok)"
                let tot_ok=$tot_ok+1
                local last_description="$(report_html last_backup): $(print_description)"
              else
		current_status=1
                let tot_error=$tot_error+1
                local status_backup="$(report_html error)"
                local last_description_error="$(report_html last_error): $(print_description)"
            fi
        done

  # count backups
  local tot_backups
  let tot_backups=$tot_ok+$tot_error

  local description="${last_description}"

  # if an error is encountered in any backup then print ERROR message
  [ ${current_status} -ne 0 ] && status_backup="$(report_html error)" &&  description="${last_description_error}"

  # print the report title
  local title="$(report_html overall_state):[${status_backup}] $(report_html totals):[${tot_backups}] $(report_html successful):[${tot_ok}] $(report_html failed):[${tot_error}]"
  # point the link to daily backup page
  local link="${report_html_uri}/${year}/${month}/${day}/"

	echo "<item>
  <title>${title}</title>
  <link>${link}</link>
  <pubDate>$(show_time_human $(read_file ${dir}/$(basename ${file_time_begin})) rss)</pubDate>
  <description>${description}</description>
</item>"
}



  rss_footer() {
echo "</channel>
</rss>"
  }

make_rss_index() {
  rss_header	$1 $2
  rss_body	$2 $1
  rss_footer	$1 $2
}

make_rss_status() {
  rss_header	$1 $2
  rss_body_status	$2 $1
  rss_footer	$1 $2
}



report_make() {
  mkdir -p "${report_html_destination_backup}"

  if [ $? -ne 0 ] 
    then
      #report_html dir_unwritable
      return 1;
    else
      archive_logs "${report_html_destination_backup}"
  fi

  # legacy files cleanups
  [ -e "${report_html_destination}/images/calendar.gif" ]	&& rm -f "${report_html_destination}/images/calendar.gif"
  [ -e "${report_html_destination}/images/back.png" ]		&& rm -f "${report_html_destination}/images/back.png"
  [ -e "${report_html_destination}/images/forward.png" ]	&& rm -f "${report_html_destination}/images/forward.png"

  # copy synbak.css file to synbak html report root 
  cp -a "${sys_dir_report}"/"${report_html_file_css}" "${report_html_destination}"/

  # copy favicon.ico file to synbak html report root 
  cp -a "${sys_dir_report}"/"favicon.ico" "${report_html_destination}"/

  # copy the images directory to synbak html report root
  cp -a "${sys_dir_report}"/"images" "${report_html_destination}"/

  # copy the javascripts directory to synbak html report root
  cp -a "${sys_dir_report}"/"js" "${report_html_destination}"/

  # copy the php calendar system directory to synbak html report root 
  cp -a "${sys_dir_report}"/"calendar" "${report_html_destination}"/

  make_calendar_config > "${report_html_destination}"/"${report_html_file_calendar_config}"

  make_html_index day	"${report_html_destination_day}"	> "${report_html_destination_day}"/"${report_html_file_index}"
  make_html_index month	"${report_html_destination_month}"	> "${report_html_destination_month}"/"${report_html_file_index}"
  make_html_index year	"${report_html_destination_year}"	> "${report_html_destination_year}"/"${report_html_file_index}"
  make_html_index total	"${report_html_destination}"		> "${report_html_destination}"/"${report_html_file_index}"

  make_rss_index  day	"${report_html_destination_day}"	> "${report_html_destination}"/"${report_rss_file_index}"
  make_rss_status day	"${report_html_destination_day}"	> "${report_html_destination}"/"${report_rss_file_status}"
}


make_html_index() {
  html_header	$1 $2
  html_body	$1 $2
  html_footer	$1 $2
}

# rebuild all indexes
rebuild_indexes() {
  for year in $(find "${report_html_destination}"/ -maxdepth 1 -type d | sed -e 's/^.\///' | grep -wv ^"." | grep -v "${report_html_destination}"/$ | sort -r)
   do
    for month in $(find "${year}" -maxdepth 1 -type d | sed -e 's/^.\///' | grep -wv ^"." | grep -v "${year}"$ | sort -r)
     do
      for day in $(find "${month}" -maxdepth 1 -type d | sed -e 's/^.\///' | grep -wv ^"." | grep -v "${month}"$ | sort -r)
       do
        [ -z $(basename "${day}" | grep "[a-zA-Z]") ] && make_html_index day "${day}" > "${day}"/"${report_html_file_index}"
       done
      [ -z $(basename "${month}" | grep "[a-zA-Z]") ] && make_html_index month "${month}" > "${month}"/"${report_html_file_index}"
     done
    [ -z $(basename "${year}" | grep "[a-zA-Z]") ] && make_html_index year "${year}" > "${year}"/"${report_html_file_index}"
   done

  make_html_index total "${report_html_destination}"		> "${report_html_destination}"/"${report_html_file_index}"

  # make rss report also
  make_rss_index  day   "${report_html_destination_day}"        > "${report_html_destination}"/"${report_rss_file_index}"
}

#echo $@

# parse the report input command and make the report
case $2 in
	ria) # comands specific to this method
		report_html rebuild_indexes
                save_time_begin_step
                report_text report_step
		rebuild_indexes > "${file_log_errors}" 2>&1
                save_time_end_step
                check_status_step
		;;
	backup)
		if [[ "${report_html}" = "yes" && "$1" = "html" ]]
		  then
		    #echo "Normal Reports run"
                    save_time_begin_step
                    report_text report_step
		    report_make > "${file_log_errors}" 2>&1
                    save_time_end_step
                    check_status_step
		  else
		    check_status_backup 2>&1 > /dev/null
		    if [[ $? -eq 1 && "${report_html_on_errors}" = "yes" && "$1" = "html" ]]
		      then
		        # echo "forcing html report errors only"
                        save_time_begin_step
                        report_text report_step
	                report_make > "${file_log_errors}" 2>&1
                        save_time_end_step
                        check_status_step
		    fi
		fi
		;;
	*)
		local extra_option_right="ria"
		local current_option="$2"
		[ -z "$2" ] && report_text extra_option_required && exit 1
		[ "$2" != "ria" ] && report_text extra_option_wrong && exit 1
		;;
esac


