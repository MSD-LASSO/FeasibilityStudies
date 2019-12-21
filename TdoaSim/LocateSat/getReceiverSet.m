function [receiverSet, distanceDiffSet, m]=getReceiverSet(n,receiverLocations,distanceDifferences)
%Separates the matrix of receiverLocations and distanceDifferences into all
%possible combinations of 3.
%Example: 4 stations -> 4 possible sets of 3 -> 4 possible directions --
%can then average these together.


receiverSet=cell(n*(n-1)*(n-2)/6,1);
distanceDiffSet=cell(n*(n-1)*(n-2)/6,1);
%the series looks something like 1,4,10,20,35,56,84 for n=[3 4 5 6 7 8 9].
m=0;
for i=1:n
    for j=i+1:n
        for k=j+1:n
            m=m+1;
            receiverSet{m}=receiverLocations([i j k],:);
            distanceDiffSet{m}=[0 distanceDifferences(i,j) distanceDifferences(i,k); 0 0 distanceDifferences(j,k); 0 0 0];
        end
    end
end



end

