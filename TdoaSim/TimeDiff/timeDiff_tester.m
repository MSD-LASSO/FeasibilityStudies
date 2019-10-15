% All elevations in Rochester are assumed to be 154 meters

%Ground Station A: The Hill At Rochester (formlerly ratchet club)
%43.063532, -77.689936, 154m
A = [43.063532 -77.689936 154];
A_er = 0.00000;
A_elev_er = 0;
clock_A = 0; %Account for 1ns of clock innacuracy

%Ground Station B: Mark Ellingson Hall
%43.086285, -77.668015, 154m
B = [43.086285 -77.668015 154];
B_er = 0.00000;
B_elev_er = 0;
clock_B = 0; %Account for 1ns of clock innacuracy

%Ground Station C: RIT Inn and Conference Center
%43.048300, -77.658663, 154m
C = [43.048300 -77.658663 154];
C_er = 0.00000;
C_elev_er = 0;
clock_C = 0; %Account for 1ns of clock innacuracy

%Satellite is directly overhead of the sentinel
% 43.084625, -77.674371, 775km
SAT = [43.084625 -77.674371 775000];
SAT_er = 0;
SAT_elev_er = 0;
S_er = [SAT_er SAT_er SAT_elev_er];

[A_B, ErAB, A_C, ErAC, B_C, ErBC] = timeDiff(A, A_er, A_elev_er, clock_A, B, B_er, B_elev_er, clock_B, C, C_er, C_elev_er, clock_C, SAT, SAT_er, SAT_elev_er);

A_B
ErAB
A_C
ErAC
B_C
ErBC