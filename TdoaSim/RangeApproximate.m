function out=RangeApproximate(Data,al,P)

if nargin<3
    load RangePolynomial.mat
end

M=[Data(:,1).^6 Data(:,1).^5 Data(:,1).^4 Data(:,1).^3 Data(:,1).^2 Data(:,1) ones(length(Data),1)];
out=M*P'*al; %scale by the semimajoraxis of the satellite. 

end