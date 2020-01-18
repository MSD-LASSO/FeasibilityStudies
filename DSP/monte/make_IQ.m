function [data] = make_IQ(BW, Fs, Time)
%This function will write a new IQ file using the input parameters
Ts = 1 / Fs;
N = round(Time/Ts);
t = zeros(N, 1);
x1 = zeros(N, 1);
m1 = zeros(N, 1);
for k = 1:N
    t(k) = Ts*(k-1);
    m1(k) = exp(-t(k)*0.1)*5*sin(BW/2*t(k)) + (1/3)*exp(-t(k)*0.2)*sin(BW*t(k)) + (1/2) *exp(-t(k)*0.05)* cos(BW/4*t(k)) + (1/3)*exp(-t(k)*0.3)*cos(BW/6*t(k));
    x1(k) = cos(m1(k)) + 1i * sin(m1(k));
end
x2(:, 1) = real(x1);%/sqrt(2);
x2(:, 2) = imag(x1);%/sqrt(2);
data = x2;
% audiowrite(new_IQ_name, x2, Fs);
end

