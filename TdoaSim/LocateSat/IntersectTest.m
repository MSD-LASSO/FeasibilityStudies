%This script will test Intersect on some simple shapes, working up to a
%hyperbola. 
clearvars
syms x y z t

%% 2 linear Lines, cross once.
Eqn1=x-y;
Eqn2=2*x-1-y;
Output=Intersect([Eqn1,Eqn2],[x,y]);
assert(length(Output{1})==1)
assert(double(Output{1})==1)
assert(double(Output{2})==1)

%% Parabola and Sqrt Root Function
Eqn1=x^2-y;
Eqn2=sqrt(x)-y;
Output=Intersect([Eqn1,Eqn2],[x,y]);
assert(length(Output{1})==2)
assert(double(Output{1}(1))==0)
assert(double(Output{1}(2))==1)
assert(double(Output{2}(1))==0)
assert(double(Output{2}(2))==1)

%% 2 Hyperbolas
Eqn1=x^2-y^2-1;
Eqn2=y^2-(x-1)^2-1;
Surf=[Eqn1,Eqn2];
Output=Intersect(Surf,[x,y]);
assert(length(Output{1})==2)
assert(double(Output{1}(1))==1.5)
assert(double(Output{1}(2))==1.5)
AssertTolerance(-1.118,double(Output{2}(1)),0.01);
AssertTolerance(1.118,double(Output{2}(2)),0.01);
figure()
fimplicit(Surf)
hold on
plot(Output{1},Output{2},'.','MarkerSize',10,'Color','Black')

%% 3 Hyperbolas
Eqn1=(x-5)^2-y^2-1;
Eqn2=-(y-2.5*sqrt(3))^2+(x-2.5)^2-1+4*(x-2.5)*(y-2.5*sqrt(3));
Eqn3=-(y-2.5*sqrt(3))^2+(x-7.5)^2-1-4*(x-7.5)*(y-2.5*sqrt(3));

Surf=[Eqn1,Eqn2,Eqn3];
Output=Intersect(Surf,[x,y]);
assert(length(Output{1})==0)
figure()
fimplicit(Surf,[0 10 0 10])

%% 2 Hyperboloids
Eqn1=x^2-y^2-z^2-1;
Eqn2=x^2-y^2-z^2+4*x*y-1;
Surf=[Eqn1,Eqn2];
Output=Intersect(Surf,[x;y;z]);
figure()
fimplicit3(Surf)
hold on
Zeqn=ones(length(Output{1}),1)*t;
fplot3(subs(Output{1},z,t),subs(Output{2},z,t),Zeqn,'linewidth',5,'color','black');
axis square

figure()
fplot3(subs(Output{1},z,t),subs(Output{2},z,t),Zeqn,'linewidth',5);
axis square

assert(length(Output{1})==4);
assert(logical(Output{1}(1)==-(z^2 + 1)^(1/2)));
assert(logical(Output{1}(2)==0));
assert(logical(Output{1}(3)==0));
assert(logical(Output{1}(4)==(z^2 + 1)^(1/2)));
assert(logical(Output{2}(1)==0));
assert(logical(Output{2}(2)==(- z^2 - 1)^(1/2)));
assert(logical(Output{2}(3)==-(- z^2 - 1)^(1/2)));
assert(logical(Output{2}(4)==0));
%% 3 Hyperboloids
Eqn1=(x-5)^2-y^2-1-z^2;
Eqn2=-(y-2.5*sqrt(3))^2+(x-2.5)^2-1+4*(x-2.5)*(y-2.5*sqrt(3))-z^2;
Eqn3=-(y-2.5*sqrt(3))^2+(x-7.5)^2-1-4*(x-7.5)*(y-2.5*sqrt(3))-z^2;
Surf=[Eqn1,Eqn2,Eqn3];
Surf=[Eqn1,Eqn2];
% Output=Intersect(Surf,[x;y;z]);
Output1=Intersect([Eqn1,Eqn2],[x;y;z]);
Output2=Intersect([Eqn1,Eqn3],[x;y;z]);
Output3=Intersect([Eqn3,Eqn2],[x;y;z]);
figure()
fimplicit3(Surf,[-5 5 -5 5 -5 5])
hold on
% plot3(Output{1},Output{2},Output{3},'x','MarkerSize',10,'color','black','linewidth',3);
fplot3(subs(Output1{1},z,t),subs(Output1{2},z,t),ones(length(Output1{1}),1)*t,'color','black','linewidth',3);
% fplot3(Output2{1},Output2{2},t,'color','black','linewidth',3);
% fplot3(Output3{1},Output3{2},t,'color','black','linewidth',3);
axis square

% figure()
% fplot3(Output{1},Output{2},Output{3},'x','MarkerSize',10,'color','black','linewidth',3);
% fplot3(subs(Output1{1},z,t),subs(Output1{2},z,t),ones(length(Output1{1}),1)*t,'color','black','linewidth',3);
% axis square

