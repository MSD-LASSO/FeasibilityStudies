% Test Cramer Rao

close all, clc, clear all

runs = 10;
MSE  = 0;
CRLB = 0;
for r = 1:runs
Iterations = 100;
N = 512;
Delay = 5;

% 1 : Generate a Random White Gaussian Signal
% ---
signal = randn(1,N);
signal = repmat(signal,[Iterations,1]);

% 2 : Generate the noise required to obtain a given SNR.
% ---
SNR = 2000;
noise_variance = 1/SNR* var(signal(1,:));
noise  = sqrt(noise_variance)*randn(Iterations,N);

% 3 : Calculate the actual SNR for both the zero-mean noise and zero-mean
%     signal
% ---
SNR = (rms(signal(1,:))/rms(noise(1,:)))^2;

% 4 : Corrupt signal with generated noise
% ---
signal_w_noise = signal + noise;

% 5 : Process cross correlations to calculate lags,
%     interpolate as defined 
% ---
x1 = signal_w_noise(1,:);
lags = [];
for seg = 1:Iterations
    x2 = signal_w_noise(seg,:);
    [Correlation, lag_array] = xcov(x1,x2);
    [~,peak_index] = max(Correlation);

    coarse = lag_array(peak_index);
    fine = -(1/2)*(Correlation(peak_index+1) - Correlation(peak_index-1)) / (Correlation(peak_index+1) + Correlation(peak_index-1) - 2*Correlation(peak_index));

    lag = coarse+fine;
    lags = [lags lag];
end
% Calculate the mean square error and compare it to the CRLB
% ---
MSE  = MSE + (mean((lags - Delay).^2))/runs;
CRLB =  CRLB + ((3/((pi.^2)*(N))) * ((1 + 2 .* SNR)./(SNR.^2)))/runs;

end


disp(CRLB/MSE)