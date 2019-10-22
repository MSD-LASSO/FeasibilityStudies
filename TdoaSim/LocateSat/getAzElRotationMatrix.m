function RM = getAzElRotationMatrix(az,el)
%This function calculates the Rotation Matrix that transforms a vector in
%the body frame to the fixed frame based on an azimuth and elevation.

RMaz=[cos(az) -sin(az) 0; sin(az) cos(az) 0; 0 0 1];
RMel=[cos(el) 0 -sin(el); 0 1 0; sin(el) 0 cos(el)];


RM=RMaz*RMel;

end