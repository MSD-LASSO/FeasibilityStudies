function [azimuth,elevation] = geo2AzEl(Location,Reference)
%Location is XYZ in a frame relative to a moving Earth.
%Reference is XYZ in a frame relative to a moving Earth.

[la,ph,radius] = cart2sph(Reference(1),Reference(2),Reference(3));
E=[-sin(la) cos(la) 0; -sin(ph)*cos(la) -sin(ph)*sin(la) cos(ph); cos(ph)*cos(la) cos(ph)*sin(la) sin(ph)];
R=6371e3*[cos(ph)*cos(la); cos(ph)*sin(la); sin(ph)];



InTopoFrame=E*(Location-Reference)';
%x and y are switched. Different definition by Orekit. 
[azimuth,elevation]=getAzEl([InTopoFrame(2) InTopoFrame(1) InTopoFrame(3)]);

% [las,phs,rads]= cart2sph(Location(1),Location(2),Location(3));
% earth = referenceSphere('Earth');
% [xNorth,yEast,zDown] = geodetic2ned(phs,las,rads,ph,la,radius,earth,'radians')

end

