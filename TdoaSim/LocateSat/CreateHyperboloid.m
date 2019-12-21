function [Hyperboloid,SymVars] = CreateHyperboloid(Station1Coordinates,Station2Coordinates,DifferenceInDistance)
%This function creates a hyperboloid in the body frame then converts it to
%the fixed frame. It returns the equation that describes that hyperboloid
%in the fixed frame. Expect this expression to be complicated.
%if the DifferenceInDistance is zero, the output will be a plane, not
%a hyperboloid.
%INPUTS: 3D coordinates of stations 1 and 2.
        %The difference in Distance between stations 1 and 2.
%OUTPUTS: symbolic eqn describing Hyperboloid.

%NOTE, the hyperboloid in the body frame is centered at the midpoint of
%station 1 and 2.

%[xb yb zb] are the coordinates in the body frame
%[x y z] are the coordinates in the fixed frame.
syms xb yb zb x y z

[RM,Offset,distance]=getRMandOffsets(Station1Coordinates,Station2Coordinates);

 
if isnumeric(DifferenceInDistance)==1 && abs(DifferenceInDistance)<1.0e-14
    %vertical plane in the body frame
    HyperboloidBody=xb;
else
    %hyperboloid.
    a=DifferenceInDistance/2;
    b=sqrt((distance/2)^2-a^2);

    %body frame hyperboloid
%     HyperboloidBody=xb^2/a^2-yb^2/b^2-zb^2/b^2-1;
    %body frame 1 sided hyperboloid
    HyperboloidBody=a*sqrt(1+yb^2/b^2+zb^2/b^2)-xb;
     %1 sided Cone
%      HyperboloidBody=a*sqrt(yb^2/b^2+zb^2/b^2)-xb;
end


%Rotate to the fixed frame
fixedCoord=[x;y;z];
Hyperboloid=subs(HyperboloidBody,[xb,yb,zb],[dot(RM(:,1),fixedCoord),dot(RM(:,2),fixedCoord),dot(RM(:,3),fixedCoord)]);
%Shift the origin
Hyperboloid=subs(Hyperboloid,[x,y,z],[x-Offset(1),y-Offset(2),z-Offset(3)]);

%% Direct Solution
% d1=(x-Station1Coordinates(1))^2+(y-Station1Coordinates(2))^2+(z-Station1Coordinates(3))^2;
% d2=(x-Station2Coordinates(1))^2+(y-Station2Coordinates(2))^2+(z-Station2Coordinates(3))^2;
% Hyperboloid=d1+d2-2*sqrt(d1)*sqrt(d2)-DifferenceInDistance^2;

%% Make 2D if neccessary.
SymVars=[x y z];

%remove z if 2D.
if isnumeric(Station1Coordinates)==1 && (Station1Coordinates(3)==0 && Station2Coordinates(3)==0)
    Hyperboloid=subs(Hyperboloid,z,0);
    SymVars=[x y];
end


end

