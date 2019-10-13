%tester for gnd2sat
lat_er = 0.001;
long_er = 0.001;
elev_er = 5; %lat and long error in degrees, elevation error in meters

RIT = [43.0846 -77.6743 154]; %RIT Campus
Kodak = [43.1608 -77.6196 154]; %Kodak Tower
PITT = [43.094061 -77.512772 154]; % Pittsford dairy
SAT = [43.0846 -77.6743 775000]; %directly above RIT
ERROR = [lat_er long_er elev_er]; %lat and long error in degrees, elevation error in meters

[distance_RIT, dist_RIT_er] = gnd2sat(RIT, ERROR, SAT, ERROR);
[distance_Kodak, dist_Kodak_er] = gnd2sat(Kodak, ERROR, SAT, ERROR);
[distance_Pitt, dist_Pitt_er] = gnd2sat(PITT, ERROR, SAT, ERROR);