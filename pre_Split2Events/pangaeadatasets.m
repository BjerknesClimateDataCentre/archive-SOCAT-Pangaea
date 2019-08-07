

clc
clear all
close all

tic

wd1 = '/Users/rpr061/Dropbox/SOCATv6/Archive_Pangaea/WIP_Preparation_docs/';
wd = '/Users/rpr061/Documents/DATAMANAGEMENT/Data_products/SOCAT/V6/SOCATv6_local/Archive_SOCATv6/SOCATv6All_SocatEnhancedData/';
wdout= '/Users/rpr061/Documents/DATAMANAGEMENT/Data_products/SOCAT/V6/SOCATv6_local/Archive_SOCATv6/merged_datasets/';


%% Read New and Updated lists
filenameN = [wd1,'ListNew.tsv'];
filenameU = [wd1,'ListUpdated.tsv'];

delimiter = '\t';
startRow = 1;
formatSpec = '%s';
fileID = fopen(filenameN,'r');
NewEvents = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\n');
fclose(fileID);

fileID = fopen(filenameU,'r');
UpdatedEvents = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\n');
fclose(fileID);

NewEvents=NewEvents{1,1}; NewEvents=strtrim(NewEvents);
UpdatedEvents=UpdatedEvents{1,1}; UpdatedEvents=strtrim(UpdatedEvents);

splitNewEvents=regexp(NewEvents, '\-', 'split');
for ind=1:length(NewEvents);
    if length(splitNewEvents{ind,1})>2
        NewDatasets{ind,1}=[splitNewEvents{ind,1}{1,1},'-',splitNewEvents{ind,1}{1,2}];
    else
        NewDatasets(ind,1)=splitNewEvents{ind,1}(1,1); end
end

% Some events were renamed 316420150622!

splitUpdatedEvents=regexp(UpdatedEvents, '\-', 'split');
for ind=1:length(UpdatedEvents);
    if length(splitUpdatedEvents{ind,1})>2
        UpdatedDatasets{ind,1}=[splitUpdatedEvents{ind,1}{1,1},'-',splitUpdatedEvents{ind,1}{1,2}];
    else
        UpdatedDatasets(ind,1)=splitUpdatedEvents{ind,1}(1,1); end
end

%% Get lists of data

AllDataFiles=dir([wd,'/**/*.tsv']);
% .name has the name of the FILE (with "_SOCAT_bundle"). Create .namedata
% for expocode only
for ind=1:length(AllDataFiles);
    namelong=AllDataFiles(ind).name;
    namesplit=strsplit(namelong, '_');
    AllDataFiles(ind).namedata=namesplit{1};
end
% THIS IS ASSUMING HEADERS DO NOT CHANGE!!!
headerPangaea={'','','','','','','','','','',...
    'LONGITUDE','LATITUDE','DEPTH, water [m]','Salinity',['Temperature, water [',char(0176),'C]'],...
    ['Temperature at equilibration [',char(0176),'C]'],'Pressure, atmospheric [hPa]',...
    'Pressure at equilibration [hPa]','Salinity, interpolated',...
    'Pressure, atmospheric, interpolated [hPa]','Depth, bathymetric, interpolated/gridded [m]',...
    'Distance [km]',['xCO2 (air), interpolated [',char(181),'mol/mol]'],...
    ['xCO2 (water) at equilibrator temperature (dry air) [',char(181),'mol/mol]'],...
    ['xCO2 (water) at sea surface temperature (dry air) [',char(181),'mol/mol]'],...
    ['Partial pressure of carbon dioxide (water) at equilibrator temperature (wet air) [',char(181),'atm]'],...
    ['Partial pressure of carbon dioxide (water) at sea surface temperature (wet air) [',char(181),'atm]'],...
    ['Fugacity of carbon dioxide (water) at equilibrator temperature (wet air) [',char(181),'atm]'],...
    ['Fugacity of carbon dioxide (water) at sea surface temperature (wet air) [',char(181),'atm]'],...
    ['Fugacity of carbon dioxide (water) at sea surface temperature (wet air) [',char(181),'atm]'],...
    'Algorithm','Quality flag [#]'};

% for loop through files

