function [noise_data] = add_noise_IQ(data, SNR)
%This function writes a copy of an existing IQ data file and adds in a
%specified amount of noise
x1 = data(:, 1) + 1i * data(:, 2);
N = size(x1, 1);
signal_power = bandpower(x1);
noise_power = signal_power / SNR;
A_noise = sqrt(noise_power);
x2 = zeros(N, 1);
x3 = zeros(N, 2);
renorm_flag = 0;
% SNR_fix = 0.157298669 * SNR ^ 1.70648464;
% noise_factor = sqrt(2 / SNR);
for k = 1:N
%     x2(k) = complex((-1 + 2*rand())*noise_factor*exp(1i * rand() * 2 * pi()));
    x2(k) = A_noise * exp(1i * rand() * 2 * pi()) + x1(k);
    if real(x2(k))^2 + imag(x2(k))^2  > 1
        renorm_flag = 1;
    end
end
if renorm_flag == 1
    x2 = x2/max(abs(x2));
end
x3(:, 1) = real(x2);
x3(:, 2) = imag(x2);
noise_data = x3;
% audiowrite(new_IQ_name, x3, Fs);
end
