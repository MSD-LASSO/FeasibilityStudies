%This script explores choosing points in the triangle formed by TDoA.
%this script has similar format to sensitivityhAnalysisNet.m, but only uses
%Monte Carlo. It uses a debugmode=1 to save intermediate plots that show
%TDoA solutions using all solvers. 
clearvars
close all



% h1=gcp;
% h1=parpool;

addpath('./LocateSat')
addpath('./TimeDiff')
load RangePolynomial.mat;
P;

R2=[42.700192000000000	-77.408628000000010	701.000000000000000]; %mees
R8=[43.213809 -77.190456 140+2*4]; %williamson high school
R9=[43.0162 -78.1380 272+3*4]; %GCC library

TR=[R2;R9;R8]; OF='MeesGCCWilliamson';


% TimeSyncErrFar=100e-9; %100ns time sync error.
TimeSyncErrFar=5e-6;
RL_err=ones(3,3)*9; %9m location error.

%% Invariants
ClkError=ones(3,1)*TimeSyncErrFar; %3x1
Sphere=wgs84Ellipsoid;


ReceiverError=[zeros(3,3) ClkError];

%% Input Ranges
%For nominal tests.
% AzimuthRange=0:10:359; %ALWAYS wrt to the first receiver. 
% ElevationRange=5:5:90;

%for quick testing
% AzimuthRange=0:45:360;
% ElevationRange=5:15:80;

%for really quick testing
AzimuthRange=180;
ElevationRange=5;

%this set of inputs causes an error!
% AzimuthRange=0:2.5:359; ElevationRange=1:1:4;


SatelliteAltitudeRange=500e3; %range of satellite range values.


DebugMode=1;
T=TR;
OutputFolder=OF;
start=1;
numTests=30;
solver=0; %0 symbolic solver, 1 least squares.
%% Create satellite test case, run sensitivity.
GND=getStruct(T,ReceiverError,T(1,:),ReceiverError(1,:),Sphere);
GND(1).ECFcoord_error=RL_err(1,:);
GND(2).ECFcoord_error=RL_err(2,:);
GND(3).ECFcoord_error=RL_err(3,:);

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
Ranges=RangeApproximate(Elevations,SatelliteAltitudeRange,P);
Refx=T(1,1);
Refy=T(1,2);
Refz=T(1,3);

AllMeans=zeros(p,2);
AllstdDevs=zeros(p,2);
AllMeanErrors=zeros(p,2);
AllstdDevError=zeros(p,2);
AllRawData=cell(p,1);

%    parfor i=start:p

for i=start:p
    Az=Azimuths(i);
    El=Elevations(i);
    Rng=Ranges(i);
%     try
        [means,stdDev,meanError,stdDevError, Data]=MonteCarlo(numTests,Az,El,Rng,T,RL_err,ClkError,DebugMode,solver);
        AllMeans(i,:)=means;
        AllstdDevs(i,:)=stdDev;
        AllMeanErrors(i,:)=meanError;
        AllstdDevError(i,:)=stdDevError;
        AllRawData{i}=Data;
%     catch ME
%         fprintf('\n')
%         fprintf(['Test ' num2str(i) ' failed due to ' ME.message ' on line ' num2str(ME.stack(end).line)]);
%         fprintf('\n')
%     end
end
% GraphSaver({'png','fig'},'../Plots/TDoAexploration',1);

save(['OutputTDoAExperiment' OutputFolder])

% for i=1:p
%     plotHistograms(AllRawData{i},[Azimuths(i) Elevations(i)],['Plots/MonteCarloHistograms/' OutputFolder]);
% end


