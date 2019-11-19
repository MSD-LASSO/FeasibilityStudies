%This script will evaluate sensitivity over a dynamics range.
clearvars
close all

h1=gcp;
% h1=parpool;

addpath('LocateSat')
addpath('TimeDiff')

R1=[43.209037000000000	-77.950921000000010	0.000000000000000]; %brockport
R2=[42.700192000000000	-77.408628000000010	0.000000000000000]; %mees
R3=[43.204291000000000	-77.469981000000000	0.000000000000000]; %webster
TimeSyncErrFar=100e-9; %100ns time sync error.
RL_err=ones(3,3)*9; %9m location error.

%% Invariants
ClkError=ones(3,1)*TimeSyncErrFar; %3x1
ReceiverLocations=[R1;R2;R3];
outputFolder='BrockportMeesWebster';
Sphere=wgs84Ellipsoid;
numSamples=2;
DebugMode=-1;

ReceiverError=[zeros(3,3) ClkError];
GND=getStruct(ReceiverLocations,ReceiverError,ReceiverLocations(1,:),ReceiverError(1,:),Sphere);
GND(1).ECFcoord_error=RL_err(1,:);
GND(2).ECFcoord_error=RL_err(2,:);
GND(3).ECFcoord_error=RL_err(3,:);

%% Input Ranges
% AzimuthRange=0:45:359; %ALWAYS wrt to the first receiver. 
% ElevationRange=15:15:75;
AzimuthRange=[0 90];
ElevationRange=[15 30 45];
SatelliteRangeRange=1000e3; %range of satellite range values.


%% Create satellite test case, run sensitivity.

Test=zeros(length(AzimuthRange)*length(ElevationRange),2);
p=0;
for i=1:length(AzimuthRange)
    for j=1:length(ElevationRange)
        p=p+1;
        Test(p,:)=[AzimuthRange(i) ElevationRange(j)];
    end
end

Azimuths=Test(:,1);
Elevations=Test(:,2);
Refx=ReceiverLocations(1,1);
Refy=ReceiverLocations(1,2);
Refz=ReceiverLocations(1,3);
% try
SensitivityTest=cell(p,1);
    parfor i=1:p
%     for i=1:length(AzimuthRange)
%         for j=1:length(ElevationRange)
            %% Set up problem and get ground truth.
%             Az=AzimuthRange(i);
%             El=ElevationRange(j);
            Az=Azimuths(i);
            El=Elevations(i);
            Rng=SatelliteRangeRange;

            %This is ALWAYS measured from Receiver 1. XY position.
%             GT(i,:)=[zPlane*cos(El)*sin(Az) zPlane*cos(El)*cos(Az)];

            [lat, long, h]=enu2geodetic(Rng*cosd(El)*sind(Az),Rng*cosd(El)*cosd(Az),Rng*sind(El),...
                Refx,Refy,Refz,Sphere);
            SAT=getStruct([lat long h],zeros(1,4),[Refx Refy Refz],zeros(1,4),Sphere);
            
            [SensitivityLocation, SensitivityTime]=OneAtaTime(GND,SAT,1,1,outputFolder,1,DebugMode,numSamples,Sphere);
            %sensitivityLocation is a 2x1 cell and SensitivityTime a 2x1 cell.
            %The cell entries are Azimuth and Elevation. Inside are mx3 and mx1
            %slopes.
            SensitivityTest{i}={SensitivityLocation, SensitivityTime};

%         end
%     end
    end
% catch ME
%     warning([ME.message ' first instance at ' num2str(ME.stack(1).line)])
%     save([outputFolder '/Error'],ME);
% end
% save([outputFolder '/Data'])
save(['Output' outputFolder])