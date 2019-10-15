function AssertToleranceMatrix(Expected,Actual,Tolerance)
%This Function will throw an error if the actual value is different than
%Expected by more than the Tolerance. It will test each value in the given
%2D matrix.

if(size(Expected,1)~=size(Actual,1)) || (size(Expected,2)~=size(Actual,2))
    assert(1==0,'Expected and Actual are not the same size')
end

for i=1:size(Expected,1)
    for j=1:size(Expected,2)
        AssertTolerance(Expected(i,j),Actual(i,j),Tolerance)
    end
end
end

