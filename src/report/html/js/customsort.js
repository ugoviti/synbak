/*
    sortDutchCurrencyValues
    -----------------------

    This function sorts alphaNumeric values e.g. 1, e, 1a, 23c, 54z
    
    Notice how the prepareData function actually returns an Array i.e. you are not limited
    in the type of data you return to the tableSort script.
*/
function sortAlphaNumericPrepareData(tdNode, innerText){
        var aa = innerText.toLowerCase().replace(" ", "");
        var reg = /((\-|\+)?(\s+)?[0-9]+\.([0-9]+)?|(\-|\+)?(\s+)?(\.)?[0-9]+)([a-z]+)/;

        if(reg.test(aa)) {
                var aaP = aa.match(reg);
                return [aaP[1], aaP[8]];
        };

        // Return an array
        return isNaN(aa) ? ["",aa] : [aa,""];
}

function sortAlphaNumeric(a, b){
        // Get the previously prepared array
        var aa = a[fdTableSort.pos];
        var bb = b[fdTableSort.pos];

        // If they are equal then return 0
        if(aa[0] == bb[0] && aa[1] == bb[1]) { return 0; };

        // Check numeric parts if not equal
        if(aa[0] != bb[0]) {
                if(aa[0] != "" && bb[0] != "") { return aa[0] - bb[0]; };
                if(aa[0] == "" && bb[0] != "") { return -1; };
                return 1;
        };
        
        // Check alpha parts if numeric parts equal
        if(aa[1] == bb[1]) return 0;
        if(aa[1] < bb[1])  return -1;
        return 1;
}

/*
    sortDutchCurrencyValues
    -----------------------

    This function sorts Dutch currency values (of the type 100.000,00)
    The function is "safe" i.e. non-currency data (like the word "Unknown") can be passed in and is sorted properly.
*/
function sortDutchCurrencyValues(a, b) {
        return fdTableSort.sortNumeric(a, b);
}
function sortDutchCurrencyValuesPrepareData(tdNode, innerText) {
        innerText = parseInt(innerText.replace(/[^0-9\.,]+/g, "").replace(/\./g,"").replace(",","."));
        return isNaN(innerText) ? "" : innerText;
}

/*
   sortByTwelveHourTimestamp
   -------------------------

   This custom sort function sorts 12 hour timestamps of an hour/minute nature.
   The hour/minute dividor can be a full-stop or a colon and it correctly calculates that 12.30am is before 1am etc
   The am/pm part can be written in lower or uppercase and can optionally contain full-stops e.g.

   am, a.m, a.m., AM, A.M etc

   Additionally, the values "12 midnight" and "12 noon" are also handled correctly.

   The question remains... does "12p.m." mean "midnight" or "12 noon"? I've decided here that it's 12 noon.

   The function is "safe" i.e. non-timestamp data (like the word "Unknown") can be passed in and is sorted properly.
*/
function sortByTwelveHourTimestamp(a, b) {
        return fdTableSort.sortNumeric(a, b);
}
function sortByTwelveHourTimestampPrepareData(tdNode, innerText) {
        tmp = innerText
        innerText = innerText.replace(":",".");

        // Check for the special cases of "12 noon" or "12 midnight"
        if(innerText.search(/12([\s]*)?noon/i) != -1) return "12.00";
        if(innerText.search(/12([\s]*)?midnight/i) != -1) return "24.00";

        var regExpPM = /^([0-9]{1,2}).([0-9]{2})([\s]*)?(p[\.]?m)/i;
        var regExpAM = /^([0-9]{1,2}).([0-9]{2})([\s]*)?(a[\.]?m)/i;

        if(innerText.search(regExpPM) != -1) {
                var bits = innerText.match(regExpPM);
                if(parseInt(bits[1]) < 12) { bits[1] = parseInt(bits[1]) + 12; }
        } else if(innerText.search(regExpAM) != -1) {
                var bits = innerText.match(regExpAM);
                if(bits[1] == "12") { bits[1] = "00"; }
        } else return "";

        if(bits[2].length < 2) { bits[2] = "0" + String(bits[2]); }

        innerText = bits[1] + "." + String(bits[2]);

        return isNaN(innerText) ? "" : innerText;
}
/*
   sortEnglishLonghandDateFormat
   -----------------------------

   This custom sort function sorts dates of the format:

   "12th April, 2006" or "12 April 2006" or "12-4-2006" or "12 April" or "12 4" or "12 Apr 2006" etc

   The function expects dates to be in the format day/month/year. Should no year be stipulated,
   the function treats the year as being the current year.

   The function is "safe" i.e. non-date data (like the word "Unknown") can be passed in and is sorted properly.
*/
function sortEnglishLonghandDateFormat(a, b) {
        // Get the innerText of the TD nodes
        var aa = a[fdTableSort.pos];
        var bb = b[fdTableSort.pos];

        return aa - bb;
}

