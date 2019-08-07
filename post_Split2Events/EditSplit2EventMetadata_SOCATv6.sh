#!/bin/bash

#dir='/Users/rpr061/Dropbox/SOCATv6/Archive_Pangaea/Split2Events/Input_Datafiles_per_basis/'
#dir='/Users/rpr061/Dropbox/SOCATv6/Archive_Pangaea/Split2Events/test/'
dir='/Users/rpr061/Documents/DATAMANAGEMENT/Data_products/SOCAT/V6/SOCATv6_local/Archive_SOCATv6/merged_datasets/'
basisdir='/Users/rpr061/Documents/DATAMANAGEMENT/Data_products/SOCAT/V6/SOCATv6_local/Archive_SOCATv6/test/'

cd $dir
for metadatafile in ${dir}*_metadata.txt; do


# Find the PI of the basis (CAREFUL WITH WAKATAKA MARU 49WA, DEPENDS ON THE DATASET!!!)
#basis='06AQ'
IFS='/_' read -r -a splitfile <<< "$metadatafile"
basis=${splitfile[9]}
#metadatafile=${dir}${basisstatus}'_metadata.txt'
echo $metadatafile
echo $basis
# Remove empty brackets next to Salinity
sed -i '.bak' 's/Salinity \[\]/Salinity/g' ${metadatafile}; rm ${metadatafile}.bak

# Datasets author
linenum=$(grep -n ${basis} ${basisdir}Basis_PI.txt | head -n 1 | cut -d: -f1)
PI=$(grep -n ${basis} ${basisdir}Basis_PI.txt | head -n 1 | cut -d$'\t' -f2)
echo ${linenum}
#PI= $(awk -v ln=$linenum 'BEGIN{FS=OFS="\t"}; FNR==ln; {print $2}' ${dir}Basis_PI.txt)
echo $PI
awk -v PId=$PI 'BEGIN{FS=OFS="\t"} FNR==7,FNR==11{$3=PId};1' ${metadatafile} > tmp && mv tmp ${metadatafile}
awk -v PId=$PI 'BEGIN{FS=OFS="\t"} FNR==22{$3=PId};1' ${metadatafile} > tmp && mv tmp ${metadatafile}

# Common Authors
# Set geocode and calculated parameters PI ID to not_given (506); fCO2 rec PI is Are Olsen 
awk 'BEGIN{FS=OFS="\t"} FNR==3,FNR==6{$3=506};1' ${metadatafile} > tmp && mv tmp ${metadatafile}
awk 'BEGIN{FS=OFS="\t"} FNR==12,FNR==21{$3=506};1' ${metadatafile} > tmp && mv tmp ${metadatafile}
awk 'BEGIN{FS=OFS="\t"} FNR==23{$3=29177};1' ${metadatafile} > tmp && mv tmp ${metadatafile}
awk 'BEGIN{FS=OFS="\t"} FNR==24,FNR==25{$3=506};1' ${metadatafile} > tmp && mv tmp ${metadatafile}

# Methods
awk 'BEGIN{FS=OFS="\t"} FNR==12{$4=7288};1' ${metadatafile} > tmp && mv tmp ${metadatafile}
awk 'BEGIN{FS=OFS="\t"} FNR==13{$4=7289};1' ${metadatafile} > tmp && mv tmp ${metadatafile}
awk 'BEGIN{FS=OFS="\t"} FNR==14{$4=7290};1' ${metadatafile} > tmp && mv tmp ${metadatafile}
awk 'BEGIN{FS=OFS="\t"} FNR==16{$4=8071};1' ${metadatafile} > tmp && mv tmp ${metadatafile}
awk 'BEGIN{FS=OFS="\t"} FNR==23{$4=7296};1' ${metadatafile} > tmp && mv tmp ${metadatafile}

# Comments
awk 'BEGIN{FS=OFS="\t"} FNR==7{$5="PSU"};1' ${metadatafile} > tmp && mv tmp ${metadatafile}
awk 'BEGIN{FS=OFS="\t"} FNR==15{$5="d2l, estimated distance to major land mass"};1' ${metadatafile} > tmp && mv tmp ${metadatafile}
awk 'BEGIN{FS=OFS="\t"} FNR==23{$5="fCO2rec"};1' ${metadatafile} > tmp && mv tmp ${metadatafile}
awk 'BEGIN{FS=OFS="\t"} FNR==24{$5="fCO2rec_src, Algorithm for generating fCO2rec from the raw data, 0:not generated"};1' ${metadatafile} > tmp && mv tmp ${metadatafile}
awk 'BEGIN{FS=OFS="\t"} FNR==25{$5="fCO2rec_flag, WOCE quality flag for fCO2rec: 2:good, 3:questionable, 4:bad, 9:not generated"};1' ${metadatafile} > tmp && mv tmp ${metadatafile}

done



#[Parameter]
#Parameter name	Parameter ID	PI ID	Method ID	Comment	Format	Factor	fill empty cells with	Range min	Range max	Number of integers influenced by line	Number of digits influenced by line
#DATE/TIME	1599	29157	43		yyyy-MM-dd'T'HH:mm						
#LONGITUDE	1601	29157	43		###0.00000	1		-113.46	35.06	1850	1
#LATITUDE	1600	29157	43		##0.00000	1		-75.8179	84.5537	1	1
#DEPTH, water [m]	1619	29157	43		#0.0	1		4.95	5.05	1	1
#Salinity []	716	29157	43		#0.000	1		3.39768	38.1447	1	1
#Temperature, water [°C]	717	29157	43		#0.000	1		-1.87254	28.8658	2289	1
#Temperature at equilibration [°C]	48924	29157	43		#0.000	1		-1.111	28.9466	2378	2
#Pressure, atmospheric [hPa]	2224	29157	43		###0.000	1		959.31	1106.96	17040	1
#Pressure at equilibration [hPa]	48925	29157	43		###0.000	1		958.815	1038.99	17099	1
#Salinity, interpolated	102735	29157	43		#0.000	1		27.7527	37.5467	1	1
#Pressure, atmospheric, interpolated [hPa]	102736	29157	43		###0.000	1		959.112	1037.47	20550	1
#Depth, bathymetric, interpolated/gridded [m]	102737	29157	43		###0	1		-199.98	5579.24	1	
#Distance [km]	21453	29157	43		###0	1		0	1010	1	
#xCO2 (air), interpolated [µmol/mol]	124243	29157	43								
#xCO2 (water) at equilibrator temperature (dry air) [µmol/mol]	49310	29157	43		##0.000	1		134.442	454.5	2	2
#xCO2 (water) at sea surface temperature (dry air) [µmol/mol]	49314	29157	43								
#Partial pressure of carbon dioxide (water) at equilibrator temperature (wet air) [µatm]	102734	29157	43								
#Partial pressure of carbon dioxide (water) at sea surface temperature (wet air) [µatm]	49313	29157	43								
#Fugacity of carbon dioxide (water) at equilibrator temperature (wet air) [µatm]	102733	29157	43								
#Fugacity of carbon dioxide (water) at sea surface temperature (wet air) [µatm]	49312	29157	43								
#Fugacity of carbon dioxide (water) at sea surface temperature (wet air) [µatm]	49312	29157	43		##0.000	1		125.583	492.124	2	2
#Algorithm	124244	29157	43		#0	1		0	1.01	1	
#Quality flag [#]	7635	29157	43		#0	1		1.98	9.09	1	
#[EOF]
