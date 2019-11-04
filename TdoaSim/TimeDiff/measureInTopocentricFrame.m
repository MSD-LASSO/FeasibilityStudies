function LocationsInTopocentricFrame = measureInTopocentricFrame(geodeticData,geodeticPoint,Sphere)
%Transforms Lat long altitude data into a Topocentric frame specified by
%geodeticPoint.
%INPUTS: Sphere - model of the Earth. If left blank, Spherical Earth is
%chosen.

if nargin<3
    Sphere=referenceSphere('Earth');
    Sphere.Radius=6378137;
end

[xEast, yNorth, zUp]=geodetic2enu(geodeticData(:,1),geodeticData(:,2),geodeticData(:,3),...
    geodeticPoint(1),geodeticPoint(2),geodeticPoint(3),Sphere);

LocationsInTopocentricFrame=[xEast yNorth zUp];
end

