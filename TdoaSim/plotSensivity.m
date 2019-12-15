%This script reads output files from a sensivity analysis and plots it.
clearvars
close all


addpath('LocateSat')
addpath('TimeDiff')

% load OutputBrockportMeesWebsterWithTimeDiffs.mat
% load OutputSensitivityForwardDiff.mat
% load OutputMBW500Altitude.mat


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
InputFolder='SensitivityResults';
PlotOutputFolder='Sensitivity10Triangles';

numRows=17; numRows=18; %numRows=6;
numCols=36; %numCols=9;
MinElCriteria=.5; %what is the minimum elevation criteria.
Vals=[0.5 1 2 5];
UncertaintyCriteria=1; %index of Vals to use. 
%some variable names
% Azimuths;
% Elevations;
% ClkError;
% RL_err;
% SensitivityTest;

TestsToRun=[1 2 3 4 5 6 7 8 9 10];
% TestsToRun=[1 2 4 5 6 7 9];
plotIntermediates=0;

n=length(TestsToRun);
TDoACoverage=zeros(n,1);
UncertaintyCoverage=zeros(n,4);
AzimuthUncertaintyStat=zeros(n,2);
ElevationUncertaintyStat=zeros(n,2);
AzUncertaintyBox=zeros(n,3);
ElUncertaintyBox=zeros(n,3);
MinEl=zeros(n,1);
MaxSensitivities=cell(n,1);

for TN=1:length(TestsToRun)
matName=OF{TestsToRun(TN)};
load([InputFolder '/Output' matName])
%% Reorganize the data
LocationSensAz{i}=cell(p,1);
LocationSensEl{i}=cell(p,1);
TimeSensAz{i}=cell(p,1);
TimeSensEl{i}=cell(p,1);
TotalUncertainty=zeros(p,2);
MaxSensitivities{TN}=zeros(12,6);
for i=1:p
    if isempty(SensitivityTest{i})==0
       LocationSensAz{i}=SensitivityTest{i}{1}{1,1};
       LocationSensEl{i}=SensitivityTest{i}{1}{1,2};
       TimeSensAz{i}=SensitivityTest{i}{2}{1,1};
       TimeSensEl{i}=SensitivityTest{i}{2}{1,2};
    else
        %missing data. pad with nans.
       LocationSensAz{i}=nan(3,3);
       LocationSensEl{i}=nan(3,3);
       TimeSensAz{i}=nan(3,1);
       TimeSensEl{i}=nan(3,1);
    end
   TotalUncertainty(i,1)=sqrt(sum(sum((LocationSensAz{i}.*RL_err).^2))+sum((TimeSensAz{i}.*ClkError).^2))*180/pi;
   TotalUncertainty(i,2)=sqrt(sum(sum((LocationSensEl{i}.*RL_err).^2))+sum((TimeSensEl{i}.*ClkError).^2))*180/pi;
   if TotalUncertainty(i,1)>180 %can't be worse than 180 degrees off in azimuth.
       TotalUncertainty(i,1)=nan;
   end
   if TotalUncertainty(i,2)>90 %can't be worse than 90 degrees off in elevation.
       TotalUncertainty(i,2)=nan;
   end
   
   R1az(i,:)=LocationSensAz{i}(1,:);
   R2az(i,:)=LocationSensAz{i}(2,:);
   R3az(i,:)=LocationSensAz{i}(3,:);
   R1el(i,:)=LocationSensEl{i}(1,:);
   R2el(i,:)=LocationSensEl{i}(2,:);
   R3el(i,:)=LocationSensEl{i}(3,:);
   
   
   Clkaz(i,:)=TimeSensAz{i}';
   Clkel(i,:)=TimeSensEl{i}';
end

%% Get the triangle Azimuths and Elevations
temp=GND(2).Topocoord;
[R2R1az, R2R1el]=getAzEl([temp(2) temp(1) temp(3)]);
temp=GND(3).Topocoord;
[R3R1az, R3R1el]=getAzEl([temp(2) temp(1) temp(3)]);

%% Plot

Data={[TotalUncertainty(:,1) R1az R2az R3az Clkaz],[TotalUncertainty(:,2) R1el R2el R3el Clkel]};
Titles={'Azimuth','Elevation'};
Subtitles={'Uncertainty','Sensitivity Receiver 1 X', 'Sensitivity Receiver 1 Y', 'Sensitivity Receiver 1 Z',...
    'Sensitivity Receiver 2 X', 'Sensitivity Receiver 2 Y', 'Sensitivity Receiver 2 Z',...
    'Sensitivity Receiver 3 X', 'Sensitivity Receiver 3 Y', 'Sensitivity Receiver 3 Z'...
    ,'Sensitivity Receiver 1 Clk','Sensitivity Receiver 2 Clk','Sensitivity Receiver 3 Clk'};

