%This script will test fitHyperbolaParametric
AddAllPaths

%% Test 1  
clearvars
RMe=[1 0; 0 sqrt(2)/2; 0 sqrt(2)/2];
Ae=2;
Be=3;
Center=[0;0; 0];
t=linspace(-5,5,44);
t=t(randperm(length(t)));
x2e=Ae*sec(t);
y2e=Be*tan(t);
Re=RMe*[x2e;y2e]-repmat(Center,1,44);

figure()
plot3(Re(1,:),Re(2,:),Re(3,:),'*');
hold on

[AsymptoteLines,RM,A,B,fitError,Raw]=fitHyperbolaParametric(Re');
t=linspace(-5,5,1000);
x2=Ae*sec(t);
y2=Be*tan(t);
z2=0*t;
R=RM*[x2;y2]-repmat(AsymptoteLines(1,:)',1,1000);

plot3(R(1,:),R(2,:),R(3,:));
plot3(AsymptoteLines(1,1)+t*AsymptoteLines(2,1),...
    AsymptoteLines(1,2)+t*AsymptoteLines(2,2),...
    AsymptoteLines(1,3)+t*AsymptoteLines(2,3),'linewidth',3)
plot3(AsymptoteLines(3,1)+t*AsymptoteLines(4,1),...
    AsymptoteLines(3,2)+t*AsymptoteLines(4,2),...
    AsymptoteLines(3,3)+t*AsymptoteLines(4,3),'linewidth',3)

legend('Expected','Fit','Asymptotes','Asymptotes');

Col1=RMe(:,1)*Ae;
Col2=RMe(:,2)*Be;
AssertToleranceMatrix(Col1,Raw(:,1),1e-10);
AssertToleranceMatrix(Col2,Raw(:,2),1e-10);

AssertToleranceMatrix(Center,AsymptoteLines(1,:)',1e-10);
AssertToleranceMatrix(RMe,RM,1e-10);
AssertTolerance(Ae,A,1e-10);
AssertTolerance(Be,B,1e-10);
AssertTolerance(0,fitError,1e-10);

%% Test 2 
clearvars
RMe=[1 0; 0 1; 0 0];
Ae=2;
Be=3;
Center=[0;0; 0];
t=linspace(-5,5,44);
t=t(randperm(length(t)));
x2e=Ae*sec(t);
y2e=Be*tan(t);
Re=RMe*[x2e;y2e]-repmat(Center,1,44);

figure()
plot3(Re(1,:),Re(2,:),Re(3,:),'*');
hold on

[AsymptoteLines,RM,A,B,fitError,Raw]=fitHyperbolaParametric(Re');
t=linspace(-5,5,1000);
x2=Ae*sec(t);
y2=Be*tan(t);
z2=0*t;
R=RM*[x2;y2]-repmat(AsymptoteLines(1,:)',1,1000);

plot3(R(1,:),R(2,:),R(3,:));
plot3(AsymptoteLines(1,1)+t*AsymptoteLines(2,1),...
    AsymptoteLines(1,2)+t*AsymptoteLines(2,2),...
    AsymptoteLines(1,3)+t*AsymptoteLines(2,3),'linewidth',3)
plot3(AsymptoteLines(3,1)+t*AsymptoteLines(4,1),...
    AsymptoteLines(3,2)+t*AsymptoteLines(4,2),...
    AsymptoteLines(3,3)+t*AsymptoteLines(4,3),'linewidth',3)

legend('Expected','Fit','Asymptotes','Asymptotes');

Col1=RMe(:,1)*Ae;
Col2=RMe(:,2)*Be;
AssertToleranceMatrix(Col1,Raw(:,1),1e-10);
AssertToleranceMatrix(Col2,Raw(:,2),1e-10);

AssertToleranceMatrix(Center,AsymptoteLines(1,:)',1e-10);
AssertToleranceMatrix(RMe,RM,1e-10);
AssertTolerance(Ae,A,1e-10);
AssertTolerance(Be,B,1e-10);
AssertTolerance(0,fitError,1e-10);

% %% Experiment
% syms a b c d e f g h m A B a1 b1 c1 a2 b2 c2
% 
% Eqn1=a^2+d^2+g^2-1;
% Eqn2=b^2+e^2+h^2-1;
% Eqn3=c^2+f^2+m^2-1;
% Eqn4=a*b+d*e+g*h;
% Eqn5=a*c+d*f+g*m;
% % Eqn4=a^2+b^2+c^2-1;
% % Eqn5=d^2+e^2+f^2-1;
% % Eqn6=g^2+h^2+m^2-1;
% Eqn7=A*a-a1;
% Eqn8=B*b-a2;
% Eqn9=A*d-b1;
% Eqn10=B*e-b2;
% Eqn11=A*g-c1;
% Eqn12=B*h-c2;
% 
% Out=solve([Eqn1;Eqn2;Eqn3;Eqn4;Eqn5;Eqn7;Eqn8;Eqn9;Eqn10;Eqn11;Eqn12],[A;B;a;b;c;d;e;f;g;h;m]);
% 
% Raw=[Col1 Col1 Col2]; %correct ans. 
% a0=double(subs(Out.a,[a1;b1;c1;a2;b2;c2],[Raw(:,2); Raw(:,3)]));
% b0=double(subs(Out.b,[a1;b1;c1;a2;b2;c2],[Raw(:,2); Raw(:,3)]));
% c0=double(subs(Out.c,[a1;b1;c1;a2;b2;c2],[Raw(:,2); Raw(:,3)]));
% d0=double(subs(Out.d,[a1;b1;c1;a2;b2;c2],[Raw(:,2); Raw(:,3)]));
% e0=double(subs(Out.e,[a1;b1;c1;a2;b2;c2],[Raw(:,2); Raw(:,3)]));
% f0=double(subs(Out.f,[a1;b1;c1;a2;b2;c2],[Raw(:,2); Raw(:,3)]));
% h0=double(subs(Out.h,[a1;b1;c1;a2;b2;c2],[Raw(:,2); Raw(:,3)]));
% g0=double(subs(Out.g,[a1;b1;c1;a2;b2;c2],[Raw(:,2); Raw(:,3)]));
% m0=double(subs(Out.m,[a1;b1;c1;a2;b2;c2],[Raw(:,2); Raw(:,3)]));
% A0=double(subs(Out.A,[a1;b1;c1;a2;b2;c2],[Raw(:,2); Raw(:,3)]));
% B0=double(subs(Out.B,[a1;b1;c1;a2;b2;c2],[Raw(:,2); Raw(:,3)]));
% 
% %% Attempt 2
% syms x1 x2 x3 y1 y2 y3 z1 z2 z3
% 
% Eqn1=x1*x3+y1*y3+z1*z3;
% Eqn2=x2*x3+y2*y3+z2*z3;
% Eqn3=x3^2+y3^2+z3^2-1;
% 
% out=solve([Eqn1 Eqn2 Eqn3],[x3 y3 z3])