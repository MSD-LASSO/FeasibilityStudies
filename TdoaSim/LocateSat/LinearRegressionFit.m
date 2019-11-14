function [x,err] = LinearRegressionFit(M,y)
%This function will solve the equation y=M*x where M is a non-square
%matrix. i.e. it is an overconstrained problem
%it solves it in a least squares sense.
%M is a nxD matrix. y a nxV matrix. x a DxV matrix.

x=(M'*M)\M'*y;

ypred=M*x;
err=sum(sum((ypred-y).^2));
end

