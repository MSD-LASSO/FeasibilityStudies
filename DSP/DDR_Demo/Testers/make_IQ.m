function [] = make_IQ(BW, Fs, SNR, Time, new_IQ_name)
%This function will write a new IQ file using the input parameters
Ts = 1 / Fs;
N = round(Time/Ts);
t = zeros(N, 1);
x1 = zeros(N, 1);
m1 = zeros(N, 1);
for k = 1:N
    t(k) = Ts*(k-1);
    m1(k) = 0.5*t(k)^3 + sin(2*pi()*BW/10*t(k));
    x1(k) = cos(2*pi()*BW*t(k) + sin(m1(k))) + 1i * sin(2*pi()*BW*t(k) + sin(m1(k)));
end
x2(:, 1) = real(x1)/sqrt(2);
x2(:, 2) = imag(x1)/sqrt(2);
audiowrite(new_IQ_name, x2, Fs);
end

