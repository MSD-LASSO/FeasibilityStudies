% ------------------------------------------------------------------------------------------
% Simple Matlab script, that reads an RTL-SDR IQ signal from a file,
% that has been captured by the "rtl_sdr" command from librtlsdr
% 
% shows the IQ signal with absolute value and angle, as well as a spectrogram
%
% by DC9ST, 2016
% ------------------------------------------------------------------------------------------

clear;
clc;
close all;
% info = audioinfo('Prism.wav');
% [y,Fs] = audioread('Prism.wav');
  
filename1 = 'example_dvb.dat';
% % filename1 = 'FalconSat3.wav';


fileID1 = fopen(filename1);
a = fread(fileID1);
fclose(fileID1); 
% N = 10000;
% extract I/Q data
num_samples1 = length(a)/2; % determine number of samples
% num_samples = N;
a1 = a(1:num_samples1*2);
inphase1 = a1(1:2:end) -128;
% inphase1 = y(1:num_samples,1);
quadrature1 = a1(2:2:end) -128;
% quadrature1 = y(1:num_samples,2);

% plot signal in time domain results
num_plot_samples = length(inphase1);

subplot(3,1,1); plot(1:num_plot_samples, inphase1(1:num_plot_samples), 1:num_plot_samples, quadrature1(1:num_plot_samples));
title('RX: I and Q');

subplot(3,1,2); plot(1:num_plot_samples, abs(inphase1+1i*quadrature1));
title('abs');

subplot(3,1,3); plot(1:num_plot_samples, unwrap(angle(inphase1+1i*quadrature1)));
title('unwrapped phase');


%% calculate and show spectrogram
figure;
complex_signal = detrend(inphase1+1i*quadrature1);
[S,F,T,P] = spectrogram(complex_signal, 512, 0, 512, num_plot_samples );
spectrum = fftshift(fliplr(10*log10(abs(P))'));
surf(F,T, spectrum, 'edgecolor', 'none');
axis tight;
view(0,90);
% 
% fc = 437*10^6;
% ts = 1/Fs;
% t = 0:ts:(N-1)*ts;
% r = zeros(N,1);
% 
% for j = 1 : N
%     r(j) = inphase1(j)  + i * quadrature1(j);
% end
% 
% plot(t, unwrap(angle(r)))
% hold on
% % plot(t, inphase1, 'linestyle', '--')
% % hold on
% % plot(t, quadrature1, 'linestyle', '--')
% xlim([0 0.0001])
% legend('RF_R_X')
% 
