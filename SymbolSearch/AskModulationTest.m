clearvars;
close all;
hold off;

% create province input signal
[data_pv, fs_pv] = audioread('weather_NRH_1.wav'); % sample frequency and data
%shortLength = length(data_pv);
shortLength = 10000;
x_pv = data_pv(1:shortLength);
clear data_pv;

% plot input signal
t_rep = 1/fs_pv; % period of "continuous" input signal
t_low = 0;
t_high = t_rep*(length(x_pv) - 1);
t_pv = t_low:t_rep:t_high; % define t interval

plot(t_pv, x_pv);
title('Input Signal - NRH');
xlabel('t [s]');

% Ask Modulation
digitalData_pv = AskModulation4Levels(x_pv);

% Plot digital data
figure();
sample = 1:length(digitalData_pv);

plot(sample, digitalData_pv, '.');
title('Digital Signal - NRH');
ylim([-0.5, 3.5]);
xlabel('sample');

% read mission control input signal
[data_ms, fs_ms] = audioread('weather_mission_1.wav'); % sample requency and data
x_ms = data_ms(1:shortLength); % shorten data
%x_ms = data_ms(1:dataSize); % shorten data
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
digitalData_ms = AskModulation4Levels(x_ms);

% Plot digital data
figure();
sample = 1:length(digitalData_ms);

plot(sample, digitalData_ms, '.');
title('Digital Signal - Mission Control');
ylim([-0.5, 3.5]);
xlabel('sample');

% digitalData_ms
% digitalData_pv

% Find Unique Symbol - Province
%symLength = power(2, 7);
symLength = 80;
[uniqueSymbolPv, idxPv, temp] = FindUniqueSymbol(digitalData_pv, symLength);
idxMs = FindUniqueSymbolIndex( digitalData_ms, uniqueSymbolPv );
%[uniqueSymbolMs, idxMs] = FindUniqueSymbol(digitalData_ms, symLength);
