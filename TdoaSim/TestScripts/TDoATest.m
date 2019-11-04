%this integration test script will test some simple TDoA cases.

%% Equilateral triangle. Point is at the exact center.
X=10;
x=X/2; %receiver location
y=sqrt(3)/2*X-X/sqrt(3); %receiver location
R1=[0,0,0];
R2=[X,0,0];
R3=[X/2,X/2*sqrt(3),0];
expected=[x y 0];

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
expected=[5 0 0];

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
expected=[5 0 0];

d1=sqrt(x^2+y^2);
d2=sqrt((R2(1)-x)^2+y^2);
d3=sqrt((R3(1)-x)^2+(R3(2)-y)^2);

distanceDiffs=abs([0 d1-d2 d1-d3; 0 0 d2-d3; 0 0 0]);

figure()
plot(x,y,'o','linewidth',3);
hold on
location=TDoA([R1;R2;R3],distanceDiffs);
AssertToleranceMatrix(expected,location,0.001);


%% Equilateral triangle. Point is outside the triangle. 
X=10;
x=11; %receiver location
y=14; %receiver location
R1=[0,0,0];
R2=[X,0,0];
R3=[X/2,X/2*sqrt(3),0];
expected=[5 0 0];

d1=sqrt(x^2+y^2);
d2=sqrt((R2(1)-x)^2+y^2);
d3=sqrt((R3(1)-x)^2+(R3(2)-y)^2);

distanceDiffs=abs([0 d1-d2 d1-d3; 0 0 d2-d3; 0 0 0]);

figure()
plot(x,y,'o','linewidth',3);
hold on
location=TDoA([R1;R2;R3],distanceDiffs);
AssertToleranceMatrix(expected,location,0.001);
