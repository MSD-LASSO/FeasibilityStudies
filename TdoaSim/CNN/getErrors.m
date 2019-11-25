function [ClkError,RL_err] = getErrors()

TimeSyncErrFar=100e-9;
ClkError=ones(3,1)*TimeSyncErrFar; %3x1
RL_err=ones(3,3)*9;
end

