%DDR Demo
close all

load RITVOICE
N = size(m, 1);
c = 3e8;
Ts = 1 / Fs;
td = 0:Ts:(N-1)*Ts; %The step size of td is the sample period
i=cumsum(m)*Ts;
kf = 3605; %Fm from part A
ym=zeros(N,1);
p = 2 * pi * kf * i;
fc = Fs / 10;
for n = 1:N
    ym(n) = cos(2 * pi * fc * td(n) + p(n));
end

figure(17)
plot(td, m)
xlabel('Time [s]')
ylabel('m[n]')
legend('Discrete time signal m[n]')

F_step = 1.77777;
Ym_o = fft(ym)*Ts;
Ym = fftshift(Ym_o);
fd = -Fs/2:F_step:Fs/2 - Fs/N;

figure(8)
plot(fd, 20*log10(abs(Ym)))
xlabel('Frequency [Hz]')
ylabel('|YM[n]|')
legend('FFT of ym[n]')
% xlim([-50000 50000])

%bullet point ii
Ac = 0.025;
% sum = 0;
% for j = 1:N
%     sum = sum + (Ac * ym(j))^2;
% end
% avg = sum / (N*Ts);

yt = Ac * ym;

%Transmitter is at (0,0)
Tx_loc = [0 0];

%First Receiver is 700 km east
Rx1_loc = [700e3 0];
Rx1_dist = norm(Rx1_loc - Tx_loc);
Rx1_delay = Rx1_dist / c;
Rx1_sample_delay = round(Rx1_delay*Fs);
Rx1_Power_loss = (fc * 4 * pi() * Rx1_dist / c) ^2;
Rx1_noise = 1e-7;

rx1 = zeros(size(yt));
n1 = zeros(size(yt));
for j = 1 : N
    n1(j) = rand()*Rx1_noise*cos(2*pi*Fs*td(n)*rand());
    if j > Rx1_sample_delay
        rx1(j) = (1/sqrt(Rx1_Power_loss))*yt(j-Rx1_sample_delay);
    end
end

sig_sum1 = 0;
for j = 1:N
    sig_sum1 = sig_sum1 + (rx1(j))^2;
end
sig_Pwr1 = sig_sum1 / (N*Ts);

nos_sum1 = 0;
for j = 1:N
    nos_sum1 = nos_sum1 + (n1(j))^2;
end
noise_Pwr1 = nos_sum1 / (N*Ts);

SNR_1 = sig_Pwr1 / noise_Pwr1;

r1 = rx1 + n1;

F_step = 1.77777;
R1_o = fft(r1)*Ts;
R1 = fftshift(R1_o);
fd = -Fs/2:F_step:Fs/2 - Fs/N;

figure(1)
plot(fd, 20*log10(abs(R1)),'g')
xlabel('Frequency [Hz]')
ylabel('|H1[n]| in dB')
legend('FFT of H1[n]')


z1 = [0;diff(r1)/Ts];

%bullet point iv

ze1 = envelope(z1)/(Ac*2*pi*kf);
h1=zeros(N,1);
avg1 = mean(ze1);
for n = 1:N
    h1(n) = ze1(n)-avg1;
end


%Second Receiver is 710 km North
Rx2_loc = [0 710e3];
Rx2_dist = norm(Rx2_loc - Tx_loc);
Rx2_delay = Rx2_dist / c;
Rx2_sample_delay = round(Rx2_delay*Fs);
Rx2_Power_loss = (fc * 4 * pi() * Rx2_dist / c) ^2;
Rx2_noise = 1e-7;

rx2 = zeros(size(yt));
n2 = zeros(size(yt));
for j = 1 : N
    n2(j) = rand()*Rx2_noise*cos(2*pi*Fs*td(n)*rand());
    if j > Rx2_sample_delay
        rx2(j) = (1/sqrt(Rx2_Power_loss))*yt(j-Rx2_sample_delay);
    end
end

sig_sum2 = 0;
for j = 1:N
    sig_sum2 = sig_sum2 + (rx2(j))^2;
end
sig_Pwr2 = sig_sum2 / (N*Ts);

nos_sum2 = 0;
for j = 1:N
    nos_sum2 = nos_sum2 + (n2(j))^2;
end
noise_Pwr2 = nos_sum2 / (N*Ts);

SNR_2 = sig_Pwr2 / noise_Pwr2;

r2 = rx2 + n2;

F_step = 1.77777;
R2_o = fft(r2)*Ts;
R2 = fftshift(R2_o);
fd = -Fs/2:F_step:Fs/2 - Fs/N;

figure(5)
plot(fd, 20*log10(abs(R2)), 'r')
xlabel('Frequency [Hz]')
ylabel('|H2[n]| in dB')
legend('FFT of H2[n]')

z2 = [0;diff(r2)/Ts];

%bullet point iv

ze2 = envelope(z2)/(Ac*2*pi*kf);
h2=zeros(N,1);
avg2 = mean(ze2);
for n = 1:N
    h2(n) = ze2(n)-avg2;
end

%bullet point iii
% 
% r = yt;
% z = [0;diff(r)/Ts];
% 
% %bullet point iv
% 
% ze = envelope(z)/(Ac*2*pi*kf);
% h=zeros(N,1);
% avg = mean(ze);
% for n = 1:N
%     h(n) = ze(n)-avg;
% end

%bullet point v

figure(9)
plot(td, h1, 'g')
hold on
plot(td, h2, 'r')
% ylim([-0.8 0.8])
% sound(h, Fs/1.6, 8)
xlabel('Time [s]')
ylabel('Signal')
legend({'h1[n]', 'h2[n]'});

[d, lags] = xcorr(h1 - mean(h1), h2 - mean(h2));
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




