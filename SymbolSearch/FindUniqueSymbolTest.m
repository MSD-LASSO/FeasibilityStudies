% tests:

% Test 1
% demodulated data, unique = 1001, 0001, 0011, 1011, 1111
binaryArray = [0 0 1 0 1 0 0 1 0 1 0 1 0 1 0 0 0 0 1 1 1 0 1 1 1 1 0 1 0 0 0 0];
symLength = 4;
[uniqueSymbol, idx] = FindUniqueSymbol(binaryArray, symLength);
if (idx ~= 16)
    warning('Unique symbol search test failed to find correct index');
elseif (uniqueSymbol ~= '1')
    warning('Unique symbol search test failed to find correct symbol');
end
