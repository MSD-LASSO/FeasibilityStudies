% This program samples, filters, and reconstructs a signal.
% The signal this is performed on is x.

clearvars;
close all;
hold off;

% create input signal
t_rep = 1e-6; % period of "continuous" input signal
t_low = 0;
t_high = 0.01;
t = t_low:t_rep:t_high; % define t interval
f_low = 1000; % lowest frequency
x = cos(2*pi*f_low*t).*cos(2*pi*3*f_low*t); % input signal
f_high = 4*f_low; % highest frequency
fs = 9000; % sample frequency

% plot input signal
plot(t, x);
title('Input Signal - x(t)');
xlabel('t [s]');
figure();

% fourier transform on signal
x_ft = fft(x); % fourier transform
x_ftshifted = fftshift(x_ft); % shift so we get negative and positive ft data
x_ftshifted_faxis = linspace(-1/t_rep/2, 1/t_rep/2, length(x_ftshifted)); % create freq axis
plot(x_ftshifted_faxis, abs(x_ftshifted));
axis([-8000 8000 0 3000]);
title('Fourier Transform of Input Signal - X(jf)');
xlabel('f [Hz]');
figure();

% calculate sample period
NyqMult = floor(1/fs/t_rep);
Ts = t_rep*NyqMult; % sample period calculated this way so we sample at defined points
if (1/Ts < 2*f_high) % sample freq must be at least 2*f
    warning('WARNING! Sample frequency is under nyquist rate\n');
end

% create impulse train
p = zeros(1, length(t)); % allocate memory for impulse train
for n = 0:((t_high-t_low)/Ts)
    idx = floor(n*Ts/t_rep + 1);
    p(idx) = 1; % set to 1 each period
end
plot(t, p);
title('Impulse Train - p(t)');
xlabel('t [s]');
figure();

% get sampled signal
xs = x.*p; % get sampled signal
plot(t, xs);
title('Sampled Signal - xs(t)');
xlabel('t [s]');
figure();

% fourier transform sampled signal
oscAmp = 4; % amp of oscillations from matlab fourier transform
xs_ft = fft(xs); % fourier transform sampled signal
xs_ftshifted = fftshift(xs_ft); % shift the ft 
xs_ftshifted(abs(xs_ftshifted)<oscAmp) = 0; % remove oscillations
xs_ftshifted_faxis = linspace(-1/t_rep/2, 1/t_rep/2, length(xs_ftshifted)); % create freq axis
plot(xs_ftshifted_faxis, abs(xs_ftshifted));
axis([-6000 6000 0 30]);
title('Fourier Transform of Sampled Signal - Xs(jf)');
xlabel('f [Hz]');
figure();

% create filter (H)
H = zeros(1, length(xs_ftshifted_faxis));
H(abs(2*pi*xs_ftshifted_faxis) < pi/Ts) = Ts; % filter is unit pulse from -fs/2 to fs/2
plot(xs_ftshifted_faxis, H);
axis([-10000 10000 0 1.5e-4]);
title('Frequency Filter - H(jf)')
xlabel('f [Hz]');
figure();

% create reconstructed FT by filtering signal with H
xr_ftshifted = xs_ftshifted.*H; % reconstructed = (sampled signal)*(filter)
xr_ftshifted_faxis = linspace(-1/t_rep/2, 1/t_rep/2, length(xs_ftshifted)); % create freq axis

% plot reconstructed FT
plot(xr_ftshifted_faxis, abs(xr_ftshifted));
axis([-6000 6000 0 3.5e-3]);
title('Fourier Transform of Reconstructed Signal - Xr(jf)');
xlabel('f [Hz]');
figure();

% plot reconstructed signal and input signal
% Note that the scale needs to be adjusted... Prof says this is typical
% TODO find out how to get original amplitude without input signal
plot(t, x);
hold on;

xr = IfftBlock(xr_ftshifted);
xr_scaled = max(x)/max(xr)*xr;
plot(t, xr_scaled);

title('Reconstructed and Input Signal - xr(t) & x(t)');
xlabel('t [s]');
legend('input', 'reconstructed');
hold off;
