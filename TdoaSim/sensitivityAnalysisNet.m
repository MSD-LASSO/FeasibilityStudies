%This script will evaluate sensitivity or Monte Carlo over a dynamic range.
%WARNING: running Monte Carlo on 1 test takes 9 hours on 6 cores for the
%symbolic solver.

%Using a least squares solver is MUCH faster.
clearvars
close all
OutputTriangleParameters %get the triangles.

% Load the fit for the satellite range.
load RangePolynomial.mat;
P;

% h1=gcp;
% h1=parpool;

addpath('LocateSat')
addpath('TimeDiff')


%% Error -- Change if desired.
% TimeSyncErrFar=100e-9; %100ns time sync error.
TimeSyncErrFar=5e-6;
RL_err=ones(3,3)*9; %9m location error.

%% Invariants
%numSamples to estimate the partial derivative. Min is 1.
numSamples=nan; %1 %for OneAtATime. Set to nan to skip.
%numTests to run before running statistics. Min is 15-30 by Central Limit
%Theorem. Recommended: 1000. This is not practical for the symbolic solver.
numTests=30; %nan %for MonteCarlo. Set to nan to skip.
useAbsoluteError=0; %for MonteCarlo. Set to 1 to use the actual satellite position in the error calculation. 
%leave at 0 to allow code to estimate its error based on statistics. 
DebugMode=-1; %-1 tells OneAtATime to not plot anything. 
solver=1; %0 symbolic solver, 1 least squares distance (recommended), 2 time difference.



%% Input Ranges
%For nominal tests.
AzimuthRange=0:10:359; %ALWAYS wrt to the first receiver. 
ElevationRange=5:5:90;

%for quick testing
% AzimuthRange=0:45:360;
% ElevationRange=5:15:80;

%for really quick testing
% AzimuthRange=345;
% ElevationRange=45;

%this set of inputs causes an error with sensitivity.
% AzimuthRange=0:2.5:359; ElevationRange=1:1:4;
%Not really a surprise since we are so low on the horizon. Our antennas
%can't read signals this low in the sky anyway.


SatelliteAltitudeRange=500e3; %range of satellite range values.

%Dictate which triangles to simulate on.
% Tests=[1,2,3,4,5,6,7,8,9,10]; 
Tests=8; 



%% Loops.
ClkError=ones(3,1)*TimeSyncErrFar; %3x1
ReceiverError=[zeros(3,3) ClkError];
Sphere=wgs84Ellipsoid;
%Outer most for loop. Don't put this one in parallel.
for TestNum=1:length(Tests)

%Get the triangle.
T=TR{Tests(TestNum)};
OutputFolder=OF{Tests(TestNum)};
%% Create satellite test case, run sensitivity.
GND=getStruct(T,ReceiverError,T(1,:),ReceiverError(1,:),Sphere);
GND(1).ECFcoord_error=RL_err(1,:);
GND(2).ECFcoord_error=RL_err(2,:);
GND(3).ECFcoord_error=RL_err(3,:);

%Transforms our 2D net into a 1D vector, neccessary for parfor.
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


start=1; %dictate which test to start on. Might be used for debugging purposes. 
if ~isnan(numSamples)
%     parfor i=start:p
        %uncomment for and comment out parfor to switch to serial
        %execution. 
    for i=start:p
            %% Run One-at-a-time
            Az=Azimuths(i);
            El=Elevations(i);
            Rng=Ranges(i);
            
            %Localize the satellite in geodetic coordinates.
            [lat, long, h]=enu2geodetic(Rng*cosd(El)*sind(Az),Rng*cosd(El)*cosd(Az),Rng*sind(El),...
                Refx,Refy,Refz,Sphere);
            SAT=getStruct([lat long h],zeros(1,4),[Refx Refy Refz],zeros(1,4),Sphere);
            
            %Based on those geodetic coordinates, get the real time
            %differences. 
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

    end
    
    save(['Output' OutputFolder])
end

if ~isnan(numTests)

    AllMeans=zeros(p,2);
    AllstdDevs=zeros(p,2);
    AllMeanErrors=zeros(p,2);
    AllstdDevError=zeros(p,2);
    AllRawData=cell(p,1);
    
%     parfor i=start:p
    for i=start:p
        Az=Azimuths(i);
        El=Elevations(i);
        Rng=Ranges(i);
        try
            %Run the Monte Carlo.
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
    
    %Debugging purposes. NOTE: you'll get 2*numTests*p number of plots. So
    %uncomment this cautiously!!!
%     for i=1:p
%         plotHistograms(AllRawData{i},[Azimuths(i) Elevations(i)],['Plots/MonteCarloHistograms/' OutputFolder]);
%     end

end


end