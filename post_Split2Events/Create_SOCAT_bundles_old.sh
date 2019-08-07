#!/bin/bash


dirroot='/Users/rpr061/Downloads/Karl'
dirdata='/Users/rpr061/Downloads/Karl/SOCATv6All_SocatEnhancedData_wDOIs'
dirmetadata='/Users/rpr061/Downloads/Karl/SOCATv6All_MetadataDocs'
dirNU='/Users/rpr061/Downloads/Karl/SOCATv6NU_bundles'
dirAll='/Users/rpr061/Downloads/Karl/SOCATv6All_bundles'

whichtype=All


cd $dirroot
pwd

if [ "$whichtype" = "NU" ]; then

if [ ! -d ${dirNU} ]; then
mkdir ${dirNU}
fi

while read -r expocode; do

echo expocode: $expocode

metafolder=$(find $dirmetadata -type d -name "*${expocode}*")
cp -R $metafolder $dirNU
newmetafolder=$(find $dirNU -type d -name "*${expocode}*")
echo metafolder: $metafolder
echo newmetafolder: $newmetafolder

datafile=$(find $dirdata -type f -name "*${expocode}*")
echo dirdata: $dirdata
cp $datafile $newmetafolder

mv $newmetafolder ${newmetafolder}_bundle
zip -r -X ${newmetafolder}_bundle.zip ${newmetafolder}_bundle

basis=${expocode:0:4}
if [ ! -d "${dirNU}/${basis}" ]; then
mkdir "${dirNU}/${basis}"
fi
mv "${newmetafolder}_bundle.zip" "${dirNU}/${basis}/"

exit

done < expocodes.txt

elif [ "$whichtype" = "All" ]; then

if [ ! -d ${dirAll} ]; then
mkdir ${dirAll}
fi

for metafolder in $(find ${dirmetadata} -type d -maxdepth 2 -mindepth 2); do
expocode=${metafolder##*/}

cp -R $metafolder $dirAll
newmetafolder=$(find $dirAll -type d -name "*${expocode}*")
echo metafolder: $metafolder
echo new metafolder: $newmetafolder

datafile=$(find $dirdata -type f -name "*${expocode}*")
echo dirdata: $dirdata
cp $datafile $newmetafolder

mv $newmetafolder ${newmetafolder}_bundle

zip -r -X ${newmetafolder}_bundle.zip ${newmetafolder}_bundle

basis=${expocode:0:4}
echo basis: ${basis}
if [ ! -d "${dirAll}/${basis}" ]; then
mkdir "${dirAll}/${basis}"
fi
mv "${newmetafolder}_bundle.zip" "${dirAll}/${basis}/"

exit

done

else
      echo "What do you want me to do?"
fi

