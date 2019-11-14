function [AsymptoteLines,RM,A,B,fitError,w]=fitHyperbolaParametric(Locations)
%This function fits a Hyperbola to a set of [x y z] data.

%NOTES:
%11/13 This function is a work-in-progress.
%Current Issues: If I use the same t input vector as how the [x y z] data
%was created, I get the same answer. When I'm finding the intersections out
%in the tdoa function, I have no idea what the t values are.
%If I don't input the same t values...things fall apart. 

%The Hyperbola Eqn is as follows:
%x''=Asect
%y''=btant
%centered at 0,0.

%RM*[x'' ; y''] - [x0; y0; z0] 
%where [x0; y0; z0] is the Bias, the center of the hyperbola, AsymptoteLines(1,:)
%where RM is [a b; d e; g h] a 3x2 matrix that will transform the hyperbola
%to 3D space.
%t is the free variable. 
%t=0 corresponds to being on the x'' axis. 

n=size(Locations,1);
t=(1:1:n)';
t=linspace(0,2*pi,n)';
% t=linspace(-5,5,44)';
M=[ones(n,1), sec(t), tan(t)];
[w, fitError]=LinearRegressionFit(M,Locations);

Bias=w(1,:);
Combined=[w(2,:) ; w(3,:)]';

A=norm(Combined(:,1));
B=norm(Combined(:,2));
RM=[Combined(:,1)/A Combined(:,2)/B];
Direction=RM(:,1)+B/A*RM(:,2);
Direction2=RM(:,1)-B/A*RM(:,2);

%cant figure out Direction2.
% x1=RM(1,1);
% x2=RM(1,2);
% y1=RM(2,1);
% y2=RM(2,2);
% z1=RM(3,1);
% z2=RM(3,2);
% RM(:,3)=[(y1*z2 - y2*z1)*(1/(x1^2*y2^2 + x1^2*z2^2 - 2*x1*x2*y1*y2 - 2*x1*x2*z1*z2 + x2^2*y1^2 + x2^2*z1^2 + y1^2*z2^2 - 2*y1*y2*z1*z2 + y2^2*z1^2))^(1/2);
%     -(x1*z2 - x2*z1)*(1/(x1^2*y2^2 + x1^2*z2^2 - 2*x1*x2*y1*y2 - 2*x1*x2*z1*z2 + x2^2*y1^2 + x2^2*z1^2 + y1^2*z2^2 - 2*y1*y2*z1*z2 + y2^2*z1^2))^(1/2);
%     (x1*y2 - x2*y1)*(1/(x1^2*y2^2 + x1^2*z2^2 - 2*x1*x2*y1*y2 - 2*x1*x2*z1*z2 + x2^2*y1^2 + x2^2*z1^2 + y1^2*z2^2 - 2*y1*y2*z1*z2 + y2^2*z1^2))^(1/2)];
% 
% Direction2=RM(1,:)+B/A*RM(2,:);

% Direction2=[0 1 0; -1 0 0; 0 0 1]*Direction; %wrong.
AsymptoteLines=[Bias ; Direction'; Bias; Direction2'];


end