%tester
clearvars
close all

input_delay = -27;

file_name_1 = 'test_data_one.wav';
file_name_2 = 'new_data.wav';
file_name_3 = 'noisy1_new_data.wav';
file_name_4 = 'noisy2_new_data.wav';
file_name_5 = 'noisy_delay_data_new.wav';
[~, Fs, N1] = readIQ(file_name_1);
Time = N1/Fs;
SNR = 0.1;
BW = 100e3;
make_IQ(BW, Fs, Time, file_name_2);
plot_fft_IQ(file_name_2);

% SNR_try = 10;
%     
% BW_try = 1e3;
% make_IQ(BW_try, Fs, SNR, Time, file_name_2)
% 
% add_noise_IQ(file_name_2, SNR_try, file_name_3);
% plot_fft_IQ(file_name_3);
% add_noise_IQ(file_name_2, SNR_try, file_name_4);
% plot_fft_IQ(file_name_4);
% delay_IQ(file_name_4, input_delay, file_name_5);
% plot_fft_IQ(file_name_5);
% 
% [delay, ~, ~, ~, ~] = cmplx_xcov_IQ(file_name_3, file_name_5, 0);







num_success = 0;
success = zeros(2, 20);

for k = 1:20
    SNR_try = 10;
    
    BW_try = 5e3*k;
    make_IQ(BW_try, Fs, SNR, Time, file_name_2)
    
    add_noise_IQ(file_name_2, SNR_try, file_name_3);
    plot_fft_IQ(file_name_3);
    add_noise_IQ(file_name_2, SNR_try, file_name_4);
    plot_fft_IQ(file_name_4);
    delay_IQ(file_name_4, input_delay, file_name_5);
    plot_fft_IQ(file_name_5);

    [delay, ~, ~, ~, ~] = cmplx_xcov_IQ(file_name_3, file_name_5, 0);

    if delay == input_delay
        num_success = num_success + 1;
        success(1, k) = 0;
    else
        success(1, k) = abs(delay - input_delay);
    end
    
    success(2, k) = BW_try;
    close all
end






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