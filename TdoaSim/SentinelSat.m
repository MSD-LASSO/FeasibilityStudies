clearvars
close all
%this will test TDoA on a simple satellite test case.
addpath('LocateSat');
addpath('TimeDiff');
% All elevations in Rochester are assumed to be 154 meters

Stations = [43.063532 -77.689936 154; 43.086285 -77.668015 154; 43.048300 -77.658663 154];
Stations4= [43.063532 -77.689936 154; 43.086285 -77.668015 154; 43.048300 -77.658663 154; 43.080282, -77.709150 154];
locationErr=[0.00005 0.0001 .9];
timeSyncErr=3e-9;
GND_Error = [locationErr timeSyncErr; locationErr timeSyncErr; locationErr timeSyncErr];
GND_Error4 = [locationErr timeSyncErr; locationErr timeSyncErr; locationErr timeSyncErr; locationErr timeSyncErr];
% GND_Error = zeros(3,4);
% GND_Error4 = zeros(4,4);
Satellites = [43.084625 -77.674371 775000];
% SAT_Error = [0.000001 0.000001 0 0];
SAT_Error= zeros(1,4);

GND = getStruct(Stations, GND_Error, Stations(1,:));
GND4= getStruct(Stations4, GND_Error4, Stations(1,:));
SAT = getStruct(Satellites, SAT_Error, Stations(1,:));

timeDifferences = timeDiff(GND, SAT);
timeDifferences4 = timeDiff(GND4, SAT);

Test1=0;
Test2=0;
Test3=1;
%% TDoA 3 Stations. A direction.
if Test1==1
receivers=[GND(1).coord; GND(2).coord; GND(3).coord];
Satxyz=SAT.coord;
% A_B=timeDifferences(1,1,1);
% A_C=timeDifferences(1,1,2);
% B_C=timeDifferences(1,1,3);
% TimeDiffs=abs([0 A_B A_C; 0 0 B_C; 0 0 0]);
[TimeDiffs,TimeDiffsErr]=timeDiff3toMatrix(GND,SAT);
ErrorAdded=TimeDiffsErr.*(rand(3,3)*2-1);
TimeDiffs=TimeDiffs+ErrorAdded; %rand -1 to 1.
DistanceDiffs=TimeDiffs*3e8;
expected=Satxyz;

figure()
plot3(expected(1),expected(2),expected(3),'o','linewidth',3);
title('3 Stations Direction Test')
% plot3(
grid on
hold on
locations=TDoA(receivers,DistanceDiffs,10,[4.5e6 4.8e6 5.1e6 ]);

syms t
h1=figure(1);
% h2=h1.Children;
% X1=h2.XLim;
% Y1=h2.YLim;
% Z1=h2.ZLim;

hold on
RM=getAzElRotationMatrix(locations(1,1),locations(1,2));
Range=[norm(Satxyz-locations(2,:)) 0 0];
RangeFixed=RM*Range'+locations(2,:)';
plot3([locations(2,1) RangeFixed(1)],[locations(2,2) RangeFixed(2)],[locations(2,3) RangeFixed(3)],'linewidth',3); 

RM=getAzElRotationMatrix(locations(3,1),locations(3,2));
Range=[norm(Satxyz-locations(4,:)) 0 0];
RangeFixed=RM*Range'+locations(4,:)';
plot3([locations(4,1) RangeFixed(1)],[locations(4,2) RangeFixed(2)],[locations(4,3) RangeFixed(3)],'linewidth',3); 
% fplot3(locations(1,1)+t*locations(2,1),locations(1,2)+t*locations(2,2),locations(1,3)+t*locations(2,3));%,[X1 Y1 Z1]);
hi=1;
GraphSaver({'png'},'Plots/Plots3Stations',0);
end
%% TDoA 4 stations a Point.
if Test2==1
receivers=[GND4(1).coord; GND4(2).coord; GND4(3).coord; GND4(4).coord];
Satxyz=SAT.coord;
A_B=timeDifferences4(1,1,1);
A_C=timeDifferences4(1,1,2);
A_D=timeDifferences4(1,1,3);
B_C=timeDifferences4(1,1,4);
B_D=timeDifferences4(1,1,5);
C_D=timeDifferences4(1,1,6);
TimeDiffs=abs([0 A_B A_C A_D; 0 0 B_C B_D; 0 0 0 C_D; 0 0 0 0]);
DistanceDiffs=TimeDiffs*3e8;
expected=Satxyz;

figure()
plot3(expected(1),expected(2),expected(3),'o','linewidth',3);
% plot3(
grid on
hold on
locations=TDoA(receivers,DistanceDiffs,10,[4.5e6 4.8e6 5.1e6 ]);

syms t
h1=figure(1);
% h2=h1.Children;
% X1=h2.XLim;
% Y1=h2.YLim;
% Z1=h2.ZLim;

hold on
RM=getAzElRotationMatrix(locations(1,1),locations(1,2));
Range=[norm(Satxyz-locations(2,:)) 0 0];
RangeFixed=RM*Range'+locations(2,:)';
plot3([locations(2,1) RangeFixed(1)],[locations(2,2) RangeFixed(2)],[locations(2,3) RangeFixed(3)],'linewidth',3); 

RM=getAzElRotationMatrix(locations(3,1),locations(3,2));
Range=[norm(Satxyz-locations(4,:)) 0 0];
RangeFixed=RM*Range'+locations(4,:)';
plot3([locations(4,1) RangeFixed(1)],[locations(4,2) RangeFixed(2)],[locations(4,3) RangeFixed(3)],'linewidth',3); 
% fplot3(locations(1,1)+t*locations(2,1),locations(1,2)+t*locations(2,2),locations(1,3)+t*locations(2,3));%,[X1 Y1 Z1]);
hi=1;
end

%% oneatatime
if Test3==1
% OneAtaTime3(GND,SAT,1,1,'SentinelSatTopo',1);
OneAtaTime3(GND,SAT,1,1,'SentinelSatECF',0);
% OneAtaTime4(GND4,SAT,0,1);
end