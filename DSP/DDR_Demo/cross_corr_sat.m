%DDR Demo
close all
[m, Fs] = audioread('Mission_Control_Prism_Test3.wav');


N = size(m, 1)/2;
c = 3e8;
Ts = 1 / Fs;
td = 0:Ts:(N-1)*Ts; %The step size of td is the sample period

fc = 437e6;

ym = m;
ym2 = m;

% F_step = 0.15879065;
% Ym_o = fft(ym)*Ts;
% Ym = fftshift(Ym_o);
% fd = -Fs/2:F_step:Fs/2 - Fs/N;
% 
% figure(8)
% plot(fd, 20*log10(sqrt(abs((Ym(:,1).^2+Ym(:,2).^2)))))
% xlabel('Frequency [Hz]')
% ylabel('|YM[n]| in dB')
% legend('FFT of ym[n]')

Ac = 0.025;


yt = Ac * ym;
yt2 = Ac * ym2;


% figure(7)
% plot(td, (sqrt(abs((ym(:,1).^2+ym(:,2).^2)))))
% xlabel('Time [s]')
% ylabel('ym[n]')
% legend('Discrete time signal ym[n]')

%Transmitter is at (0,0)
Tx_loc = [0 0];

%First Receiver is 700 km east
Rx1_loc = [710e3 0];
Rx1_dist = norm(Rx1_loc - Tx_loc);
Rx1_delay = Rx1_dist / c;
Rx1_sample_delay = round(Rx1_delay*Fs);
Rx1_Power_loss = (fc * 4 * pi() * Rx1_dist / c) ^2;
Rx1_noise = 0e-10;

rx1 = zeros(N, 2);
n1 = zeros(N, 2);
for j = 1 : N
    n1(j, 1) = rand()*Rx1_noise*cos(2*pi*Fs*td(j)*rand());
    n1(j, 2) = rand()*Rx1_noise*cos(2*pi*Fs*td(j)*rand());
    if j > Rx1_sample_delay
        rx1(j, 1) = (1/sqrt(Rx1_Power_loss))*yt(j-Rx1_sample_delay,1);
        rx1(j, 2) = (1/sqrt(Rx1_Power_loss))*yt(j-Rx1_sample_delay,2);
    end
end

sig_sum1 = 0;
for j = 1:N
    sig_sum1 = sig_sum1 + (abs(rx1(j,1) + rx1(j, 2)))^2;
end
sig_Pwr1 = sig_sum1 / (N*Ts);

nos_sum1 = 0;
for j = 1:N
    nos_sum1 = nos_sum1 + (abs(n1(j, 1)+n1(j, 2)))^2;
end
noise_Pwr1 = nos_sum1 / (N*Ts);

SNR_1 = sig_Pwr1 / noise_Pwr1;

r1 = rx1 + n1;



h1 = r1;

%Second Receiver is 710 km North
Rx2_loc = [0 700e3];
Rx2_dist = norm(Rx2_loc - Tx_loc);
Rx2_delay = Rx2_dist / c;
Rx2_sample_delay = round(Rx2_delay*Fs);
Rx2_Power_loss = (fc * 4 * pi() * Rx2_dist / c) ^2;
Rx2_noise = 0e-10;

rx2 = zeros(N, 2);
n2 = zeros(N, 2);
for j = 1 : N
    n2(j, 1) = rand()*Rx2_noise*cos(2*pi*Fs*td(j)*rand());
    n2(j, 2) = rand()*Rx2_noise*cos(2*pi*Fs*td(j)*rand());
    if j > Rx2_sample_delay
        rx2(j, 1) = (1/sqrt(Rx2_Power_loss))*yt2(j-Rx2_sample_delay, 1);
        rx2(j, 2) = (1/sqrt(Rx2_Power_loss))*yt2(j-Rx2_sample_delay, 2);
    end
end

sig_sum2 = 0;
for j = 1:N
    sig_sum2 = sig_sum2 + (abs(rx2(j, 1)+ rx2(j, 2)))^2;
end
sig_Pwr2 = sig_sum2 / (N*Ts);

nos_sum2 = 0;
for j = 1:N
    nos_sum2 = nos_sum2 + (abs(n2(j,1) + n2(j, 2)))^2;
end
noise_Pwr2 = nos_sum2 / (N*Ts);

SNR_2 = sig_Pwr2 / noise_Pwr2;

r2 = rx2 + n2;



h2 = r2;


figure(9)
plot(td,(sqrt(abs((h1(:,1).^2+h1(:,2).^2)))), 'g')
hold on
plot(td, (sqrt(abs((h2(:,1).^2+h2(:,2).^2)))), 'r')
xlabel('Time [s]')
ylabel('Signal')
legend({'h1[n]', 'h2[n]'});

h1_c = zeros(size(td));
h2_c = zeros(size(td));

for j = 1:N
    h1_c(j) = h1(j, 1) + 1i * h1(j, 2) + n1(j, 1) + 1i * n1(j, 2);
    h2_c(j) = h2(j, 1) + 1i * h2(j, 2) + n2(j, 1) + 1i * n2(j, 2);
end

F_step = Fs/N;
H1_o = fft(h1_c)*Ts;
H1 = fftshift(H1_o);
fd = -Fs/2:F_step:Fs/2 - Fs/N;

figure(1)
plot(fd, 20*log10(abs(H1)), 'g')
xlabel('Frequency [Hz]')
ylabel('|H1[n]| in dB')
legend('FFT of H1[n]')

F_step = Fs/N;
H2_o = fft(h2_c)*Ts;
H2 = fftshift(H2_o);
fd = -Fs/2:F_step:Fs/2;

figure(5)
plot(fd, 20*log10(abs(H2)), 'r')
xlabel('Frequency [Hz]')
ylabel('|H2[n]| in dB')
legend('FFT of H2[n]')


[d, lags] = xcorr(h1_c, h2_c);
d2 = abs(d)/max(abs(d));
figure(4)
plot(lags/Fs, abs(d2))
xlabel('Time Delay [s]');
ylabel('Normalized Crosscorrelation');
title('Crosscorrelation Plot');
legend('Location1 - Location2');
[x1, x2] = max(abs(d));
delay = x2 - round(size(lags, 2)/2); 
actual_delay = Rx1_sample_delay - Rx2_sample_delay;





