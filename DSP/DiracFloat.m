function [ y ] = DiracFloat( x, offset, tol )
% This is a delta dirac function with a scale of 1 that works for float
% comparisons because it uses a tolerance.

y = (abs(x - offset) < tol);

end

