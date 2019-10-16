% This is the main, top-level program.
% It will set the parameters and utilize the Calculate Time Difference 
% program and the Locate Satellite program for each point, then display the 
% results.

% Setup
earthRadius = 6371; %km
elev_low = earthRadius + 200;
elev_high = earthRadius + 600;

%Satellite Points
theta = -pi:0.001:pi;
rho = zeros(1, length(theta));
rho(1:floor(length(theta)/2)) = linspace(elev_low, elev_high, floor(length(theta)/2));
rho(floor(length(theta)/2):length(theta)) = linspace(elev_high, elev_low, length(theta)-floor(length(theta)/2)+1);
polarZ = 400*cos(theta);
[x, y, z] = pol2cart(theta, rho, polarZ);
plot3(x, y, z);
axis([-7000 7000 -7000 7000 -2000 2000]);

% Calculate Time Difference