%This script will create samples over a range. 
addpath('../LocateSat')
addpath('../TimeDiff')
addpath('..');


%% Reading Ground Truth. Not exactly sure how to do this with multiple "labels". Every GT has an x and y value.
% digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos', ...
%     'nndatasets','DigitDataset');
% digitDatasetPath='Images';
% imds = imageDatastore(digitDatasetPath, ...
%     'IncludeSubfolders',true,'LabelSource','foldernames');
% imds.Labels

% digitDatasetPath='Images';
% imds = imageDatastore(digitDatasetPath, ...
%     'IncludeSubfolders',true,'LabelSource','foldernames');
% imds.Labels
% 
% digitDatasetPath='Images';
% imds = imageDatastore(digitDatasetPath, ...
%     'IncludeSubfolders',false);
% load Images/GT
% imds.Labels=GT(1,:);
R1=[0.751981147060969	-1.355756142252390	0.000000000000000]*180/pi;
R2=[0.754139962266053	-1.360500226411991	0.000000000000000]*180/pi;
R3=[0.745258941633743	-1.351035428051473	0.000000000000000]*180/pi;
TimeSyncErrFar=100e-9;
R_err=ones(3,3)*9;

%% Invariants
ReceiverError=[]; %same size as ReceiverLocations
ClkError=[]; %3x1
ReceiverLocations=[R1;R2;R3];
numImages=1000;
Sphere=wgs84Ellipsoid;

ReceiverError=[ReceiverError ClkError];
GND=getStruct(ReceiverLocations,ReceiverError,ReceiverLocations(1,:),ReceiverError(1,:),Sphere);

%% Inputs
AzimuthRange=[45 55]; %ALWAYS wrt to the first receiver. 
ElevationRange=[40 45];
SatelliteRangeRange=[500e3 1000e3]; %range of satellite range values.

zPlaneRange=[0 200e3];


%% Canonical Form of Image
%largest X or Y value is if the Range is entirely in that direction.
XLimits=[-SatelliteRangeRange(2) SatelliteRangeRange(2)];
YLimits=[-SatelliteRangeRange(2) SatelliteRangeRange(2)];


%% Create numImages
GT=zeros(numImages,2);
for i=1:numImages
    %% Set up problem and get ground truth.
    Az=rand(1)*diff(AzimuthRange)+AzimuthRange(1);
    El=rand(1)*diff(ElevationRange)+ElevationRange(1);
    Rng=rand(1)*diff(SatelliteRangeRange)+SatelliteRangeRange(1);
    zPlane=rand(1)*diff(zPlaneRange)+zPlaneRange(1);
    
    %This is ALWAYS measured from Receiver 1. XY position.
    GT(i,:)=[zPlane*cos(El)*sin(Az) zPlane*cos(El)*cos(Az)];
    
    [lat, long, h]=enu2ecef(Rng*cos(El)*sin(Az),Rng*cos(El)*cos(Az),Rng*sin(El),Sphere);
    SAT=getStruct([lat long h],zeros(1,4),ReceiverLocations(1,:),zeros(1,4),Sphere);
    
    [TimeDiff, TimeDiffErr]=timeDiff3toMatrix(GND,SAT);
    
    %% Get the plots
    %Apply the Noise
    DistanceDiff=normrnd(TimeDiff,TimeDiffErr)*3e8; %model error as a Gaussian.
%     [RL, RL_err]=geo2rect(ReceiverLocations,ReceiverError,Sphere);
    RL=geo2rect(ReceiverLocations,zeros(3,3),Sphere);
    RL=normrnd(RL,RL_err);
    
    Hyperboloid=sym(zeros(3,1));
    p=1;
    for ii=1:3
        for j=1:3
            if j>ii
                R1=RL(ii,:);
                R2=RL(j,:);
                %assume SymVars is the same for all cases.
                [temp,SymVars]=CreateHyperboloid(R1,R2,distanceDiff(ii,j));
                Hyperboloid(p)=temp;
                p=p+1;
            end
        end
    end
    syms z
    Hyperbola=subs(Hyperboloid,z,zPlane);
    
    figure()
    fimplicit(Hyperbola,[XLimits YLimits],'linewidth',3);
    
    %% Save Image
    F = getframe;
    [X, map]=frame2im(f); %can alternatively collect colormap as well.
    imwrite(X,['Images/' num2str(i) '.png']);
    imread(['Images/' num2str(i) '.png']); %debugging purposes.

end
