#!/bin/bash

# ANADIR CALCULO DE LONGITUD DE 360 A +-180!!!


SOCATv=2019
# Root directory of SOCAT files
wd=/Users/rpr061/Downloads/SOCATv2019All_ABCDE_enhanced_datafiles
cd ${wd}/..

# If script has been run before and not clean up (e.g. testing), remove previous files
if [ -f SOCATv${SOCATv}_InpEvents_FirstLastPosition.txt ]; then
      rm filedirlist SOCATv${SOCATv}_InpEvents_FirstLastPosition.txt header firstline lastline
fi

#cd $wd

# Unzip all. Sometimes it does no need to
# find . -name '*.zip' -exec sh -c 'unzip -o -d "${0%.*}" "$0"' '{}' ';'

# List of all the .tsv files (SOCAT files)
# Text file with the list (may be useful to have as a summary)
find $wd -name "*.tsv" ! -path "*.zip" > filedirlist
#filedirlist=$(find $wd -name "*.tsv" ! -path "*.zip")
filedirlist=()
while IFS= read -r -d $'\0'; do filedirlist+=("$REPLY"); done < <(find $wd -name "*.tsv" ! -path "*.zip" -print0)

# Create output file
printf "Campaign\tLatitudeEvent\tLongitudeEvent\tLatitudeEvent2\tLongitudeEvent2\tNlim\tSlim\tElim\tWlim\tlatmean\tlonmean\tStartDate\tEndDate\n" >> SOCATv${SOCATv}_ALL_ABCDE_InpEvents_FirstLastPosition.txt


