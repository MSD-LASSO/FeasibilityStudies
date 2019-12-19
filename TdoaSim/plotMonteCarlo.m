%This script reads output files from a sensivity analysis and plots it.
clearvars
close all


addpath('LocateSat')
addpath('TimeDiff')

OF{1}='MeesBrockportWebster';
OF{2}='MeesWebsterPavilion';
OF{3}='InnInstituteEllingson';
OF{4}='MeesPavilionInn';
OF{5}='InnBrockportWebster';
OF{6}='MeesWilliamsonBrockport';
OF{7}='InnGCCBrockport';
OF{8}='MeesGCCWilliamson';
OF{9}='MeesWebsterGCC';
OF{10}='MeesInnWilliamson';
InputFolder='MonteCarloResults';
PlotOutputFolder='MonteCarlo10TrianglesLeastSquares';

numRows=18; %numRows=6;
numCols=36; %numCols=9;
MinElCriteria=5; %what is the minimum elevation criteria.
Vals=[0.5 1 2 5 10];
UncertaintyCriteria=5; %index of Vals to use. 
%some variable names
% Azimuths;
% Elevations;
% ClkError;
% RL_err;
% SensitivityTest;

TestsToRun=[1 2 3 4 5 6 7 8 9 10];
% TestsToRun=[8];
plotIntermediates=1;

n=length(TestsToRun);
% TDoACoverage=zeros(n,1);
UncertaintyCoverage=zeros(n,4);
AzimuthUncertaintyStat=zeros(n,2);
ElevationUncertaintyStat=zeros(n,2);
AzUncertaintyBox=zeros(n,3);
ElUncertaintyBox=zeros(n,3);
MinEl=zeros(n,1);
MaxEl=zeros(n,1);
MaxSensitivities=cell(n,1);

for TN=1:length(TestsToRun)
matName=OF{TestsToRun(TN)};
load([InputFolder '/OutputMonteCarlo' matName])
AllMeanErrors(AllMeanErrors==0)=nan;
AllstdDevError(AllstdDevError==0)=nan;
%% Reorganize the data
TotalUncertainty=(AllMeanErrors+2*AllstdDevError)*180/pi; %get error in degrees. 
if TotalUncertainty(i,1)>180 %can't be worse than 180 degrees off in azimuth.
    TotalUncertainty(i,1)=nan;
end
if TotalUncertainty(i,2)>90 %can't be worse than 90 degrees off in elevation.
    TotalUncertainty(i,2)=nan;
end

%% Get the triangle Azimuths and Elevations
temp=GND(2).Topocoord;
[R2R1az, R2R1el]=getAzEl([temp(2) temp(1) temp(3)]);
temp=GND(3).Topocoord;
[R3R1az, R3R1el]=getAzEl([temp(2) temp(1) temp(3)]);

%% Plot
x=reshape(Azimuths,numRows,numCols);
y=reshape(Elevations,numRows,numCols);

%3D plots
z=reshape(TotalUncertainty(:,1),numRows,numCols);
z2=reshape(TotalUncertainty(:,2),numRows,numCols);

%% 3D plots of uncertainty
if plotIntermediates==1
    figure()
    colors = get(gca, 'ColorOrder');
    colormap(colors)
    surf(x,y,z,z*0+1)
%     plot3(Azimuths,Elevations,TotalUncertainty(:,1),'*')
    title('Uncertainty across the Horizon.')
    xlabel('Input Azimuth wrt Brockport (deg)')
    ylabel('Input Elevation wrt Brockport (deg)')
    zlabel('Azimuth and Elevation Uncertainty (deg)')
    hold on
    grid on
    surf(x,y,z2,z2*0+2)
%     plot3(Azimuths,Elevations,TotalUncertainty(:,2),'*')
    legend('Azimuth Uncertainty','Elevation Uncertainty')
    zlim([0 Vals(UncertaintyCriteria)*2])
    if length(TestsToRun)>1
        GraphSaver({'png','fig'},['Plots/' PlotOutputFolder '/' matName],1,1);
    end
end

