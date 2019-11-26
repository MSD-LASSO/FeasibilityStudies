function [ idx ] = FindUniqueSymbolIndex( binaryArray, symbol )
% Search for index where the symbol occurred

idx = -1;

for i = 1:length(binaryArray)-length(symbol)+1
    if (binaryArray(i) == symbol(1))
        idx = i;
        j = i;
        while j < i+length(symbol) && idx ~=  -1
            if (binaryArray(j) ~= symbol(j-i+1))
                idx = -1;
            end
            j = j + 1;
        end
        if (idx ~= 1)
            break;
        end
    end
end

if (idx ~= -1)
    warning('Could not locate unique sequence');
end

end