for ifiles=1:length(AllDataFiles);
    currentfile=[AllDataFiles(ifiles).folder,'/',AllDataFiles(ifiles).name];
    currentbasis=AllDataFiles(ifiles).name(1:4);
    
    ifiles
    
    % Initialize
    if ifiles==1;
        oldbasis=currentbasis;
        filecounterN=0; filecounterU=0; end
    
    % If different basis, reset the count.
    if ~strcmp(currentbasis,oldbasis); filecounterN=0; filecounterU=0; end
    
    % Is it new or updated?
    [isNew,indexN]=ismember(AllDataFiles(ifiles).namedata,NewDatasets);
    if isNew;
        filecounterN=filecounterN+1;
        currentevent=NewEvents{indexN};
    else; isNew=0; end
    
    % Exception for changes in expocode, but old event
    if strcmp(AllDataFiles(ifiles).namedata,'33RO20071215');
        [isUpdated,indexU]=ismember('33RO20080102',UpdatedDatasets);
    elseif strcmp(AllDataFiles(ifiles).namedata,'33RO20081014');
        [isUpdated,indexU]=ismember('33RO20081018',UpdatedDatasets);
    else
        [isUpdated,indexU]=ismember(AllDataFiles(ifiles).namedata,UpdatedDatasets);
        
    end
    
    if isUpdated;
        filecounterU=filecounterU+1;
        currentevent=UpdatedEvents{indexU};
    else; isUpdated=0; end
    
    
    %% Headers
    
   
    wholetext=textread(currentfile, '%s','delimiter','\n');
    
    headerline=find(~cellfun(@isempty,regexp(wholetext,'Expocode\tversion\tSOCAT_DOI')));
    headerfull=strsplit(wholetext{headerline},'\t');
    header=regexprep(headerfull,'\s\[.*\]','');
    % Header check
    if ifiles>1 & ~strcmp(wholetext{headerline},oldheader);
        error('Headers do not match'); 
    elseif ifiles==1; oldheader=wholetext{headerline};
    end
    
        % Now the folder has ALL SOCAT files, not only N/U v6; skip if old
    if ~isNew && ~ isUpdated; continue; end
    
    numbervars=size(header,2);
    allvars=[1:32];
    strvars=[find(~cellfun(@isempty,regexp(header,'Expocode'))),...
        find(~cellfun(@isempty,regexp(header,'version'))),...
        find(~cellfun(@isempty,regexp(header,'SOCAT_DOI'))),...
        find(~cellfun(@isempty,regexp(header,'QC_Flag')))];
    numvars=allvars(~ismember(allvars,strvars));
    
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
    
    
    % Create datetime column
    for jj=5:10%1:numbervars;
        if ismember(jj, strvars) %string variable
            eval([header{jj},'=dataArray{:,jj};']);
        elseif ismember(jj, numvars)
            eval([header{jj},'=cellfun(@str2num,dataArray(:,jj));']);
        end
    end
    
    datetime=cellstr(datestr([yr,mon,day,hh,mm,ss],'yyyy-mm-ddThh:MM:ss'));
    
    
    % Create EventLabel column
    event={''};
    event{1,1}=currentevent;
    event(2:length(hh),1)={''};
    
    % Create Longitude column (+- 180 deg)
    longitudecell=dataArray(:,11);
    longitudenumber360=cellfun(@str2num,longitudecell);
    longitudenumber180=longitudenumber360;
    longitudenumber180(longitudenumber180>180)=longitudenumber180(longitudenumber180>180)-360;
    longitude180cellnum=num2cell(longitudenumber180);
    longitude180cell=cellfun(@(x) num2str(x,'%9.5f'),longitude180cellnum,'UniformOutput',0);
%    figure;plot(longitudenumber360); hold on; plot(longitudenumber180, 'r'); saveas(gcf,[currentevent,'.jpg']); close gcf;
    
    % Create depth 
    depthcell=cell(length(longitudecell),1);
    depthcell(:)={'5.0'};
    
    
    %% Create output matrix
    
    matrix=event;
    matrix(:,2)=datetime;
    matrix(:,3)=longitude180cell;
    matrix(:,4)=dataArray(:,12);
    matrix(:,5)=depthcell;
    matrix(:,6:24)=dataArray(:,14:end);
    % 4D does not recognize NaN
    matrix(strcmp(matrix,'NaN'))={''};
    
    
    matrix1=matrix.';
    
    
    % Write datafile. Which to write: N/U, newfile/append.
    % REMEMBER 'native','UTF-8', otherwise it won't work!!
    if isNew==1 && filecounterN==1;
        fileID = fopen([wdout,currentbasis,'_N.txt'],'w', 'native', 'UTF-8');
        fprintf(fileID, [repmat('%s\t',1,23),'%s\n'],'EventLabel', 'DATE/TIME',headerPangaea{11:end});
    elseif isUpdated==1 && filecounterU==1;
        fileID = fopen([wdout,currentbasis,'_U.txt'],'w', 'native', 'UTF-8');
        fprintf(fileID, [repmat('%s\t',1,23),'%s\n'],'EventLabel', 'DATE/TIME',headerPangaea{11:end});
    elseif isNew==1;
        fileID = fopen([wdout,currentbasis,'_N.txt'],'a', 'native', 'UTF-8');
    elseif isUpdated==1;
        fileID = fopen([wdout,currentbasis,'_U.txt'],'a', 'native', 'UTF-8');
    end
    
    fprintf(fileID,[repmat('%s\t',1,23),'%s\n'],matrix1{:});
    %  fprintf(fileID,[repmat('%s\t',1,22),'%s\r\n'],datetime{:},dataArray{:,11:end});
    fclose(fileID)
    
    
    oldbasis=currentbasis;
    oldheader=wholetext{headerline};
    
    clearvars longitude*
end
toc

%% Wishlist: identify all-NaN columns and remove