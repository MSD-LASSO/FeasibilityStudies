%This script tests AssertTolerance functionality.

%% These should not throw an error. 
AssertTolerance(1,0,1);
AssertTolerance(1,1,1);
AssertTolerance(0.5,0.6,0.2);
AssertTolerance(0,-0.01,0.05);

%% These should throw an error
try
    AssertTolerance(0,-0.01,0.005)
    error('Test Failed')
catch
end
try
    AssertTolerance(0,0.01,0.005)
    error('Test Failed')
catch
end