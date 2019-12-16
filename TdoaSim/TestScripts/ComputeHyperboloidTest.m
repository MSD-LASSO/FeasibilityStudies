%This script tests the computing how close the input coordinates are to
%lying on a hyperboloid, given general station coordinates.
AddAllPaths
%We compare against CreateHyperboloid for these tests. 
syms x y z
%% 2D. Stations located at (-1,0) and (1,0). Difference in Distance is near 0.
R1=[-1 0 0];
R2=[1 0 0];
delta=0.2; %closer to B over A.
[Hyperboloid,SymVars]=CreateHyperboloid(R1,R2,delta);
vec=[1;2;0];
val=ComputeHyperboloid(R1,R2,delta,vec);
valExp=double(subs(Hyperboloid,SymVars,vec(1:2)'));

AssertTolerance(valExp,val,1e-10);

%% 2D. 45 degree angle. Centered around zero still.
%The result is an ellispe.
%This is because the delta chosen is larger than the maximum distance
%between the stations. (not physically possible)
R1=1/sqrt(2)*[-cosd(45) -sind(45) 0];
R2=1/sqrt(2)*[cosd(45) sind(45) 0];
delta=2;
[Hyperboloid,SymVars]=CreateHyperboloid(R1,R2,delta);
vec=[10;-25;0];
val=ComputeHyperboloid(R1,R2,delta,vec);
valExp=double(subs(Hyperboloid,SymVars,vec(1:2)'));

AssertTolerance(valExp,val,1e-10);


%% 2D. Offset only. No angle.
R1=[0 1 0];
R2=[2 1 0];
delta=0.2;
[Hyperboloid,SymVars]=CreateHyperboloid(R1,R2,delta);
vec=[-11;20;0];
val=ComputeHyperboloid(R1,R2,delta,vec);
valExp=double(subs(Hyperboloid,SymVars,vec(1:2)'));

AssertTolerance(valExp,val,1e-10);


%% 2D. Offset + 60 degree
RM=[cosd(60) -sind(60) 0; sind(60) cosd(60) 0; 0 0 1];
R1original=[2; 3; 0];
R2original=[6; 3; 0];
Rcenter=[4; 3; 0];
R1=RM*R1original;
R2=RM*R2original;
delta=1;
[Hyperboloid,SymVars]=CreateHyperboloid(R1,R2,delta);
vec=[2.5;3;0];
val=ComputeHyperboloid(R1,R2,delta,vec);
valExp=double(subs(Hyperboloid,SymVars,vec(1:2)'));

AssertTolerance(valExp,val,1e-10);


%% 3D. Offset only
R1=[-1 0 1];
R2=[1 0 1];
delta=0.2;
[Hyperboloid,SymVars]=CreateHyperboloid(R1,R2,delta);
vec=[1;2;6];
val=ComputeHyperboloid(R1,R2,delta,vec);
valExp=double(subs(Hyperboloid,SymVars,vec'));

AssertTolerance(valExp,val,1e-10);


%% 3D. 45 degree angle. With offset in z. 
%The result is an ellispsoid.
%Again the delta is too large. Not physically possible. 
R1=1/sqrt(2)*[-cosd(45) -sind(45) 1];
R2=1/sqrt(2)*[cosd(45) sind(45) 1];
delta=2;
[Hyperboloid,SymVars]=CreateHyperboloid(R1,R2,delta);
vec=[1;2;9];
val=ComputeHyperboloid(R1,R2,delta,vec);
valExp=double(subs(Hyperboloid,SymVars,vec'));

AssertTolerance(valExp,val,1e-10);


%% 0 Difference
R1=[-1 0 1];
R2=[1 0 1];
delta=0;
[Hyperboloid,SymVars]=CreateHyperboloid(R1,R2,delta);
vec=[1;2;9];
val=ComputeHyperboloid(R1,R2,delta,vec);
valExp=double(subs(Hyperboloid,SymVars,vec'));

AssertTolerance(valExp,val,1e-10);

%% 0 Difference shifted.
R1=[1 3 5];
R2=[3 -5 2];
delta=0;
[Hyperboloid,SymVars]=CreateHyperboloid(R1,R2,delta);
vec=[1;2;9];
val=ComputeHyperboloid(R1,R2,delta,vec);
valExp=double(subs(Hyperboloid,SymVars,vec'));

AssertTolerance(valExp,val,1e-10);

%% Part of the equilateral triangle in 2D.
R1=[0 0 0];
R3=[5 5*sqrt(3) 0];
delta=-5*(sqrt(3)-1);
[Hyperboloid,SymVars]=CreateHyperboloid(R1,R3,delta);
vec=[1;2;0];
val=ComputeHyperboloid(R1,R3,delta,vec);
valExp=double(subs(Hyperboloid,SymVars,vec(1:2)'));

AssertTolerance(valExp,val,1e-10);

%% Part of the equilateral triangle in 3D.
clearvars
X=10;
x1=7; %receiver location
y1=-4; %receiver location
z1=100;
R1=[0,0,0];
R2=[X,0,0.05];
R3=[X/2,X/2*sqrt(3),0.1];
d1=sqrt((R1(1)-x1)^2+(R1(2)-y1)^2+(R1(3)-z1)^2);
d2=sqrt((R2(1)-x1)^2+(R2(2)-y1)^2+(R2(3)-z1)^2);
delta=d1-d2;
[Hyperboloid,SymVars]=CreateHyperboloid(R1,R2,delta);
vec=[1;2;9];
val=ComputeHyperboloid(R1,R2,delta,vec);
valExp=double(subs(Hyperboloid,SymVars,vec'));

AssertTolerance(valExp,val,1e-10);

