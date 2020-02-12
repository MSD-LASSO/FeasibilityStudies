function [LocationsInTopocentricFrame,Error] = measureInTopocentricFrame(geodeticData,geodeticPoint,Sphere,geoError)
%Transforms Lat long altitude data into a Topocentric frame specified by
%geodeticPoint.
%INPUTS: Sphere - model of the Earth. If left blank, Spherical Earth is
%chosen.

if nargin<3
    Sphere=referenceSphere('Earth');
end

[xEast, yNorth, zUp]=geodetic2enu(geodeticData(:,1),geodeticData(:,2),geodeticData(:,3),...
    geodeticPoint(1),geodeticPoint(2),geodeticPoint(3),Sphere);
[xEastMax, yNorthMax, zUpMax]=geodetic2enu(geodeticData(:,1)+geoError(:,1),geodeticData(:,2)+geoError(:,2),geodeticData(:,3)+geoError(:,3),...
    geodeticPoint(1),geodeticPoint(2),geodeticPoint(3),Sphere);
[xEastMin, yNorthMin, zUpMin]=geodetic2enu(geodeticData(:,1)-geoError(:,1),geodeticData(:,2)-geoError(:,2),geodeticData(:,3)-geoError(:,3),...
    geodeticPoint(1),geodeticPoint(2),geodeticPoint(3),Sphere);

avgXerr=(abs(xEastMax-xEast)+abs(xEast-xEastMin))/2;
avgYerr=(abs(yNorthMax-yNorth)+abs(yNorth-yNorthMin))/2;
avgZerr=(abs(zUpMax-zUp)+abs(zUp-zUpMin))/2;


Error=[avgXerr, avgYerr, avgZerr];
LocationsInTopocentricFrame=[xEast yNorth zUp];
end

