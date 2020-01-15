function [] = add_noise_IQ(IQ_file, SNR, new_IQ_name)
%This function writes a copy of an existing IQ data file and adds in a
%specified amount of noise
[x1, Fs, N] = readIQ(IQ_file);
x2 = zeros(N, 1);
x3 = zeros(N, 2);
SNR_fix = 0.157298669 * SNR ^ 1.70648464;
noise_factor = sqrt(2 * rms(x1)^2 / SNR_fix);
for k = 1:N
    x2(k) = x1(k) + complex((-1 + 2*rand())*noise_factor*exp(1i * rand() * 2 * pi()));
    if abs(x2(k)) > 1
        x2(k) = complex(exp(1i * rand() * 2 * pi()));
    end
    x3(k, 1) = real(x2(k));
    x3(k, 2) = imag(x2(k));
end

audiowrite(new_IQ_name, x3, Fs);
end
