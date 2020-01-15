%This test explores all similar the uncertainty estimate is to actual
%error.
clearvars
close all



% h1=gcp;
% h1=parpool;

AddAllPaths
load RangePolynomial.mat;
P;

R2=[42.700192000000000	-77.408628000000010	701.000000000000000]; %mees
R8=[43.213809 -77.190456 140+2*4]; %williamson high school
R9=[43.0162 -78.1380 272+3*4]; %GCC library

TR=[R2;R9;R8]; OF='MeesGCCWilliamson';


% TimeSyncErrFar=100e-9; %100ns time sync error.
TimeSyncErrFar=5e-6;
RL_err=ones(3,3)*9; %9m location error.

%% Invariants
ClkError=ones(3,1)*TimeSyncErrFar; %3x1
Sphere=wgs84Ellipsoid;


ReceiverError=[zeros(3,3) ClkError];

%% Input Ranges
%For nominal tests.
% AzimuthRange=0:10:359; %ALWAYS wrt to the first receiver. 
% ElevationRange=5:5:90;

%for quick testing
% AzimuthRange=0:45:360;
% ElevationRange=5:15:80;

%for really quick testing
AzimuthRange=180;
ElevationRange=45;

%this set of inputs causes an error!
% AzimuthRange=0:2.5:359; ElevationRange=1:1:4;


SatelliteAltitudeRange=500e3; %range of satellite range values.


DebugMode=0;
T=TR;
OutputFolder=OF;
start=1;

solver=1; %0 symbolic solver, 1 least squares.

%% Create satellite test case, run Monte Carlo
GND=getStruct(T,ReceiverError,T(1,:),ReceiverError(1,:),Sphere);
GND(1).ECFcoord_error=RL_err(1,:);
GND(2).ECFcoord_error=RL_err(2,:);
GND(3).ECFcoord_error=RL_err(3,:);

Test=zeros(length(AzimuthRange)*length(ElevationRange),2);
p=0;
for i=1:length(AzimuthRange)
    for j=1:length(ElevationRange)
        p=p+1;
        Test(p,:)=[AzimuthRange(i) ElevationRange(j)];
    end
end

Azimuths=Test(:,1);
Elevations=Test(:,2);
Ranges=RangeApproximate(Elevations,SatelliteAltitudeRange,P);
Refx=T(1,1);
Refy=T(1,2);
Refz=T(1,3);

AllMeans=zeros(p,2);
AllstdDevs=zeros(p,2);
AllMeanErrors=zeros(p,2);
AllstdDevError=zeros(p,2);
AllRawData=cell(p,1);

%    parfor i=start:p

%% Test Parameters
RL_errForTest=RL_err;
RL_errForTest(1,:)=0;
RT=[GND(1).Topocoord; GND(2).Topocoord; GND(3).Topocoord];
zPlanes=[50e3 400e3 1200e3];
costFunction=1;
plotSavePath='';
numTests=100;
%%

%% Run Tests
for i=start:p
    Az=Azimuths(i);
    El=Elevations(i);
    Rng=Ranges(i);
        [means,stdDev,meanError,stdDevError, Data]=MonteCarlo(numTests,Az,El,Rng,T,RL_err,ClkError,DebugMode,solver);
        AllMeans(i,:)=means;
        AllstdDevs(i,:)=stdDev;
        AllMeanErrors(i,:)=meanError;
        AllstdDevError(i,:)=stdDevError;
        AllRawData{i}=Data;
        
        [lat, long, h]=enu2geodetic(Rng*cosd(El)*sind(Az),Rng*cosd(El)*cosd(Az),Rng*sind(El),TR(1,1),TR(1,2),TR(1,3),Sphere);
        SAT=getStruct([lat long h],zeros(1,4),RT(1,:),zeros(1,4),Sphere);
        [TimeDiff, TimeDiffErr]=timeDiff3toMatrix(GND,SAT);
        TR_err=[1e-5*pi/180 1e-5*pi/180 3];
        [location,location_error,rawData]=TDoAwithErrorEstimation(numTests,RL_errForTest(:,1:3),TimeDiffErr*3e8,TR_err,RT,TimeDiff*3e8,TR(1,:),Sphere,0,zPlanes,DebugMode,'',costFunction,plotSavePath);

