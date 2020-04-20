clearvars
addpath('LocateSat')
addpath('TimeDiff')

%Run this script to see the average distance and maximum angle of each
%proposed triangle. This script is not called by anything, just used as a
%reference. The smaller the max angle, the better conditioned the triangle
%is. The larger the mean distance, the better TDoA will perform.
%These triangles are used in the SensitivityAnalysisNet.m.

%Nominal location of all stations
R1=[43.209037000000000	-77.950921000000010	175.000000000000000]; %brockport
R2=[42.700192000000000	-77.408628000000010	701.000000000000000]; %mees
R3=[43.204291000000000	-77.469981000000000	147.000000000000000]; %webster
R4=[42.871390000000000	-78.018577000000000	323.000000000000000]; %pavilion
R5=[43.0853460000000 -77.6791050000000 170+4*4]; %Institute Hall
R6=[43.0483000000000 -77.6586630000000 176+5*4]; %RIT inn
R7=[43.0862850000000 -77.6680150000000 163.4+12*4]; %ellingson
R8=[43.213809 -77.190456 140+2*4]; %williamson high school
R9=[43.0162 -78.1380 272+3*4]; %GCC library

%Triangles.
TR{1}=[R2;R1;R3]; OF{1}='MeesBrockportWebster';
TR{2}=[R2;R3;R4]; OF{2}='MeesWebsterPavilion';
TR{3}=[R6;R5;R7]; OF{3}='InnInstituteEllingson';
TR{4}=[R2;R4;R6]; OF{4}='MeesPavilionInn';
TR{5}=[R6;R1;R3]; OF{5}='InnBrockportWebster';
TR{6}=[R2;R8;R1]; OF{6}='MeesWilliamsonBrockport';
TR{7}=[R6;R9;R1]; OF{7}='InnGCCBrockport';
TR{8}=[R2;R9;R8]; OF{8}='MeesGCCWilliamson';
TR{9}=[R2;R3;R9]; OF{9}='MeesWebsterGCC';
TR{10}=[R2;R6;R8]; OF{10}='MeesInnWilliamson';
Sphere=wgs84Ellipsoid;

Distance=zeros(10,4);
Angles=zeros(10,4);
for i=1:10
    ts=TR{i};
    GND=getStruct(ts,zeros(3,4),ts(1,:),zeros(1,4),Sphere);

    RT=[GND(1).Topocoord; GND(2).Topocoord; GND(3).Topocoord];
    d12=norm(RT(2,:)-RT(1,:));
    d13=norm(RT(3,:)-RT(1,:));
    d23=norm(RT(3,:)-RT(2,:));
    
    m=mean([d12 d13 d23]);
    
    %https://www.mathsisfun.com/algebra/trig-solving-sss-triangles.html
    a=d23;
    b=d13;
    c=d12;
    
    C=acosd((a^2+b^2-c^2)/(2*a*b));
    A=acosd((b^2+c^2-a^2)/(2*b*c));
    B=acosd((c^2+a^2-b^2)/(2*a*c));
    
    Distance(i,:)=[d12 d13 d23 m]/1000;
    Angles(i,:)=[A B C max([A B C])];
    
end

disp('Table of Triangles')
table(OF',Distance(:,4),Angles(:,4),'VariableNames',{'Name','Mean Distance (km)','Max Angle (deg)'})