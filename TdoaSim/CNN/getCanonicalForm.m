function Limits=getCanonicalForm(zPlanes,minElevation)
%returns max X Y values for all speicified z Planes.

if size(zPlanes,2)>size(zPlanes,1)
    %if zPlane is a row vector, change it to a column vector.
    zPlanes=zPlanes';
end

maxR=zPlanes/sind(minElevation); %minimum elevation
maxXY=maxR*cosd(minElevation);
Limits=[-maxXY maxXY];
end