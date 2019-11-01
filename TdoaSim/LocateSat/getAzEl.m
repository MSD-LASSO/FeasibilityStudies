function [azimuth,elevation] = getAzEl(r)
%This function returns the azimuth and elevation of the given point.
x=r(1);
y=r(2);
z=r(3);
rb=sqrt(x^2+y^2);
elevation=atan2(z,rb);
azimuth=atan2(y,x);
if azimuth<0
    azimuth=2*pi+azimuth; %define is 0 to 360.
end
end

