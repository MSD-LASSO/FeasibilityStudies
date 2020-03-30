function [IQ_matrix, Fs, N] = readIQ(IQ_file)
%UNTITLED2 This function will read in a wav file and return a complex array
%(N x 1)
[m, Fs] = audioread(IQ_file);
N = size(m, 1);
IQ_matrix = m(:,1);% + 1i * m(:,2);

% %(N x 1)
% [m, Fs] = audioread(IQ_file);
% N = size(m, 1);
% sa=ceil(start*N);
% en=ceil(stop*N);
% IQ_matrix = m(sa:en,1);% + 1i * m(:,2);
% 
% %Resize.
% N=size(IQ_matrix,1);
end

