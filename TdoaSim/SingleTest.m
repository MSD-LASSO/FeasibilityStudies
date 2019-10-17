clearvars
close all
%this will test TDoA on a simple satellite test case.
addpath('LocateSat');
addpath('TimeDiff');
% All elevations in Rochester are assumed to be 154 meters

%Ground Station A: The Hill At Rochester (formlerly ratchet club)
%43.063532, -77.689936, 154m
A = [43.063532 -77.689936 154];
A_er = 0.00000;
A_elev_er = 0;
clock_A = 0; %Account for 1ns of clock innacuracy
[temp1,temp2,temp3]=geo2rect(A(1),0,A(2),0,A(3),0);
Axyz=[temp1 temp2 temp3];

%Ground Station B: Mark Ellingson Hall
%43.086285, -77.668015, 154m
B = [43.086285 -77.668015 154];
B_er = 0.00000;
B_elev_er = 0;
clock_B = 0; %Account for 1ns of clock innacuracy
[temp1,temp2,temp3]=geo2rect(B(1),0,B(2),0,B(3),0);
Bxyz=[temp1 temp2 temp3];

%Ground Station C: RIT Inn and Conference Center
%43.048300, -77.658663, 154m
C = [43.048300 -77.658663 154];
C_er = 0.00000;
C_elev_er = 0;
clock_C = 0; %Account for 1ns of clock innacuracy
[temp1,temp2,temp3]=geo2rect(C(1),0,C(2),0,C(3),0);
Cxyz=[temp1 temp2 temp3];


%Satellite is directly overhead of the sentinel
% 43.084625, -77.674371, 775km
SAT = [43.084625 -77.674371 775000];
SAT_er = 0;
SAT_elev_er = 0;
S_er = [SAT_er SAT_er SAT_elev_er];
[temp1,temp2,temp3]=geo2rect(SAT(1),0,SAT(2),0,SAT(3),0);
Satxyz=[temp1 temp2 temp3];

[A_B, ErAB, A_C, ErAC, B_C, ErBC] = timeDiff(A, A_er, A_elev_er, clock_A, B, B_er, B_elev_er, clock_B, C, C_er, C_elev_er, clock_C, SAT, SAT_er, SAT_elev_er);


%% TDoA
receivers=[Axyz;Bxyz;Cxyz];
TimeDiffs=[0 A_B A_C; 0 0 B_C; 0 0 0];
DistanceDiffs=TimeDiffs*3e8;
expected=Satxyz;

figure()
plot3(expected(1),expected(2),expected(3),'o','linewidth',3);
% plot3(
grid on
hold on
locations=TDoA(receivers,DistanceDiffs);
