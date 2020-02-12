%Authors: Anthony Iannuzzi, awi7573@rit.edu and Zoe-Jerusha Beepat, zeb6290@g.rit.edu
clearvars

host='127.0.0.1';
port=5010;
t = tcpclient(host, port);

%Needed Inputs:
%1 Integer,1 Integer, 1 Integer, 3 doubles, 3 doubles, 3n doubles, 3n
%doubles, k*m doubles, k*m doubles.

%where n is the number of stations
%k is equal to (n^2-n)/2


%Solver - Integer. Set to 0 for symbolic solver, 1 for Hyperboloid minimum
%         distance, 2 for minimum time difference difference. Default 1. 
%Number of stations - Integer.
%Number of time difference sets - Integer. This is the number of discrete
%                                 data sets from a given ground track. 
%Reference - 3 Doubles, a 1x3 matrix denoting the reference location 
%            [Lat,Long,altitude] decimal degrees and meters!
%Reference Error - a 1x3 matrix denoting the reference location error
%                  [dLat,dLong,daltitude]
%Receiver Locations - a nx3 matrix denoting station location error with
%                     respect to a reference, [Lat,Long,altitude].
%                     Given 4 stations: a, b, c, d, the order is:
%                     [Lata,Longa,Altitudea; Latb,Longb,Alttudeb; ...]
%Receiver Location Error - a nx3 matrix denoting station location error in
%                          the form [dLat,dLong,daltitude] error.
%Time Difference - kxm matrix denoting all time differences in the form:
%                  Given 3 stations, a, b, c. The time differences are
%                  [Tab; Tac; Tbc;] in units of microseconds 
%Time Difference Error - a kxm matrix denoting every time difference error
%                        between each station in the network.

%% Read values from TCP
h1=read(t);

%% Figure out whether bytes need to be flipped.
Nominal = typecast(h1(1:4), 'int32');
if abs(Nominal)>2
    Flipped = typecast(flip(h1(1:4)), 'int32');
    if abs(Flipped)>2
        error('ERROR 101: Byte Sequence unrecognized OR solver input was not 0,1,2');
    else
        flag=1;
    end
else
    flag=0;
end

%% Read integers
sizeInt=4;
numArgs=3;
strOfIntVars=zeros(numArgs,1);

for intIdx = 1:numArgs
    dataBytes = h1(1+(intIdx-1)*sizeInt : intIdx*sizeInt);
    strOfIntVars(intIdx) = typecast(ToFlipOrNot(dataBytes,flag), 'int32');
end
solver=strOfIntVars(1);
n=strOfIntVars(2);
m=strOfIntVars(3);
k=(n^2-n)/2;
finalPreviousIdx=intIdx*sizeInt;

%% Read Reference Data
%expect Lat Long Altitude then error in Lat Long Altitude.
ReferenceData=zeros(1,6);
sizeDouble=8;
numArgs=6;
for doubleIdx = 1:numArgs
    dataBytes = h1(finalPreviousIdx+1+(doubleIdx-1)*sizeDouble : finalPreviousIdx+doubleIdx*sizeDouble);
    ReferenceData(doubleIdx) = typecast(ToFlipOrNot(dataBytes,flag), 'double');
end
ReferenceGPS=ReferenceData(1:3);
ReferenceGPSerr=ReferenceData(4:6);
finalPreviousIdx=finalPreviousIdx+doubleIdx*sizeDouble;

%% Read Station Data
%expect Lat Long Altitude of station 1, then Lat Long Altitude of station
%2, etc. to station n
%then expect error in Lat Long Altitude of station 1, then error in Lat Long 
%Altitude of station 2, etc. to error in station n
ReceiverData=zeros(n,3);
sizeDouble=8;
numArgs=3*n;
row=1;
col=1;
for doubleIdx = 1:numArgs
    dataBytes = h1(finalPreviousIdx+1+(doubleIdx-1)*sizeDouble : finalPreviousIdx+doubleIdx*sizeDouble);
    ReceiverData(row,col) = typecast(ToFlipOrNot(dataBytes,flag), 'double');
    col=col+1;
    if col==4
        row=row+1;
        col=1;
    end
end
RecieversGPS=ReceiverData;
finalPreviousIdx=finalPreviousIdx+doubleIdx*sizeDouble;