x=reshape(Azimuths,numRows,numCols);
y=reshape(Elevations,numRows,numCols);
%Sensitivities
for i=1:2 %azimuth then elevation
    for j=1:size(Data{i},2)
        temp=Data{i}(:,j);
        
         %%%This can be used to filter really high uncertainties.%%%%
%         if TotalUncertainty(i,1)>180 %can't be worse than 180 degrees off in azimuth.
%             TotalUncertainty(i,1)=nan;
%         end
%         if TotalUncertainty(i,2)>90 %can't be worse than 90 degrees off in elevation.
%             TotalUncertainty(i,2)=nan;
%         end

        z=reshape(temp,numRows,numCols);
        if j>1
            [maxSensitivity,RowIndexForMaxOfEachCol]=max(z);
            [maxSensitivity,ColIndexForMax]=max(maxSensitivity);
            if j<10
                maxSensitivity=maxSensitivity*1000; %convert to km.
            else
                maxSensitivity=maxSensitivity/1e9; %convert to ns. 
            end
            AzLoc=x(1,ColIndexForMax);
            ElLoc=y(RowIndexForMaxOfEachCol(ColIndexForMax),1);
            MaxSensitivities{TN}(j-1,3*i-2:3*i)=[AzLoc,ElLoc,maxSensitivity];
        end
        if plotIntermediates==1
            figure()
            [M,c]=contour(x,y,z,'ShowText','on');
            c.LineWidth = 3;
            hold on
            plot(R2R1az*180/pi,R2R1el*180/pi,'o','LineWidth',3);
            plot(R3R1az*180/pi,R3R1el*180/pi,'o','LineWidth',3);
            title([Titles{i} ' ' Subtitles{j} ' across the Horizon.'])
            legend('Sensitivity','R2 wrt R1','R3 wrt R1')
            xlabel('Input Azimuth wrt Brockport (deg)')
            ylabel('Input Elevation wrt Brockport (deg)')
            grid on
        end
    end
end




if plotIntermediates==1
    %time difference plots.
    timeDiffs(:,4)=mean(timeDiffs,2);
    Titles={'R1 to R2','R1 to R3','R2 to R3','Average'};
    for i=1:4
        figure()
        z=reshape(timeDiffs(:,i),numRows,numCols);
        [M,c]=contour(x,y,z,'ShowText','on');
        c.LineWidth = 3;
        hold on
        plot(R2R1az*180/pi,R2R1el*180/pi,'o','LineWidth',3);
        plot(R3R1az*180/pi,R3R1el*180/pi,'o','LineWidth',3);
        title([Titles{i} ' Time Difference across the Horizon.'])
        legend('Time Difference (s)','R2 wrt R1','R3 wrt R1')
        xlabel('Input Azimuth wrt Brockport (deg)')
        ylabel('Input Elevation wrt Brockport (deg)')
        grid on
    end
    z1=reshape(timeDiffs(:,1),numRows,numCols);
    z2=reshape(timeDiffs(:,2),numRows,numCols);
    z3=reshape(timeDiffs(:,3),numRows,numCols);
    z4=reshape(timeDiffs(:,4),numRows,numCols);
    figure()
    colors = get(gca, 'ColorOrder');
    colormap(colors)
    % plot3(Azimuths,Elevations,timeDiffs(:,4),'*');
    surf(x,y,z1,z1*0+1)
    title('Time Differences across the Horizon.')
    xlabel('Input Azimuth wrt Brockport (deg)')
    ylabel('Input Elevation wrt Brockport (deg)')
    zlabel('Azimuth and Elevation Uncertainty (deg)')
    hold on
    grid on
    surf(x,y,z2,z1*0+2)
    surf(x,y,z3,z1*0+3)
    surf(x,y,z4,z1*0+4)
    legend(Titles)
end



%3D plots
z=reshape(TotalUncertainty(:,1),numRows,numCols);
z2=reshape(TotalUncertainty(:,2),numRows,numCols);

