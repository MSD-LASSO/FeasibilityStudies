function plotHistograms(Data,correct,location,save)
if nargin<4
    save=1;
end

if nargin<3
   location='Plots/MonteCarlo'; 
end

Az=correct(1);
El=correct(2);

if isempty(Data)==0
numTests=length(Data.EstAzEl);
% EstAzEl=Data.EstAzEl*180/pi;
Errors=Data.Error*180/pi;


figure()
subplot(1,2,1)
histogram(Errors(:,1))
hold on
%     plot(AzX,AzR,'linewidth',3)
title([num2str(Az) '&' num2str(El) ' Az Uncertainty from ' num2str(numTests) ' tests. Mean Err ' num2str(nanmean(Errors(:,1)),'%1.3f') ' Std Dev ' num2str(nanstd(Errors(:,1)),'%1.3f')])
xlabel('Error in Azimuth (deg)')
ylabel('Likelihood')
grid on

subplot(1,2,2)
histogram(Errors(:,2))
hold on
%     plot(ElX,ElR,'linewidth',3)
title(['El Uncertainty ' num2str(numTests) ' tests. Mean Err ' num2str(nanmean(Errors(:,2)),'%1.3f') ' Std Dev ' num2str(nanstd(Errors(:,2)),'%1.3f')])
xlabel('Error in Elevation (deg)')
ylabel('Likelihood')
grid on

figure()
plot(0,0,'o','linewidth',3)
hold on
plot(Errors(:,1),Errors(:,2),'.')
title(['Error in Azimuth and Elevation Plot for Az ' num2str(Az) ' and El ' num2str(El)])
xlabel('Error in Azimuth (deg)')
ylabel('Error in Elevation (deg)')
else
figure()
histogram(zeros(100,0))
title([num2str(Az) '&' num2str(El) 'Az El Uncertainty Undefined'])

end


if save==1
    GraphSaver({'png','fig'},location,1,1);
end
end