%Metrics for each triangle
%Coverage based on Time difference more than 100ns for all stations.
%Coverage based on Uncertainty less than 0.5, 1, 2, 5 degrees for az,el
%Min, Max Locations and uncertainty.
%Avg Uncertainty with std. dev. and Box Plot with median.


% TDoACoverage(TN)=sum(min(abs(timeDiffs),[],2)>100e-9)/size(timeDiffs,1);
maxUncertainty=max(TotalUncertainty,[],2);
for kk=1:length(Vals)
    UncertaintyCoverage(TN,kk)=sum(maxUncertainty<Vals(kk))/size(TotalUncertainty,1);
end
% UncertaintyCoverage(TN,2)=sum(maxUncertainty<Vals(2))/size(TotalUncertainty,1);
% UncertaintyCoverage(TN,3)=sum(maxUncertainty<Vals(3))/size(TotalUncertainty,1);
% UncertaintyCoverage(TN,4)=sum(maxUncertainty<Vals(4))/size(TotalUncertainty,1);
AzimuthUncertaintyStat(TN,:)=[nanmean(TotalUncertainty(:,1)) nanstd(TotalUncertainty(:,1))];
ElevationUncertaintyStat(TN,:)=[nanmean(TotalUncertainty(:,2)) nanstd(TotalUncertainty(:,2))];
AzUncertaintyBox(TN,:)=quantile(TotalUncertainty(:,1),[0.25 0.5 0.75]);
ElUncertaintyBox(TN,:)=quantile(TotalUncertainty(:,2),[0.25 0.5 0.75]);
Azb(:,TN)=TotalUncertainty(:,1);
Elb(:,TN)=TotalUncertainty(:,2);

%rows are elevation, columns are elevation. 
z=reshape(TotalUncertainty(:,1),numRows,numCols);
z2=reshape(TotalUncertainty(:,2),numRows,numCols);
AzAllowable=find(sum(z<MinElCriteria,2)>=0.4*numCols); %finds the first elevation where all azimuths unc. were below Criteria.
ElAllowable=find(sum(z2<MinElCriteria,2)>=0.4*numCols); %finds the first elevation where all elevation unc. were below Criteria.
if isempty(AzAllowable) || isempty(ElAllowable)
    MinEl(TN)=nan;
else
    MinEl(TN)=Elevations(max(AzAllowable(1),ElAllowable(1))); %finds the first elevation where all angles were below Criteria.
    MaxEl(TN)=Elevations(min(AzAllowable(end),ElAllowable(end)));
end  


end

% figure()
% bar(TestsToRun,TDoACoverage)
% title('TDoA Coverage by Triangle')
% xlabel('Tests')
% ylabel('Sky Coverage based on TD precision (%)')
% ylim([0.8 1])


figure()
bar(TestsToRun,UncertaintyCoverage)
title('Uncertainty Coverage by Triangle')
xlabel('Tests')
ylabel('Sky Coverage based on TD accuracy (%)')
legend('0.5 deg','1 deg','2 deg','5 deg','10 deg','location','northeastoutside')

figure()
subplot(1,2,1)
boxplot(Azb,'symbol','');
title('Azimuth Uncertainties')
ylim([0 max(max(AzUncertaintyBox))*1.25])
ylabel('Azimuth Uncertainty (deg)')
xlabel('Tests')

subplot(1,2,2)
boxplot(Elb,'symbol','');
title('Elevation Uncertainties')
ylim([0 max(max(ElUncertaintyBox))*1.25])
ylabel('Elevation Uncertainty (deg)')
xlabel('Tests')

UncertaintyCov=UncertaintyCoverage(:,UncertaintyCriteria);
MedianAzErr=nanmedian(Azb)';
iqrAzErr=iqr(Azb)';
MedianElErr=nanmedian(Elb)';
iqrElErr=iqr(Elb)';

table(UncertaintyCov,MedianAzErr,iqrAzErr,MedianElErr,iqrElErr,MinEl,MaxEl)

GraphSaver({'png','fig'},['Plots/' PlotOutputFolder],1,1);
