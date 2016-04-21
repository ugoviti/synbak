<?php

# Copyright (C) 2006 Simple Reliable Networks
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#

## Set configuration variables

require_once("config.inc.php");

// used variables
$yearID  = 0;
$monthID = 0;
$dayID   = 0;
$cal     = 0;
$myurl   = 0;

#####
## No need to change anything below this line

//Let's grab the proper working directory relative to the url.
$rel_url = join(array_slice(split( "/" ,dirname($_SERVER['PHP_SELF'])),0,-1),"/");

$prog_dir = getcwd();  // get the current directory
chdir(".."); //back it up one
$base_dir = getcwd(); // this is the base absolute directory 

require_once("activecalendar.php");  // include the active calendar class


## FUNCTIONS ##

//This function attempts to get the current language setting from the browser.
//Note it will only use the FIRST language it can identify in the list of languages
//Enabled in the browser.
function getBrowserLang(){
  $br_lang = strtolower($_SERVER["HTTP_ACCEPT_LANGUAGE"]);

  $br_lang = explode(",",$br_lang);
  
  //We're gonna assume that the primary language set is the one to display 
  $result = $br_lang[0];

return $result;
}


//Set the language variables - days and months
function setLang($lang){
global $cal;

$months_en = array("January","February","March","April","May","June","July","August","September","October","November","December");
$days_en = array("Sun","Mon","Tue","Wed","Thu","Fri","Sat");

$months_it = array("Gennaio","Febbraio","Marzo","Aprile","Maggio","Giugno","Luglio","Agosto","Settembre","Ottobre","Novembre","Dicembre");
$days_it = array("Dom","Lun","Mar","Mer","Gio","Ven","Sab");

$months_de = array("Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember");
$days_de = array("Son","Mon","Die","Mit","Don","Fre","Sam");

$months_fr = array("janvier","Février","Mars","Avril","Mai","Juin","Juilletl","Août","Septembre","Octobre","Novembre","Décembre");
$days_fr = array("Dim","Lun","Mar","Mer","Jeu","Ven","Sam");

$months_es = array("Enero","Febrero","Marzo","Abril","Mayo","Junio","Juli","Agosto","Septiembre","Octubre","Noviembre","Deciembre");
$days_es = array("Dom","Lun","Mar","Mié","Jue","Vie","Sab");


//Now set the language array to use
switch($lang) {
	case "en-us" 	: $cal->setMonthNames($months_en);
			  $cal->setDayNames($days_en);
			  break;
	case "en"	: $cal->setMonthNames($months_en);
			  $cal->setDayNames($days_en);
			  break;
	case "it"	: $cal->setMonthNames($months_it);
			  $cal->setDayNames($days_it);
			  break;
	case "de"	: $cal->setMonthNames($months_de);
			  $cal->setDayNames($days_de);
			  break;
	case "fr"	: $cal->setMonthNames($months_fr);
			  $cal->setDayNames($days_fr);
			  break;
	case "es"	: $cal->setMonthNames($months_es);
			  $cal->setDayNames($days_es);
			  break;

	default		: $cal->setMonthNames($months_en);
			  $cal->setDayNames($days_en);
}

}


// Get the count stored in a file (usually cnt.err or cnt.ok)
// Takes a full path and filename as the argument
function getCnt($file) {
  $result = 0;

  $handle = fopen($file, 'r');
 
  while (!feof($handle)) {
       $result .= fgets($handle, 4096);
   }
 
  fclose($handle);

  // Convert value to an integer
  $result = intval($result);

return $result;
}

// Get the status of the logs for a given directory
function getLogStatus($dir){

	// Look at the cnt.err file to see if there are any errors in any logs in the directory
	// Set the return value to the appropriate ccs class if there's an error or ok
	if(file_exists("$dir/cnt.err")){	
		$cnt = getCnt("$dir/cnt.err");

		if($cnt > 0){
			$result = "err_log";
		} else {
			$result = "ok_log";
		}
	} else {
		$result = "ok_log";
	}

return $result;
}

