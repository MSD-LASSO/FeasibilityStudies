function [point,err] = LeastSquaresLines(LineFits)
%This function will solve for the closest point of intersection between all
%given lines.

%Each line has the form w=[x0 y0 z0; xd yd zd]. A 3D LINE.
%Lines are in a nx1 cell array of n lines. 

if size(LineFits{1},2)~=3
    error('Incorrect number of columns. Must be a 3D line')
end

n=size(LineFits,1);

if n==1
    error('Incorrect number of lines. Must input at least 2 lines')
end

M=zeros(n*3,3+n);
y=zeros(n*3,1);
for i=1:n
    M(3*i-2:3*i,1:3)=eye(3);
    M(3*i-2:3*i,3+i)=LineFits{i}(2,:)';
    y(3*i-2:3*i)=LineFits{i}(1,:)';
end

[point,err]=LinearRegressionFit(M,y);
%throw away all but the first 3 elements. Rest of "t" variables.
point=point(1:3);
end

