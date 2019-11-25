function [R1,R2,R3,Sphere] = getReceiverLocations()
%Currently no inputs. This can change to several discrete locations with an
%if statement and single input arguement. 
R1=[0.751981147060969	-1.355756142252390	0.000000000000000]*180/pi;
R2=[0.754139962266053	-1.360500226411991	0.000000000000000]*180/pi;
R3=[0.745258941633743	-1.351035428051473	0.000000000000000]*180/pi;
Sphere=wgs84Ellipsoid;
end

