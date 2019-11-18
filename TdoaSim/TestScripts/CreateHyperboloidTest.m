%This script tests the creation of a hyperboloid, given general station
%coordinates.
AddAllPaths
%it is believed that CreateHyperboloid works as intended. Its hard to make
%tests that I know the right answer to though. 
syms x y z
%% 2D. Stations located at (-1,0) and (1,0). Difference in Distance is near 0.
R1=[-1 0 0];
R2=[1 0 0];
delta=0.2; %closer to B over A.
Hyperboloid=CreateHyperboloid(R1,R2,delta);
figure()
plot(R1(1),R1(2),'.','MarkerSize',20);
hold on
plot(R2(1),R2(2),'.','MarkerSize',20);
plot([R1(1) R2(1)],[R1(2) R2(2)],'linewidth',2,'color','black');
grid on


% expected=100*x^2 - (100*y^2)/99 - 1; %2-sided Hyperbola
expected=((100*y^2)/99 + 1)^(1/2)/10 - x; %1-sided
fimplicit(Hyperboloid,'linewidth',5);
fimplicit(expected,'linewidth',2);
legend('R1','R2','Connecting Line','Hyperbola','Correct')
assert(logical(expected==Hyperboloid));

%% 2D. 45 degree angle. Centered around zero still.
%The result is an ellispe.
%This is because the delta chosen is larger than the maximum distance
%between the stations. (not physically possible)
R1=1/sqrt(2)*[-cosd(45) -sind(45) 0];
R2=1/sqrt(2)*[cosd(45) sind(45) 0];
delta=2;
Hyperboloid=CreateHyperboloid(R1,R2,delta);
figure()
plot(R1(1),R1(2),'.','MarkerSize',10);
hold on
plot(R2(1),R2(2),'.','MarkerSize',10);
grid on
fimplicit(Hyperboloid,[-2 2 -2 2],'linewidth',5);
% expected=(3*x^2)/2 - x*y + (3*y^2)/2 - 1; %2 sided
expected=(1 - 2*((2^(1/2)*x)/2 - (2^(1/2)*y)/2)^2)^(1/2) - (2^(1/2)*y)/2 - (2^(1/2)*x)/2; %1 sided
fimplicit(expected,'linewidth',3);
assert(logical(expected==simplify(expand(Hyperboloid),'steps',10)));

%% 2D. Offset only. No angle.
R1=[0 1 0];
R2=[2 1 0];
delta=0.2;
Hyperboloid=CreateHyperboloid(R1,R2,delta);
figure()
plot(R1(1),R1(2),'.','MarkerSize',10);
hold on
plot(R2(1),R2(2),'.','MarkerSize',10);
grid on

% expected=100*(x-1)^2 - (100*(y-1)^2)/99 - 1; %2 sided
expected=((100*(y - 1)^2)/99 + 1)^(1/2)/10 - x + 1; %1 sided
fimplicit(Hyperboloid,'linewidth',5);
fimplicit(expected,'linewidth',2);
legend('R1','R2','Hyperbola','Correct')
assert(logical(expected==Hyperboloid));

%% 2D. Offset + 60 degree
RM=[cosd(60) -sind(60) 0; sind(60) cosd(60) 0; 0 0 1];
R1original=[2; 3; 0];
R2original=[6; 3; 0];
Rcenter=[4; 3; 0];
R1=RM*R1original;
R2=RM*R2original;
delta=1;
Hyperboloid=CreateHyperboloid(R1,R2,delta);
figure()
plot(R1(1),R1(2),'.','MarkerSize',10,'color','blue');
hold on
plot(R2(1),R2(2),'.','MarkerSize',10,'color','blue');
plot(R1original(1),R1original(2),'.','MarkerSize',10,'color','black');
plot(R2original(1),R2original(2),'.','MarkerSize',10,'color','black');
grid on
%2sided
% expected=4*(x/2 + (3^(1/2)*(y - 5589081546040917/1125899906842624))/2 + 1346747901294977/4503599627370496)^2 - (4*((3^(1/2)*(x + 1346747901294977/2251799813685248))/2 - y/2 + 5589081546040917/2251799813685248)^2)/15 - 1;
%1sided
expected=((4*((3^(1/2)*(x + 1346747901294977/2251799813685248))/2 - y/2 + 5589081546040917/2251799813685248)^2)/15 + 1)^(1/2)/2 - (3^(1/2)*(y - 5589081546040917/1125899906842624))/2 - x/2 - 1346747901294977/4503599627370496;

fimplicit(Hyperboloid,'linewidth',5);
fimplicit(expected,'linewidth',2);
legend('R1','R2','R1org','R2org','Hyperbola','Correct')

assert(logical(expected==Hyperboloid));

%% 3D. Offset only
R1=[-1 0 1];
R2=[1 0 1];
delta=0.2;
Hyperboloid=CreateHyperboloid(R1,R2,delta);
figure()
plot3(R1(1),R1(2),R1(3),'.','MarkerSize',20);
hold on
plot3(R2(1),R2(2),R1(3),'.','MarkerSize',20);
grid on
% expected=-100*(z-1)^2/99+100*x^2 - (100*y^2)/99 - 1; %2 sided
expected=((100*(z - 1)^2)/99 + (100*y^2)/99 + 1)^(1/2)/10 - x;
fimplicit3(Hyperboloid);
% fimplicit3(expected,'linewidth',2);
legend('R1','R2','Hyperbola','Correct')

assert(logical(expected==Hyperboloid));

