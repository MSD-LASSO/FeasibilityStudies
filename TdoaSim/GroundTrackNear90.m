%This script examines the sensitivity of a TDoA system for 3 different
%ground tracks:
    %1. On the Same rooftop
    %2. Around RIT. Elligson, Institute, and RIT Inn
    %3. Far. Institute, Brockport, and Bristol UofR observatory.
%these ground tracks were produced in Orekit.

close all
clearvars
addpath('LocateSat')
addpath('TimeDiff')
Sphere=referenceSphere('Earth');

%% Get all the Data in the ground tracks folder.
Folder='GroundTracks/Sphere';
[stations,satellites,satellitesGT,GTframe,Time,names]=readGroundTrack(Folder);

%% Dictate expected Errors.
%for the OneataTime, all errors have been multiplied by 3.
%Garmin GPS expected accuracy is 3m or better. 
locationErr=9;
%0.4 picoseconds. Based on Wire length mismatch.
TimeSyncErrRoof=.12e-10;
%20 nanoseconds. Based on location accuracy of TV station and our
%receivers. 
TimeSyncErrFar=20e-9;


%% Cycle through the ground cycles one at a time.
n=length(names);

for i=1:n %1:n
    %% Prepare the error.
    name=names{i}; 
    m=size(stations{i},1);
    GND_error=zeros(m,4); %Error will be added as a function of position, not lat long.
    if contains(name,'RITRoof')
        GND_error(:,4)=ones(m,1)*TimeSyncErrRoof;
    else
        GND_error(:,4)=ones(m,1)*TimeSyncErrFar;
    end
    
    %THis could is here because the Lat and Long are incorrect on the text
    %files.
%     temp=stations{i}*180/pi;
%     temp=[temp(:,2) temp(:,1) temp(:,3)];
%     GND = getStruct(temp, GND_error);
    %%%%%%%%%%%%%%%%
    GND = getStruct([stations{i}(:,1:2)*180/pi stations{i}(:,3)], GND_error, [GTframe{i}(1:2)*180/pi GTframe{i}(3)], zeros(1,3),Sphere);
    
    %manually set coordinate error.
    for j=1:length(GND)
        GND(j).ECFcoord_error=ones(1,3)*locationErr;
    end
    
    %% For each satellite position, solve for the sensitivity.
    z=size(satellites{i},1);
    for j=22:z %2:z
        %THis could is here because the Lat and Long are incorrect on the text
        %files.
%         temp=satellites{i}(j,:);
%         temp=[temp(:,2)*180/pi temp(:,1)*180/pi temp(:,3)];
%         SAT = getStruct(temp, zeros(1,4));
        %%%%%%%%%%%%%%%%
        %no satellite error for now.
        
        %gut check.
%         [xs ys zs]=sph2cart(satellites{i}(j,2),satellites{i}(j,1),satellites{i}(j,3)+6378137);
%         latSat=0.379014295692151;
%         longSat=-1.449246893353793;
%         al=6378137;
%         alSat=492863.000000001300000+al;
%         [xs2,ys2,zs2]=sph2cart(longSat,latSat,alSat);

        SAT = getStruct([satellites{i}(j,1:2) satellites{i}(j,3)],zeros(1,4),[GTframe{i}(1:2)*180/pi GTframe{i}(3)],zeros(1,3),Sphere);

        [SensitivityLocation, SensitivityTime]=OneAtaTime(GND,SAT,1,0,name(1:end-3),0,0);
    end
    
end