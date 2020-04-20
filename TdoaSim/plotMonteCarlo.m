%This script reads output files from a monte carlo analysis and plots it.
clearvars
close all


addpath('LocateSat')
addpath('TimeDiff')

%% The order of triangles. Same as OutputTriangleParameters
OutputTriangleParameters

%% Inputs -- Change these --
%With the below inputs, we will run only for triangle 8. We are comparing
%two datasets, Estimated Uncertainty and EdgesAdjustedClosestHyperbolaCost
%We are expecting nets the size of 18x36. Our 3D plots will have a zlimit
%of 10*2 degrees. We will use 5+ degrees in elevation for coverage counts
%and 0.5,1,2,5,10 degrees for bar chart coverage calculations. 

%Just hit run and watch. Note, output will be saved to folder called
%"dummy"

%See (%% Metrics for each triangle) below for additional tunable
%parameters.

% specify the input folder where .mats are located.
InputFolder='MonteCarloResults/Estimated Uncertainty';
% InputFolder='.'; %use the current directory.

%Specify where plots will be saved to. Automatically in plots/ directory.
%this will be a sub directory.
% PlotOutputFolder='MonteCarlo10TrianglesEstimatedUncertainty';
PlotOutputFolder='dummy';

%The number of rows and cols depends on the resolution of the net generated
%from sensitivityAnalysisNet. The latest use numRows and numCols.
numRows=18; %numRows=6;
numCols=36; %numCols=9;

%Used for the boxplots and coverage.
MinElCriteria=5; %what is the minimum elevation criteria.
Vals=[0.5 1 2 5 10]; %count the number of uncertainties below these amounts.
UncertaintyCriteria=5; %Use this index of Vals for the z limit in 3D mesh drawings. Ex. =5 uses Vals=10 deg for zLim.


%some variable names
% Azimuths;
% Elevations;
% ClkError;
% RL_err;
% SensitivityTest;

%TestsToRun correspond to which triangles you want to run.
% TestsToRun=[1 2 3 4 5 6 7 8 9 10]; 
TestsToRun=[8];

%Set to 0 to only show only final plots comparing all triangles in main dataset
%Set to 1 to show 3D meshes for the main dataset
%Set to 2 to show 3D meshes for main dataset AND 3D meshes comparing the
%main and auxilary datasets. 
plotIntermediates=2;
%If you want to compare two datasets to each other. Use the AuxInput to
%load the second dataset. Format is same as InputFolder
AuxInput='MonteCarloResults/EdgesAdjustedClosestHyperbolaCost';



%% Compute Plots.
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

%For each triangle.
for TN=1:length(TestsToRun)
matName=OF{TestsToRun(TN)}; %Get name of the triangle.

if plotIntermediates==2
    %save off the auxilary data for later comparison.
    load([AuxInput '/OutputMonteCarlo' matName])
    AllstdDevError(AllstdDevError==0)=nan; %when there's no data for a node in the net, set to Nan to show a hole in the 3D mesh.
    %% Reorganize the data
    TotalUncertaintyAux=(AllMeanErrors+2*AllstdDevError)*180/pi; %get error in degrees.
    zAux=reshape(TotalUncertaintyAux(:,1),numRows,numCols);
    z2Aux=reshape(TotalUncertaintyAux(:,2),numRows,numCols);
end
    
    
%load main dataset.
load([InputFolder '/OutputMonteCarlo' matName])
AllstdDevError(AllstdDevError==0)=nan; %make holes in mesh where Monte Carlo failed or there's no data.
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
    %% Plot the main dataset.
    figure()
    colors = get(gca, 'ColorOrder');
    colormap(colors)
    surf(x,y,z,z*0+1)
    title('Uncertainty across the Horizon.')
    xlabel('Input Azimuth wrt Brockport (deg)')
    ylabel('Input Elevation wrt Brockport (deg)')
    zlabel('Azimuth and Elevation Uncertainty (deg)')
    hold on
    grid on
    surf(x,y,z2,z2*0+2)
    legend('Azimuth Uncertainty','Elevation Uncertainty')
    zlim([0 Vals(UncertaintyCriteria)*2])
    if length(TestsToRun)>1
        GraphSaver({'png','fig'},['Plots/' PlotOutputFolder '/' matName],1,1);
    end
