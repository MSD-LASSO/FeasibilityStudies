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

% plot3([0 xEast], [0 yNorth],[0,zUp],'linewidth',3);
% hold on

% [la,ph,radius] = cart2sph(NewReference(1),NewReference(2),NewReference(3));
% E=[-sin(la) cos(la) 0; -sin(ph)*cos(la) -sin(ph)*sin(la) cos(ph); cos(ph)*cos(la) cos(ph)*sin(la) sin(ph)];
% R=6378137*[cos(ph)*cos(la); cos(ph)*sin(la); sin(ph)];
% 
% 
% 
% InTopoFrame=E*(Location-NewReference)';
% %x and y are switched. Different definition by Orekit. 
% [azimuth2,elevation2]=getAzEl([InTopoFrame(2) InTopoFrame(1) InTopoFrame(3)]);

% [las,phs,rads]= cart2sph(Location(1),Location(2),Location(3));
% earth = referenceSphere('Earth');
% [xNorth,yEast,zDown] = geodetic2ned(phs,las,rads,ph,la,radius,earth,'radians')

end

