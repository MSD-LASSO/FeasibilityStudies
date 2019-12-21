%Range Approximation
%This range approximation is based off of 4 different simulated satellite
%passes. Input the elevation then multiply by the semimajor axis of the
%satellite. Recommended use is limited to circular orbits. 
Data=xlsread('RangeApproximationVals.xlsx','Sheet2');
% Data(:,[3:5 8:10 13:15])=[];

% P=zeros(4,7);
% figure()
% for i=1:4
%     plot(Data(:,2*i-1),Data(:,2*i))
%     hold on
%     P(i,:)=polyfit(Data(:,2*i-1),Data(:,2*i),6);
% end
% P
% Pmean=mean(P)
Data(:,1)=Data(:,1)*180/pi;
Data(:,2)=Data(:,2)/500e3 %scale by satellite range.
P=polyfit(Data(:,1),Data(:,2),6);
M=[Data(:,1).^6 Data(:,1).^5 Data(:,1).^4 Data(:,1).^3 Data(:,1).^2 Data(:,1) ones(length(Data),1)];
Y=M*P';

figure()
plot(Data(:,1),Data(:,2),'o');
hold on
plot(Data(:,1),Y,'linewidth',3);
grid on
title('Curve Fit')
xlabel('Elevation (deg)')
ylabel('Range (m)')


Residuals=(Data(:,2)-Y).^2;
figure()
plot(Data(:,1),500e3*Residuals,'.');
grid on
title(['RSME ' num2str(500e3*sqrt(sum(Residuals))/1000) ' km for 500km altitude Satellite'])
xlabel('Elevation (deg)')
ylabel('Range (m)')

PercentError=abs(Data(:,2)-Y)./Data(:,2)*100;
figure()
plot(Data(:,1),PercentError,'.');
grid on
title(['Average Percent Error: ' num2str(mean(PercentError)) '%'])
xlabel('Elevation (deg)')
ylabel('Percent Error (%)')

GraphSaver({'fig','png'},'Plots/RangeApproximation',1);
save('RangePolynomial','P');