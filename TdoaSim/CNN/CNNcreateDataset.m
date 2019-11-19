%This script will create samples over a range. 
clearvars
close all

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
RL_err=ones(3,3)*9;

%% Invariants
% ReceiverError=[]; %same size as ReceiverLocations
ClkError=ones(3,1)*TimeSyncErrFar; %3x1
ReceiverLocations=[R1;R2;R3];
numImages=500;
outputFolder='Test2properSize';
mkdir(['Images/' outputFolder]);
Sphere=wgs84Ellipsoid;

% ReceiverError=[ReceiverError ClkError];
ReceiverError=[zeros(3,3) ClkError];
GND=getStruct(ReceiverLocations,ReceiverError,ReceiverLocations(1,:),ReceiverError(1,:),Sphere);

%% Input Ranges
AzimuthRange=[45 55]; %ALWAYS wrt to the first receiver. 
ElevationRange=[40 45];
SatelliteRangeRange=[500e3 1000e3]; %range of satellite range values.
zPlaneRange=[0 200e3];

%% Canonical Form of Image
%largest X or Y value is if the Range is entirely in that direction.
XLimits=[-SatelliteRangeRange(2) SatelliteRangeRange(2)];
YLimits=[-SatelliteRangeRange(2) SatelliteRangeRange(2)];


%% Create numImages
try
    GT=zeros(numImages,2);
    figure('Position', [100 100 floor(224^3/171/226) floor(224^3/174/227)])
    for i=1:numImages
        %% Set up problem and get ground truth.
        Az=rand(1)*diff(AzimuthRange)+AzimuthRange(1);
        El=rand(1)*diff(ElevationRange)+ElevationRange(1);
        Rng=rand(1)*diff(SatelliteRangeRange)+SatelliteRangeRange(1);
        zPlane=rand(1)*diff(zPlaneRange)+zPlaneRange(1);

        %This is ALWAYS measured from Receiver 1. XY position.
        GT(i,:)=[zPlane*cos(El)*sin(Az) zPlane*cos(El)*cos(Az)];

        [lat, long, h]=enu2geodetic(Rng*cosd(El)*sind(Az),Rng*cosd(El)*cosd(Az),Rng*sind(El),...
            ReceiverLocations(1,1),ReceiverLocations(1,2),ReceiverLocations(1,3),Sphere);
        SAT=getStruct([lat long h],zeros(1,4),ReceiverLocations(1,:),zeros(1,4),Sphere);

        [TimeDiff, TimeDiffErr]=timeDiff3toMatrix(GND,SAT);

        %% Get the plots
        %Apply the Noise
        distanceDiff=normrnd(TimeDiff,TimeDiffErr)*3e8; %model error as a Gaussian.
    %     [RL, RL_err]=geo2rect(ReceiverLocations,ReceiverError,Sphere);
        [X Y Z]=geodetic2enu(ReceiverLocations(:,1),ReceiverLocations(:,2),ReceiverLocations(:,3),...
            ReceiverLocations(1,1),ReceiverLocations(1,2),ReceiverLocations(1,3),Sphere);
        RL=normrnd([X Y Z],RL_err);

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

        figure(1)
        fimplicit(Hyperbola,[XLimits YLimits],'linewidth',3);

        %% Save Image
        F = getframe;
        [X, map]=frame2im(F); %can alternatively collect colormap as well.
        imwrite(255-X,['Images/' outputFolder '/' num2str(i) '.png']);
    %     imshow(imread(['Images/' num2str(i) '.png'])); %debugging purposes.
    end
catch ME
    warning([ME.message ' first instance at ' num2str(ME.stack(1).line)])
    save([outputFolder 'Error'],ME);
end
save(outputFolder,'GT')

