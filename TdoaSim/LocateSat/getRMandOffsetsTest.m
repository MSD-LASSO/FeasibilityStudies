%this script will test getRMandOffsets on some toy examples. 
%the tests will slowly work up to something that is expected for the TDoA
%simulator

%% No Angle. Offset only. 2D.
R1=[1 1 0];
R2=[3 1 0];
[RM,Offset]=getRMandOffsets(R1,R2);
assert(Offset(1)==2);
assert(Offset(2)==1);
assert(Offset(3)==0);
assert(sum(sum(RM==eye(3)))==9); %by equaling 9, all elements are same. 

%% No Angle. Offset only. 3D.
R1=[3 4 5];
R2=[7 4 5];
[RM,Offset]=getRMandOffsets(R1,R2);
assert(Offset(1)==5);
assert(Offset(2)==4);
assert(Offset(3)==5);
assert(sum(sum(RM==eye(3)))==9); %by equaling 9, all elements are same.

%% 45 deg Angle. Offset. 2D
R1=[1 1 0];
R2=[3 3 0];
[RM,Offset]=getRMandOffsets(R1,R2);
expectedO=[2 2 0];
AssertToleranceMatrix(expectedO,Offset,0.001);
expectedRM=[sqrt(2)/2 -sqrt(2)/2 0; sqrt(2)/2 sqrt(2)/2 0; 0 0 1];
AssertToleranceMatrix(expectedRM,RM,0.001);

%% 10 deg Azimuth, 35 deg Elevation. No offset. 3D.
R1=[0 0 0];
R2=[4.03354 0.711221 2.86788];
[RM,Offset]=getRMandOffsets(R1,R2);
expectedO=R2/2;
AssertToleranceMatrix(expectedO,Offset,0.001);
expectedRM=[cosd(10)*cosd(35) -sind(10) -cosd(10)*sind(35); sind(10)*cosd(35) cosd(10) -sind(10)*sind(35); sind(35) 0 cosd(35)];
AssertToleranceMatrix(expectedRM,RM,0.001);

%% 10 deg Azimuth, 35 deg Elevation. Offset. 3D.
R1=[2 3 4];
R2=[4.03354 0.711221 2.86788]+R1;
[RM,Offset]=getRMandOffsets(R1,R2);
expectedO=(R2-R1)/2+R1;
AssertToleranceMatrix(expectedO,Offset,0.001);
expectedRM=[cosd(10)*cosd(35) -sind(10) -cosd(10)*sind(35); sind(10)*cosd(35) cosd(10) -sind(10)*sind(35); sind(35) 0 cosd(35)];
AssertToleranceMatrix(expectedRM,RM,0.001);



