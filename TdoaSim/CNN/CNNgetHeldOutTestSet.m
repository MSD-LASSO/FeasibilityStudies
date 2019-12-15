%This script evaluates the specified networks on a held out test set.
%Taking the data all the way to azimuth and elevation. Note, you must load
%at least 2 neural networks for 2 different planes for this to work.
clearvars
close all

addpath('../LocateSat')
addpath('../TimeDiff')
addpath('..');

%% Inputs
numTests=[1000 1000]; %number of tests done for both NO error and WITH error. so total number is twice this.

[R1,R2,R3,Sphere]=getReceiverLocations;
[ClkError, RL_err]=getErrors;
ClkError=ClkError*0;
RL_err=RL_err*0;

% ReceiverError=[]; %same size as ReceiverLocations
ReceiverLocations=[R1;R2;R3];
GND=getStruct(ReceiverLocations,zeros(3,4),ReceiverLocations(1,:),ReceiverLocations(1,:)*0,Sphere);
receivers=[GND(1).Topocoord; GND(2).Topocoord; GND(3).Topocoord];

%Nueral network locations
% RelativePath='C:\Users\awian\Desktop\MachineIntelligence\Test 4\trainedNetworks';
RelativePath='C:\Users\awian\Desktop\MachineIntelligence\trainedNetworks100k';
inputFolderWithBarcode=[RelativePath '\netsBC'];
inputFolderWithoutBarcode=[RelativePath '\netsNBC'];

% outputFolder='Test11TESTSETerrors';
outputFolder='Test25val';
% DataFolder='C:\Users\awian\Desktop\MachineIntelligence\10kTrainedResults';
% DataFolder='C:\Users\awian\Desktop\MachineIntelligence\Test 4\onTest25Val';
DataFolder='C:\Users\awian\Desktop\MachineIntelligence\trainedNetworks100k';

AzimuthRange=[0 360]; %ALWAYS wrt to the first receiver. 
ElevationRange=[15 85];
SatelliteRangeRange=[500e3 5000e3]; %range of satellite range values.
zPlanes=[400e3 50e3 1200e3]; %primary must be listed first.


%create tests if they don't exist. 
if exist(['Images/' outputFolder],'dir')==0
%     mkdir(['Images/' outputFolder]);
    CNNcreateDataset(numTests,outputFolder,AzimuthRange,ElevationRange,SatelliteRangeRange,zPlanes,RL_err,ClkError);
end
    
%% TEST
%load nets. 
disp('Getting CNN predictions')

load([outputFolder '.mat']);
digitDatasetPath=['Images/' outputFolder];

if exist([DataFolder '/' outputFolder 'CNNoutputs.mat'],'file')==2
    load([DataFolder '/' outputFolder 'CNNoutputs']);
    disp('Loaded previous computations')
else
    addpath(inputFolderWithBarcode);
    load netz400
    % netz400=net;
    imds = imageDatastore([digitDatasetPath '/400'], ...
        'IncludeSubfolders',true,'LabelSource','none');
    Out400=predict(net,imds);
    disp('Progress 1/6')

    load netz50
    imds = imageDatastore([digitDatasetPath '/50'], ...
        'IncludeSubfolders',true,'LabelSource','none');
    Out50=predict(net,imds);
    disp('Progress 2/6')
    % netz50=net;

    load netz1200
    imds = imageDatastore([digitDatasetPath '/1200'], ...
        'IncludeSubfolders',true,'LabelSource','none');
    Out1200=predict(net,imds);
    disp('Progress 3/6')
    % netz1200=net;
    rmpath(inputFolderWithBarcode);

    addpath(inputFolderWithoutBarcode);
    load netz400
    imds = imageDatastore([digitDatasetPath '/400NBC'], ...
        'IncludeSubfolders',true,'LabelSource','none');
    Out400NBC=predict(net,imds);
    disp('Progress 4/6')
    % netz400NBC=net;

    load netz50
    imds = imageDatastore([digitDatasetPath '/50NBC'], ...
        'IncludeSubfolders',true,'LabelSource','none');
    Out50NBC=predict(net,imds);
    disp('Progress 5/6')
    % netz50NBC=net;

    load netz1200
    imds = imageDatastore([digitDatasetPath '/1200NBC'], ...
        'IncludeSubfolders',true,'LabelSource','none');
    Out1200NBC=predict(net,imds);
    disp('Progress 6/6')
    % netz1200NBC=net;
    rmpath(inputFolderWithoutBarcode);

    save([DataFolder '/' outputFolder 'CNNoutputs'],'Out400','Out50','Out1200','Out400NBC','Out50NBC','Out1200NBC');
end

