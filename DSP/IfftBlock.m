function [ sig ] = IfftBlock( sig_ftshifted )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

sig_ft = ifftshift(sig_ftshifted);
sig = ifft(sig_ft);
end

