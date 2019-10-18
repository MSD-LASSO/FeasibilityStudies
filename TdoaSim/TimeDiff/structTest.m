Stations = [43.063532 -77.689936 154; 43.086285 -77.668015 154; 43.048300 -77.658663 154];
GND_Error = [0.000001 0.000001 0 0; 0.000001 0.000001 0 0; 0.000001 0.000001 0 0];
Satellites = [43.084625 -77.674371 775000];
SAT_Error = [0.000001 0.000001 0 0];


GND = getStruct(Stations, GND_Error);
SAT = getStruct(Satellites, SAT_Error);
assert(GND(2).lat==43.086285);

GND(3)



% %Ground Station A: The Hill At Rochester (formlerly ratchet club)
% %43.063532, -77.689936, 154m
% A = [43.063532 -77.689936 154];
% A_er = 0.000001;
% A_elev_er = 0;
% clock_A = 0; %Account for 1ns of clock innacuracy
% 
% %Ground Station B: Mark Ellingson Hall
% %43.086285, -77.668015, 154m
% B = [43.086285 -77.668015 154];
% B_er = 0.000001;
% B_elev_er = 0;
% clock_B = 0; %Account for 1ns of clock innacuracy
% 
% %Ground Station C: RIT Inn and Conference Center
% %43.048300, -77.658663, 154m
% C = [43.048300 -77.658663 154];
% C_er = 0.000001;
% C_elev_er = 0;
% clock_C = 0; %Account for 1ns of clock innacuracy

% %Satellite is directly overhead of the sentinel
% % 43.084625, -77.674371, 775km
% SAT = [43.084625 -77.674371 775000];
% SAT_er = 0;
% SAT_elev_er = 0;
% S_er = [SAT_er SAT_er SAT_elev_er];