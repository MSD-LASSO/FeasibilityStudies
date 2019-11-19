%This script tests the idea of approximating the hyperboloids as cones.
%doesn't work 11/18. Can't get the solver to output anything. We can still
%try using cones instead of hyperbolas...might simplify some things?
AddAllPaths
syms x1 y1 z1 x2 y2 z2 d12 d23 x y z az1 el1 az2 el2 A1 B1 A2 B2
syms a b c d e f g h m C1 C2 X Y Z
%note here x1 y1 z1 corresponds to the midpoint between stations 1 and 2
%x2 y2 z2 corresponds to the modipoint between stations 1 and 3.

Cone12=createCone(x1,y1,z1,az1,el1,A1,B1,C1);
Cone13=createCone(x2,y2,z2,az2,el2,A2,B2,C2);

% Hyperboloid12=CreateHyperboloid([x1 y1 z1],[x2 y2 z2],d12);
% Hyperboloid13=CreateHyperboloid([x1 y1 z1],[x3 y3 z3],d23);
% Cone12=Hyperboloid12-1;
% Cone13=Hyperboloid13-1;

% out1=solve(Cone12,y); %we are throwing away a soln here.
% Eqn2=simplify(subs(Cone13,y,out1(2)),'steps',10);
% out=solve(Eqn2,z)
% out=solve([Cone12 Cone13],[y z]);


function cone=createCone(x0,y0,z0,az,el,A,B,C)
syms x y z a b c d e f g h m X Y Z
% RMaz=[cos(az) -sin(az) 0; sin(az) cos(az) 0; 0 0 1];
% RMel=[cos(el) 0 -sin(el); 0 1 0; sin(el) 0 cos(el)];
% 
% RM=RMaz*RMel;
%we want transpose so...
RMaz=[cos(az) sin(az) 0; -sin(az) cos(az) 0; 0 0 1];
RMel=[cos(el) 0 sin(el); 0 1 0; -sin(el) 0 cos(el)];

RM=RMel*RMaz;
% RM=[a b c;d e f; g h m];

FF=RM*[x;y;z]; %approximation: assume x,y,z are much larger than x0 y0 z0
%this is partially true already since we are approximating the hyperboloid
%as a cone. What isn't quite true is y and z together are large.
% FF=RM*[x-x0;y-y0;z-z0];
rx=FF(1);
ry=FF(2);
rz=FF(3);
cone=expand(rx^2/A^2-ry^2/B^2-rz^2/B^2);
cone=subs(cone,a^2*x0^2/A^2+b^2*y0^2/A^2+c^2*z0^2/A^2-...
    d^2*x0^2/B^2-e^2*y0^2/B^2-f^2*z0^2/B^2-...
    g^2*x0^2/B^2-h^2*y0^2/B^2-m^2*z0^2/B^2,C);
% cone=subs(cone,[x^2 y^2 z^2],[X Y Z]);
    
end
