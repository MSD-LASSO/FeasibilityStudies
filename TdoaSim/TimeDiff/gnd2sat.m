function [distance, dist_er] = gnd2sat(gnd, gnd_er, sat,  sat_er)
%This function takes in a position vector for a satellite and a ground
%station. It also takes in an error vector for each of the position.
%The function outputs the distance between them and an error for that
%distance
%   The lat and long inputs are in degrees. The elevation is relative to
%   sea level.
[x_gnd, y_gnd, z_gnd, xg_er, yg_er, zg_er] = geo2rect(gnd(1), gnd_er(1), gnd(2), gnd_er(2), gnd(3), gnd_er(3));
[x_sat, y_sat, z_sat, xs_er, ys_er, zs_er] = geo2rect(sat(1), sat_er(1), sat(2), sat_er(2), sat(3), sat_er(3));

gnd = [x_gnd y_gnd z_gnd];
sat = [x_sat y_sat z_sat];

gnd_min = [x_gnd-xg_er y_gnd-yg_er z_gnd-zg_er];
gnd_max = [x_gnd+xg_er y_gnd+yg_er z_gnd+zg_er];

sat_min = [x_sat-xs_er y_sat-ys_er z_sat-zs_er];
sat_max = [x_sat+xs_er y_sat+ys_er z_sat+zs_er];

distance = norm(sat - gnd);

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

