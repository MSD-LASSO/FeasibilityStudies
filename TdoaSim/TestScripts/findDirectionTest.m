%this function will test intersecting a Sphere with a 3D line.

syms x y z t


%% along X axis
W=[0 0 0; 1 0 0];
ReceiverLocation=[ 3.34951e6 ,450e4,-302e4];
[az,el,r]=findDirection(W,ReceiverLocation);
rExpected=[6371e3 0 0];
azE=0;
elE=0;
AssertTolerance(azE,az,1e-10);
AssertTolerance(elE,el,1e-10);
AssertToleranceMatrix(rExpected,r,1e-10);

%% some line I made up
W=[-302 503 -4; 950 -404 50];
ReceiverLocation=[ 3.34951e6 ,450e4,-302e4];
[az,el,r]=findDirection(W,ReceiverLocation);
rExpected=[5856142.17292081,-2490026.94301053,308229.903837937];
azE=atan2(-404,950);
elE=atan2(50,sqrt(950^2+404^2));
AssertTolerance(azE,az,1e-10);
AssertTolerance(elE,el,1e-10);
AssertToleranceMatrix(rExpected,r,1e-4);

%% Visualization
figure()
syms x y z
fimplicit3(x^2+y^2+z^2==1)
axis square
syms t
hold on
fplot3(0.2+t,-0.3-2*t,0.5+0.5*t,[-1 0.5],'linewidth',3)