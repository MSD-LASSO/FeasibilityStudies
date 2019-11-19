%This script reads output files from a sensivity analysis and plots it.
load OutputBrockportMeesWebster.mat

%some variable names
Azimuths;
Elevations;
ClkError;
RL_err;
SensitivityTest;

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
end



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




