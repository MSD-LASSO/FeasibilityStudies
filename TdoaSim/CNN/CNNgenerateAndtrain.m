clearvars
close all

addpath('../LocateSat')
addpath('../TimeDiff')
addpath('..');

%% Inputs
numPrimary=200;
numTests=[numPrimary numPrimary/10]; %number of tests done for both NO error and WITH error. so total number is twice this.
numVal=numTests*0.25;

[R1,R2,R3,Sphere]=getReceiverLocations;
[ClkError, RL_err]=getErrors;

% ReceiverError=[]; %same size as ReceiverLocations
ReceiverLocations=[R1;R2;R3];
GND=getStruct(ReceiverLocations,zeros(3,4),ReceiverLocations(1,:),ReceiverLocations(1,:)*0,Sphere);
receivers=[GND(1).Topocoord; GND(2).Topocoord; GND(3).Topocoord];

%Nueral network locations
inputFolderWithBarcode='C:\Users\awian\Desktop\MachineIntelligence\netsBC';
inputFolderWithoutBarcode='C:\Users\awian\Desktop\MachineIntelligence\netsNBC';

outputFolder='Test12';

AzimuthRange=[0 360]; %ALWAYS wrt to the first receiver. 
ElevationRange=[15 85];
SatelliteRangeRange=[500e3 5000e3]; %range of satellite range values.
zPlanes=[400e3 50e3 1200e3]; %primary must be listed first.


%% Generate Images
%create tests if they don't exist. 
if exist([outputFolder '.mat'],'file')==0
%     mkdir(['Images/' outputFolder]);
    CNNcreateDataset(numTests,outputFolder,AzimuthRange,ElevationRange,SatelliteRangeRange,zPlanes,RL_err,ClkError);
    CNNcreateDataset(numVal,[outputFolder 'val'],AzimuthRange,ElevationRange,SatelliteRangeRange,zPlanes,RL_err,ClkError);
end

%% Train
% RelativePath='C:\Users\awian\Desktop\MachineIntelligence';
RelativePath='MiniTest';
mkdir([RelativePath '\netsBC'])
mkdir([RelativePath '\netsNBC'])
mkdir([RelativePath '\plots'])

ImageFolder='400'; zz=1; names=0; netPath=[RelativePath '\Resnet101Modified.mat']; textT='netz400';
CNNtrain(ImageFolder,zz,names,netPath,textT,outputFolder,RelativePath);
ImageFolder='400NBC'; zz=1; names=1; netPath=[RelativePath '\Resnet101Modified.mat']; textT='netz400';
CNNtrain(ImageFolder,zz,names,netPath,textT,outputFolder,RelativePath);

ImageFolder='50'; zz=2; names=0; netPath=[RelativePath '\netsBC\netz400.mat']; textT='netz50';
CNNtrain(ImageFolder,zz,names,netPath,textT,outputFolder,RelativePath);
ImageFolder='50NBC'; zz=2; names=1; netPath=[RelativePath '\netsNBC\netz400.mat']; textT='netz50';
CNNtrain(ImageFolder,zz,names,netPath,textT,outputFolder,RelativePath);

ImageFolder='1200'; zz=3; names=0; netPath=[RelativePath '\netsBC\netz400.mat']; textT='netz1200';
CNNtrain(ImageFolder,zz,names,netPath,textT,outputFolder,RelativePath);
ImageFolder='1200NBC'; zz=3; names=1; netPath=[RelativePath '\netsNBC\netz400.mat']; textT='netz1200';
CNNtrain(ImageFolder,zz,names,netPath,textT,outputFolder,RelativePath);

Plots=findall(groot, 'Type', 'Figure');
textT={'netz400','netz400NBC','netz50','netz50NBC','netz1200','netz1200NBC'};
formats={'png'};
for i=1:length(Plots)
    for j=1:length(formats)
        saveas(Plots(i),[RelativePath '\plots\' textT{i}],formats{j});
    end
end