%% Get Directions
% Out400=predict(netz400,imds);
% Out50=predict(netz50,imds);
% Out1200=predict(netz1200,imds);
% Out400NBC=predict(netz400NBC,imds);
% Out50NBC=predict(netz50NBC,imds);
% Out1200NBC=predict(netz1200NBC,imds);
disp('Getting Directions')
if exist([DataFolder '/' outputFolder 'CNNandSymbolicDirections.mat'],'file')==2
    load([DataFolder '/' outputFolder 'CNNandSymbolicDirections.mat']);
else
    Direction=zeros(length(Out400),2);
    DirectionNBC=zeros(length(Out400NBC),2);
    errSyms=zeros(length(Out400),2);
    err=zeros(length(Out400),4);
    errNBC=zeros(length(Out400),4);

    load([outputFolder '.mat']);
    GTendgoal;
    distanceDiff=timeDiffs;
    ReceiverLocations;
    DebugMode=0;
    AdditionalTitleStr='CNN tests';
    for i=1:length(Out400)
%         X=[Out400(i,1)*400e3 Out50(i,1)*50e3 Out1200(i,1)*1200e3]';
%         Y=[Out400(i,2)*400e3 Out50(i,2)*50e3 Out1200(i,2)*1200e3]';
%         XNBC=[Out400NBC(i,1)*400e3 Out50NBC(i,1)*50e3 Out1200NBC(i,1)*1200e3]';
%         YNBC=[Out400NBC(i,2)*400e3 Out50NBC(i,2)*50e3 Out1200NBC(i,2)*1200e3]';
        X=Out400(i,1)*400e3;
        Y=Out400(i,2)*400e3;
        XNBC=Out400NBC(i,1)*400e3;
        YNBC=Out400NBC(i,2)*400e3;
        n=size(X,1);
        t=[1:1:n]';
        [az1, el1]=getAzEl([Y(1) X(1) 400e3]);
        az2=az1; az3=az1; el2=el1; el3=el1;
%         [az2, el2]=getAzEl([Y(2) X(2) 50e3]);
%         [az3, el3]=getAzEl([Y(3) X(3) 1200e3]);
        
%         [Mx, errX]=LinearRegressionFit(t,X);
%         [My, errY]=LinearRegressionFit(t,Y);
%         [Mz, errZ]=LinearRegressionFit(t,[50e3; 400e3; 1200e3]);
%         [az,el]=getAzEl([My Mx Mz]);
        Direction(i,:)=[mean([az1 az2 az3]) mean([el1 el2 el3])]*180/pi;
        RSME(i,:)=(Out400(i,:)-GT(i,:,1)).^2;
%         err(i,:)=[0, 0, errX, errY, errZ];
        err(i,:)=[Direction(i,:)-GTendgoal(i,:) std([az1 az2 az3])*180/pi std([el1 el2 el3])*180/pi];
        
        [az1, el1]=getAzEl([YNBC(1) XNBC(1) 400e3]);
%         [az2, el2]=getAzEl([YNBC(2) XNBC(2) 50e3]);
%         [az3, el3]=getAzEl([YNBC(3) XNBC(3) 1200e3]);
        az2=az1; az3=az1; el2=el1; el3=el1;
%         [MxNBC,errX]=LinearRegressionFit(t,XNBC);
%         [MyNBC,errY]=LinearRegressionFit(t,YNBC);
%         [az,el]=getAzEl([MyNBC MxNBC Mz]);
%         DirectionNBC(i,:)=[az,el]*180/pi;
        DirectionNBC(i,:)=[mean([az1 az2 az3]) mean([el1 el2 el3])]*180/pi;
        RSMENBC(i,:)=(Out400NBC(i,:)-GT(i,:,1)).^2;
%         errNBC(i,:)=[0, 0, errX, errY, errZ];
        errNBC(i,:)=[DirectionNBC(i,:)-GTendgoal(i,:) std([az1 az2 az3]) std([el1 el2 el3])];
        
%         tempDistanceMatrix=[0 distanceDiff(i,1) distanceDiff(i,2); 0 0 distanceDiff(i,3); 0 0 0];
%         locations=TDoA(receivers,tempDistanceMatrix,ReceiverLocations(1,:),Sphere,1e-5,[50e3 400e3 1200e3],DebugMode,AdditionalTitleStr);
%         temp=GTendgoal(i,:)*pi/180;
%         RM=getAzElRotationMatrix(temp(1),temp(2));
%         expected=RM*[GTrng(i); 0; 0];
%         [az, el]=geo2AzEl(expected,locations(2,:),ReceiverLocations(1,:));
%         expectedAzEl=[az el 0];
%         actualAzEl=locations(1,:);
%         errSyms(i,:)=(expectedAzEl(1:2)-actualAzEl(1:2))*180/pi;
%         disp(i/length(Out400)*100)
    end
