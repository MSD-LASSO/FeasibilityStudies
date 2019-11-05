function [azimuth,elevation] = geo2AzEl(Location,Reference,Sphere)
%Location is XYZ in a frame relative to a moving Earth.
%Reference is XYZ in a frame relative to a moving Earth.

if nargin<3
    Sphere=referenceSphere('Earth');
    Sphere.Radius=6378137;
end

X=Location(1);
Y=Location(2);
Z=Location(3);
Xref=Reference(1);
Yref=Reference(2);
Zref=Reference(3);

[lat0,lon0,h0] = ecef2geodetic(Sphere,Xref,Yref,Zref);
[xEast,yNorth,zUp] = ecef2enu(X,Y,Z,lat0,lon0,h0,Sphere);
[azimuth,elevation]=getAzEl([yNorth xEast zUp]);



[la,ph,radius] = cart2sph(Reference(1),Reference(2),Reference(3));
E=[-sin(la) cos(la) 0; -sin(ph)*cos(la) -sin(ph)*sin(la) cos(ph); cos(ph)*cos(la) cos(ph)*sin(la) sin(ph)];
R=6378137*[cos(ph)*cos(la); cos(ph)*sin(la); sin(ph)];



InTopoFrame=E*(Location-Reference)';
%x and y are switched. Different definition by Orekit. 
[azimuth2,elevation2]=getAzEl([InTopoFrame(2) InTopoFrame(1) InTopoFrame(3)]);

% [las,phs,rads]= cart2sph(Location(1),Location(2),Location(3));
% earth = referenceSphere('Earth');
% [xNorth,yEast,zDown] = geodetic2ned(phs,las,rads,ph,la,radius,earth,'radians')

end

