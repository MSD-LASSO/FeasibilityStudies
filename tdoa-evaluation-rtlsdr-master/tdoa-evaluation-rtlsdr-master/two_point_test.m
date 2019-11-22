% 2pt_test
c = 1;
f = 0;
v = 1;

[sr1, fs1] = audioread('weather_NRH_1.wav');
[sr2, fs2] = audioread('weather_mission_1.wav');

% sound(sr1, fs1);
% sound(sr2, fs2);

N = round(size(sr1, 1)/c);
m_1 = zeros(N, 1);
m_2 = zeros(N, 1);

for j = 1:N
    m_1(j) = sr1(j+f*round(c*N/v), 1);% +  1i* sr1(j+f*round(c*N/v), 2);
end
for j = 1:N
    m_2(j) = sr2(j+f*round(c*N/v), 1);% +  1i* sr2(j+f*round(c*N/v), 2);
end



[d, lags] = xcorr(abs(m_1)-mean(abs(m_1)), abs(m_2)-mean(abs(m_2)),'coeff');
% corr = correlate_iq(slice_1_1, slice_2_1, 'abs', 0);
% stem(lags/fs1, d)
d2 = abs(d)/max(abs(d));
plot(lags/fs1, abs(d2))
xlabel('Time Delay [s]');
ylabel('Normalized Crosscorrelation');
title('Crosscorrelation Plot');
legend('Location1 - Location2');
% plot(lags/fs1, abs(corr));
[x1, x2] = max(abs(d));
% [sch1, sch2] = max(abs(corr));
delay = x2 - N; 
% delayS = sch2 - N;









% 
% N = round(size(sr2, 1));
% 
% slice_1_1 = zeros(N, 1);
% % slice_1_2 = zeros(N/4, 1);
% % slice_1_3 = zeros(N/4, 1);
% % slice_1_4 = zeros(N/4, 1);
% 
% slice_2_1 = zeros(N, 1);
% % slice_2_2 = zeros(N/4, 1);
% % slice_2_3 = zeros(N/4, 1);
% % slice_2_4 = zeros(N/4, 1);
% 
% for j = 1:N
%     slice_1_1(j) = sr1(j, 1) +  1i* sr1(j, 2);
% end
% for j = 1:N/2
%     slice_2_1(j) = sr2(j, 1) +  1i* sr2(j, 2);
% end
% 
% % 
% % for j = 1:N/4
% %     slice_1_2(j) = sr1(j+N/4, 1) + 1i * sr1(j+N/4, 2);
% %     slice_2_2(j) = sr2(j+N/4, 1) + 1i * sr2(j+N/4, 2);
% % end
% % 
% % for j = 1:N/4
% %     slice_1_3(j) = sr1(j+2*N/4, 1) + 1i * sr1(j+2*N/4, 2);
% %     slice_2_3(j) = sr2(j+2*N/4, 1) + 1i * sr2(j+2*N/4, 2);
% % end
% % 
% % for j = 1:N/4
% %     slice_1_4(j) = sr1(j+3*N/4, 1) + 1i * sr1(j+3*N/4, 2);
% %     slice_2_4(j) = sr2(j+3*N/4, 1) + 1i * sr2(j+3*N/4, 2);
% % end
% % 
% 
% y = xcorr(slice_2_1,slice_1_1);
% x1 = correlate_iq(slice_1_1, slice_2_1, 'dphase', 2);
% [z, idx1] = max(x1);
% delay1 = idx1 - length(x1);
% 
% % 
% % x2 = correlate_iq(slice_1_2, slice_2_2, 'abs', 0);
% % [~, idx2] = max(x2);
% % delay2 = idx2 - length(x2);
% % 
% % x3 = correlate_iq(slice_1_3, slice_2_3, 'abs', 0);
% % [~, idx3] = max(x3);
% % delay3 = idx3 - length(x3);
% % 
% % x4 = correlate_iq(slice_1_4, slice_2_4, 'abs', 0);
% % [~, idx4] = max(x4);
% % delay4 = idx4 - length(x4);
% % 
% % delay = 0.25*(delay1+delay2+delay3+delay4);
% % 
% plot(abs(y))
% 
% [max_val, max_loc] = max(abs(y));
