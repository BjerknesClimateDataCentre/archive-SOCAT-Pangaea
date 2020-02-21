#!/bin/bash

#SOCATv=6
# Root directory of SOCAT files
#wd=/Users/rpr061/Documents/DATAMANAGEMENT/Pangaea/Archive_SOCATv6/SOCATv6Only_SOCATBundles

#cd $wd

# For all folders/basis
#basis=( $(find $wd -type d -maxdepth 1 -not -path "${wd}"))

#for ibasis in $(seq 0 $((${#basis[@]} -1))); do
## List of all the .tsv files (SOCAT files) associated with the basis
## Text file with the list (may be useful to have as a summary)
#currentdir=${basis[$ibasis]}
currentdir=/Users/rpr061/Desktop/26NA/
##currentdir=$(echo $wd${basis[$ibasis]} | sed s#\.//#/#g) 
echo $currentdir

filedirlist=( $(find $currentdir -name "*.tsv" ! -path "*.zip") )
echo $filedirlist
# Loop through files
for ifile in $(seq 0 $((${#filedirlist[@]} -1))); do
      filedir=${filedirlist[$ifile]}
      filename=${filedir##*/}
      expocode=${filename%%_*}
      echo $(($ifile +1)) $expocode


# Extract header of enhanced file 
# Find line number of header:
headerline=$(grep -n "date_and_time" $filedir | awk -F  ":" '{print $1}') || { echo 'headerline failed ' ${basis[$ibasis]} ; exit 1; }
echo $headerline

printf "${filedir}\t${headerline}\n" >> ${currentdir}_files.txt

if [ $ifile -eq 0 ]; then
# Output file
sed ${headerline}'q;d' $filedir > ${currentdir}_dataset.txt
fi

totaldatalines=$(wc -l $filedir | awk '{print $1}') || { echo 'totaldatalines failed ' ${basis[$ibasis]} ; exit 1; }
echo $totaldatalines

datalines=$(( $totaldatalines - $headerline )) || { echo 'datalines failed ' ${basis[$ibasis]} ; exit 1; }
echo $datalines


# Add data # This line takes VERY long
tail -n $datalines >> ${currentdir}_dataset.txt || { echo 'tail failed ' ${basis[$ibasis]} ; exit 1; }

# Add EventLabel

done

mv ${currentdir}_files.txt $wd


#done
