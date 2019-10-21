function [RM,Offset,distance] = getRMandOffsets(R1,R2)
%Function will return the full coordinate transformation between a fixed
%coordinate system and a body coordinate frame.
%The body coordinate frame is located in the middle of position vector
%between R1 and R2
%INPUTS: R1 and R2 are coordinates in the fixed coordinate frame.
%OUTPUTS: rotation matrix, coordinates of origin of body frame (Offset)
%w.r.t. to the fixed frame that can transform any point in the body frame
%to the fixed frame. Distance is the absolute distance between R1 and R2.

%how to transform. RM*(x',y',z')-Offset where [x' y' z'] is the coordinates
%the body frame. 

%distance between R1 and R2
distanceVector=R2-R1;
distance=norm(distanceVector);
unitVector=distanceVector/distance;

%halfway between R1 and R2 is the origin.
Offset=R1+unitVector*distance/2;

%The body frame x axis is aligned with distanceVector.
%get azimuth and elevation.
[az el]=getAzEl(distanceVector);

RMaz=[cos(az) -sin(az) 0; sin(az) cos(az) 0; 0 0 1];
RMel=[cos(el) 0 -sin(el); 0 1 0; sin(el) 0 cos(el)];

RM=RMaz*RMel;

end

