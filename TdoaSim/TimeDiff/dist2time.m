function [time_diff, time_error] = dist2time(length_Sat2A, length_Sat2A_er, length_Sat2B, length_Sat2B_er, clock_A, clock_B)
%This function inputs the 2 distances between the satellite and 2 ground
%stations. It also inputs a clock error for each and a distance error.
%   The error is the sum of the distance error and the clock error
c = 299792458;
timeA = length_Sat2A / c;
timeA_error = length_Sat2A_er / c;

timeB = length_Sat2B / c;
timeB_error = length_Sat2B_er / c;

clock_error = abs(clock_A) + abs(clock_B);

time_diff = timeA-timeB;
time_error = clock_error + timeA_error + timeB_error;
end

