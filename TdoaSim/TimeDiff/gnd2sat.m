function [distance, dist_er] = gnd2sat(ground, Gerror, satellite,  Serror)
%This function takes in a position vector for a satellite and a ground
%station. It also takes in an error vector for each of the position.
%The function outputs the distance between them and an error for that
%distance
%   The lat and long inputs are in degrees. The elevation is relative to
%   sea level.

gnd_min = ground - Gerror;
gnd_max = ground + Gerror;

sat_min = satellite - Serror;
sat_max = satellite + Serror;

distance = norm(satellite - ground);

g1 = norm(gnd_max - gnd_max)/2;
g2 = norm(gnd_max - gnd_min)/2;
g3 = norm(gnd_min - gnd_max)/2;
g4 = norm(gnd_min - gnd_min)/2;

g_dist_er = max([g1 g2 g3 g4]);

s1 = norm(sat_max - sat_max)/2;
s2 = norm(sat_max - sat_min)/2;
s3 = norm(sat_min - sat_max)/2;
s4 = norm(sat_min - sat_min)/2;

s_dist_er = max([s1 s2 s3 s4]);

dist_er = g_dist_er + s_dist_er;
end

