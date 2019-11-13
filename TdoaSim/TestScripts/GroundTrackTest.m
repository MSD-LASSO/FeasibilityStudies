%This script will test 4 distinct points in the sky on the TDoA algorithm.
%the goal of these tests is to evaluate whether TDoA is getting the right
%answer with no errors in the system.

%these values are intentionally hardcoded as they are not made to change!

clearvars
close all
AddAllPaths
Sphere=referenceSphere('Earth');

R1=[0.751981147060969	-1.355756142252390	0.000000000000000]*180/pi;
R2=[0.754139962266053	-1.360500226411991	0.000000000000000]*180/pi;
R3=[0.745258941633743	-1.351035428051473	0.000000000000000]*180/pi;
wrt=1;

% Test 1. Near 90 degrees Elevation
CorrectAzEl1=[1.420116627706961	4.534353629818127	505306.800452124900000];
CorrectLatLong1=[42.970173362488836	-78.529902515799800	500000.000000003300000];

% Test 2. Near 60 degrees Elevation
CorrectAzEl2=[1.079432439071580	3.631492807810037	561301.595367456800000];
CorrectLatLong2=[41.127745003408684	-79.058801910051710	500000.000000005060000];

% Test 3. Near 30 degrees Elevation
CorrectAzEl3=[0.502037788906868	3.445979547719456	936713.730361054900000];
CorrectLatLong3=[36.507217302112310	-80.233083772327920	500000.000000004000000];

% Test 4. Near 0 degrees Elevation
CorrectAzEl4=[0.001319580295457	3.376827576966401	2564737.079504350700000];
CorrectLatLong4=[21.629967379902713	-83.049196699587950	500000.000000002150000];

% Visualization of Problem
reference=R1;
R=[R1; R2; R3];
CorrectLatLong=[CorrectLatLong1;CorrectLatLong2;CorrectLatLong3;CorrectLatLong4];

[xR, yR, zR]=geodetic2enu(R(:,1),R(:,2),R(:,3),reference(1),reference(2),reference(3),Sphere);
[xS, yS, zS]=geodetic2enu(CorrectLatLong(:,1),CorrectLatLong(:,2),CorrectLatLong(:,3),reference(1),reference(2),reference(3),Sphere);

%create 5 instances of the same plot. Each test will update 2 plots.
for i=1:5
    h(i)=figure()
    plot3(xR,yR,zR,'s','color','red','linewidth',3)
    hold on
    plot3(xS,yS,zS,'.','color','green','MarkerSize',25)
    xlabel('x East (m)')
    ylabel('y North (m)')
    zlabel('z Zenith (m)')
    title('Test Setup of a Crude Ground Track in the Topocentric Frame')
    axis equal
    h1=gca;
    set(h1,'FontSize',14);
    Title=h1.Title;
    Title.FontSize=18;
    grid on
    legend('Receiver Locations','Satellite Locations')
end

GND=getStruct(R, zeros(3,4), reference,zeros(1,4),Sphere);
SAT=getStruct(CorrectLatLong, zeros(4,4), reference,zeros(1,4),Sphere);

%% Tests
Elevation={'90','60','30','0'};
Range=2800000; %I chose this value for the plot. 
numTests=4;
for i=1:numTests
TimeDiffs=timeDiff3toMatrix(GND,SAT(i));
receivers=[GND(1).Topocoord; GND(2).Topocoord; GND(3).Topocoord];
figure(h(i))
locations=TDoA(receivers,TimeDiffs*3e8,reference,Sphere,1e-10,[50e7 100e7 200e7 500e7 2000e7],1,['CrudeGroundTrackTestElevation: ' Elevation{i}]);
title(['TDoA solution to near ' Elevation{i} ' degree elevation test case'])
legend('Receiver Locations','Satellite Locations','Receiver Connections','Hab','Hac','Hbc','Planes','L1','L1Bias','L2','L2Bias')
virtualStation(i,:)=locations(2,:);
[y, x, z]=sph2cart(locations(1,1),locations(1,2),Range);
FurtherPoint(i,:)=[x y z];

expected=SAT(i).Topocoord;
[az, el]=geo2AzEl(expected,locations(2,:),reference);
expectedAzEl=[az el 0];
actualAzEl=locations(1,:);

[y, x, z]=sph2cart(az,el,Range);
FurtherPointCorrect(i,:)=[x y z];


%ignore 2nd solution...momentarily.
soln1(i,:)=expectedAzEl-actualAzEl;
end

%% Final Visualization
figure(h(5))
plot3(virtualStation(:,1),virtualStation(:,2),virtualStation(:,3),'d','color','blue','linewidth',3)
for i=1:numTests
    plot3([virtualStation(i,1) virtualStation(i,1)+FurtherPoint(i,1)],...
        [virtualStation(i,2) virtualStation(i,2)+FurtherPoint(i,2)],...
        [virtualStation(i,3) virtualStation(i,3)+FurtherPoint(i,3)],...
        'color','blue','linewidth',3)
    plot3([virtualStation(i,1) virtualStation(i,1)+FurtherPointCorrect(i,1)],...
        [virtualStation(i,2) virtualStation(i,2)+FurtherPointCorrect(i,2)],...
        [virtualStation(i,3) virtualStation(i,3)+FurtherPointCorrect(i,3)],...
        'color','green','linewidth',3)
end
legend('Receiver Locations','Satellite Locations','Virtual Stations')

figure()
subplot(1,2,1)
plot([90 60 30 0],soln1(:,1)*180/pi,'s','linewidth',3);
xlabel('True Elevation of Satellite (deg)')
ylabel('Azimuth Error (deg)')
title('Azimuth Error. No input error')
grid on
subplot(1,2,2)
plot([90 60 30 0],soln1(:,2)*180/pi,'s','linewidth',3);
xlabel('True Elevation of Satellite (deg)')
ylabel('Elevation Error (deg)')
title('Elevation Error. No input error')
grid on

GraphSaver({'png'},'../Plots/GroundTrackTestAllZPlanes',1);


