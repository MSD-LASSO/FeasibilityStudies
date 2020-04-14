function out=RangeApproximate(Data,al,P)
%Will estimate the range based on the satellites' altitude and elevation.
%NOTE: if the polynomial values are not given, it will try to load them. If
%it can't find them this WILL throw an error.

if nargin<3
    load RangePolynomial.mat
end

M=[Data(:,1).^6 Data(:,1).^5 Data(:,1).^4 Data(:,1).^3 Data(:,1).^2 Data(:,1) ones(length(Data),1)];
out=M*P'*al; %scale by the semimajoraxis of the satellite. 

end