function [azimuth, elevation,EarthCoordinates]=findDirection(lineFit,ReceiverLocation)
%this function will calculate the azimuth and elevation of the fitted line
%with respect to virtual reference point (point on Earth where line
%crosses).
%lineFit and ReceiverLocation is measured in Earth's frame.
%there are 2 intersections of the line with the ellipse. We use the one
%closer to the ReceiverLocation. 

[azimuth,elevation]=getAzEl(lineFit(2,:));

x0=lineFit(1,1);
y0=lineFit(1,2);
z0=lineFit(1,3);
mx=lineFit(2,1);
my=lineFit(2,2);
mz=lineFit(2,3);

syms x y z t
Symvars=[x y z];
% Eqnx=x0+mx/mz*(z-z0)-x;
% Eqny=y0+my/mz*(z-z0)-y;
Eqnx=x0+t*mx-x;
Eqny=y0+t*my-y;
Eqnz=z0+t*mz-z;

% R=6371e3;
R=6378137;
% EqnSphere1=sqrt(R^2-x^2-y^2)-z;
% EqnSphere2=-sqrt(R^2-x^2-y^2)-z;
Sphere=x^2+y^2+z^2-R^2;

surf=[Sphere,Eqnx,Eqny,Eqnz];

solution=Intersect(surf,Symvars);
EarthCoordinates=double([solution{2},solution{3},solution{4}]);

%choose point closest to the Receiver.
d=zeros(size(EarthCoordinates,1),1);
for i=1:size(EarthCoordinates,1)
    d(i)=norm(EarthCoordinates(i,:)-ReceiverLocation);
end
[~,I]=min(d);
EarthCoordinates=EarthCoordinates(I,:);

