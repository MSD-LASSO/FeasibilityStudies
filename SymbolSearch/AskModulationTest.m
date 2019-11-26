clearvars;
close all;
hold off;

dataSize = 2000;

% create province input signal
[data_pv, fs_pv] = audioread('Loc2_97900000Hz_IQ(Province).wav'); % sample frequency and data
x_pv = data_pv(1:dataSize); % shorten data
clear data_pv;

% plot input signal
figure();
t_rep = 1/fs_pv; % period of "continuous" input signal
t_low = 0;
t_high = t_rep*(length(x_pv) - 1);
t_pv = t_low:t_rep:t_high; % define t interval

plot(t_pv, x_pv);
title('Input Signal - Province');
xlabel('t [s]');

% Ask Modulation
digitalData_pv = AskModulation(x_pv);

% Plot digital data
figure();
sample = 1:length(digitalData_pv);

plot(sample, digitalData_pv, '.');
title('Digital Signal - Province');
ylim([0.5, 3.5]);
xlabel('sample');

% read mission control input signal
[data_ms, fs_ms] = audioread('Loc1_97900000Hz_IQ(Mission Control).wav'); % sample requency and data
x_ms = data_ms(1:dataSize); % shorten data
clear data_ms;

% plot input signal
figure();
t_rep = 1/fs_ms; % period of "continuous" input signal
t_low = 0;
t_high = t_rep*(length(x_ms) - 1);
t_ms = t_low:t_rep:t_high; % define t interval

plot(t_ms, x_ms);
title('Input Signal - Mission Control');
xlabel('t [s]');

% Ask Modulation
digitalData_ms = AskModulation(x_ms);

% Plot digital data
figure();
sample = 1:length(digitalData_ms);

plot(sample, digitalData_ms, '.');
title('Digital Signal - Mission Control');
ylim([0.5, 3.5]);
xlabel('sample');

