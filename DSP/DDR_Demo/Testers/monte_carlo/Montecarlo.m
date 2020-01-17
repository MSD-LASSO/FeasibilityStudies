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
trials_data = zeros(13, 48000);
%index 1 is the SNR
%index 2 is the BW
%index 3 is the Time
%index 4 is the Fs
%Index 5 is the trial number (k)
%index 6 is the cmplx_xcorr_error
%index 7 is the cmplx_xcov_error
%index 8 is the abs_xcorr_error
%index 9 is the abs_xcov_error
%index 10 is the phase_xcorr_error
%index 11 is the phase_xcov_error
%index 12 is the phase_diff_xcorr_error
%index 13 is the phase_diff_xcov_error

for SNR_index = 1:6
    SNR = SNRs(SNR_index);

    for BW_index = 1:5
        BW = BWs(BW_index);
       
        for Time_index = 1:4
            Time = Times(Time_index);
            
            for Sample_Rate_index = 1:4
                Fs = Sample_Rates(Sample_Rate_index);
                
                for k = 1:Num_Trials
                    trials_data(1, c) = SNR;
                    trials_data(2, c) = BW;
                    trials_data(3, c) = Time;
                    trials_data(4, c) = Fs;
                    trials_data(5, c) = k;
                    make_IQ(BW, Fs, Time, monte_1);
                    delay_IQ(monte_1, delay_input, monte_2);
                    add_noise_IQ(monte_1, SNR, monte_1);
                    add_noise_IQ(monte_2, SNR, monte_2);

                    [cmplx_xcorr_delay, ~, ~, ~, ~] = cmplx_xcorr_IQ(monte_1, monte_2, 0);
                    trials_data(6, c) = delay_input - cmplx_xcorr_delay;
                    close all
                    
                    [cmplx_xcov_delay, ~, ~, ~, ~] = cmplx_xcov_IQ(monte_1, monte_2, 0);
                    trials_data(7, c) = delay_input - cmplx_xcov_delay;
                    close all
                    
                    [abs_xcorr_delay, ~, ~, ~, ~] = abs_xcorr_IQ(monte_1, monte_2, 0);
                    trials_data(8, c) = delay_input - abs_xcorr_delay;
                    close all
                    
                    [abs_xcov_delay, ~, ~, ~, ~] = abs_xcov_IQ(monte_1, monte_2, 0);
                    trials_data(9, c) = delay_input - abs_xcov_delay;
                    close all
                    
                    [phase_xcorr_delay, ~, ~, ~, ~] = phase_xcorr_IQ(monte_1, monte_2, 0);
                    trials_data(10, c) = delay_input - phase_xcorr_delay;
                    close all
                    
                    [phase_xcov_delay, ~, ~, ~, ~] = phase_xcov_IQ(monte_1, monte_2, 0);
                    trials_data(11, c) = delay_input - phase_xcov_delay;
                    close all
                    
                    [phase_diff_xcorr_delay, ~, ~, ~, ~] = phase_diff_xcorr_IQ(monte_1, monte_2, 0);
                    trials_data(12, c) = delay_input - phase_diff_xcorr_delay;
                    close all
                    
                    [phase_diff_xcov_delay, ~, ~, ~, ~] = phase_diff_xcov_IQ(monte_1, monte_2, 0);
                    trials_data(13, c) = delay_input - phase_diff_xcov_delay;
                    close all
                    
                    
                    c = c + 1;
                    c/48000 * 100
                end
            end
        end
    end
end

