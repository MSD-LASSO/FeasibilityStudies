function [means,stdDev,meanError,stdDevError, Data]=MonteCarlo(numTests,Az,El,Rng,ReceiverLocations,RL_err,ClkError,DebugMode,solver)
%This function perturbates the given parameters by their error,
%approximated as a Gaussian. This will give us insight into approximate
%uncertainties.
% numTests=numTests+1; %we always sample 0 error as a baseline. 
zPlanes=[50e3 400e3 1200e3];
%% Invariants    
Sphere=wgs84Ellipsoid;
ReceiverError=[zeros(3,3) ClkError];
Rx=ReceiverLocations(1,1);
Ry=ReceiverLocations(1,2);
Rz=ReceiverLocations(1,3);
Reference=[Rx,Ry,Rz];
GND=getStruct(ReceiverLocations,ReceiverError,Reference,ReceiverError(1,:),Sphere);
RT=[GND(1).Topocoord; GND(2).Topocoord; GND(3).Topocoord];

[lat, long, h]=enu2geodetic(Rng*cosd(El)*sind(Az),Rng*cosd(El)*cosd(Az),Rng*sind(El),...
   Rx,Ry,Rz,Sphere);

SAT=getStruct([lat long h],zeros(1,4),ReceiverLocations(1,:),zeros(1,4),Sphere);
expected=SAT.Topocoord;

%% Set up nominal conditions
[TimeDiff, TimeDiffErr]=timeDiff3toMatrix(GND,SAT);
% [X, Y, Z]=geodetic2enu(ReceiverLocations(:,1),ReceiverLocations(:,2),ReceiverLocations(:,3),Rx,Ry,Rz,Sphere);
%% Run No error.
cols=3;
%here to optimize parfor.
% Data=cell(1,5); %Data contains DistanceDiff, Receiver locations, the TDoA output locations, and the estimated az el. 
DDs=zeros(numTests,3);
Rlocations=cell(numTests,1);
TDoAsolution=cell(numTests,1);
EstAzEl=zeros(numTests,2);
Errors=zeros(numTests,2);

[actualAzEl,err,locations]=doTest(RT,TimeDiff*3e8,Reference,Sphere,zPlanes,DebugMode,1,Az,El,expected,solver);
% DDs(1,:)=[TimeDiff(1,2), TimeDiff(1,3), TimeDiff(2,3)]*3e8;
% Rlocations{1}=RT;
% TDoAsolution{1}=locations;
% EstAzEl(1,:)=actualAzEl(1,1:2);
% Errors(1,:)=err(1,1:2);

%% Run all other tests
%can be parfor. 
for i=1:numTests

    %% Apply the Noise
    distanceDiff=normrnd(TimeDiff,TimeDiffErr)*3e8; %model error as a Gaussian.
    DDs(i,:)=[distanceDiff(1,2), distanceDiff(1,3), distanceDiff(2,3)];
%     RL=normrnd([X Y Z],RL_err);
    RL=normrnd(RT,RL_err);
    Rlocations{i}=RL;
    
    [actualAzEl,err,locations]=doTest(RL,distanceDiff,Reference,Sphere,zPlanes,DebugMode,i,Az,El,expected,solver);
    
    TDoAsolution{i}=locations;
    EstAzEl(i,:)=actualAzEl(1,1:2);
    Errors(i,:)=err(1,1:2);
    
    
end

%% Final data processing
Data.DistanceDiff=DDs;
Data.ReceiverLocations=Rlocations;
Data.TDoAlocations=TDoAsolution;
Data.EstAzEl=EstAzEl;
Data.Error=Errors;

means=nanmean(EstAzEl);
stdDev=nanstd(EstAzEl);

meanError=nanmean(Errors);
stdDevError=nanstd(Errors);

if DebugMode>=0
%     AzX=[min(EstAzEl(:,1)) max(EstAzEl(:,1))];
%     ElX=[min(EstAzEl(:,2)) max(EstAzEl(:,2))];
%     AzR=normpdf(AzX,means(1),stdDev(1));
%     ElR=normpdf(ElX,means(2),stdDev(2));
%    plotHistograms(Data,[Az El]);
end
end

function [actualAzEl,err,locations]=doTest(RL,distanceDiff,Reference,Sphere,zPlanes,DebugMode,i,Az,El,expected,solver)

% locations=TDoA(RL,distanceDiff,Reference,Sphere,10,zPlanes,DebugMode,['Iteration: ' num2str(i) ' for Azimuth/Elevation ' num2str(Az) ' and ' num2str(El)]);
locations=TDoA(RL,distanceDiff,Reference,Sphere,10,zPlanes,DebugMode,['Iteration: ' num2str(i) ' for Azimuth/Elevation ' num2str(Az) ' and ' num2str(El)],solver);
    
    if isempty(locations)==0 && size(locations,1)==4
        %if we don't have lineFits, then we don't have a solution

        [az, el]=geo2AzEl(expected,locations(2,:),Reference);
        expectedAzEl=[az el 0];
        actualAzEl=locations(1,:);
        
        err=expectedAzEl-actualAzEl;
    else
        %nan will get ignored in the plot.
        actualAzEl=nan(1,3);
        err=nan(1,3);
    end
    
end
