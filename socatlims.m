
clc
clear all
close all

tic
wd = '/Users/rpr061/Desktop/SOCATv2019v7All_ABCDE_enhanced_datafiles/';
wdout= '/Users/rpr061/Documents/localtestarea/SOCATPangaea_metadatadataset/';

AllDataFiles=dir([wd,'/**/*.tsv']);
% .name has the name of the FILE (with "_SOCAT_bundle/enhanced)"). Create .namedata
% for expocode only
for ind=1:length(AllDataFiles);
    namelong=AllDataFiles(ind).name;
    namesplit=strsplit(namelong, '_');
    AllDataFiles(ind).namedata=namesplit{1};
end

fileIDout=fopen([wdout,'SOCATv2019alllims.txt'],'w', 'native', 'UTF-8');
        fprintf(fileIDout, [repmat('%s\t',1,6),'%s\n'],...
            'expocode','Nlat','Slat','medlat','Elon','Wlon','medlon');  
        
for ifiles=1:length(AllDataFiles)
    currentfile=[AllDataFiles(ifiles).folder,'/',AllDataFiles(ifiles).name];    
    ifiles
      
    wholetext=textread(currentfile, '%s','delimiter','\n');
    
    headerline=find(~cellfun(@isempty,regexp(wholetext,'Expocode\tversion\tSOCAT_DOI')));
    
    
    %% Read data files
    % Initialize variables.
    
    delimiter = '\t';
    startRow = headerline +1;
    
    % Read columns of data as text:
    formatSpec = [repmat('%s',1,32),'\n'];
    fileID = fopen(currentfile,'r');
    dataArray1 = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\n');
    dataArray=[dataArray1{:}];
    fclose(fileID);
    
    latitudecolumn=cellfun(@str2num,dataArray(:,12));
    longitudecolumn=cellfun(@str2num,dataArray(:,11));
    longitudecolumn(longitudecolumn>180.)=longitudecolumn(longitudecolumn>180.)-360.;
    
    Nlat=num2str(nanmax(latitudecolumn));
    Slat=num2str(nanmin(latitudecolumn));
    medlat=num2str(nanmean(latitudecolumn));
   
    Elon=num2str(nanmax(longitudecolumn));
    Wlon=num2str(nanmin(longitudecolumn));
    medlon=num2str(nanmean(longitudecolumn));
    
expocode=dataArray{1,1};

    % Write file 
    fprintf(fileIDout,[repmat('%s\t',1,6),'%s\n'],expocode,Nlat,Slat,medlat,Elon,Wlon,medlon);
end
    fclose(fileIDout)
toc