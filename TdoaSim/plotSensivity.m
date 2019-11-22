%This script reads output files from a sensivity analysis and plots it.
clearvars
close all
load OutputBrockportMeesWebsterWithTimeDiffs.mat

%some variable names
Azimuths;
Elevations;
ClkError;
RL_err;
SensitivityTest;

%% Reorganize the data
LocationSensAz{i}=cell(p,1);
LocationSensEl{i}=cell(p,1);
TimeSensAz{i}=cell(p,1);
TimeSensEl{i}=cell(p,1);
TotalUncertainty=zeros(p,2);
for i=1:p
   LocationSensAz{i}=SensitivityTest{i}{1}{1,1};
   LocationSensEl{i}=SensitivityTest{i}{1}{1,2};
   TimeSensAz{i}=SensitivityTest{i}{2}{1,1};
   TimeSensEl{i}=SensitivityTest{i}{2}{1,2};
   TotalUncertainty(i,1)=sqrt(sum(sum((LocationSensAz{i}.*RL_err).^2))+sum((TimeSensAz{i}.*ClkError).^2))*180/pi;
   TotalUncertainty(i,2)=sqrt(sum(sum((LocationSensEl{i}.*RL_err).^2))+sum((TimeSensEl{i}.*ClkError).^2))*180/pi;
   
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

x=reshape(Azimuths,17,36);
y=reshape(Elevations,17,36);
for i=1:2 %azimuth then elevation
    for j=1:size(Data{i},2)
       figure()
       z=reshape(Data{i}(:,j),17,36);
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

timeDiffs(:,4)=mean(timeDiffs,2);
Titles={'R1 to R2','R1 to R3','R2 to R3','Average'};
for i=1:4
    figure()
    z=reshape(timeDiffs(:,i),17,36);
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

figure()
plot3(Azimuths,Elevations,timeDiffs(:,4),'*');
title('Time Differences across the Horizon.')
xlabel('Input Azimuth wrt Brockport (deg)')
ylabel('Input Elevation wrt Brockport (deg)')
zlabel('Azimuth and Elevation Uncertainty (deg)')
hold on
grid on
plot3(Azimuths,Elevations,timeDiffs(:,1),'*')
plot3(Azimuths,Elevations,timeDiffs(:,2),'*')
plot3(Azimuths,Elevations,timeDiffs(:,3),'*')
legend(Titles)
% z1=reshape(TotalUncertainty(:,1),17,36);
% 
% 
% z2=reshape(TotalUncertainty(:,2),17,36);
% figure()
% contour(x,y,z2);
% title('Elevation Uncertainty across the Horizon.')
% xlabel('Input Azimuth wrt Brockport (deg)')
% ylabel('Input Elevation wrt Brockport (deg)')
% grid on








%3D plots
figure()
plot3(Azimuths,Elevations,TotalUncertainty(:,1),'*')
title('Uncertainty across the Horizon.')
xlabel('Input Azimuth wrt Brockport (deg)')
ylabel('Input Elevation wrt Brockport (deg)')
zlabel('Azimuth and Elevation Uncertainty (deg)')
hold on
grid on
plot3(Azimuths,Elevations,TotalUncertainty(:,2),'*')
legend('Azimuth Uncertainty','Elevation Uncertainty')


%from  https://www.mathworks.com/matlabcentral/answers/59463-plot-heatmap-with-3-variables
% x=Azimuths;
% y=Elevations;
% z=TotalUncertainty(:,1);
% figure()
% 
% minx = min(x);
% maxx = max(x);
% miny = min(y);
% maxy = max(y);
% meanValue = mean(z);
% heatMapImage = meanValue  * ones(100, 100);
% for k = 1 : length(x)
%   column = round( (x(k) - minx) * 100 / (maxx-minx) ) + 1; 
%   row = round( (y(k) - miny) * 100 / (maxy-miny) ) + 1;
%   heatMapImage(row, column) = z(k);
% end
% imshow(heatMapImage, []);
% colormap('hot');
% colorbar;

GraphSaver({'png','fig'},'Plots/Sensitivity',1,1);