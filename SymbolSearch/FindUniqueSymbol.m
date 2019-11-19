function [ uniqueSymbol, idx ] = FindUniqueSymbol( binaryArray, symLength )
% Searches for a unique symbol of size symLength in binaryArray
% Outputs idx - the index of the symbol's start
%             - unique Symb, a number of the unique symbol

arrLength = length(binaryArray);
map = containers.Map('KeyType', 'char', 'ValueType', 'int8');
uniqueGroup = containers.Map('KeyType', 'char', 'ValueType', 'int8');

for i = 1: (arrLength - symLength + 1)
    key_array = binaryArray(i: i+symLength-1 );
    key_char = binaryVectorToHex(key_array);
    if (map.isKey(key_char))
        map(key_char) = map(key_char) + 1;
        remove(uniqueGroup, key_char);
    else
        map(key_char) = 1;
        uniqueGroup(key_char) = i;
    end
end

if (uniqueGroup.Count > 0)
    AllUniqueSymbols = uniqueGroup.keys;
    uniqueSymbol = AllUniqueSymbols{1};
    idx = uniqueGroup(uniqueSymbol);
end

end

