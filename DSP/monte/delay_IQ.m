function [delayed_data] = delay_IQ(data, sample_delay)
%This function writes a delayed copy of an existing IQ data file sample
%delays are negative to indicate that the new file is lagging the old one
x1 = data(:, 1) + 1i * data(:, 2);
N = size(x1, 1);
x2 = zeros(N, 2);
for k = 1:N
    if k <= -1 * sample_delay
        x2(k) = 0;
    else
        x2(k, 1) = real(x1(k + sample_delay));
        x2(k, 2) = imag(x1(k + sample_delay));
    end
end
delayed_data = x2;
% audiowrite(new_IQ_name, x2, Fs);
end

