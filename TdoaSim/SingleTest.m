clearvars
close all
%this will test TDoA on a simple satellite test case.
addpath('LocateSat');
addpath('TimeDiff');
% All elevations in Rochester are assumed to be 154 meters

Stations = [43.063532 -77.689936 154; 43.086285 -77.668015 154; 43.048300 -77.658663 154];
% GND_Error = [0.000001 0.000001 0 0; 0.000001 0.000001 0 0; 0.000001 0.000001 0 0];
GND_Error = zeros(3,4);
Satellites = [43.084625 -77.674371 775000];
% SAT_Error = [0.000001 0.000001 0 0];
SAT_Error= zeros(1,4);

GND = getStruct(Stations, GND_Error);
SAT = getStruct(Satellites, SAT_Error);

timeDifferences = timeDiff(GND, SAT)


%% TDoA
receivers=[GND(1).coord; GND(2).coord; GND(3).coord];
Satxyz=SAT.coord;
A_B=timeDifferences(1,1,1);
A_C=timeDifferences(1,1,2);
B_C=timeDifferences(1,1,3);
TimeDiffs=abs([0 A_B A_C; 0 0 B_C; 0 0 0]);
DistanceDiffs=TimeDiffs*3e8;
expected=Satxyz;

figure()
plot3(expected(1),expected(2),expected(3),'o','linewidth',3);
% plot3(
grid on
hold on
locations=TDoA(receivers,DistanceDiffs,10,[4.5e6 4.8e6 5.1e6 ]);

syms t
h1=figure(5);
% h2=h1.Children;
% X1=h2.XLim;
% Y1=h2.YLim;
% Z1=h2.ZLim;

hold on
fplot3(locations(1,1)+t*locations(2,1),locations(1,2)+t*locations(2,2),locations(1,3)+t*locations(2,3));%,[X1 Y1 Z1]);
hi=1;