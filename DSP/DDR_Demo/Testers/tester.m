%tester
clearvars
close all
file_name_1 = 'test_data_one.wav';
file_name_2 = 'new_data.wav';
[~, Fs, N1] = readIQ(file_name_1);
Time = N1/Fs;
SNR = 0.1;
BW = 50e3;
make_IQ(BW, Fs, SNR, Time, file_name_2);
plot_fft_IQ(file_name_2);









% clc;
% clear all;
% close all;
% t=0:.001:1;
% fm=1;
% fc=100;
% m=sin(2*pi*fm*t);
% subplot(311);
% plot(m);
% title('Message signal');
% c=cos(2*pi*fc*t+5*sin(2*pi*fm*t));
% subplot(313);
% plot(c);
% title('fm signal');
% subplot(312);
% plot(cos(2*pi*fc*t));
% title('Carrier signal');

















% delay_set = -150000;
% SNR = 1;
% file_name_2 = strcat('NOISY_', file_name_1);
% file_name_3 = strcat('DELAYED_', file_name_2);
% 
% add_noise_IQ(file_name_1, SNR, file_name_2);
% 
% plot_fft_IQ(file_name_2);
% 
% delay_IQ(file_name_2, delay_set, file_name_3);
% [delay, corr_factor, lags_matrix, lags, Ts] = phase_diff_xcov_IQ(file_name_1, file_name_3, 0);