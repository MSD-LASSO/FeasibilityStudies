function [azimuth,elevation] = geo2AzEl(Location,NewReference,CurrentReference,Sphere)
%Location and New Reference are [X Y Z] measured in the ECEF frame if
%CurrentReference = [0 0 0] and in a Topocentric Frame referenced at
%coordinates CurrentReference in the ECEF Frame.

if nargin<3
    CurrentReference=[0 0 0];
end


if nargin<4
    Sphere=referenceSphere('Earth');
end

X=Location(1);
Y=Location(2);
Z=Location(3);
Xref=NewReference(1);
Yref=NewReference(2);
Zref=NewReference(3);

if sum(CurrentReference)~=0
    %Transform New Reference from Topocentric Frame to a Geodetic Point.
    [lat0,lon0,h0]=enu2geodetic(Xref,Yref,Zref,CurrentReference(1),CurrentReference(2),CurrentReference(3),Sphere);
    %remeasure location in the ECEF frame.
    [X, Y, Z]=enu2ecef(X,Y,Z,CurrentReference(1),CurrentReference(2),CurrentReference(3),Sphere);
else
    %Transform New Reference from ECEF to a Geodetic Point.
    [lat0,lon0,h0] = ecef2geodetic(Sphere,Xref,Yref,Zref);
end

%Convert the location to a Topocentric Frame whose origin is at the
%NewReference.
[xEast,yNorth,zUp] = ecef2enu(X,Y,Z,lat0,lon0,h0,Sphere);
[azimuth,elevation]=getAzEl([yNorth xEast zUp]);

end

