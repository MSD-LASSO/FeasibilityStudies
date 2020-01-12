function [sample_delay, corr_factor, lags_matrix, lags, Ts] = phase_diff_xcov_IQ(IQ_data_1, IQ_data_2, max_lag)
%This function  takes in two IQ data files and returns the complex cross
%correlation results
[x1, Fs1, N1] = readIQ(IQ_data_1);
[x2, Fs2, N2] = readIQ(IQ_data_2);
if Fs1 ~= Fs2
    disp('The data sets are sampled at different frequencies');
    return;
end
if max_lag == 0
    if N1 <= N2
        max_lag_f = N1;
    else
        max_lag_f = N2;
    end
else
    max_lag_f = max_lag;
end
Ts = 1 / Fs1;
m1 = zeros(N1,1);
m1(1) = 0;
for k = 2:N1
    m1(k) = angle(x1(k))- angle (x1(k-1));
end
m2 = zeros(N2,1);
m2(1) = 0;
for k = 2:N2
    m2(k) = angle(x2(k))- angle (x2(k-1));
end
[d, lags] = xcov(m1, m2, max_lag_f);
d_norm = abs(d)/max(abs(d));
hold off
plot(lags*Ts, abs(d_norm))
xlabel('Time Delay [s]');
ylabel('Normalized Crosscorrelation');
title('Phase DIfference Crosscorrelation Plot');
legend(strcat(IQ_data_1,' - ',IQ_data_2));
[corr_factor, index_max] = max(abs(d));
sample_delay = index_max - round(size(lags, 2)/2); 
lags_matrix = d;
end

