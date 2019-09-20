#!/bin/bash

s2edir='/Users/rpr061/Documents/localtestarea/SOCATv2019Pangaea/splitted_imp/'
#DATAMANAGEMENT/Data_products/SOCAT/V6/SOCATv6_local/Archive_SOCATv6/merged_datasets/splitted_imp/'
#s2edir='/Users/rpr061/Documents/DATAMANAGEMENT/Data_products/SOCAT/V6/SOCATv6_local/Archive_SOCATv6/merged_datasets/splitted_imp/'
#s2edir='/Users/rpr061/Documents/DATAMANAGEMENT/Data_products/SOCAT/V6/SOCATv6_local/Archive_SOCATv6/test/Data_per_Basis/splitted_imp/'
#dir='/Users/rpr061/Dropbox/SOCATv6/Archive_Pangaea/Split2Events/test/'
sumdir=''
#summaryfile='
cd $s2edir
cd ..

infofile=Overview_New_Updated_SOCATv2019.tsv

# Find column index of needed variables
iStaffID=$(sed -n $'1s/\t/\\\n/gp' ${infofile} | grep -nx 'Pangaea_Staff_ID(s)' | cut -d: -f1)
iInstID=$(sed -n $'1s/\t/\\\n/gp' ${infofile} | grep -nx 'Pangaea_Staff_1_Institution_ID' | cut -d: -f1)
iTitle=$(sed -n $'1s/\t/\\\n/gp' ${infofile} | grep -nx 'Dataset_title' | cut -d: -f1)
iComment=$(sed -n $'1s/\t/\\\n/gp' ${infofile} | grep -nx 'Dataset_comment' | cut -d: -f1)
iOtherVID=$(sed -n $'1s/\t/\\\n/gp' ${infofile} | grep -nx 'Other_version_ID' | cut -d: -f1)
iFileName=$(sed -n $'1s/\t/\\\n/gp' ${infofile} | grep -nx 'Export_filename' | cut -d: -f1)
iSourceDataID=$(sed -n $'1s/\t/\\\n/gp' ${infofile} | grep -nx 'Source_dataset_ID' | cut -d: -f1)

counter=0
#filename=${s2edir}${event}.txt
for filename in ${s2edir}*.txt; do

      counter=$(( $counter + 1 ))

#      if [ $counter -eq 2 ]; then
#            exit "Check it out. Counter= $counter}"
#      fi

## ONLY NEEDED FOR MAC. CHANGE THE ^M TO \r
if [ "$(uname)" == "Darwin" ]; then
vi ${filename} -c ':%s//\r/g' -c ':wq'
fi

