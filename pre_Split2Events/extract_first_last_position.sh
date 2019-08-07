#!/bin/bash

# ANADIR CALCULO DE LONGITUD DE 360 A +-180!!!


SOCATv=6
# Root directory of SOCAT files
wd=/Users/rpr061/Documents/DATAMANAGEMENT/Pangaea/Archive_SOCATv6/SOCATv6Only_SOCATBundles

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
filedirlist=( $(find $wd -name "*.tsv" ! -path "*.zip") )

# Create output file
printf "Campaign\tLatitudeEvent\tLongitudeEvent\tLatitudeEvent2\tLongitudeEvent2\n" >> SOCATv${SOCATv}_InpEvents_FirstLastPosition.txt


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

#echo $latcol $loncol

# Extract 1st line. (awk's use of $ is different for shell; need to specify the variable IN awk)
sed $((${headerline} +1))'q;d' $filedir > firstline
firstlat=$(awk -v awklatcol=$latcol '{print $awklatcol}' firstline) || { echo 'awk failed ' $expocode ; exit 1; }
firstlon=$(awk -v awkloncol=$loncol '{print $awkloncol}' firstline)

# Extract last line
tail -n 1 $filedir > lastline
lastlat=$(awk -v awklatcol=$latcol '{print $awklatcol}' lastline)
lastlon=$(awk -v awkloncol=$loncol '{print $awkloncol}' lastline)


printf "$expocode\t$firstlat\t$firstlon\t$lastlat\t$lastlon\n" >> SOCATv${SOCATv}_InpEvents_FirstLastPosition.txt

done

rm header firstline lastline