%% 3D. 45 degree angle. With offset in z. 
%The result is an ellispsoid.
%Again the delta is too large. Not physically possible. 
R1=1/sqrt(2)*[-cosd(45) -sind(45) 1];
R2=1/sqrt(2)*[cosd(45) sind(45) 1];
delta=2;
Hyperboloid=CreateHyperboloid(R1,R2,delta);
figure()
plot3(R1(1),R1(2),R1(3),'.','MarkerSize',10);
hold on
plot3(R2(1),R2(2),R1(3),'.','MarkerSize',10);
grid on
fimplicit3(Hyperboloid);
% expected=(3*x^2)/2 - x*y + (3*y^2)/2 + 2*z^2 - 2*2^(1/2)*z; %2 sided
expected=(1 - 2*(z - 2^(1/2)/2)^2 - 2*((2^(1/2)*x)/2 - (2^(1/2)*y)/2)^2)^(1/2) - (2^(1/2)*y)/2 - (2^(1/2)*x)/2;
fimplicit3(expected);
assert(logical(expected==simplify(expand(Hyperboloid))));

%% 0 Difference
R1=[-1 0 1];
R2=[1 0 1];
delta=0;
Hyperboloid=CreateHyperboloid(R1,R2,delta);
figure()
plot3(R1(1),R1(2),R1(3),'.','MarkerSize',10);
hold on
plot3(R2(1),R2(2),R1(3),'.','MarkerSize',10);
grid on
fimplicit3(Hyperboloid);
expected=x;
assert(logical(expected==simplify(Hyperboloid)));

%% 0 Difference shifted.
R1=[1 3 5];
R2=[3 -5 2];
delta=0;
Hyperboloid=CreateHyperboloid(R1,R2,delta);
figure()
plot3(R1(1),R1(2),R1(3),'.','MarkerSize',10);
hold on
plot3(R2(1),R2(2),R1(3),'.','MarkerSize',10);
grid on
fimplicit3(Hyperboloid);
expected=-(77^(1/2)*(16*y - 4*x + 6*z + 3))/154;
assert(logical(expected==simplify(Hyperboloid)));

%% Part of the equilateral triangle in 2D.
R1=[0 0 0];
R3=[5 5*sqrt(3) 0];
delta=-5*(sqrt(3)-1);
Hyperboloid=CreateHyperboloid(R1,R3,delta);
figure()
plot(R1(1),R1(2),'.','MarkerSize',20);
hold on
plot(R3(1),R3(2),'.','MarkerSize',20);
plot([R1(1) R3(1)],[R1(2) R3(2)],'linewidth',2,'color','black');
grid on
fimplicit(Hyperboloid,'linewidth',5);
%analytically derived solution for 2 sided.
% expected=sym(4*(1/2*(x-5/2)+sqrt(3)/2*(y-5/2*sqrt(3)))^2/(25*(sqrt(3)-1)^2)-4*(-sqrt(3)/2*(x-5/2)+1/2*(y-5/2*sqrt(3)))^2/(100-25*(sqrt(3)-1)^2)-1);
%1 sided
expected=5/4 - (3^(1/2)*(y - (5*3^(1/2))/2))/2 - (8242159360458665*((2*3^(1/2)*((5*3^(1/2))/4 - y/2 + (3^(1/2)*(x - 5/2))/2)^2)/75 + 1)^(1/2))/4503599627370496 - x/2;
fimplicit(expected,'linewidth',3);
AssertTolerance(0,double(subs(expected,[x y],[5 0])),0.000001);
assert(logical(expected==Hyperboloid));

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
Hyperboloid=CreateHyperboloid(R1,R2,delta);
figure()
fimplicit3(Hyperboloid,[-100 100 -100 100 -100 100])
figure()
fimplicit3(Hyperboloid,[-100 100 -100 100 -100 100])
hold on

syms x y z
L1=x^2+y^2+z^2;
L2=(x-10)^2+y^2+(z-0.05)^2;
D=(sqrt(10000+49+16)-sqrt((100-0.05)^2+9+16));
%These equations are the same. 
% Eqn1=L1+L2-D^2-2*sqrt(L1)*sqrt(L2);
% Eqn1=(1125899906842624*(8000*x + 40*z - 40001)^2)/1121331742143099759025 - (281474976710656*(x - 200*z)^2)/281313842550703531413 - (281474976710656*y^2)/7032670247011413 - 1;
Eqn1=(17556241531995*((281474976710656*y^2)/7032670247011413 + (281474976710656*((40001^(1/2)*(x - 5))/40001 - (200*40001^(1/2)*(z - 1/40))/40001)^2)/7032670247011413 + 1)^(1/2))/140737488355328 - (200*40001^(1/2)*(x - 5))/40001 - (40001^(1/2)*(z - 1/40))/40001;
fimplicit3(Eqn1,[-100 100 -100 100 -100 100])
% fimplicit3(Eqn1,[2 7 -5 10 0 100])
HyperboloidEqn=string(simplify(Hyperboloid,'steps',10));
Eqn1="(17556241531995*((281474976710656*y^2)/7032670247011413 + (281474976710656*((40001^(1/2)*(x - 5))/40001 - (200*40001^(1/2)*(z - 1/40))/40001)^2)/7032670247011413 + 1)^(1/2))/140737488355328 - (200*40001^(1/2)*(x - 5))/40001 - (40001^(1/2)*(z - 1/40))/40001";


%they are the same. I couldn't get symbolic toolbox to see this. So I used
%strings.
assert(logical(Eqn1==HyperboloidEqn));


