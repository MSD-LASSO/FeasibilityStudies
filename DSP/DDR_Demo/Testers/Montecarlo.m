%Monte Carlo Simulation for a signal varying diferent parameters.
%The signal is going to be delayed by -27 samples and compared with itself
%the trial will run for 100 time at each of the following SNR values:
%[1, 5, 10, 20, 50, 100];
%and at each of the following bandwidths
%[500 1e3 10e3 100e3 500e3]
%and at each of the following durations
%[0.1s 0.5s 1s 2s]
%and at each of the following sample rates
%[1_MSPS 3_MSPS 10_MSPS 20_MSPS]
%The cross correlation will be conducted with all 8 methods
%the accuracy/errors of each method will be computed and the results will
%be organized

clearvars
close all
delay_input = -27;

SNRs = [1, 5, 10, 20, 50, 100];
% SNR_index = 1; %6 SNRs

BWs = [500 1e3 10e3 100e3 500e3];
% BW_index = 1; %5 Bandwidths

Times = [0.1 0.5 1 2];
% Time_index = 1; %4 times

Sample_Rates = [1e6 3e6 10e6 20e6];
% Sample_Rate_index = 1; %4 sample rates

Num_Trials = 100;

monte_1 = 'monte_carlo_data_1.wav';
monte_2 = 'monte_carlo_data_2.wav';

% global_trial_index
c = 1;
trials_cmplx_xcorr = zeros(6, 48000);
%index 1 is the SNR
%index 2 is the BW
%index 3 is the Time
%index 4 is the Fs
%Index 5 is the trial number (k)
%index 6 is the error

for SNR_index = 1:6
    SNR = SNRs(SNR_index);

    for BW_index = 1:5
        BW = BWs(BW_index);
       
        for Time_index = 1:4
            Time = Times(Time_index);
            
            for Sample_Rate_index = 1:4
                Fs = Sample_Rates(Sample_Rate_index);
                
                for k = 1:Num_Trials
                    trials_cmplx_xcorr(1, c) = SNR;
                    trials_cmplx_xcorr(2, c) = BW;
                    trials_cmplx_xcorr(3, c) = Time;
                    trials_cmplx_xcorr(4, c) = Fs;
                    trials_cmplx_xcorr(5, c) = k;
                    make_IQ(BW, Fs, Time, monte_1);
                    delay_IQ(monte_1, delay_input, monte_2);
                    add_noise_IQ(monte_1, SNR, monte_1);
                    add_noise_IQ(monte_2, SNR, monte_2);

                    [cmplx_xcorr_delay, ~, ~, ~, ~] = cmplx_xcorr_IQ(monte_1, monte_2, 0);
                    trials_cmplx_xcorr(6, c) = delay_input - cmplx_xcorr_delay;
                    close all
                    c = c + 1;
                end
            end
        end
    end
end

