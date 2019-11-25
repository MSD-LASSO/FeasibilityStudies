%This script evaluates the specified networks on a held out test set.
%Taking the data all the way to azimuth and elevation. Note, you must load
%at least 2 neural networks for 2 different planes for this to work.
clearvars
close all

addpath('../LocateSat')
addpath('../TimeDiff')
addpath('..');

%% Inputs
numTests=1000; %number of tests done for both NO error and WITH error. so total number is twice this.

[R1,R2,R3,Sphere]=getReceiverLocations;
[ClkError, RL_err]=getErrors;

% ReceiverError=[]; %same size as ReceiverLocations
ReceiverLocations=[R1;R2;R3];

%Nueral network locations
inputFolderWithBarcode='C:\Users\awian\Desktop\MachineIntelligence\netsBC';
inputFolderWithoutBarcode='C:\Users\awian\Desktop\MachineIntelligence\netsNBC';

outputFolder='Test10Output';

AzimuthRange=[0 360]; %ALWAYS wrt to the first receiver. 
ElevationRange=[15 85];
SatelliteRangeRange=[500e3 5000e3]; %range of satellite range values.


%create tests if they don't exist. 
if exist(['Images/' outputFolder],'directory')==0
%     mkdir(['Images/' outputFolder]);
    CNNcreateDataset(numTests,outputFolder,AzimuthRange,ElevationRange,SatelliteRangeRange);
end
    
%% TEST
%load nets. 
addpath(inputFolderWithBarcode);
load netz400
netz400=net;
load netz50
netz50=net;
load netz1200
netz1200=net;
rmpath(inputFolderWithBarcode);

addpath(inputFolderWithoutBarcode);
load netz400
netz400NBC=net;
load netz50
netz50NBC=net;
load netz1200
netz1200NBC=net;
rmpath(inputFolderWithoutBarcode);

load([outputFolder '.mat']);
digitDatasetPath=['Images/' outputFolder];
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','none');

Out400=predict(netz400,imds);
Out50=predict(netz50,imds);
Out1200=predict(netz1200,imds);

Directions=

Out400NBC=predict(netz400NBC,imds);
Out50NBC=predict(netz50NBC,imds);
Out1200NBC=predict(netz1200NBC,imds);


parfor i=1:numTests
    
    
end