elseif plotIntermediates==2
    %% Compare the 2 datasets: Main and Aux
    figure()
    colors = get(gca, 'ColorOrder');
    colormap(colors)
    surf(x,y,z,z*0+1)
    title('Uncertainty comparison Azimuth')
    xlabel('Input Azimuth (deg)')
    ylabel('Input Elevation (deg)')
    zlabel('Azimuth  Uncertainty (deg)')
    hold on
    grid on
    surf(x,y,zAux,zAux*0+2)
    legend('Azimuth Estimated Unc.','Azimuth Absolute Unc.')
    zlim([0 Vals(UncertaintyCriteria)*2])
    
    figure()
    colors = get(gca, 'ColorOrder');
    colormap(colors)
    surf(x,y,z2,z2*0+1)
    title('Uncertainty comparison Elevation')
    xlabel('Input Azimuth (deg)')
    ylabel('Input Elevation (deg)')
    zlabel('Elevation  Uncertainty (deg)')
    hold on
    grid on
    surf(x,y,z2Aux,z2Aux*0+2)
    legend('Elevation Estimated Unc.','Elevation Absolute Unc.')
    zlim([0 Vals(UncertaintyCriteria)*2])
    
    if length(TestsToRun)>1
        GraphSaver({'png','fig'},['Plots/' PlotOutputFolder '/' matName],1,1);
    end
end

%% Metrics for each triangle
%NOTE: some of these are hardcoded. 
%Coverage based on Time difference more than minTD for all stations.
%Coverage based on Uncertainty less than 0.5, 1, 2, 5 degrees for az,el
%Min, Max Locations and uncertainty.
%Avg Uncertainty with std. dev. and Box Plot with median.


maxUncertainty=max(TotalUncertainty,[],2);
for kk=1:length(Vals)
    UncertaintyCoverage(TN,kk)=sum(maxUncertainty<Vals(kk))/size(TotalUncertainty,1);
end
AzimuthUncertaintyStat(TN,:)=[nanmean(TotalUncertainty(:,1)) nanstd(TotalUncertainty(:,1))];
ElevationUncertaintyStat(TN,:)=[nanmean(TotalUncertainty(:,2)) nanstd(TotalUncertainty(:,2))];
AzUncertaintyBox(TN,:)=quantile(TotalUncertainty(:,1),[0.25 0.5 0.75]);
ElUncertaintyBox(TN,:)=quantile(TotalUncertainty(:,2),[0.25 0.5 0.75]);
Azb(:,TN)=TotalUncertainty(:,1);
Elb(:,TN)=TotalUncertainty(:,2);

%rows are elevation, columns are elevation. 
z=reshape(TotalUncertainty(:,1),numRows,numCols);
z2=reshape(TotalUncertainty(:,2),numRows,numCols);
AzAllowable=find(sum(z<MinElCriteria,2)>=0.4*numCols); %finds the first elevation where 40% of the  azimuths unc. were below Criteria.
ElAllowable=find(sum(z2<MinElCriteria,2)>=0.4*numCols); %finds the first elevation where 40% of the elevation unc. were below Criteria.
if isempty(AzAllowable) || isempty(ElAllowable)
    MinEl(TN)=nan;
else
    MinEl(TN)=Elevations(max(AzAllowable(1),ElAllowable(1))); %finds the first elevation where all angles were below Criteria.
    MaxEl(TN)=Elevations(min(AzAllowable(end),ElAllowable(end)));
end  


end

%% Plot the final results. This is what you get when plotIntermediates=0


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
% ylim([0 max(max(AzUncertaintyBox))*1.25])
ylim([0 30]);
ylabel('Azimuth Uncertainty (deg)')
xlabel('Tests')

subplot(1,2,2)
boxplot(Elb,'symbol','');
title('Elevation Uncertainties')
% ylim([0 max(max(ElUncertaintyBox))*1.25])
ylim([0 10])
ylabel('Elevation Uncertainty (deg)')
xlabel('Tests')

UncertaintyCov=UncertaintyCoverage(:,UncertaintyCriteria);
MedianAzErr=nanmedian(Azb)';
iqrAzErr=iqr(Azb)';
MedianElErr=nanmedian(Elb)';
iqrElErr=iqr(Elb)';

table(UncertaintyCov,MedianAzErr,iqrAzErr,MedianElErr,iqrElErr,MinEl,MaxEl)

GraphSaver({'png','fig'},['Plots/' PlotOutputFolder],1,1);
