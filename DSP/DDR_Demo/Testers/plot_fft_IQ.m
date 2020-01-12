function [X_f, fd, Fs] = plot_fft_IQ(IQ_file)
%This function plots the fft of an IQ data file
[x, Fs, N] = readIQ(IQ_file);

Ts = 1/Fs;
F_step = Fs/N;
x_o = fft(x)*Ts;
X_f = fftshift(x_o);
fd = -Fs/2:F_step:Fs/2-F_step;

hold off
figure
plot(fd, 20*log10(abs(X_f)))
xlabel('Frequency [Hz]')
ylabel('|X[n]| in dB')
legend('FFT of X[n]')
title(IQ_file)
end

