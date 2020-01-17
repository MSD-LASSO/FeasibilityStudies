function [] = delay_IQ(IQ_file, sample_delay, new_IQ_name)
%This function writes a delayed copy of an existing IQ data file sample
%delays are negative to indicate that the new file is lagging the old one
[x1, Fs, N] = readIQ(IQ_file);
x2 = zeros(N, 2);
for k = 1:N
    if k <= -1 * sample_delay
        x2(k) = 0;
    else
        x2(k, 1) = real(x1(k + sample_delay));
        x2(k, 2) = imag(x1(k + sample_delay));
    end
end
audiowrite(new_IQ_name, x2, Fs);
end

