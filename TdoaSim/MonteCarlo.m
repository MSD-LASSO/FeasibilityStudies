function [means,stdDev,meanError,stdDevError, Data]=MonteCarlo(numTests,Az,El,Rng,ReceiverLocations,RL_err,ClkError,DebugMode,solver,useAbsoluteError,TR)
%This function perturbates the given parameters by their error,
%approximated as a Gaussian. This will give us insight into approximate
%uncertainties.

%ASSUMES that RL_err is error in rectilinear coordinates with units of m.
%It is not expecting lat, long, altitude error.

% numTests=numTests+1; %we always sample 0 error as a baseline. 
zPlanes=[50e3 400e3 1200e3];
%% Invariants    
Sphere=wgs84Ellipsoid;
ReceiverError=[zeros(3,3) ClkError];
%Use this if you want to input lat,long,altitude error!
% ReceiverError=[RL_err ClkError]; 
Rx=ReceiverLocations(1,1);
Ry=ReceiverLocations(1,2);
Rz=ReceiverLocations(1,3);
Reference=[Rx,Ry,Rz];
GND=getStruct(ReceiverLocations,ReceiverError,Reference,ReceiverError(1,:),Sphere);

%Use these only when inputting rectilinear error (NOT geo error).
GND(1).ECFcoord_error=RL_err(1,:);
GND(2).ECFcoord_error=RL_err(2,:);
GND(3).ECFcoord_error=RL_err(3,:);

RT=[GND(1).Topocoord; GND(2).Topocoord; GND(3).Topocoord];

[lat, long, h]=enu2geodetic(Rng*cosd(El)*sind(Az),Rng*cosd(El)*cosd(Az),Rng*sind(El),...
   Rx,Ry,Rz,Sphere);

SAT=getStruct([lat long h],zeros(1,4),ReceiverLocations(1,:),zeros(1,4),Sphere);
expected=SAT.Topocoord;

%% Set up nominal conditions
[TimeDiff, TimeDiffErr]=timeDiff3toMatrix(GND,SAT);
% [X, Y, Z]=geodetic2enu(ReceiverLocations(:,1),ReceiverLocations(:,2),ReceiverLocations(:,3),Rx,Ry,Rz,Sphere);

%% Estimate using relative error if asked
if useAbsoluteError==0
    TR_err=[1e-5*pi/180 1e-5*pi/180 3];
    [location,location_error,Data]=TDoAwithErrorEstimation(numTests,ReceiverError(:,1:3),TimeDiffErr*3e8,TR_err,RT,TimeDiff*3e8,TR,Sphere,0,zPlanes,DebugMode,'',solver,'DebuggingMonte');
    means=Data.meanAzEl;
    stdDev=Data.AzElstandardDeviation;
    meanError=(Data.nominalAzEl-Data.meanAzEl)*0; %zero out. doesn't seem like a good measure
    stdDevError=Data.AzElstandardDeviation;
    return
end


%% Run No error.
cols=3;
%here to optimize parfor.
% Data=cell(1,5); %Data contains DistanceDiff, Receiver locations, the TDoA output locations, and the estimated az el. 
DDs=zeros(numTests,3);
Rlocations=cell(numTests,1);
TDoAsolution=cell(numTests,1);
EstAzEl=zeros(numTests,2);
Errors=zeros(numTests,2);

% [actualAzEl,err,locations]=doTest(RT,TimeDiff*3e8,Reference,Sphere,zPlanes,DebugMode,1,Az,El,expected,solver);
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
    
    if abs(err(1,1))>pi
        if err(1,1)>pi
            %actual is 359 and estimated is 2 degrees
            %error is calc at -357 degrees. Should be 3 degrees.
            Errors(i,:)=[2*pi-err(1,1) err(1,2)];
        else
            %actual is 2 degrees, estimated is 359 degrees
            %error is calc at 357 degrees. Should be -3 degrees
            Errors(i,:)=[err(1,1)+2*pi err(1,2)];
        end
    else
        Errors(i,:)=err(1,1:2); 
    end
    
    
    
end
%% Determine if the Estimated Azimuth values vary across 0. (i.e. we have 5 degrees and 359 degrees)
[EstAzEl,flag]=moveAzimuthReference(EstAzEl);
%if flag=1, we must convert the final answers back to the original
%reference.

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

if flag==1
    if means(1)<0
        means(1)=means(1)+2*pi;
    end
end

if DebugMode>=0
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
