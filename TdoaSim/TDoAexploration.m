%This script explores choosing points in the triangle formed by TDoA.
%this script has similar format to sensitivityhAnalysisNet.m, but only uses
%Monte Carlo. It uses a debugmode=1 to save intermediate plots that show
%TDoA solutions using all solvers. 

%It is designed as a lighter version of sensitivityAnalysisNet.m
clearvars
close all


addpath('./LocateSat')
addpath('./TimeDiff')
load RangePolynomial.mat;
P;

%% Inputs
R2=[42.700192000000000	-77.408628000000010	701.000000000000000]; %mees
R8=[43.213809 -77.190456 140+2*4]; %williamson high school
R9=[43.0162 -78.1380 272+3*4]; %GCC library

TR=[R2;R9;R8]; OF='MeesGCCWilliamson';


% TimeSyncErrFar=100e-9; %100ns time sync error.
TimeSyncErrFar=1e-3 %5e-6;
RL_rect_err=ones(3,3)*9; %9m location error.

DebugMode=1; %set to 0 to not see plots. Recommended: 1
numTests=30; %number of tests. Recommended: 30
solver=0; %0 symbolic solver, 1 least squares. Using 0 will get the solver type comparison plots

%% Invariants
ClkError=ones(3,1)*TimeSyncErrFar; %3x1
Sphere=wgs84Ellipsoid;


ReceiverError=[zeros(3,3) ClkError];

%% Input Ranges
%for quick testing. While the infrastructure is there, its recommended to
%only send one Azimuth, Elevation value since we plot every TDoA solution.
%For one pair, that's at least 30 tests * 3 plots/per test = 90 plots!~
% AzimuthRange=0:45:360;
% ElevationRange=5:15:80;

%Recommended
AzimuthRange=65;
ElevationRange=50;


SatelliteAltitudeRange=500e3; %range of satellite range values.


T=TR;
OutputFolder=OF;
start=1;
%% Create satellite test cases, run sensitivity.


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


%% Run the Tests
for i=start:p
    Az=Azimuths(i);
    El=Elevations(i);
    Rng=Ranges(i);

    [means,stdDev,meanError,stdDevError, Data]=MonteCarlo(numTests,Az,El,Rng,T,RL_rect_err,ClkError,DebugMode,solver,1,T(1,:));
    AllMeans(i,:)=means;
    AllstdDevs(i,:)=stdDev;
    AllMeanErrors(i,:)=meanError;
    AllstdDevError(i,:)=stdDevError;
    AllRawData{i}=Data;

end

%% save results. With 90 plots, again not recommended to save the plots. 
% GraphSaver({'png','fig'},'../Plots/TDoAexploration',1);

save(['OutputTDoAExperiment' OutputFolder])


