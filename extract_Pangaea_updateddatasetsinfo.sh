#!/bin/bash

# List of dataset IDs (part of DOI)
datasets[0]=853471
datasets[1]=853499
datasets[2]=866144
datasets[3]=866146
datasets[4]=879170
datasets[5]=879173
datasets[6]=879174
datasets[7]=878591
datasets[8]=866160
datasets[9]=866162
datasets[10]=866164
datasets[11]=866171
datasets[12]=866172
datasets[13]=878586
datasets[14]=851484
datasets[15]=878920
datasets[16]=851610
datasets[17]=851710
datasets[18]=851711
datasets[19]=852486



printf "DatasetID\tCampaignName\tOptionalLabel\tCampaignID\tEventName\tEventID\tBasisName\tBasisID\n" >> PangaeaUpdatedDatasetsInfo.txt


numbersets1=${#datasets[*]}
numbersets=$(($numbersets1 - 1))
for i in $(seq 0 $numbersets);
do

dsetid=${datasets[$i]}

# Get content of webpage
wget -q https://doi.pangaea.de/10.1594/PANGAEA.${dsetid} 

# Campaign

CampaignName=$(sed -n '/Campaign: /{ s/Campaign: <\/em><span>/%%%%/; s/^.*%%%%//; s/<\/span>.*//; p; }' PANGAEA.${dsetid})

OptionalLabel=$(sed -n "/Campaign: /{ s|${CampaignName}</span>|%%%%|; s/^.*%%%%//; s/<a .*//; p; }" PANGAEA.${dsetid})

#if optional name exists and contains brackets: remove brackets & spaces
# IT DOESNT WOOOORK
#if [ ! -z $OptionalLabel ]; then
#OptionalLabel=$(echo “$OptionalLabel” | sed 's/[ )(]//g')
#fi

CampaignID=$(sed -n '/<meta name="keywords/{ s/@campaign/%%%%/; s/^.*%%%%//; s/;.*//; p; }' PANGAEA.${dsetid})

# Event

# sed seems to complain when trying to substitute a “ (do in the cleanup)
EventName=$(sed -n '/q=event/{ s/q=event%3Alabel%3A/%%%%/; s/^.*%%%%//; s/"><\/a>.*//; p; }' PANGAEA.${dsetid})

EventID=$(sed -n '/<meta name="keywords/{ s/@event/%%%%/; s/^.*%%%%//; s/;.*//; p; }' PANGAEA.${dsetid})

# Basis (if available)

if grep -q @basis PANGAEA.${dsetid} ; then

BasisName=$(sed -n '/Basis: /{ s/Basis: <\/em><span>/%%%%/; s/^.*%%%%//; s/<\/span>.*//; p; }' PANGAEA.${dsetid})

BasisID=$(sed -n '/<meta name="keywords/{ s/@basis/%%%%/; s/^.*%%%%//; s/;.*//; p; }' PANGAEA.${dsetid})

else
BasisID=
BasisName=

fi


# Print values in file
printf "$dsetid\t$CampaignName\t$OptionalLabel\t$CampaignID\t$EventName\t$EventID\t$BasisName\t$BasisID\n" >> PangaeaUpdatedDatasetsInfo.txt

rm PANGAEA.${dsetid}

done


# Cleanup
# Remove parenthesis and spaces (specially from OptionalLabel)
sed -i '.bak' "s/[)]//g" Pangaea_UpdatedDatasetsInfo.txt; rm *.bak
sed -i '.bak' "s/ (//g" PangaeaUpdatedDatasetsInfo.txt; rm *.bak

 
