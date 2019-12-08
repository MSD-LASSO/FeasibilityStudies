function [ uniqueSymbol, idx, temp ] = FindUniqueSymbol( digitalArray, symLength )
% Searches for a unique symbol of size symLength in binaryArray
% Outputs idx - the index of the symbol's start
%             - uniqueSymbol, an array containing the unique symbol

arrLength = length(digitalArray);
if (arrLength >= power(2, 31))
    error('Digital array too large for value type. Increase size of type.')
end

map = containers.Map('KeyType', 'char', 'ValueType', 'int8');
uniqueGroup = containers.Map('KeyType', 'char', 'ValueType', 'int32');

% create two maps: (1) symbol->number occurrences (2) unique symbol->index
for i = 1: (arrLength - symLength + 1)
    key_char = char(digitalArray(i: i+symLength-1 ));
    if (map.isKey(key_char))
        map(key_char) = map(key_char) + 1;
        if (uniqueGroup.isKey(key_char))
            remove(uniqueGroup, key_char);
        end
    else
        map(key_char) = 1;
        uniqueGroup(key_char) = i;
    end
end

% find the first unique 
if (uniqueGroup.Count > 0)
    % find the unique symbol closest to the midpoint of the data
    % done to increase likelihood that other stations got this signal
    uniqueIdxs = uniqueGroup.values;
    midIdx = floor(arrLength/2); % define midpoint index
    uniqueIdxsVector = [uniqueIdxs{:}];
    % find the unique index closest to midpoint
    
    idx = min( abs(uniqueIdxsVector-midIdx)) + midIdx;
    
    % get unique symbol
    uniqueSymbol = digitalArray(idx: idx+symLength-1 );
    temp = uniqueGroup;
else
    warning('No unique sequence found.');
end

end