filenameext=${filename##*/}
event=${filenameext%%.*}

sumlinenumber=$(grep -n $event ${infofile} | cut -d: -f1)
sumline=$(grep $event ${infofile})

# Temporary fix for the event
ievent=$(sed -n $'1s/\t/\\\n/gp' ${infofile} | grep -nx 'Pangaea_Event' | cut -d: -f1)
eventname=$(grep $event ${infofile} | awk -v col=$ievent 'BEGIN{FS=OFS="\t"} {print $col}' | sed 's/;/,/g')
sed -i '.bak' "s/\"EventLabel\": \".*\",/\"EventLabel\": \"${eventname}\",/g" $filename


# Staff ID
sumStaffID=$(grep $event ${infofile} | awk -v col=$iStaffID 'BEGIN{FS=OFS="\t"} {print $col}' | sed 's/;/,/g')
s2eStaffID=$(grep 'AuthorIDs' $filename | cut -d"[" -f2 | cut -d"]" -f1 | sed 's/ //g')
if [ "${sumStaffID}" != "${s2eStaffID}" ]; then 
      echo "not the same Authors. $event"; 
      sed -i '.bak' 's/\"AuthorIDs\": \[ [0-9,]* \],/\"AuthorIDs\": \[ '${sumStaffID}' \],/g' $filename
fi

# Source (PI1 Institution)
sumInstID=$(grep $event ${infofile} | awk -v col=$iInstID 'BEGIN{FS=OFS="\t"} {print $col}')
s2eInstID=$(grep 'SourceID' $filename | cut -d: -f2 | sed 's/[ ,]//g')
if [ "${sumInstID}" != "${s2eInstID}" ]; then 
      echo "not the same Source. $event"; 
      sed -i '.bak' 's/\"SourceID\": [0-9].*,/\"SourceID\": '${sumInstID}',/g' $filename
fi

# Dataset Title
sumTitle=$(grep $event ${infofile} | awk -v col=$iTitle 'BEGIN{FS=OFS="\t"} {print $col}')
s2eTitle=$(grep 'Title' $filename | cut -d: -f2 | sed 's/^ \"//g' |sed 's/[,"]//g')
if [ "${sumTitle}" != "${s2eTitle}" ]; then 
      echo "not the same Title. $event"; 
      sed -i '.bak' "s/\"Title\": \".*\",/\"Title\": \"${sumTitle}\",/g" $filename
fi

# Dataset Comment
sumComment=$(grep $event ${infofile} | awk -v col=$iComment 'BEGIN{FS=OFS="\t"} {print $col}')
s2eComment=$(grep 'DataSetComment' $filename | cut -d: -f2 | sed 's/^ \"//g' |sed 's/[,"]//g')
if [ "${sumComment}" != "${s2eComment}" ]; then 
      echo "not the same Comment. $event"; 
      sed -i '.bak' "s/\"DataSetComment\": \".*\",/\"DataSetComment\": \"${sumComment}\",/g" $filename
fi

# Other version ID (bundle; RelationTypeID=12)
sumOtherVID=$(grep $event ${infofile} | awk -v col=$iOtherVID 'BEGIN{FS=OFS="\t"} {print $col}')
s2eOtherVID=$(grep '"RelationTypeID": 12' $filename | cut -d: -f2 | sed 's/^ //g' | sed 's/,.*//g')
if [ "${sumOtherVID}" != "${s2eOtherVID}" ]; then 
      echo "not the same Other Version. $event"; 
      sed -i '.bak' "s/\"ID\": [0-9].*, \"RelationTypeID\": 13/\"ID\": ${sumOtherVID}, \"RelationTypeID\": 13/g" $filename
fi

# Source Data Set if available
sumSourceDataID=$(grep $event ${infofile} | awk -v col=$iSourceDataID 'BEGIN{FS=OFS="\t"} {print $col}')
if [ ! -z "${sumSourceDataID}" ]; then
      echo "Add Source Data ID. $event"
      sed -i '.bak' "s/RelationTypeID\": 13 } \],/RelationTypeID\": 13 \},\\
    \{ \"ID\": ${sumSourceDataID}, \"RelationTypeID\": 16 \} \],/g" $filename
fi

# Export file name
sumFileName=$(grep $event ${infofile} | awk -v col=$iFileName 'BEGIN{FS=OFS="\t"} {print $col}')
s2eFileName=$(grep 'ExportFilename' $filename | cut -d: -f2 | sed 's/^ \"//g' |sed 's/[,"]//g')
if [ "${sumFileName}" != "${s2eFileName}" ]; then 
      echo "not the same Filename. $event"; 
      sed -i '.bak' "s/\"ExportFilename\": \".*\",/\"ExportFilename\": \"${sumFileName}\",/g" $filename
fi

# Variables author
Staff1=$(echo $sumStaffID | cut -d, -f1)
sed -i '.bak' "s/\"ID\": 716, \"PI_ID\": [0-9].*, \"MethodID\"/\"ID\": 716, \"PI_ID\": ${Staff1}, \"MethodID\"/g" $filename
sed -i '.bak' "s/\"ID\": 717, \"PI_ID\": [0-9].*, \"MethodID\"/\"ID\": 717, \"PI_ID\": ${Staff1}, \"MethodID\"/g" $filename
sed -i '.bak' "s/\"ID\": 48924, \"PI_ID\": [0-9].*, \"MethodID\"/\"ID\": 48924, \"PI_ID\": ${Staff1}, \"MethodID\"/g" $filename
sed -i '.bak' "s/\"ID\": 2224, \"PI_ID\": [0-9].*, \"MethodID\"/\"ID\": 2224, \"PI_ID\": ${Staff1}, \"MethodID\"/g" $filename
sed -i '.bak' "s/\"ID\": 48925, \"PI_ID\": [0-9].*, \"MethodID\"/\"ID\": 48925, \"PI_ID\": ${Staff1}, \"MethodID\"/g" $filename


# 2 fCO2: fix methods/author. If only one present, it's fCO2_rec (Are Olsen, method !=43)
# Other version ID (bundle; RelationTypeID=12)
linefirst=$(grep -m 1 -n '"ID": 49312, "PI_ID"' $filename | cut -d: -f1)
timesfCO2=$(grep -o '"ID": 49312, "PI_ID"' $filename | wc -l | sed 's/ //g')

if [ ${timesfCO2} -eq 2 ]; then
      linesecond=$(( $linefirst + 1 ))
      sed -i '.bak' "${linefirst}s/\"PI_ID\": [0-9].*, \"MethodID\"/\"PI_ID\": ${Staff1}, \"MethodID\"/g" $filename
      sed -i '.bak' "${linesecond}s/\"PI_ID\": [0-9].*, \"MethodID\": 43, \"Format\"/\"PI_ID\": 29177, \"MethodID\": 7296, \"Comment\": \"fCO2rec\", \"Format\"/g" $filename

elif [ ${timesfCO2} -eq 1 ]; then
      sed -i '.bak' "${linefirst}s/\"PI_ID\": [0-9].*, \"MethodID\": 43, \"Format\"/\"PI_ID\": 29177, \"MethodID\": 7296, \"Comment\": \"fCO2rec\", \"Format\"/g" $filename

fi

done

#rm ${s2edir}*.bak

# Originally the titles had dot at the end; remove
for filesub in ${s2edir}*.txt; do 
      linenum=$(grep -n "\"Title\"" ${filesub} | cut -d: -f1) 
      sed -i '.bak' "${linenum}s/\.\",/\",/g" ${filesub}
done

