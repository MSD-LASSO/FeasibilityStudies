function [means,stdDev,meanError,stdDevError, Data]=MonteCarlo(numTests,Az,El,Rng,ReceiverLocations,RL_err,ClkError,DebugMode,solver,useAbsoluteError,referenceStation)
%This function perturbates the given parameters by their error,
%approximated as a Gaussian. This will give us insight into approximate
%uncertainties.

%INPUTS:
%numTests -- the number of times to run the simulation with perturbated
%errors.

%Az -- nominal azimuth of the satellite (deg)
%El -- nominal elevation of the satellite (deg)
%Rng -- nominal range of the satellite (m)

%ReceiverLocations -- Lat Long altitude of stations. 

%RL_err is the error in the location of the receivers in Rectilinear format
%with units of (m).
%It is not expecting lat, long, altitude error.

%ClkError -- error in clocks at each station. This includes absolute errors
%and relative errors.

%DebugMode -- set to 1 to see TDoA plots. Set to 0 to see nothing

%solver -- the solver TDoA will use. =0 symbolic, =1 distance least
%squares, =2 time difference least squares. See TDoA.m

%UseAbsoluteError -- =1 to measure error based on Az, El, Rng. =0 to
%measure a relative error based on the Std. Dev. from numTest outputs.
%Default value of 1.

%referenceStation -- station that satellite az,el,rng is measured from.
%Default value is the FIRST station


if nargin<11
   referenceStation=ReceiverLocations(1,:); 
end
if nargin<10
    useAbsoluteError=1;
end

%% Manual switching of error mode
ReceiverError=[zeros(3,3) ClkError];

%Use this if you want to input lat,long,altitude error!
% ReceiverError=[RL_err ClkError]; 


%% These our are hueristically chosen "best" planes.
zPlanes=[50e3 400e3 1200e3];
%% Invariants    
Sphere=wgs84Ellipsoid;

Rx=referenceStation(1);
Ry=referenceStation(2);
Rz=referenceStation(3);
GND=getStruct(ReceiverLocations,ReceiverError,referenceStation,ReceiverError(1,:),Sphere);

%Use these only when inputting rectilinear error (NOT geo error).
GND(1).ECFcoord_error=RL_err(1,:);
GND(2).ECFcoord_error=RL_err(2,:);
GND(3).ECFcoord_error=RL_err(3,:);

%TDoA can use either Topocentric coordinates or Earth Fixed coordinates.
%Typically, topocentric makes more sense.
RT=[GND(1).Topocoord; GND(2).Topocoord; GND(3).Topocoord];

%Get the lat, long, and altitude of the satellite.
[lat, long, h]=enu2geodetic(Rng*cosd(El)*sind(Az),Rng*cosd(El)*cosd(Az),Rng*sind(El),...
   Rx,Ry,Rz,Sphere);

% get the satellite object. There is no "error" associated with where this
% satellite is in the sky. 
SAT=getStruct([lat long h],zeros(1,4),referenceStation,zeros(1,4),Sphere);
expected=SAT.Topocoord;

%% Set up nominal conditions
[TimeDiff, TimeDiffErr]=timeDiff3toMatrix(GND,SAT);

%% Estimate using relative error if asked
if useAbsoluteError==0
    TR_err=[1e-5*pi/180 1e-5*pi/180 3];
    [location,location_error,Data]=TDoAwithErrorEstimation(numTests,ReceiverError(:,1:3),TimeDiffErr*3e8,TR_err,RT,TimeDiff*3e8,referenceStation,Sphere,0,zPlanes,DebugMode,'',solver,'DebuggingMonte');
    means=Data.meanAzEl;
    stdDev=Data.AzElstandardDeviation;
    meanError=(Data.nominalAzEl-Data.meanAzEl)*0; %zero out. doesn't seem like a good measure
    stdDevError=Data.AzElstandardDeviation;
    return
end


%% Run a test with no Error.

%Uncomment this line and the lines below Errors to run a single test WITH
%NO  input error. You can use this to get an idea of how much error is in
%inherently in the TDoA algorithm due to numerical precision, and
%approximating the intersection of the hyperboloids as a line. 
%numTests=numTests+1;

%for each test, record the following WITH the random error included
DDs=zeros(numTests,3); %record the distance differences
Rlocations=cell(numTests,1); %record the receiver locations
TDoAsolution=cell(numTests,1); %the direction the math thought
EstAzEl=zeros(numTests,2); %the azimuth and elevation
Errors=zeros(numTests,2); %the error in azimuth and elevation.

% [actualAzEl,err,locations]=doTest(RT,TimeDiff*3e8,referenceStation,Sphere,zPlanes,DebugMode,1,Az,El,expected,solver);
% DDs(1,:)=[TimeDiff(1,2), TimeDiff(1,3), TimeDiff(2,3)]*3e8;
% Rlocations{1}=RT;
% TDoAsolution{1}=locations;
% EstAzEl(1,:)=actualAzEl(1,1:2);
% Errors(1,:)=err(1,1:2);

%% Run all other tests
%can be parfor. Don't run parfors in parfors. Typically MonteCarlo is
%called by a script already running in parfor. 
for i=1:numTests

    %% Apply the Noise
    %all input error is modeled as a Gaussian.
    distanceDiff=normrnd(TimeDiff,TimeDiffErr)*3e8; %simulates the "time synchronization error"
    DDs(i,:)=[distanceDiff(1,2), distanceDiff(1,3), distanceDiff(2,3)];
    RL=normrnd(RT,RL_err); %simulates the GPS "recorded" 
    Rlocations{i}=RL;
    
    %Run the test
    [actualAzEl,err,locations]=doTest(RL,distanceDiff,referenceStation,Sphere,zPlanes,DebugMode,i,Az,El,expected,solver);
    
    TDoAsolution{i}=locations;
    EstAzEl(i,:)=actualAzEl(1,1:2);
    
    
    %% Adjust errors when azimuth is close to 0.
    if abs(err(1,1))>pi
        if err(1,1)>pi
            %Example:
            %actual is 359 and estimated is 2 degrees
            %error is calc at -357 degrees. Should be 3 degrees.
            Errors(i,:)=[2*pi-err(1,1) err(1,2)];
        else
            %Example:
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

%a nan means we found no solution. 
means=nanmean(EstAzEl);
stdDev=nanstd(EstAzEl);

meanError=nanmean(Errors);
stdDevError=nanstd(Errors);


%if flag==1, then we shifted the azimuth reference. This will shift the
%azimuth reference back, if needed 
if flag==1
    if means(1)<0
        means(1)=means(1)+2*pi;
    end
end

if DebugMode>=0
   plotHistograms(Data,[Az El],'',0); %'' and 0 mean don't save the histograms, just make them. 
end
end

function [actualAzEl,err,locations]=doTest(RL,distanceDiff,Reference,Sphere,zPlanes,DebugMode,i,Az,El,expected,solver)

    locations=TDoA(RL,distanceDiff,Reference,Sphere,10,zPlanes,DebugMode,['Iteration: ' num2str(i) ' for Azimuth/Elevation ' num2str(Az) ' and ' num2str(El)],solver);
   
    %if we don't have lineFits, then we don't have a solution
    if isempty(locations)==0 && size(locations,1)==4
        
        %record our solution
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
