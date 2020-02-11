%Authors: Anthony Iannuzzi, awi7573@rit.edu and Zoe-Jerusha Beepat, zeb6290@g.rit.edu

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
numTests=100;
n
k=n^2-n;
m
Sphere=wgs84Ellipsoid;
zPlanes=[50e3 400e3 1200e3];
DebugMode=0;
RecieversGPS
RecieverGPSerr
TimeDifferenceList
TimeDifferenceErrList
ReferenceGPS
ReferenceGPSerr

%% convert to TDoA inputs
Rx=ReferenceGPS(1,1);
Ry=ReferenceGPS(1,2);
Rz=ReferenceGPS(1,3);
GND=getStruct(RecieversGPS,RecieverGPSerr,ReferenceGPS,ReferenceGPSerr,Sphere);
RT=[GND(1).Topocoord; GND(2).Topocoord; GND(3).Topocoord];
RT_err=[GND(1).Topocoord; GND(2).Topocoord; GND(3).Topocoord];

%convert to time difference matrix. 
DistanceDiff=cell(m,2);
c=2.99792458e8;
TimeDifferenceList=TimeDifferenceList*c;
TimeDifferenceErrList=TimeDifferenceErrList*c;
for u=1:m
    DistanceDiff{u,1}=zeros(n,n);
    DistanceDiff{u,2}=zeros(n,n);
    p=1;
    for i=1:n
        for j=1:n
            DistanceDiff{u,1}(i,j)=TimeDifferenceList(p,u);
            DistanceDiff{u,2}(i,j)=TimeDifferenceErrList(p,u);
            p=p+1;
        end
    end
end

%to do: test the topocentric error implementation. Finish translating
%inputs. Make TCP reader. 
        
% [X, Y, Z]=geodetic2enu(ReceiverLocations(:,1),ReceiverLocations(:,2),ReceiverLocations(:,3),Rx,Ry,Rz,Sphere);




%% Run TDoA
[location,location_error,Data]=TDoAwithErrorEstimation(numTests,ReceiverError(:,1:3),TimeDiffErr*3e8,ReferencError,ReceiverLocations,TimeDiff*3e8,Reference,Sphere,0,zPlanes,DebugMode,'',solver);
    means=Data.meanAzEl;
    stdDev=Data.AzElstandardDeviation;
    meanError=(Data.nominalAzEl-Data.meanAzEl)*0; %zero out. doesn't seem like a good measure
    stdDevError=Data.AzElstandardDeviation;

%Figure out the inputs we are getting
%Are those inputs the same every time?

%24 inputs?
%we will send them all in a single byte stream.
%we will parse that stream in some manner


%for the server,
%need to install matlab if I want to work in there.
%work in the root. 