%% 3D plots of uncertainty
if plotIntermediates==1
    figure()
    colormap(colors)
    surf(x,y,z,z*0+1)
    % plot3(Azimuths,Elevations,TotalUncertainty(:,1),'*')
    title('Uncertainty across the Horizon.')
    xlabel('Input Azimuth wrt Brockport (deg)')
    ylabel('Input Elevation wrt Brockport (deg)')
    zlabel('Azimuth and Elevation Uncertainty (deg)')
    hold on
    grid on
    surf(x,y,z2,z2*0+2)
    % plot3(Azimuths,Elevations,TotalUncertainty(:,2),'*')
    legend('Azimuth Uncertainty','Elevation Uncertainty')
    zlim([0 0.5])
    GraphSaver({'png','fig'},['Plots/' PlotOutputFolder '/' matName],1,1);
end

%Metrics for each triangle
%Coverage based on Time difference more than 100ns for all stations.
%Coverage based on Uncertainty less than 0.5, 1, 2, 5 degrees for az,el
%Min, Max Locations and uncertainty.
%Avg Uncertainty with std. dev. and Box Plot with median.


TDoACoverage(TN)=sum(min(abs(timeDiffs),[],2)>100e-9)/size(timeDiffs,1);
maxUncertainty=max(TotalUncertainty,[],2);
UncertaintyCoverage(TN,1)=sum(maxUncertainty<Vals(1))/size(TotalUncertainty,1);
UncertaintyCoverage(TN,2)=sum(maxUncertainty<Vals(2))/size(TotalUncertainty,1);
UncertaintyCoverage(TN,3)=sum(maxUncertainty<Vals(3))/size(TotalUncertainty,1);
UncertaintyCoverage(TN,4)=sum(maxUncertainty<Vals(4))/size(TotalUncertainty,1);
AzimuthUncertaintyStat(TN,:)=[nanmean(TotalUncertainty(:,1)) nanstd(TotalUncertainty(:,1))];
ElevationUncertaintyStat(TN,:)=[nanmean(TotalUncertainty(:,2)) nanstd(TotalUncertainty(:,2))];
AzUncertaintyBox(TN,:)=quantile(TotalUncertainty(:,1),[0.25 0.5 0.75]);
ElUncertaintyBox(TN,:)=quantile(TotalUncertainty(:,2),[0.25 0.5 0.75]);
Azb(:,TN)=TotalUncertainty(:,1);
Elb(:,TN)=TotalUncertainty(:,2);

%rows are elevation, columns are elevation. 
z=reshape(TotalUncertainty(:,1),numRows,numCols);
z2=reshape(TotalUncertainty(:,2),numRows,numCols);
AzAllowable=find(sum(z<MinElCriteria,2)==numCols,1); %finds the first elevation where all azimuths unc. were below Criteria.
ElAllowable=find(sum(z2<MinElCriteria,2)==numCols,1); %finds the first elevation where all elevation unc. were below Criteria.
if isempty(AzAllowable) || isempty(ElAllowable)
    MinEl(TN)=nan;
else
    MinEl(TN)=Elevations(max(AzAllowable,ElAllowable)); %finds the first elevation where all angles were below Criteria.
end  

end

figure()
bar(TestsToRun,TDoACoverage)
title('TDoA Coverage by Triangle')
xlabel('Tests')
ylabel('Sky Coverage based on TD precision (%)')
ylim([0.8 1])


figure()
bar(TestsToRun,UncertaintyCoverage)
title('Uncertainty Coverage by Triangle')
xlabel('Tests')
ylabel('Sky Coverage based on TD accuracy (%)')
ylim([0.3 1])
legend('0.5 deg','1 deg','2 deg','5 deg','location','northeastoutside')

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

table(TDoACoverage,UncertaintyCov,MedianAzErr,iqrAzErr,MedianElErr,iqrElErr,MinEl)

for k=1:2 %azimuth / Elevation
    figure()
    for i=1:12 %for each variable
        subplot(4,3,i)
        temp=zeros(length(OF),1);
        for j=1:length(OF) %get sensitivity for each variable
            temp(j)=abs(MaxSensitivities{j}(i,3*k));
        end
        semilogy(1:1:length(OF),temp,'o','linewidth',3)
        grid on
        xlabel('Test Number')
        if i<10
            ylabel('(deg/km)')
        else
            ylabel('(deg/ns)')
        end
        title([Titles{k} ' ' Subtitles{i+1}])
    end
end

GraphSaver({'png','fig'},['Plots/' PlotOutputFolder],1,1);
