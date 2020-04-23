clearvars
close all
%this tutorial will test TDoA on a simple satellite test case.


%Add the required paths.
addpath('./LocateSat/')
addpath('./TimeDiff/')


%Dictate the tests to run, see the user manual.
test3stations_ECEF=1; %Apply 3 stations
test3stations_Topo=1; %Apply 3 stations
test4stations=0; %apply 4 stations BROKEN 
simulatedNoise=0;

%Define station coordinates in geo
Stations_geo = [43.063532 -77.689936 154; 43.086285 -77.668015 154; 43.048300 -77.658663 154];
Stations4_geo= [43.063532 -77.689936 154; 43.086285 -77.668015 154; 43.048300 -77.658663 154; 43.080282, -77.709150 154];

%Define some errors. NOTE: the errors we show here are completely madeup
%and have no correlation with our current system.
locationErr=[0.00005 0.0001 .9]; %lat, long, altitude
timeSyncErr=3e-9; %timing
GND_Error = [locationErr timeSyncErr; locationErr timeSyncErr; locationErr timeSyncErr];
GND_Error4 = [locationErr timeSyncErr; locationErr timeSyncErr; locationErr timeSyncErr; locationErr timeSyncErr];

Satellites = [43.084625 -77.674371 775000];
SAT_Error= zeros(1,4); %we are placing the satellite in the sky. So it doesn't really make sense to add noise here.

%Create structures for the ground network and the satellite.
GND = getStruct(Stations_geo, GND_Error, Stations_geo(1,:), GND_Error(1,:));
GND4= getStruct(Stations4_geo, GND_Error4, Stations_geo(1,:), GND_Error(1,:));
SAT = getStruct(Satellites, SAT_Error, Stations_geo(1,:), GND_Error(1,:));

%Get the simulated time differences based on the satellite location.
timeDifferences = timeDiff(GND, SAT);
timeDifferences4 = timeDiff(GND4, SAT);

%Generate a random number for the time dfference noise.
randomNumber=(rand(3,3)*2-1);
%% TDoA 3 Stations. A direction.
if test3stations_ECEF==1
%Get the receivers in Earth Cenetered Coordinates
receivers=[GND(1).ECFcoord; GND(2).ECFcoord; GND(3).ECFcoord];
Satxyz=SAT.ECFcoord;

%Get the time difference in matrix form for input to TDoA
[TimeDiffs,TimeDiffsErr]=timeDiff3toMatrix(GND,SAT);

%Add some noise, if specified.
if simulatedNoise==1
    ErrorAdded=TimeDiffsErr.*randomNumber;
    TimeDiffs=TimeDiffs+ErrorAdded; %rand -1 to 1.
end
DistanceDiffs=TimeDiffs*3e8;

expected=Satxyz;

figure()
plot3(expected(1),expected(2),expected(3),'o','linewidth',3);
title('3 Stations Direction Test')
grid on
hold on
%Calculate the satellite direction. 
locations=TDoA(receivers,DistanceDiffs,[],referenceSphere('Earth'),10,[4.5e6 4.8e6 5.1e6 ],1,'',1);
disp('Earth Centered Fixed Frame')
disp(['Direction (in deg): ' num2str(locations(1,:)*180/pi)])
disp(['Referenced From: ' num2str(locations(2,:))])
legend('Satellite','Station','','Reference point','Direction')

if test3stations_ECEF==1 && test3stations_Topo==1
    %for use in part 4 of the tutorial. Comparind topocentric and ECEF
    %coordinates. 
    figure(4)
    plot3(expected(1),expected(2),expected(3),'o','linewidth',3);
    title('3 Stations Direction Test')
    grid on
    hold on
    locations=TDoA(receivers,DistanceDiffs,[],referenceSphere('Earth'),10,[4.5e6 4.8e6 5.1e6 ],1,'',1);
    legend('Satellite','Station','','Reference point','Direction')
    
end

end
%% TDoA 3 stations Topocentric Frame. Part 2
if test3stations_Topo==1
%we now measure everything in a topocentric frame centered at station 1.
receivers=[GND(1).Topocoord; GND(2).Topocoord; GND(3).Topocoord];
Satxyz=SAT.Topocoord;
[TimeDiffs,TimeDiffsErr]=timeDiff3toMatrix(GND,SAT);
if simulatedNoise==1
    ErrorAdded=TimeDiffsErr.*randomNumber;
    TimeDiffs=TimeDiffs+ErrorAdded; %rand -1 to 1.
end
DistanceDiffs=TimeDiffs*3e8;
expected=Satxyz;

figure()
plot3(expected(1),expected(2),expected(3),'o','linewidth',3);
title('3 Stations Direction Test')
grid on
hold on
locations_topo=TDoA(receivers,DistanceDiffs,Stations_geo(1,:),referenceSphere('Earth'),10,[50e3 400e3 1200e3 ],1,'',1);
disp('Topocentric Frame, centered at Station 1')
disp(['Direction (in deg): ' num2str(locations_topo(1,:)*180/pi)])
disp(['Referenced From: ' num2str(locations_topo(2,:))])
legend('Satellite','Station','','Reference point','Direction')
end


%% Some comparisons Part 3 and 4
if test3stations_ECEF==1 && test3stations_Topo==1
   
    addpath('TestScripts\')
    
    DeltaDirection=locations(1,:)-locations_topo(1,:)
    %code will throw an error if the directions from part 1 and 2 are more
    %than 0.5 degrees off. They should be very close. 
    AssertToleranceMatrix(locations(1,:),locations_topo(1,:),0.5);
    
    %convert the topocentric output reference point to the Earth Fixed
    %Frame for comparison
    [X,Y,Z]=enu2ecef(locations_topo(2,1),locations_topo(2,2),...
        locations_topo(2,3),Stations_geo(1,1),Stations_geo(1,2),...
        Stations_geo(1,3),referenceSphere('Earth'));
    
    %they are in perfect agreement. See the user manual as to why. 
    DeltaReference=locations(2,:)-[X,Y,Z]
    
    figure()
    plot3(locations(2,1),locations(2,2),locations(2,3),'s','color','red','MarkerFaceColor','red')
    hold on
    grid on
    plot3(X,Y,Z,'^','color','blue','MarkerFaceColor','blue')
    plot3(0,0,0,'o','color','black','MarkerFaceColor','black')
    legend('ECEF fit','Topo Fit','Center of the Earth')
    
    %Part 4. Rotate the figure. Notice despite the references being located
    %in different XYZ coordinates, they lie on the same line!
    figure(4)
    plot3(X,Y,Z,'^','color','blue','MarkerFaceColor','blue')
    legend('Satellite','Station','','Reference point','Direction','','Topo Reference Point')
    
end

%order the figures for proper viewings.
figure(4)
figure(3)
figure(2)
figure(1)


%% TDoA 4 stations a Point.
%this is broken.  TDoA 4+ stations needs updating. 
if test4stations==1
receivers=[GND4(1).ECFcoord; GND4(2).ECFcoord; GND4(3).ECFcoord; GND4(4).ECFcoord];
Satxyz=SAT.ECFcoord;
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
locations=TDoA(receivers,DistanceDiffs,[],referenceSphere('Earth'),10,[4.5e6 4.8e6 5.1e6 ],1,'',1);

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
hi=1;
end