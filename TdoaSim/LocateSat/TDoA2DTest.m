%this integration test script will test some simple 2D TDoA cases.

%% Equilateral triangle. Point is at the exact center.
X=10;
x=X/2; %receiver location
y=sqrt(3)/2*X-X/sqrt(3); %receiver location
R1=[0,0,0];
R2=[X,0,0];
R3=[X/2,X/2*sqrt(3),0];
expected=[x y 0];
expected=[expected; expected];

d1=sqrt(x^2+y^2);
d2=sqrt((R2(1)-x)^2+y^2);
d3=sqrt((R3(1)-x)^2+(R3(2)-y)^2);

distanceDiffs=abs([0 d1-d2 d1-d3; 0 0 d2-d3; 0 0 0]);

figure()
plot(x,y,'o','linewidth',3);
hold on
location=TDoA([R1;R2;R3],distanceDiffs);
AssertToleranceMatrix(expected,location,0.001);


%% Equilateral triangle. Point is on the bottom of the triangle. 
X=10;
x=5; %receiver location
y=0; %receiver location
R1=[0,0,0];
R2=[X,0,0];
R3=[X/2,X/2*sqrt(3),0];
%second point is a ghost point.
expected=[5 0 0 ; 5 5.14568548894944 0];

d1=sqrt(x^2+y^2);
d2=sqrt((R2(1)-x)^2+y^2);
d3=sqrt((R3(1)-x)^2+(R3(2)-y)^2);

distanceDiffs=abs([0 d1-d2 d1-d3; 0 0 d2-d3; 0 0 0]);

figure()
plot(x,y,'o','linewidth',3);
hold on
location=TDoA([R1;R2;R3],distanceDiffs);
AssertToleranceMatrix(expected,location,0.001);

%% Equilateral triangle. Point is inside the triangle. 
X=10;
x=7; %receiver location
y=1; %receiver location
R1=[0,0,0];
R2=[X,0,0];
R3=[X/2,X/2*sqrt(3),0];
%first is a ghost point.
expected=[2.09644147539099 5.05651484796011 0;x y 0];

d1=sqrt(x^2+y^2);
d2=sqrt((R2(1)-x)^2+y^2);
d3=sqrt((R3(1)-x)^2+(R3(2)-y)^2);

distanceDiffs=abs([0 (d1-d2)+0.6 (d1-d3)-0.3; 0 0 (d2-d3)+0.3; 0 0 0]);


figure()
plot(x,y,'o','linewidth',3);
hold on
location=TDoA([R1;R2;R3],distanceDiffs,1e-5,0,1);
AssertToleranceMatrix(expected,location,0.001);


%% Equilateral triangle. Point is outside the triangle. 
% close all
X=10;
x=11; %receiver location
y=14; %receiver location
R1=[0,0,0];
R2=[X,0,0];
R3=[X/2,X/2*sqrt(3),0];
%first is a ghost point.
expected=[-13.1306530584762 -44.3182287629861 0; x y 0];

d1=sqrt(x^2+y^2);
d2=sqrt((R2(1)-x)^2+y^2);
d3=sqrt((R3(1)-x)^2+(R3(2)-y)^2);

% distanceDiffs=abs([0 d1-d2 d1-d3; 0 0 d2-d3; 0 0 0]);
distanceDiffs=abs([0 (d1-d2)+0.15 (d1-d3)-0.075; 0 0 (d2-d3)+0.075; 0 0 0]);

figure()
plot(x,y,'o','linewidth',3);
hold on
location=TDoA([R1;R2;R3],distanceDiffs,1e-5,0,1);
AssertToleranceMatrix(expected,location,0.001);
