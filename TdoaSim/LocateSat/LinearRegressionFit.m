function [x,err] = LinearRegressionFit(M,y)
%This function will solve the equation y=M*x where M is a non-square
%matrix. i.e. it is an overconstrained problem
%it solves it in a least squares sense.
%M is a nxD matrix. y a nx1 matrix. x a Dx1 matrix.

x=(M'*M)\M'*y;

ypred=M*x;
err=sum((ypred-y).^2);
end

