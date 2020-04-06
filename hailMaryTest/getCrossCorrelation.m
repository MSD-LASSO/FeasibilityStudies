%this script is here for compability's sake. It will work with the hailMary
%test, but not neccessarily future tests. Use the getCrossCorrelation
%located in the FilterDemod/ folder of the GNU git branch for the most
%up-to-date copy.

clearvars
close all
addpath('../TdoaSim/')

% mainPath='C:\Users\awian\Desktop\MSD\3_9_ref_only';
% mainPath='C:\Users\awian\Desktop\MSD\3_12_ref_same_pi';
% mainPath='C:\Users\awian\Desktop\MSD\3_13_same_pi_APS';
mainPath='C:\Users\awian\Desktop\MSD\hailMary';

pi1_directory=dir([mainPath '\pi1_filtered']);
pi2_directory=dir([mainPath '\pi2_filtered']);
max = size(pi2_directory, 1);



delta_scheduler = zeros(max-2,1);
delta_file = zeros(max-2,4);
file_save_time_1 = zeros(max-2, 4);
file_save_time_2 = zeros(max-2, 4);
fractionOfData=0.0050;
sample_delay = zeros(max-2,1/fractionOfData);
time_delay = zeros(max-2,1/fractionOfData);
offset = zeros(max-2,1/fractionOfData);
for i = 3:length(pi1_directory)
    if i~=11 && i~=12
        continue
    end
    i
    pi_1_file = [mainPath '\pi1_filtered\' pi1_directory(i).name];
    pi_2_file = [mainPath '\pi2_filtered\' pi2_directory(i).name];
    
    str=split(pi1_directory(i).name,'_');
    assumedMin=60*str2double(str{6});
    scheduledTime(i-2)=assumedMin+str2double(str{7})+str2double(str{8})/1e6;
    
    
    
    a=assumedMin+str2double(str{10})+str2double(str{11})/1e6;
    b=assumedMin+str2double(str{13})+str2double(str{14})/1e6;
    c=assumedMin+str2double(str{16})+str2double(str{17})/1e6;
    d=60*str2double(str{19})+str2double(str{20})+str2double(str{21}(1:end-4))/1e6;
    file_save_time_1(i-2,:)=[a,b,c,d];
    
    
    str=split(pi2_directory(i).name,'_');
    assumedMin=60*str2double(str{6});
    a=assumedMin+str2double(str{10})+str2double(str{11})/1e6;
    b=assumedMin+str2double(str{13})+str2double(str{14})/1e6;
    c=assumedMin+str2double(str{16})+str2double(str{17})/1e6;
    d=60*str2double(str{19})+str2double(str{20})+str2double(str{21}(1:end-4))/1e6;
    file_save_time_2(i-2,:)=[a,b,c,d];
    
%     
    intersect=pi_1_file(strfind(pi_1_file,'2020'):strfind(pi_1_file,'2020')+25);
    
    
    delta_file(i-2,:) = file_save_time_1(i-2,:) - file_save_time_2(i-2,:);
    
%     p=1;
%     for percent=0:fractionOfData:1-fractionOfData
    
        [x1, Fs1, N1] = readIQ(pi_1_file);
        [x2, Fs2, N2] = readIQ(pi_2_file);

        [sample_delay(i-2,:), ~, ~, ~, ~] = abs_xcov_IQ(pi_1_file, pi_2_file, 0, intersect,fractionOfData);
        time_delay(i-2,:) = sample_delay(i-2,:) /Fs1;
        %We use column 2 of delta_file because "aftersetup" seems to
        %correct the delays the best.
        offset(i-2,:) = time_delay(i-2,:) -  delta_file(i-2,2);
        t = 0:1/Fs1:(N1-1)/Fs1;
        
%         figure()
%         plot(t, x1+1, t, x2-1)
%         legend('First Pi', 'Second Pi')
%         xlabel('Time [s]')
%         ylabel('Signals with offsets')
%         ylim([-2.5 2.5]);
%         title(intersect)
    

        clear x1
        clear x2
        clear t
%     end
    
end

% plot_fft_IQ(pi_1_file_1);
% plot_fft_IQ(pi_2_file_1);

% clear x1
% clear x2
% clear t


% plot((file_save_time_1+file_save_time_2)/2 - (file_save_time_1(1)+file_save_time_2(1))/2, offset)
% title('Time offsets Bewteen the Pis --- Pi2 time - Pi1 time')
% ylabel('Offset Time [s]')
% xlabel('Test Time [s]')
% offset
offset=[time_delay offset];
m=mean(abs(offset));
s=std(abs(offset));
disp(mean(abs(offset))); disp(std(abs(offset)))

% GraphSaver({'png'},'Plots',0,0);
close all

% save('getCrossCorrelation1_5sec.mat');
% save('getCC1_5secTD.mat','offset');

% input_delay = -27;
% 
% orig_data = 'new_file_IQ.wav';
% my_data = 'myData.wav';
% delayed_data = 'myDataDelayed.wav';
% [~, Fs, N1] = readIQ(orig_data);
% plot_fft_IQ(orig_data);
% 



















% [x2, Fs1, N2] = readIQ(gen_IQ);
% y1 = lowpass(x2, 50e3, Fs);
% y2(:, 1) = real(y1);
% y2(:, 2) = imag(y1);
% audiowrite(new_IQ_name, y2, Fs);
% plot_fft_IQ(gen_IQ);
% plot_fft_IQ(new_IQ_name);

% cmplx_xcorr_IQ(gen_IQ, new_IQ_name, 0);





















% 
% 
% 
% SNR_try = 40000;
%     
% BW_try = 100e3;
% make_IQ(BW_try, Fs, Time, file_name_2)
% add_noise_IQ(file_name_2, SNR_try, file_name_3);
% plot_fft_IQ(file_name_3);
% add_noise_IQ(file_name_2, SNR_try, file_name_4);
% % plot_fft_IQ(file_name_4);
% delay_IQ(file_name_4, input_delay, file_name_5);
% plot_fft_IQ(file_name_5);
% 
% 
% 
% 
% 
% 
% % 
% [delay1, ~, ~, ~, ~] = cmplx_xcorr_IQ(file_name_3, file_name_5, 0);
% [delay2, ~, ~, ~, ~] = cmplx_xcov_IQ(file_name_3, file_name_5, 0);
% [delay3, ~, ~, ~, ~] = abs_xcorr_IQ(file_name_3, file_name_5, 0);
% [delay4, ~, ~, ~, ~] = abs_xcov_IQ(file_name_3, file_name_5, 0);
% [delay5, ~, ~, ~, ~] = phase_xcorr_IQ(file_name_3, file_name_5, 0);
% [delay6, ~, ~, ~, ~] = phase_xcov_IQ(file_name_3, file_name_5, 0);
% [delay7, ~, ~, ~, ~] = phase_diff_xcorr_IQ(file_name_3, file_name_5, 0);
% [delay8, ~, ~, ~, ~] = phase_diff_xcov_IQ(file_name_3, file_name_5, 0);
% 
% 
% 
% 
% 
% 
% num_success = 0;
% success = zeros(2, 20);
% 
% for k = 1:20
%     SNR_try = 10;
%     
%     BW_try = 5e3*k;
%     make_IQ(Fs, SNR, Time, file_name_2)
%     
%     add_noise_IQ(file_name_2, SNR_try, file_name_3);
%     plot_fft_IQ(file_name_3);
%     add_noise_IQ(file_name_2, SNR_try, file_name_4);
%     plot_fft_IQ(file_name_4);
%     delay_IQ(file_name_4, input_delay, file_name_5);
%     plot_fft_IQ(file_name_5);
% 
%     [delay, ~, ~, ~, ~] = cmplx_xcov_IQ(file_name_3, file_name_5, 0);
% 
%     if delay == input_delay
%         num_success = num_success + 1;
%         success(1, k) = 0;
%     else
%         success(1, k) = abs(delay - input_delay);
%     end
%     
%     success(2, k) = BW_try;
%     close all
% end
% 
% 
% 
% 
% 
% 
% % clc;
% % clear all;
% % close all;
% % t=0:.001:1;
% % fm=1;
% % fc=100;
% % m=sin(2*pi*fm*t);
% % subplot(311);
% % plot(m);
% % title('Message signal');
% % c=cos(2*pi*fc*t+5*sin(2*pi*fm*t));
% % subplot(313);
% % plot(c);
% % title('fm signal');
% % subplot(312);
% % plot(cos(2*pi*fc*t));
% % title('Carrier signal');
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% % delay_set = -150000;
% % SNR = 1;
% % file_name_2 = strcat('NOISY_', file_name_1);
% % file_name_3 = strcat('DELAYED_', file_name_2);
% % 
% % add_noise_IQ(file_name_1, SNR, file_name_2);
% % 
% % plot_fft_IQ(file_name_2);
% % 
% % delay_IQ(file_name_2, delay_set, file_name_3);
% % [delay, corr_factor, lags_matrix, lags, Ts] = phase_diff_xcov_IQ(file_name_1, file_name_3, 0);