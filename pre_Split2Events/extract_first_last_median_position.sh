#!/bin/bash

# ANADIR CALCULO DE LONGITUD DE 360 A +-180!!!


SOCATv=6
# Root directory of SOCAT files
#wd=/Users/rpr061/Documents/DATAMANAGEMENT/Pangaea/Archive_SOCATv6/SOCATv6Only_SOCATBundles
#wd=/Users/rpr061/Documents/DATAMANAGEMENT/Data_products/SOCAT/V6/SOCATv6_local/Archive_SOCATv6/SOCATv6All_SocatEnhancedData
wd=/Users/rpr061/Documents/DATAMANAGEMENT/Data_products/SOCAT/V6/SOCATv6_local/Archive_SOCATv6/SOCATv6Only_SOCATBundles

# If script has been run before and not clean up (e.g. testing), remove previous files
if [ -f SOCATv${SOCATv}_InpEvents_FirstLastPosition.txt ]; then
      rm filedirlist SOCATv${SOCATv}_InpEvents_FirstLastPosition.txt header firstline lastline
fi



#cd $wd

# Unzip all
# find . -name '*.zip' -exec sh -c 'unzip -o -d "${0%.*}" "$0"' '{}' ';'

# List of all the .tsv files (SOCAT files)
# Text file with the list (may be useful to have as a summary)
find $wd -name "*.tsv" ! -path "*.zip" > filedirlist
#filedirlist=$(find $wd -name "*.tsv" ! -path "*.zip")
filedirlist=()
while IFS= read -r -d $'\0'; do filedirlist+=("$REPLY"); done < <(find $wd -name "*.tsv" ! -path "*.zip" -print0)

# Create output file
printf "Campaign\tLatitudeEvent\tLongitudeEvent\tLatitudeEvent2\tLongitudeEvent2\tNlim\tSlim\tElim\tWlim\tlatmean\tlonmean\n" >> SOCATv${SOCATv}_InpEvents_FirstLastPosition.txt


# Loop through
#for ifile in $(seq 0 1); do
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

#echo $latcol $loncol

# Extract 1st line. (awk's use of $ is different for shell; need to specify the variable IN awk)
sed $((${headerline} +1))'q;d' $filedir > firstline
firstlat=$(awk -v awklatcol=$latcol '{print $awklatcol}' firstline) || { echo 'awk failed ' $expocode ; exit 1; }
firstlon=$(awk -v awkloncol=$loncol '{print $awkloncol}' firstline)

# Extract last line
tail -n 1 $filedir > lastline
lastlat=$(awk -v awklatcol=$latcol '{print $awklatcol}' lastline)
lastlon=$(awk -v awkloncol=$loncol '{print $awkloncol}' lastline)


# Extract dataset to temporary file; then extract lat and lon columns
#THIS LINE IS WRONG!!!
tail -n +$(( $headerline +1 )) $filedir > data.temp
awk -v awklatcol=$latcol '{print $awklatcol}' data.temp > lat.temp
awk -v awkloncol=$loncol '{print $awkloncol}' data.temp > lon.temp

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

# centroid
meanlat=$(awk '{ total += $1 } END { print total/NR }' lat.temp)
meanlon=$(awk '{ total += $1 } END { print total/NR }' lon.temp)
if (( $(echo "$meanlon > 180." | bc -l) )); then
      meanlon=$(echo "${meanlon} - 360." | bc)
fi

# print file
printf "$expocode\t$firstlat\t$firstlon\t$lastlat\t$lastlon\t$maxlat\t$minlat\t$maxlon\t$minlon\t$meanlat\t$meanlon\n" >> SOCATv${SOCATv}_InpEvents_FirstLastPosition.txt

done

rm header firstline lastline data.temp lat.temp lon.temp
