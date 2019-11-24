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
numImages=250;
outputFolder='Test8zPlane400val';
mkdir(['Images/' outputFolder]);
Sphere=wgs84Ellipsoid;

% ReceiverError=[ReceiverError ClkError];
ReceiverError=[zeros(3,3) ClkError];
GND=getStruct(ReceiverLocations,ReceiverError,ReceiverLocations(1,:),ReceiverError(1,:),Sphere);

%% Input Ranges
AzimuthRange=[0 90]; %ALWAYS wrt to the first receiver. 
ElevationRange=[15 85];
SatelliteRangeRange=[500e3 5000e3]; %range of satellite range values.
% zPlaneRange=[0 200e3];
zPlaneRange=[400e3 400e3];

%% Canonical Form of Image
%largest X or Y value is if the Range is entirely in that direction.
% XLimits=[-SatelliteRangeRange(2) SatelliteRangeRange(2)];
% YLimits=[-SatelliteRangeRange(2) SatelliteRangeRange(2)];
XLimits=[-zPlaneRange(2) zPlaneRange(2)];
YLimits=[-zPlaneRange(2) zPlaneRange(2)];


%% Create numImages
try
    GT=zeros(numImages,2);
    name=cell(numImages,1);
    timeDiffs=zeros(numImages,3);
%     zPlanes=zeros(numImages,1);
    figure('Position', [100 100 floor(224^3/171/226) floor(224^3/174/227)])
    for i=1:numImages
        %% Set up problem and get ground truth.
        Az=rand(1)*diff(AzimuthRange)+AzimuthRange(1);
        El=rand(1)*diff(ElevationRange)+ElevationRange(1);
        Rng=rand(1)*diff(SatelliteRangeRange)+SatelliteRangeRange(1);
        zPlane=rand(1)*diff(zPlaneRange)+zPlaneRange(1);
%         zPlanes(i)=zPlane;
        
        %This is ALWAYS measured from Receiver 1. XY position.
        GT(i,:)=[zPlane*cosd(El)*sind(Az) zPlane*cosd(El)*cosd(Az)]/zPlane;
%         GT(i,:)=[zPlane*cos(El)*sin(Az) zPlane*cos(El)*cos(Az)];

        [lat, long, h]=enu2geodetic(Rng*cosd(El)*sind(Az),Rng*cosd(El)*cosd(Az),Rng*sind(El),...
            ReceiverLocations(1,1),ReceiverLocations(1,2),ReceiverLocations(1,3),Sphere);
        SAT=getStruct([lat long h],zeros(1,4),ReceiverLocations(1,:),zeros(1,4),Sphere);

        [TimeDiff, TimeDiffErr]=timeDiff3toMatrix(GND,SAT);

        %% Get the plots
        %Apply the Noise
        distanceDiff=normrnd(TimeDiff,TimeDiffErr)*3e8; %model error as a Gaussian.
%         timeDiffs(i,:)=[distanceDiff(1,2), distanceDiff(1,3), distanceDiff(2,3) zPlane];
        timeDiffs(i,:)=[distanceDiff(1,2), distanceDiff(1,3), distanceDiff(2,3)];
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

        %% Convert the numerical data to image.
        %structure of this:
        %every 2 elements in TimeDiffs an zPlane will be saved as pixel
        %value of 2.5x greater. 
        %if the value is negative, set px to 255, otherwise px=0.
        
        pp=0;
        pixel=zeros(1,224);
        for jj=1:size(timeDiffs,2)
            pp=pp+1;
            floating=timeDiffs(i,jj);
            if floating>0
                positive=255;
            else
                positive=0;
            end
            str=num2str(floating,'%15.15f');
            
            pixel(pp:pp+2)=positive;
            ppPreLoop=pp;
            kk=1;
            while kk<length(str)-1 && pp<ppPreLoop+45
                pp=pp+3;
                pixel(pp:pp+2)=str2double(str(kk:kk+1))*2.5;
                kk=kk+2;
            end
            if pp<ppPreLoop+45
                pp=ppPreLoop+45;
            end
        end
        
        
        
        %% Save Image
        name{i}=['Images/' outputFolder '/' num2str(i) '.png'];
        F = getframe;
        [X, map]=frame2im(F); %can alternatively collect colormap as well.
        X(end-5:end,:,1)=repmat(pixel,6,1);
        X(end-5:end,:,2)=repmat(pixel,6,1);
        X(end-5:end,:,3)=repmat(pixel,6,1);
        
        imwrite(255-X,name{i});
    %     imshow(imread(name{i})); %debugging purposes.
    end
catch ME
    warning([ME.message ' first instance at ' num2str(ME.stack(1).line)])
    save([outputFolder 'Error'],ME);
end
save(outputFolder,'GT','timeDiffs','ReceiverLocations','name')

