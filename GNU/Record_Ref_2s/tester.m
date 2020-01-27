%tester
clearvars
close all
sample_delay = -27;
num_samples = 40e6;
filename = 'ref_sig_test_1.txt';
new_IQ_name = 'ref_sig_IQ_short.wav';
% f = fopen(filename, 'rb'); 
% d = fread (f, [2, num_samples/8], 'float'); 
% v = d(1,:) + d(2,:)*1i; 
% [r, c] = size (v); 
% v = reshape (v, c, r); 
% x2(:, 1) = real(v);
% x2(:, 2) = imag(v);
% Fs = 20e6;
% audiowrite(new_IQ_name, x2, Fs);
% plot_fft_IQ(new_IQ_name);
delayed_file = 'ref_sig_IQ_short_delayed.wav';
delay_IQ(new_IQ_name, sample_delay, delayed_file);
cmplx_xcorr_IQ(new_IQ_name, delayed_file, 0);