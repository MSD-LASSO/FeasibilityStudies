function [A_B, ErAB, A_C, ErAC, B_C, ErBC] = timeDiff(A, A_er, A_elev_er, clock_A, B, B_er, B_elev_er, clock_B, C, C_er, C_elev_er, clock_C, SAT, SAT_er, SAT_elev_er)
%This function inputs the three geographical coordinates of the ground
%stations and a satellite and returns the time differences
%   Detailed explanation goes here

A_er = [A_er A_er A_elev_er];
B_er = [B_er B_er B_elev_er];
C_er = [C_er C_er C_elev_er];
S_er = [SAT_er SAT_er SAT_elev_er];

[d_A, d_A_er] = gnd2sat(A, A_er, SAT, S_er);
[d_B, d_B_er] = gnd2sat(B, B_er, SAT, S_er);
[d_C, d_C_er] = gnd2sat(C, C_er, SAT, S_er);

[A_B, ErAB] = dist2time(d_A, d_A_er, d_B, d_B_er, clock_A, clock_B);
[A_C, ErAC] = dist2time(d_A, d_A_er, d_C, d_C_er, clock_A, clock_C);
[B_C, ErBC] = dist2time(d_B, d_B_er, d_C, d_C_er, clock_B, clock_C);



end

