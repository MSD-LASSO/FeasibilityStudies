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

test_vector = zeros(48000, 13);

% global_trial_index
c = 1;
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
                    test_vector(c, 1) = SNR;
                    test_vector(c, 2) = BW;
                    test_vector(c, 3) = Time;
                    test_vector(c, 4) = Fs;
                    test_vector(c, 5) = k;                
                    c = c + 1;
                end
            end
        end
    end
end
SNR = test_vector(:, 1);
BW = test_vector(:, 2);
Time = test_vector(:, 3);
Fs = test_vector(:, 4);
ks = test_vector(:, 5);


parfor (n =1:48000)
    make_IQ(BW(n), Fs(n), Time(n), monte_1);
    delay_IQ(monte_1, delay_input, monte_2);
    add_noise_IQ(monte_1, SNR(n), monte_1);
    add_noise_IQ(monte_2, SNR(n), monte_2);
    
    test_vector_sub = zeros(1, 13);
    
    test_vector_sub(1) = SNR(n);
    test_vector_sub(2) = BW(n);
    test_vector_sub(3) = Time(n);
    test_vector_sub(4) = Fs(n);
    test_vector_sub(5) = ks(n);
    
    
    [cmplx_xcorr_delay, ~, ~, ~, ~] = cmplx_xcorr_IQ(monte_1, monte_2, 0);
    test_vector_sub(6) = delay_input - cmplx_xcorr_delay;

    [cmplx_xcov_delay, ~, ~, ~, ~] = cmplx_xcov_IQ(monte_1, monte_2, 0);
    test_vector_sub(7) = delay_input - cmplx_xcov_delay;

    [abs_xcorr_delay, ~, ~, ~, ~] = abs_xcorr_IQ(monte_1, monte_2, 0);
    test_vector_sub(8) = delay_input - abs_xcorr_delay;

    [abs_xcov_delay, ~, ~, ~, ~] = abs_xcov_IQ(monte_1, monte_2, 0);
    test_vector_sub(9) = delay_input - abs_xcov_delay;
    
    [phase_xcorr_delay, ~, ~, ~, ~] = phase_xcorr_IQ(monte_1, monte_2, 0);
    test_vector_sub(10) = delay_input - phase_xcorr_delay;

    [phase_xcov_delay, ~, ~, ~, ~] = phase_xcov_IQ(monte_1, monte_2, 0);
    test_vector_sub(11) = delay_input - phase_xcov_delay;

    [phase_diff_xcorr_delay, ~, ~, ~, ~] = phase_diff_xcorr_IQ(monte_1, monte_2, 0);
    test_vector_sub(12) = delay_input - phase_diff_xcorr_delay;

    [phase_diff_xcov_delay, ~, ~, ~, ~] = phase_diff_xcov_IQ(monte_1, monte_2, 0);
    test_vector_sub(13) = delay_input - phase_diff_xcov_delay;
    
    test_vector(n, :) = test_vector_sub;
    n/48000 * 100
end

save results.mat
