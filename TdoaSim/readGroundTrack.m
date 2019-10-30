function [stations,satellites,satellitesGT,GTframe,Time,names]=readGroundTrack(Name)
%This data will read the output ground track from Orekit. 
%The expected text file format is as follows:
%Lat Long Altitude
% X   Y      Z
%continue for each receiver
%Elevation wrt E Azimuth Range Lat Long Altitude Time
%    X              Y       Z    A    B     C       D
%continue for each data point

%Time is expected as an AbsoluteDate in form
%YYYY-DD-MMThh:min:sec.millisecond
%EX: 2019-10-20T23:42:25.227

%OUTPUT: Lx3 station vector with Lat Long altitude of stations
        %mx3 satellite vector with Lat Long altitude of all satellite
        %positions.
        %mx3 satellite Ground Truth vector with azimuth, elevation, range
        %of all satellite positions with respect to the specified station.
        %1x3 frame coordinates where az, el, rng is measured from.
        %mx1 absolute times.
        %1x1 name of the fileName. 
%These outputs are each in a nx1 cell array where n is the number of input
%files.
        
%Name is either a folder of filename.
%if its a folder, readGroundTrack will read in all text files in that
%folder.
if exist(Name,'dir')==7
    %temp is a struct array. We only want the "name" field.
    temp=dir(Name);
    %removes '.' and '..' and makes format FolderName/FileName
    fileName=cell(size(temp,1)-2,1);
    names=cell(size(temp,1)-2,1);
    for i=3:size(temp,1)
        names{i-2}=temp(i).name;
        fileName{i-2}=[Name '/' temp(i).name];
    end
    
else
    %ASSUMES name is in working directory.
    fileName{1}=Name;
    names{1}=fileName{1};
end

%% Read each file.
n=size(fileName,1);
stations=cell(n,1);
satellites=cell(n,1);
satellitesGT=cell(n,1);
Time=cell(n,1);
GTframe=cell(n,1);

for i=1:n
    fid=fopen(fileName{i});
    % set linenum to the desired line number that you want to import

    linenum=1;
    %%NOTE str2double does NOT work. 
    C = textscan(fid,'%s',1,'delimiter','\n', 'headerlines',linenum-1); %read header. do nothing with it. 
    
    %find stations
    findingStations=true;
    while findingStations
        
        C = textscan(fid,'%s',1,'delimiter','\n', 'headerlines',linenum-1);
        temp=cell2mat(C{1});
        Line=str2num(temp);
        if isempty(Line)==1
            break;
        end
        stations{i}(Line(4)+1,:)=Line(1:3);
    end
    
    %find satellite pos's.
    C=regexp(C{1}{1},'\d*','Match');
    wrt=str2num(C{1});
    GTframe{i}=stations{i}(wrt+1,:);
    findingSats=true;
    count=1;
    while findingSats
        % use '%s' if you want to read in the entire line or use '%f' if you want to read only the first numeric value
        C = textscan(fid,'%s',1,'delimiter','\n', 'headerlines',linenum-1);
        if isempty(C{1})==1
            fclose(fid);
            break;
        end
        DivideIndex=strfind(C{1}{1},':');
        DivideIndex=DivideIndex(1)-14;
        Line=str2num(C{1}{1}(1:DivideIndex));
%         if isnan(Line)==1
%             break;
%         end
        satellitesGT{i}(count,:)=Line(1:3); %1st three are az el rng
        satellites{i}(count,:)=Line(4:6); %2nd set of 3 is lat long altitude.
        Time{i}(count,:)=C{1}{1}(DivideIndex+1:end);
        count=count+1;
    end
end
    
    
end