ReceiverData=zeros(n,4);
sizeDouble=8;
numArgs=4*n;
row=1;
col=1;
for doubleIdx = 1:numArgs
    dataBytes = h1(finalPreviousIdx+1+(doubleIdx-1)*sizeDouble : finalPreviousIdx+doubleIdx*sizeDouble);
    ReceiverData(row,col) = typecast(ToFlipOrNot(dataBytes,flag), 'double');
    col=col+1;
    if col==5
        row=row+1;
        col=1;
    end
end
RecieverGPSerr=ReceiverData;
finalPreviousIdx=finalPreviousIdx+doubleIdx*sizeDouble;


%% Read Time Difference Data
%For 3 stations, expect Tab,Tac,Tbc, etc. for 1 point in sky
%then for each point in sky.
TimeData=zeros(k,2*m);
sizeDouble=8;
numArgs=2*k*m;
row=1;
col=1;
for doubleIdx = 1:numArgs
    dataBytes = h1(finalPreviousIdx+1+(doubleIdx-1)*sizeDouble : finalPreviousIdx+doubleIdx*sizeDouble);
    TimeData(row,col) = typecast(ToFlipOrNot(dataBytes,flag), 'double');
    row=row+1;
    if row==k+1
        row=1;
        col=col+1;
    end
end
TimeDifferenceList=TimeData(:,1:m);
TimeDifferenceErrList=TimeData(:,m+1:2*m);
finalPreviousIdx=finalPreviousIdx+doubleIdx*sizeDouble;




numTests=100;

Sphere=wgs84Ellipsoid;
zPlanes=[50e3 400e3 1200e3];
DebugMode=0;

addpath('TimeDiff')
addpath('LocateSat')


%% convert to TDoA inputs
Rx=ReferenceGPS(1,1);
Ry=ReferenceGPS(1,2);
Rz=ReferenceGPS(1,3);
GND=getStruct(RecieversGPS,RecieverGPSerr,ReferenceGPS,ReferenceGPSerr,Sphere);
RT=[GND(1).Topocoord; GND(2).Topocoord; GND(3).Topocoord];
RT_err=[GND(1).Topocoord_error; GND(2).Topocoord_error; GND(3).Topocoord_error];

%convert to time difference matrix. 
DistanceDiff=cell(m,2);
c=2.99792458e8;
TimeDifferenceList=TimeDifferenceList*c;
TimeDifferenceErrList=TimeDifferenceErrList*c;
means=cell(m,1);
stdDev=cell(m,1);
meanError=cell(m,1);
stdDevError=cell(m,1);
allData=cell(m,1);
for u=1:m
    DistanceDiff{u,1}=zeros(n,n);
    DistanceDiff{u,2}=zeros(n,n);
    p=1;
    for i=1:n
        for j=1:n
            if(i~=j && j>i)
                DistanceDiff{u,1}(i,j)=TimeDifferenceList(p,u);
                DistanceDiff{u,2}(i,j)=TimeDifferenceErrList(p,u);
                p=p+1;
            end
        end
    end
    
    %% Run TDoA
    [location,location_error,Data]=TDoAwithErrorEstimation(numTests,RT_err,DistanceDiff{u,2},ReferenceGPSerr,RT,DistanceDiff{u,1},ReferenceGPS,Sphere,0,zPlanes,DebugMode,'',solver,'Plots/TDoAsolutions');
    meansDeg{u}=Data.meanAzEl*180/pi;
    stdDevDeg{u}=Data.AzElstandardDeviation*180/pi;
    meanError{u}=(Data.nominalAzEl-Data.meanAzEl)*0; %zero out. doesn't seem like a good measure
    stdDevError{u}=Data.AzElstandardDeviation;
    allData{u}=Data;
    
end

%to do: test the topocentric error implementation. Finish translating
%inputs. Make TCP reader. 
        
% [X, Y, Z]=geodetic2enu(ReceiverLocations(:,1),ReceiverLocations(:,2),ReceiverLocations(:,3),Rx,Ry,Rz,Sphere);






%Figure out the inputs we are getting
%Are those inputs the same every time?

%24 inputs?
%we will send them all in a single byte stream.
%we will parse that stream in some manner


%for the server,
%need to install matlab if I want to work in there.
%work in the root. 

function Ary=ToFlipOrNot(Ary,flag)
    if flag==1
        Ary=flip(Ary);
    end
end