%         RefPoints=rawData.EstRef;
%         RefAz=rawData.EstAzEl(:,1);
%         RefEl=rawData.EstAzEl(:,2);
%         
%         LineEndPoint=[Rng*cos(RefEl).*sin(RefAz) Rng*cos(RefEl).*cos(RefAz) Rng*sin(RefEl)]+RefPoints;
%         LineSlopes=LineEndPoint-RefPoints;
%         
%         meanRef=nanmean(RefPoints);
%         StdRef=nanstd(RefPoints);
%         uncertaintyRef=StdRef*2;
%         
%         meanLineSlope=nanmean(LineSlopes);
%         StdLineSlope=nanstd(LineSlopes);
%         uncertaintyLineSlope=StdLineSlope*2;
%         meanDirection=[atan2(meanLineSlope(1),meanLineSlope(2)) atan2(meanLineSlope(3),sqrt(sum(meanLineSlope(1:2).^2)))];
% %         uncertaintyDirection=
%         
%         dx=uncertaintyLineSlope(1);
%         dy=uncertaintyLineSlope(2);
%         dz=uncertaintyLineSlope(3);
%         x=meanLineSlope(1);
%         y=meanLineSlope(2);
%         z=meanLineSlope(3);
%         dazdx=1/(y*(x^2/y^2 + 1));
%         dazdy=-x/(y^2*(x^2/y^2 + 1));
%         deldx=-(x*z)/((z^2/(x^2 + y^2) + 1)*(x^2 + y^2)^(3/2));
%         deldy=-(y*z)/((z^2/(x^2 + y^2) + 1)*(x^2 + y^2)^(3/2));
%         deldz=1/((z^2/(x^2 + y^2) + 1)*(x^2 + y^2)^(1/2));
%         
%         daz=sqrt((dazdx*dx)^2+(dazdy*dy)^2);
%         del=sqrt((deldx*dx)^2+(deldy*dy)^2+(deldz*dz)^2);
        
%         figure()
%         plot3(RefPoints(1,1),RefPoints(1,2),RefPoints(1,3),'o','linewidth',4,'color','green')
%         hold on
%         plot3([RefPoints(1,1) LineEndPoint(1,1)], [RefPoints(1,2) LineEndPoint(1,2)], [RefPoints(1,3) LineEndPoint(1,3)], 'color','red','linewidth',3)
%         
%         plot3(RefPoints(2:end,1),RefPoints(2:end,2),RefPoints(2:end,3),'.','linewidth',3,'color','blue');
%         title(['Reference Errors: ' num2str(uncertaintyRef) 'm and AzEl Errors: ' num2str(daz*180/pi) '&' num2str(del*180/pi) ' deg'])
%         xlabel('X east (m)')
%         ylabel('Y north (m)')
%         zlabel('Z zenith (m)')
%         grid on
% 
%         
%         for jj=1:length(LineEndPoint)
%             plot3([RefPoints(jj,1) LineEndPoint(jj,1)], [RefPoints(jj,2) LineEndPoint(jj,2)], [RefPoints(jj,3) LineEndPoint(jj,3)],'.-', 'color','cyan')
%         end
%         
%         %either does not work as intended or just doesn't look pretty.
% %         for i1=-1:2:1
% %             for j1=-1:2:1
% %                 for k1=-1:2:1
% %                     for L1=-1:2:1
% %                         for m1=-1:2:1
% %                             refBound=meanRef+[i1 j1 k1].*uncertaintyRef;
% %                             elBound=location(1,2)+L1*del;
% %                             azBound=location(1,1)+m1*daz;
% %                             LineEndPointBound=[Rng*cos(elBound).*sin(azBound) Rng*cos(elBound).*cos(azBound) Rng*sin(elBound)]+refBound;
% %                             plot3([refBound(1) LineEndPointBound(1)], [refBound(2) LineEndPointBound(2)], [refBound(3) LineEndPointBound(3)],'o-', 'color','blue','linewidth',2)
% %                         end
% %                     end
% %                 end
% %             end
% %         end
%         
%         legend('Nominal Reference','Nominal Direction','Reference Points','Directions')
        
        disp(i)
        fprintf('\n')
        AssertToleranceMatrix(means*180/pi,location(1,1:2)*180/pi,0.1);
        AssertToleranceMatrix(means*180/pi,location(3,1:2)*180/pi,0.1);
        AssertToleranceMatrix(stdDev*180/pi,location_error(1,1:2)*180/pi,0.5);
%         AssertToleranceMatrix(stdDev*180/pi,[daz del]*180/pi,0.5);

%     catch ME
%         fprintf('\n')
%         fprintf(['Test ' num2str(i) ' failed due to ' ME.message ' on line ' num2str(ME.stack(end).line)]);
%         fprintf('\n')
%     end
end
% GraphSaver({'png','fig'},'../Plots/TDoAexploration',1);

save(['UncertaintyTestResults/' OutputFolder])





