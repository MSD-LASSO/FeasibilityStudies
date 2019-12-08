function [ idx ] = FindUniqueSymbolIndex( digitalArray, symbol )
% Search for index where the symbol occurred
% digitalArray is an array of integers
% symbol is an array of integers

idx = -1;

for i = 1:length(digitalArray)-length(symbol)+1
    if (digitalArray(i) == symbol(1))
        idx = i;
        j = i;
        while j < i+length(symbol) && idx ~=  -1
            if (digitalArray(j) ~= symbol(j-i+1))
                idx = -1;
            end
            j = j + 1;
        end
        if (idx ~= -1)
            break;
        end
    end
end

if (idx == -1)
    %warning('Could not locate unique sequence');
end

idx=int32(idx);

end

