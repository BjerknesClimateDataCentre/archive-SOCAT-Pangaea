#!/bin/bash


dirroot='/Users/rpr061/Downloads/Karl'
dirdata='/Users/rpr061/Downloads/Karl/SOCATv6All_SocatEnhancedData_wDOIs'
dirmetadata='/Users/rpr061/Downloads/Karl/SOCATv6All_MetadataDocs'
dirNU='/Users/rpr061/Downloads/Karl/SOCATv6NU_bundles'
dirAll='/Users/rpr061/Downloads/Karl/SOCATv6All_bundles'

whichtype=All

# -----

cd $dirroot


# Choices for NU or All datasets
if [ "$whichtype" = "NU" ]; then
dirbundle=${dirNU}
listexpocodes=( $( cat "${dirroot}/expocodes.txt") )

elif [ "$whichtype" = "All" ]; then
dirbundle=${dirAll}
count=0
for expofolder in $(find ${dirmetadata} -type d -maxdepth 2 -mindepth 2); do
listexpocodes[$count]=${expofolder##*/}
count=$(( ${count} + 1 ))
done

else
echo "What do you want me to do?"

fi

# Loop through expocodes

echo how many expocodes: ${#listexpocodes[@]}

for expocode in ${listexpocodes[@]}; do

echo expocode: $expocode

# Make sure the dirbundle folder does not already exist; if it does, ask to delete.
# Otherwise, it rewrites with several _bundle attached and weird things
# For now, this script can only run all the way through, not stop and restart
if [ ! -d ${dirbundle} ]; then
mkdir ${dirbundle}

else
read -p "${dirbundle} exists; do you want to delete it?" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
rm -R ${dirbundle}
else
exit
fi

fi

metafolder=$(find $dirmetadata -type d -name "*${expocode}*")
cp -R $metafolder $dirbundle
newmetafolder=$(find $dirbundle -type d -name "*${expocode}*")
echo metafolder: $metafolder
echo new metafolder: $newmetafolder

datafile=$(find $dirdata -type f -name "*${expocode}*")
echo dirdata: $dirdata
cp $datafile $newmetafolder

mv $newmetafolder ${newmetafolder}_bundle
zip -rjX "${newmetafolder}_bundle.zip" "${newmetafolder}_bundle"

basis=${expocode:0:4}
echo basis: ${basis}
if [ ! -d "${dirbundle}/${basis}" ]; then
mkdir "${dirbundle}/${basis}"
fi
mv "${newmetafolder}_bundle.zip" "${dirbundle}/${basis}/"

rm -R "${newmetafolder}_bundle"

done

# Zip main folder
zip -rX "${dirbundle}.zip" ${dirbundle}

