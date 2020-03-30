clearvars
close all

addpath('../TdoaSim/LocateSat/')
addpath('../TdoaSim/TimeDiff/')
addpath('../TdoaSim/')

data=dlmread('afterExcel.txt','',0,0);

%We are ignoring Canada (the 3rd set of az,el,al) because we didn't have
%a station there.
elevations=data(:,[1 4]);
azimuths=data(:,[2 5]);
ranges=data(:,[3 6]);
relTime=data(:,10);

%Station Locations.
Luca=[43.109762, -77.410156, 144.5];
Anthony=[39.764722, -76.673888, 304.8];

%get the shape of the Earth and set up the stations. 
Sphere=referenceSphere('Earth');
GND=getStruct([Luca;Anthony],zeros(2,4),Anthony,zeros(1,3),Sphere);

%convert satellite topocentric data into lat, long, altitude.
[lats,longs,alts]=aer2geodetic(azimuths(:,1),elevations(:,1),ranges(:,1),Luca(1),Luca(2),Luca(3),Sphere);
[lats2,longs2,alts2]=aer2geodetic(azimuths(:,2),elevations(:,2),ranges(:,2),Anthony(1),Anthony(2),Anthony(3),Sphere);
%technically these should be the same, but we have rounding error. We will
%use the average
Satgeodetic=[(lats+lats2) (longs+longs2) (alts+alts2)]/2;


SAT=getStruct(Satgeodetic,zeros(size(Satgeodetic,1),4),Anthony,zeros(1,3),Sphere);

output=timeDiff(GND,SAT);
%we are not considering error here at all, so elminate the second row.
timeDifferences=output(1,:);
maxTimeDiff=norm(GND(1).Topocoord-GND(2).Topocoord)/3e8;


%% Now we consider our Data. 30 second interval. 

ScheTimes=xlsread('supportingData.xlsx','Scheduled','B23:B42');

%first get the scheduled times with the same RELATIVE TIMING reference that
%the satellite uses. This we use Orekit for. RMS=5.2448
% CCvalues=xlsread('supportingData.xlsx','Scheduled','C23:C42'); %for 30 second TDs
% sampleLength=30; %we collected data for 30 seconds.
% CCvalues=[0;0;CCvalues];
% offset=repmat(CCvalues,1,2);

%% Other intervals
% sampleLength=6; %we process the data in 6 second increments.
% load getCC6secTD.mat %For 6 second interval. RMS=1.2342
% sampleLength=1.5; %we process the data in 1.5 second increments.
% load getCC1_5secTD.mat
sampleLength=0.15; %we process the data in 0.15 second increments.
load getCC01_5secTD.mat

%Reference 1 and 2 represent time_delay 1 and 2.
halfway=size(offset,2)/2;
CCvalues=reshape(offset(3:end,halfway+1:end)',size(offset(3:end,halfway+1:end),1)*halfway,1);



p=1;
for i=1:length(ScheTimes)
    for j=0:30/sampleLength-1
        newScheTimes(p)=ScheTimes(i)+j*sampleLength;
        p=p+1;
    end
end
ScheTimes=newScheTimes';

%% resume.
% ScheTimes=ScheTimes(:,1);



% Now, we collect all theoretical time differences inside each collection
% range.
dt=0.1; %in the Timedifferences dataset, the dt is 0.1 or 100ms.
RangeOfRelTimes=cell(length(ScheTimes),1);
RangeOfTimeDiffs=cell(length(ScheTimes),1);
for i=1:length(ScheTimes)
    target=ScheTimes(i);
    [~,idx]=min(abs(target-relTime));
    RangeOfRelTimes{i}=relTime(idx:idx+sampleLength/dt);
    RangeOfTimeDiffs{i}=timeDifferences(idx:idx+sampleLength/dt);
    
end






%% Plot the Time Differences
%% Zoomed in
figure()
plot(relTime,timeDifferences,'linewidth',2,'color','black')
hold on
plot([0 relTime(end)],[maxTimeDiff,maxTimeDiff],'color','red')
plot([0 relTime(end)],[-maxTimeDiff,-maxTimeDiff],'color','red')
for i=1:length(RangeOfRelTimes)

    plot(RangeOfRelTimes{i},RangeOfTimeDiffs{i},'linewidth',3)
%     color = get(lineH, 'Color');
    plot(mean(RangeOfRelTimes{i}),mean(RangeOfTimeDiffs{i}),'o','color','black','MarkerFaceColor','black')
    discretizedValues(i)=mean(RangeOfTimeDiffs{i}*1000);
    plot(mean(RangeOfRelTimes{i}),CCvalues(i),'s','color','red','linewidth',2)
end

grid on
title(['Time Differences of LUSAT pass starting at 2020-03-26T18:31:40.105 Sample Length ' num2str(sampleLength)]);
xlabel('Relative Time since start of pass (s)')
ylabel('Time difference between Shrewsbury, PA and Fairport, NY')
legend('Time Differences','Theoretical Maximum','Theoretical Minimum')
ylim([-maxTimeDiff*3,maxTimeDiff*3])

%% Totally Zoomed out
figure()
plot(relTime,timeDifferences,'linewidth',2,'color','black')
hold on
plot([0 relTime(end)],[maxTimeDiff,maxTimeDiff],'color','red')
plot([0 relTime(end)],[-maxTimeDiff,-maxTimeDiff],'color','red')
for i=1:length(RangeOfRelTimes)

    plot(RangeOfRelTimes{i},RangeOfTimeDiffs{i},'linewidth',3)
%     color = get(lineH, 'Color');
    plot(mean(RangeOfRelTimes{i}),mean(RangeOfTimeDiffs{i}),'o','color','black','MarkerFaceColor','black')
    discretizedValues(i)=mean(RangeOfTimeDiffs{i}*1000);
    plot(mean(RangeOfRelTimes{i}),CCvalues(i),'s','color','red','linewidth',2)
end

grid on
title(['Time Differences of LUSAT pass starting at 2020-03-26T18_31_40_105 LR Sample Length ' num2str(sampleLength)]);
xlabel('Relative Time since start of pass (s)')
ylabel('Time difference between Shrewsbury, PA and Fairport, NY')
legend('Time Differences','Theoretical Maximum','Theoretical Minimum')

%% Mid Zoom
figure()
plot(relTime,timeDifferences,'linewidth',2,'color','black')
hold on
plot([0 relTime(end)],[maxTimeDiff,maxTimeDiff],'color','red')
plot([0 relTime(end)],[-maxTimeDiff,-maxTimeDiff],'color','red')
for i=1:length(RangeOfRelTimes)

    plot(RangeOfRelTimes{i},RangeOfTimeDiffs{i},'linewidth',3)
%     color = get(lineH, 'Color');
    plot(mean(RangeOfRelTimes{i}),mean(RangeOfTimeDiffs{i}),'o','color','black','MarkerFaceColor','black')
    discretizedValues(i)=mean(RangeOfTimeDiffs{i}*1000);
    plot(mean(RangeOfRelTimes{i}),CCvalues(i),'s','color','red','linewidth',2)
end

grid on
title(['Time Differences of LUSAT pass starting at 2020-03-26T18_31_40_105 Mid Sample Length ' num2str(sampleLength)]);
xlabel('Relative Time since start of pass (s)')
ylabel('Time difference between Shrewsbury, PA and Fairport, NY')
legend('Time Differences','Theoretical Maximum','Theoretical Minimum')
ylim([-maxTimeDiff*750,maxTimeDiff*750])

GraphSaver({'png','fig'},['Plots/FinalResult'],0,0);
RMS=rms(discretizedValues'-CCvalues)