# Loop through
for ifile in $(seq 0 $((${#filedirlist[@]} -1))); do
      filedir=${filedirlist[$ifile]}
      filename=${filedir##*/}
      expocode=${filename%%_*}
      echo $(($ifile +1)) $expocode

# Extract header of enhanced file 
# Find line number of header:
headerline=$(grep -n "Expocode\tversion\tSOCAT_DOI" $filedir | awk -F  ":" '{print $1}')
sed ${headerline}'q;d' $filedir > header

# Find which columns have latitude and longitude 
latcol=$(awk -v RS='\t' '/latitude/{print NR; exit}' header)
loncol=$(awk -v RS='\t' '/longitude/{print NR; exit}' header)
yearcol=$(awk -v RS='\t' '/yr/{print NR; exit}' header)
monthcol=$(awk -v RS='\t' '/mon/{print NR; exit}' header)
daycol=$(awk -v RS='\t' '/day/{print NR; exit}' header)
hourcol=$(awk -v RS='\t' '/hh/{print NR; exit}' header)
mincol=$(awk -v RS='\t' '/mm/{print NR; exit}' header)
seccol=$(awk -v RS='\t' '/ss/{print NR; exit}' header)

#echo $latcol $loncol

# Extract 1st line. (awk's use of $ is different for shell; need to specify the variable IN awk)
sed $((${headerline} +1))'q;d' $filedir > firstline
firstlat=$(awk -v awklatcol=$latcol '{print $awklatcol}' firstline) || { echo 'awk failed ' $expocode ; exit 1; }
firstlon=$(awk -v awkloncol=$loncol '{print $awkloncol}' firstline)
firstyear=$(awk -v awkyearcol=$yearcol '{print $awkyearcol}' firstline)
firstmonth=$(awk -v awkmonthcol=$monthcol '{print $awkmonthcol}' firstline)
firstday=$(awk -v awkdaycol=$daycol '{print $awkdaycol}' firstline)
firsthour=$(awk -v awkhourcol=$hourcol '{print $awkhourcol}' firstline)
firstmin=$(awk -v awkmincol=$mincol '{print $awkmincol}' firstline)
firstsec=$(awk -v awkseccol=$seccol '{print $awkseccol}' firstline)

# Extract last line
tail -n 1 $filedir > lastline
lastlat=$(awk -v awklatcol=$latcol '{print $awklatcol}' lastline)
lastlon=$(awk -v awkloncol=$loncol '{print $awkloncol}' lastline)
lastyear=$(awk -v awkyearcol=$yearcol '{print $awkyearcol}' lastline)
lastmonth=$(awk -v awkmonthcol=$monthcol '{print $awkmonthcol}' lastline)
lastday=$(awk -v awkdaycol=$daycol '{print $awkdaycol}' lastline)
lasthour=$(awk -v awkhourcol=$hourcol '{print $awkhourcol}' lastline)
lastmin=$(awk -v awkmincol=$mincol '{print $awkmincol}' lastline)
lastsec=$(awk -v awkseccol=$seccol '{print $awkseccol}' lastline)

# Extract dataset to temporary file; then extract lat and lon columns
#THIS LINE IS WRONG!!!
tail -n +$(( $headerline +1 )) $filedir > data.temp
awk -v awklatcol=$latcol '{print $awklatcol}' data.temp > lat.temp
awk -v awkloncol=$loncol '{print $awkloncol}' data.temp > lon.temp
awk -v awkyearcol=$yearcol '{print $awkyearcol}' data.temp > year.temp
awk -v awkmonthcol=$monthcol '{print $awkmonthcol}' data.temp > month.temp
awk -v awkdaycol=$daycol '{print $awkdaycol}' data.temp > day.temp
awk -v awkhourcol=$hourcol '{print $awkhourcol}' data.temp > hour.temp
awk -v awkmincol=$mincol '{print $awkmincol}' data.temp > min.temp
awk -v awkseccol=$seccol '{print $awkseccol}' data.temp > sec.temp

minlat=$(sort -nk1,1 lat.temp | head -1 | cut -d ' ' -f3)
maxlat=$(sort -nrk1,1 lat.temp | head -1 | cut -d ' ' -f3)

minlon=$(sort -nk1,1 lon.temp | head -1 | cut -d ' ' -f3)
if (( $(echo "$minlon > 180." | bc -l) )); then
#      if [ $minlon -gt 180. ]; then
      minlon=$(echo "${minlon} - 360." | bc)
fi

maxlon=$(sort -nrk1,1 lon.temp | head -1 | cut -d ' ' -f3)
if (( $(echo "$maxlon > 180." | bc -l) )); then
#      if [ $minlon -gt 180. ]; then
      maxlon=$(echo "${maxlon} - 360." | bc)
fi

minyear=$(sort -nk1,1 year.temp | head -1 | cut -d ' ' -f3)
maxyear=$(sort -nrk1,1 year.temp | head -1 | cut -d ' ' -f3)

minmonth=$(sort -nk1,1 month.temp | head -1 | cut -d ' ' -f3)
maxmonth=$(sort -nrk1,1 month.temp | head -1 | cut -d ' ' -f3)

minday=$(sort -nk1,1 day.temp | head -1 | cut -d ' ' -f3)
maxday=$(sort -nrk1,1 day.temp | head -1 | cut -d ' ' -f3)

minhour=$(sort -nk1,1 hour.temp | head -1 | cut -d ' ' -f3)
maxhour=$(sort -nrk1,1 hour.temp | head -1 | cut -d ' ' -f3)

minmin=$(sort -nk1,1 min.temp | head -1 | cut -d ' ' -f3)
maxmin=$(sort -nrk1,1 min.temp | head -1 | cut -d ' ' -f3)

minsec=$(sort -nk1,1 sec.temp | head -1 | cut -d ' ' -f3)
maxsec=$(sort -nrk1,1 sec.temp | head -1 | cut -d ' ' -f3)

mindate=$(echo ${minyear}-${minmonth}-${minday}T${minhour}:${minmin}:${minsec}Z)
maxdate=$(echo ${maxyear}-${maxmonth}-${maxday}T${maxhour}:${maxmin}:${maxsec}Z)

# centroid
meanlat=$(awk '{ total += $1 } END { print total/NR }' lat.temp)
meanlon=$(awk '{ total += $1 } END { print total/NR }' lon.temp)
if (( $(echo "$meanlon > 180." | bc -l) )); then
      meanlon=$(echo "${meanlon} - 360." | bc)
fi

# print file
printf "$expocode\t$firstlat\t$firstlon\t$lastlat\t$lastlon\t$maxlat\t$minlat\t$maxlon\t$minlon\t$meanlat\t$meanlon\t$mindate\t$maxdate\n" >> SOCATv${SOCATv}_ALL_ABCDE_InpEvents_FirstLastPosition.txt

done

rm header firstline lastline data.temp lat.temp lon.temp year.temp month.temp day.temp hour.temp min.temp sec.temp
