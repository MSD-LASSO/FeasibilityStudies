% tests:

% Test 1
% demodulated data, unique = 1001, 0001, 0011, 1011, 1111
digitalArray = [0 0 1 0 1 0 0 1 0 1 0 1 0 1 0 0 0 0 1 1 1 0 1 1 1 1 0 1 0 0 0 0];
symLength = 4;
[uniqueSymbol, idx] = FindUniqueSymbol(digitalArray, symLength);
if (idx ~= 16)
    warning('Unique symbol search test failed to find correct index');
elseif (uniqueSymbol ~= [0 0 0 1])
    warning('Unique symbol search test failed to find correct symbol');
end

% Test 2
% check the found index matches returned index
foundIdx = FindUniqueSymbolIndex(digitalArray, uniqueSymbol);
if (foundIdx ~= idx)
    warning('Original idx and found idx do not match');
end

% Test 3
clear;
digitalArray = [0 1 2 3 4 0 1 1 2 1 3 1 0 1 1 2 1 3 1 0 2 0 1 0 2 0 1 2 3 4 0 1];
symLength = 4;
[uniqueSymbol, idx] = FindUniqueSymbol(digitalArray, symLength);
if (idx ~= 18)
    warning('Unique symbol search test failed to find correct index');
elseif (uniqueSymbol ~= [3 1 0 2])
    warning('Unique symbol search test failed to find correct symbol');
end

foundIdx = FindUniqueSymbolIndex(digitalArray, uniqueSymbol);
if (foundIdx ~= idx)
    warning('Original idx and found idx do not match');
end