function sortEnglishLonghandDateFormatPrepareData(tdNode, innerText) {
        var months = ['january','february','march','april','may','june','july','august','september','october','november','december'];

        var aa = innerText.toLowerCase();

        // Replace the longhand months with an integer equivalent
        for(var i = 0; i < 12; i++) {
                aa = aa.replace(months[i], i+1).replace(months[i].substring(0,3), i+1);
        }

        // If there are still alpha characters then return -1
        if(aa.search(/a-z/) != -1) return -1;

        // Replace multiple spaces and anything that is not numeric
        aa = aa.replace(/\s+/g, " ").replace(/[^\d\s]/g, "");

        // If were left with nothing then return -1
        if(aa.replace(" ", "") == "") return -1;

        // Split on the (now) single spaces
        aa = aa.split(" ");

        // If something has gone terribly wrong then return -1
        if(aa.length < 2) return -1;

        // If no year stipulated, then add this year as default
        if(aa.length == 2) {
                aa[2] = String(new Date().getFullYear());
        }

        // Equalise the day and month
        if(aa[0].length < 2) aa[0] = "0" + String(aa[0]);
        if(aa[1].length < 2) aa[1] = "0" + String(aa[1]);

        // Deal with Y2K issues
        if(aa[2].length != 4) {
                aa[2] = (parseInt(aa[2]) < 50) ? '20' + aa[2] : '19' + aa[2];
        }

        // YMD (can be used as integer during comparison)
        return aa[2] + String(aa[1]) + aa[0];
}
/*
   sortIPAddress
   -------------

   This custom sort function correctly sorts IP addresses i.e. it checks all of the address parts and not just the first.

   The function is "safe" i.e. non-IP address data (like the word "Unknown") can be passed in and is sorted properly.
*/
function sortIPAddress(a,b) {
        var aa = a[fdTableSort.pos];
        var bb = b[fdTableSort.pos];

        return aa - bb;
}
function sortIPAddressPrepareData(tdNode, innerText) {
        // Get the innerText of the TR nodes
        var aa = innerText;

        // Remove spaces
        aa = aa.replace(" ","");

        // If not an IP address then return -1
        if(aa.search(/^([0-9]{1,3}).([0-9]{1,3}).([0-9]{1,3}).([0-9]{1,3})$/) == -1) return -1;

        // Split on the "."
        aa = aa.split(".");

        // If we don't have 4 parts then return -1
        if(aa.length != 4) return -1;

        var retVal = "";

        // Make all the parts an equal length and create a master integer
        for(var i = 0; i < 4; i++) {
                retVal += (String(aa[i]).length < 3) ? "0000".substr(0, 3 - String(aa[i]).length) + String(aa[i]) : aa[i];
        }

        return retVal;
}
/*
   sortScientificNotation
   ----------------------

   This custom sort function sorts numbers stipulated in scientific notation

   The function is "safe" i.e. data like the word "Unknown" can be passed in and is sorted properly.

   N.B. The only way I can think to really sort scientific notation is to convert
        it to a floating point number and then perform the sort on that. If you can think of
        an easier/better way then please let me know.
*/
function sortScientificNotation(a, b) {
        return fdTableSort.sortNumeric(a, b);
}
function sortScientificNotationPrepareData(tdNode, innerText) {
        var aa = innerText;

        var floatRegExp = /((\-|\+)?(\s+)?[0-9]+\.([0-9]+)?|(\-|\+)?(\s+)?(\.)?[0-9]+)/g;

        aa = aa.match(floatRegExp);

        if(!aa || aa.length != 2) return "";

        var f1 = parseFloat(aa[0].replace(" ",""))*Math.pow(10,parseFloat(aa[1].replace(" ","")));
        return isNaN(f1) ? "" : f1;
}

/*
        sortImage
        ---------

        This is the function called in order to sort the data previously prepared by the function
        "sortImagePrepareData". It does a basic case sensitive comparison on the data.
*/
function sortImage(a, b) { return fdTableSort.sortText(a, b); }

/*
        This is the function used to prepare i.e. parse data, to be used during the sort
        of the images within the last table.

        In this case, we are checking to see if the TD node has any child nodes that are
        images and, if an image exists, return it's "src" attribute.
        If no image exists, then we return an empty string.

        The "prepareData" functions are passed the actual TD node and also the TD node inner text
        which means you are free to check for child nodes etc and are not just limited to
        sorting on the TD node's inner text.

        The prepareData functions are not required (only your bespoke sort function is required)
        and only called by the script should they exist.
*/
function sortImagePrepareData(td, innerText) {
        var img = td.getElementsByTagName('img');
        return img.length ? img[0].src: "";
}

/*
        sortFileSize
        ------------

        1 Byte = 8 Bit
        1 Kilobyte = 1024 Bytes
        1 Megabyte = 1048576 Bytes
        1 Gigabyte = 1073741824 Bytes
*/
function sortFileSize(a, b) { return fdTableSort.sortNumeric(a, b); }

function sortFileSizePrepareData(td, innerText) {
        var regExp = /(kb|mb|gb)/i;

        var type = innerText.search(regExp) != -1 ? innerText.match(regExp)[0] : "";

        switch (type.toLowerCase()) {
                case "kb" :
                        mult = 1024;
                        break;
                case "mb" :
                        mult = 1048576;
                        break;
                case "gb" :
                        mult = 1073741824;
                        break;
                default :
                        mult = 1;
        }

        innerText = parseFloat(innerText.replace(/[^0-9\.\-]/g,''));

        return isNaN(innerText) ? "" : innerText * mult;
}
