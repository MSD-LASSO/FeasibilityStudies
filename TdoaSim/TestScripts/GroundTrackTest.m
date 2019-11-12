%This script will test 4 distinct points in the sky on the TDoA algorithm.
%the goal of these tests is to evaluate whether TDoA is getting the right
%answer with no errors in the system.

%these values are intentionally hardcoded as they are not made to change!

clearvars
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

%create 9 instances of the same plot. Each test will update 2 plots.
for i=1:9
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

%% Test 1
TimeDiffs=timeDiff3toMatrix(GND,SAT(1));
figure(h(1))
title('TDoA solution to near 90 degree elevation test case')
locations=TDoA(R,TimeDiffs*3e8,reference,1e-10,[0 50e3 100e3 200e3 500e3 2000e3],1,'CrudeGroundTrackTest');
[az, el]=geo2AzEl(expected,locations(2,:));

figure(h(2))
plot3(locations([2],1),locations([2],2),locations([2],3),'d','color','blue','linewidth',3)
plot3(locations([4],1),locations([4],2),locations([4],3),'d','color','magenta','linewidth',3)
legend('Receiver Locations','Satellite Locations','Virtual Station 1','Virtual Station 2')
expectedAzEl=[az el 0];
actualAzEl=locations([1 3],:);

%ignore 2nd solution...momentarily.
soln1=expectedAzEl-actualAzEl;

