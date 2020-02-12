%This script will evaluate sensitivity or Monte Carlo over a dynamic range.
%WARNING: running Monte Carlo on 1 test takes 9 hours on 6 cores for the
%symbolic solver.
clearvars
close all

load RangePolynomial.mat;
P;

% h1=gcp;
% h1=parpool;

addpath('LocateSat')
addpath('TimeDiff')

R1=[43.209037000000000	-77.950921000000010	175.000000000000000]; %brockport
R2=[42.700192000000000	-77.408628000000010	701.000000000000000]; %mees
R3=[43.204291000000000	-77.469981000000000	147.000000000000000]; %webster
R4=[42.871390000000000	-78.018577000000000	323.000000000000000]; %pavilion
R5=[43.0853460000000 -77.6791050000000 170+4*4]; %Institute Hall
R6=[43.0483000000000 -77.6586630000000 176+5*4]; %RIT inn
R7=[43.0862850000000 -77.6680150000000 163.4+12*4]; %ellingson
R8=[43.213809 -77.190456 140+2*4]; %williamson high school
R9=[43.0162 -78.1380 272+3*4]; %GCC library


TR{1}=[R2;R1;R3]; OF{1}='MeesBrockportWebster';
TR{2}=[R2;R3;R4]; OF{2}='MeesWebsterPavilion';
TR{3}=[R6;R5;R7]; OF{3}='InnInstituteEllingson';
TR{4}=[R2;R4;R6]; OF{4}='MeesPavilionInn';
TR{5}=[R6;R1;R3]; OF{5}='InnBrockportWebster';
TR{6}=[R2;R8;R1]; OF{6}='MeesWilliamsonBrockport';
TR{7}=[R6;R9;R1]; OF{7}='InnGCCBrockport';
TR{8}=[R2;R9;R8]; OF{8}='MeesGCCWilliamson';
TR{9}=[R2;R3;R9]; OF{9}='MeesWebsterGCC';
TR{10}=[R2;R6;R8]; OF{10}='MeesInnWilliamson';

% TimeSyncErrFar=100e-9; %100ns time sync error.
TimeSyncErrFar=5e-6;
RL_err=ones(3,3)*9; %9m location error.

%% Invariants
ClkError=ones(3,1)*TimeSyncErrFar; %3x1
Sphere=wgs84Ellipsoid;
%numSamples to estimate the partial derivative. Min is 1.
numSamples=nan; %for OneAtATime. Set to nan to skip.
%numTests to run before running statistics. Min is 15-30 by Central Limit
%Theorem. Recommended: 1000. This is not practical for the symbolic solver.
numTests=30; %for MonteCarlo. Set to nan to skip.
useAbsoluteError=0; %for MonteCarlo. Set to 1 to use the actual satellite position in the error calculation. 
%leave at 0 to allow code to estimate its error based on statistics. 
DebugMode=-1; %tells OneAtATime to not output anything. 

ReceiverError=[zeros(3,3) ClkError];

%% Input Ranges
% AzimuthRange=0:45:359; %ALWAYS wrt to the first receiver. 
% ElevationRange=15:15:75;

%For nominal tests.
AzimuthRange=0:10:359; %ALWAYS wrt to the first receiver. 
ElevationRange=5:5:90;

%for quick testing
% AzimuthRange=0:45:360;
% ElevationRange=5:15:80;

%for really quick testing
AzimuthRange=345;
ElevationRange=45;

%this set of inputs causes an error with sensitivity.
% AzimuthRange=0:2.5:359; ElevationRange=1:1:4;


SatelliteAltitudeRange=500e3; %range of satellite range values.

% Tests=[1,2,3,4,5,6,7,8,9,10]; 
Tests=8;
solver=1; %0 symbolic solver, 1 least squares.
for TestNum=1:length(Tests)
T=TR{Tests(TestNum)};
OutputFolder=OF{Tests(TestNum)};
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
% try
SensitivityTest=cell(p,1);
timeDiffs=zeros(p,3);


% load('Results/ErrorTest8.mat')
% % start=37;
% load('Results/ErrorTest10.mat')
% start=509;
% ending=500;
% load('Results/ErrorTest3.mat')
% start=37;
% ending=start+3;
start=1;
if ~isnan(numSamples)
    parfor i=start:p


%     for i=start:p
            %% Set up problem and get ground truth.
%             Az=AzimuthRange(i);
%             El=ElevationRange(j);
            Az=Azimuths(i);
            El=Elevations(i);
            Rng=Ranges(i);

            %This is ALWAYS measured from Receiver 1. XY position.
%             GT(i,:)=[zPlane*cos(El)*sin(Az) zPlane*cos(El)*cos(Az)];

            [lat, long, h]=enu2geodetic(Rng*cosd(El)*sind(Az),Rng*cosd(El)*cosd(Az),Rng*sind(El),...
                Refx,Refy,Refz,Sphere);
            SAT=getStruct([lat long h],zeros(1,4),[Refx Refy Refz],zeros(1,4),Sphere);
            
            [TimeDiffs,TimeDiffErr]=timeDiff3toMatrix(GND,SAT);
            timeDiffs(i,:)=[TimeDiffs(1,2), TimeDiffs(1,3), TimeDiffs(2,3)];
            
            try
                [SensitivityLocation, SensitivityTime]=OneAtaTime(GND,SAT,1,1,OutputFolder,1,DebugMode,numSamples,Sphere,solver);
                %sensitivityLocation is a 2x1 cell and SensitivityTime a 2x1 cell.
                %The cell entries are Azimuth and Elevation. Inside are mx3 and mx1
                %slopes.
                SensitivityTest{i}={SensitivityLocation, SensitivityTime};
            catch ME
                fprintf('\n')
                fprintf(['Test ' num2str(i) ' failed due to ' ME.message ' on line ' num2str(ME.stack(end).line)]);
                fprintf('\n')
            end

%         end
%     end
    end
    
    save(['Output' OutputFolder])
end

if ~isnan(numTests)
%    parfor i=start:p
    AllMeans=zeros(p,2);
    AllstdDevs=zeros(p,2);
    AllMeanErrors=zeros(p,2);
    AllstdDevError=zeros(p,2);
    AllRawData=cell(p,1);
    
    for i=start:p
        Az=Azimuths(i);
        El=Elevations(i);
        Rng=Ranges(i);
        try
            [means,stdDev,meanError,stdDevError, Data]=MonteCarlo(numTests,Az,El,Rng,T,RL_err,ClkError,DebugMode,solver,useAbsoluteError,T(1,:));
            AllMeans(i,:)=means;
            AllstdDevs(i,:)=stdDev;
            AllMeanErrors(i,:)=meanError;
            AllstdDevError(i,:)=stdDevError;
            AllRawData{i}=Data;
        catch ME
                fprintf('\n')
                fprintf(['Test ' num2str(i) ' failed due to ' ME.message ' on line ' num2str(ME.stack(end).line)]);
                fprintf('\n')
        end
   end
 
    save(['OutputMonteCarlo' OutputFolder])
    
%     for i=1:p
%         plotHistograms(AllRawData{i},[Azimuths(i) Elevations(i)],['Plots/MonteCarloHistograms/' OutputFolder]);
%     end
    
%     plotHistograms(AllRawData{i})
end
% catch ME
%     warning([ME.message ' first instance at ' num2str(ME.stack(1).line)])
%     save([OutputFolder '/Error'],ME);
% end
% save([outputFolder '/Data'])




end