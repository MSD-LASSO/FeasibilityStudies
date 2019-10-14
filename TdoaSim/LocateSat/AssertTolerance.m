function AssertTolerance(Expected,Actual,Tolerance)
%This Function will throw an error if the actual value is different than
%Expected by more than the Tolerance.
assert(Actual<=Expected+Tolerance,['Actual ' num2str(Actual) 'is greater than Expected ' num2str(Expected)]);
assert(Actual>=Expected-Tolerance,['Actual ' num2str(Actual) 'is less than Expected ' num2str(Expected)]);
end

