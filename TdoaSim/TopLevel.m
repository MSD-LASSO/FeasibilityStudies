% This is the main, top-level program.
% It will set the parameters and utilize the Calculate Time Difference 
% program and the Locate Satellite program for each point, then display the 
% results.

% Setup
earthRadius = 6371; %km
elev_low = 200;
elev_high = 600;


% Populate Satellite Points
% t=-pi:0.01:pi;
% sat_elev = zeros(1, length(t));
% sat_elev(1:floor(length(t)/2)) = linspace(earthRadius + elev_low, earthRadius + elev_high, floor(length(t)/2));
% sat_elev(floor(length(t)/2):length(t)) = linspace(earthRadius + elev_high, earthRadius + elev_low, length(t)-floor(length(t)/2)+1);
% x=sat_elev.*cos(t);
% y=sat_elev.*sin(t);
% z=sat_elev.*sin(t);
% plot3(x,y,z);

%with polar
theta = -pi:0.01:pi;
rho = zeros(1, length(theta));
rho(1:floor(length(theta)/2)) = linspace(earthRadius + elev_low, earthRadius + elev_high, floor(length(theta)/2));
rho(floor(length(theta)/2):length(theta)) = linspace(earthRadius + elev_high, earthRadius + elev_low, length(theta)-floor(length(theta)/2)+1);
polarZ = linspace(20, 20, length(theta));
[x, y, z] = pol2cart(theta, rho, polarZ);
plot3(x, y, z);


% Calculate Time Difference