%     err(:,1:2)=Direction-GTendgoal;
%     errNBC(:,1:2)=DirectionNBC-GTendgoal;
    Ind=abs(err)>180;
    err(Ind)=360-abs(err(Ind));
    Ind=abs(errNBC)>180;
    errNBC(Ind)=360-abs(errNBC(Ind));
%     Ind=abs(errSyms)>180;
%     errSyms(Ind)=360-abs(errSyms(Ind));
%     load([outputFolder 'SymbolicDirections']);

%     save([DataFolder '/' outputFolder 'CNNandSymbolicDirections'],'Direction','DirectionNBC','errSyms','err','errNBC');
end


CNN1=quantile(abs(err),[0 0.25 0.5 0.75 1])
CNNnbc=quantile(abs(errNBC),[0 0.25 0.5 0.75 1])
sqrt(sum(sum(RSME)))/length(Out400)
sqrt(sum(sum(RSMENBC)))/length(Out400NBC)
% Sym=quantile(abs(errSyms),[0 0.25 0.5 0.75])

% i=863;
% temp=GTendgoal(i,:)*pi/180;
% RM=getAzElRotationMatrix(temp(1),temp(2));
% expected=RM*[10e3; 0; 0];

% DebugMode=1;
% h=figure()
% plot3(receivers(:,1),receivers(:,2),receivers(:,3),'s','color','red','linewidth',3)
% hold on
% plot3(expected(1),expected(2),expected(3),'.','color','green','MarkerSize',25)
% xlabel('x East (m)')
% ylabel('y North (m)')
% zlabel('z Zenith (m)')
% title('Test Setup of a Crude Ground Track in the Topocentric Frame')
% axis equal
% h1=gca;
% set(h1,'FontSize',14);
% Title=h1.Title;
% Title.FontSize=18;
% grid on
% 
% temp=Direction(i,:)*pi/180;
% RM=getAzElRotationMatrix(temp(1),temp(2));
% Out=RM*[500e3; 0; 0];
% plot3([0 Out(1)],[0 Out(2)],[0 Out(3)],'linewidth',3);
% 
% legend('Receiver Locations','Satellite Locations','CNN Fit')
% load([outputFolder '.mat'])
% distanceDiff=timeDiffs;
% AdditionalTitleStr='CNN tests';
% tempDistanceMatrix=-[0 distanceDiff(i,1) distanceDiff(i,2); 0 0 distanceDiff(i,3); 0 0 0];
% locations=TDoA(receivers,tempDistanceMatrix,ReceiverLocations(1,:),Sphere,1e-5,[50e3 400e3 1200e3],DebugMode,AdditionalTitleStr);
% 
% [az, el]=geo2AzEl(expected,locations(2,:),ReceiverLocations(1,:));
% expectedAzEl=[az el 0];
% actualAzEl=locations(1,:);
% errSyms(i,:)=(expectedAzEl(1:2)-actualAzEl(1:2))*180/pi;
% disp(i/length(Out400)*100)
% 


figure()
subplot(1,2,1)
plot(abs(err(:,1)),'.');
hold on
plot(abs(errNBC(:,1)),'.');
plot(abs(errSyms(:,1)),'.');
title('Azimuth error with Input Error')
xlabel('Test Number')
ylabel('Azimuth Error (deg)')
ylim([0 180])

subplot(1,2,2)
plot(abs(err(:,2)),'.');
hold on
plot(abs(errNBC(:,2)),'.');
plot(abs(errSyms(:,2)),'.');
title('Azimuth error with Input Error')
xlabel('Test Number')
ylabel('Elevation Error (deg)')
legend('Bar Code CNN','CNN','Symbolic')
ylim([0 90])

figure()
plot(GT(:,1,1),GT(:,2,1),'.')
hold on
plot(Out400(:,1),Out400(:,2),'.')
plot(Out400NBC(:,1),Out400NBC(:,2),'.')

grid on
xlabel('Normalized X Value')
ylabel('Normalized Y Value')
title('Distribution of Ground Truth and CNN outputs')
legend('Ground Truth','CNN trained','CNN untrained')


figure()
plot(GTendgoal(:,1),GTendgoal(:,2),'.')

hold on
plot(Direction(:,1),Direction(:,2),'.')
plot(DirectionNBC(:,1),DirectionNBC(:,2),'.')
grid on
xlabel('Azimuth (deg)')
ylabel('Elevation (deg)')
title('Distribution of Ground Truth Directions and CNN outputs')
legend('Ground Truth','CNN trained','CNN untrained')


GraphSaver({'fig','png'},'../Plots/CNNoutputs',0);