// Calculate all the days that have backups logged for the given month
function getLogDays($yearID,$monthID){
	global $base_dir,$rel_url,$cal;
	
	$result = array();

	$month_dir = $base_dir."/".$yearID."/".$monthID;

	if(file_exists($month_dir)){
		chdir($month_dir);
		$cur_dir = opendir(".");
		 while($day_dir = readdir($cur_dir)){
                        if (is_numeric($day_dir)) {

				$day_url = $rel_url."/".$yearID."/".$monthID."/".$day_dir;
		
		
				// Check the log status for the current day (error_log or ok_log)	
				$status = getLogStatus($month_dir."/".$day_dir);
			
				// Set the calendar event
                               	$cal->setEvent($yearID,$monthID,$day_dir,$status,"$day_url/index.html");
 
			}
		}

	}

return $result;
}

// Get all the months that have log events for the given year
function getLogMonths($yearID){
  	global $base_dir;
  
	$year_dir = $base_dir ."/".$yearID;
	
	$event_months = array();
	
	if(file_exists($year_dir)){
		chdir($year_dir);
		
		$cur_dir = opendir(".");
		while($month_dir = readdir($cur_dir)){
			if (is_numeric($month_dir)) {
				$event_months[$month_dir] = getLogDays($yearID,$month_dir);	
			}	
		}	
		
	}
}

## MAIN ##

extract($_GET); // get the new values (if any) of $yearID,$monthID,$dayID

$cal = new activeCalendar($yearID,$monthID,$dayID); // Create the calendar object

// Set the calendar language by the browser language
setLang(getBrowserLang());

$cal->startOnSun=1; // Start the week on Sunday

$thisYear=$cal->actyear; // get the current year


// Enable the year navigation
$previous="<img src=\"" . $report_html_file_image_previous ."\" border=\"0\" alt=\"&lt;&lt;\" onmouseover=\"this.style.background='red';\" onmouseout=\"this.style.background=''\" />"; // use png arrow back
$next="<img src=\"" . $report_html_file_image_next . "\" border=\"0\" alt=\"&gt;&gt;\" onmouseover=\"this.style.background='red';\" onmouseout=\"this.style.background=''\" />"; // use png arrow forward
$cal->enableYearNav($myurl,$previous,$next); 
$cal->enableYearNav($myurl,$previous,$next);

// Set calendar events for every day in the year that has one or more log files
getLogMonths($thisYear);

## HTML ##
?>
<?php print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"; ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
   <html>
    <head>
      <title><?php echo $page_title_html; ?></title>
      <link rel='stylesheet' type='text/css' href='<?php echo $report_html_file_css; ?>' />
      <link rel='stylesheet' type='text/css' href='calendar.css' />
      <link rel='alternate' type='application/rss+xml' title='<?php echo $page_title_rss; ?>' href='<?php echo  $report_rss_file_index; ?>'>
    </head>
    <body>
      <div align=center>
        <a href='<?php echo $report_html_logo_link; ?>'><img src='<?php echo $report_html_logo_image; ?>' title='<?php echo $report_html_logo_link; ?>'/></a>
        <p>
          <a href='<?php echo $synbak_homepage; ?>' title='<?php echo $synbak_package; ?> Home Page' target='_blank'><img src='<?php echo $report_html_logo_image_synbak; ?>' /></a>
          <font size=3><b><?php echo $synbak_description; ?></b></font>
          <br>
          <font size=1><a href='<?php echo $synbak_author_homepage; ?>' target='_blank' title='<?php echo $synbak_author_homepage; ?>'><b><?php echo $synbak_copyright; ?></b></a></font>
        </p>
        <p><a href='../'><img border=0 src='<?php echo $report_html_file_image_detail; ?>' title='<?php echo $txt_detailed_view; ?>' onmouseover="this.style.background='red';" onmouseout="this.style.background=''" align='absmiddle'></a></p>

<?php print $cal->showYear(); ?>
<p><font size=1><i><?php echo $last_update; ?></i></font></p>
</div>
</body>
</html>

