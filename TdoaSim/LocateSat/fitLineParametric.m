function [weights,err]=fitLineParametric(Locations)
%This function fits a parametric line fit to Locations. t is the
%independent variable, output is 
    %weights = [bx by bz ; mx my mz] 
    %the first row is the bias vector.
    %the second row is the direction vector.
    %equation of line is Point=[bx by bz]+t*[mx my mz] 
    %or Point=weights(1,:)+t*weights(2,:)

% n=size(Locations,1);
% M=[ones(n,1) Locations(:,1:2)];
% z=Locations(:,3);
% weights=(M'*M)\M'*z;

n=size(Locations,1);
t=[1:1:n]';
weights=zeros(2,size(Locations,2));

for i=1:size(Locations,2)
    weights(:,i)=fitLine2D(Locations(:,i),n,t);
end


fittedPoints=weights(1,:)+t*weights(2,:);
err=sum(sum((fittedPoints-Locations).^2));
end

function w=fitLine2D(data,n,t)
%find the bias and slope for a 2D line. t is independent, data is dependent.  


M=[ones(n,1), t];
w=LinearRegressionFit(M,data);

end