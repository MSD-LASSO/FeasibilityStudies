%tester for gnd2sat
lat_er = 0.00001;
long_er = 0.00001;
clockA = 1e-9;
clockB = 1e-9;
elev_er = 5; %lat and long error in degrees, elevation error in meters

RIT = [43.0846 -77.6743 154]; %RIT Campus
Kodak = [43.1608 -77.6196 154]; %Kodak Tower
PITT = [43.094061 -77.512772 154]; % Pittsford dairy
SAT = [43.0846 -77.6743 775000]; %directly above RIT
ERROR = [lat_er long_er elev_er]; %lat and long error in degrees, elevation error in meters

[distance_RIT, dist_RIT_er] = gnd2sat(RIT, ERROR, SAT, ERROR);
[distance_Kodak, dist_Kodak_er] = gnd2sat(Kodak, ERROR, SAT, ERROR);
[distance_Pitt, dist_Pitt_er] = gnd2sat(PITT, ERROR, SAT, ERROR);

[R_K, Er1] = dist2time(distance_RIT, dist_RIT_er, distance_Kodak, dist_Kodak_er, clockA, clockB);
[R_P, Er2] = dist2time(distance_RIT, dist_RIT_er, distance_Pitt, dist_Pitt_er, clockA, clockB);
[P_K, Er3] = dist2time(distance_Pitt, dist_Pitt_er, distance_Kodak, dist_Kodak_er, clockA, clockB);