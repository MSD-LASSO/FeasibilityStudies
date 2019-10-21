%This script creates some simple datapoints to test fitLineParametric

%% No error 2D
x=0:1:10;
y=x+1;
[weights,error]=fitLineParametric([x',y']);
ExpectedW=[-1,0;1,1];
AssertToleranceMatrix(ExpectedW,weights,1e-10);
AssertTolerance(0,error,1e-10);

%% no error 3D
t=0:2:100;
Ew=[-5,6,9;-2 3 10];
Lx=Ew(1,1)+t*Ew(2,1);
Ly=Ew(1,2)+t*Ew(2,2);
Lz=Ew(1,3)+t*Ew(2,3);

[weights,error]=fitLineParametric([Lx' Ly' Lz']);
ExpectedW=[-1,0,-11;-4 6 20];
AssertToleranceMatrix(ExpectedW,weights,1e-10);
AssertTolerance(0,error,1e-10);

%% 2D with error
x=0:1:10;
y=x+1+rand(1,length(x))/10000;
yFit=x+1;
PredErr=sum((yFit-y).^2);
ExpectedW=[-1 0; 1 1];
[weights,error]=fitLineParametric([x' y']);
AssertToleranceMatrix(ExpectedW,weights,1e-4);
AssertTolerance(PredErr,error,1e-4);