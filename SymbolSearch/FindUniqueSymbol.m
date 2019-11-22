function [ uniqueSymbol, idx ] = FindUniqueSymbol( binaryArray, symLength )
% Searches for a unique symbol of size symLength in binaryArray
% Outputs idx - the index of the symbol's start
%             - unique Symb, a number of the unique symbol

arrLength = length(binaryArray);
map = containers.Map('KeyType', 'char', 'ValueType', 'int8');
uniqueGroup = containers.Map('KeyType', 'char', 'ValueType', 'int8');

% create two maps: (1) symbol->number occurrences (2) unique symbol->index
for i = 1: (arrLength - symLength + 1)
    key_array = binaryArray(i: i+symLength-1 );
    key_char = binaryVectorToHex(key_array);
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
    %closestVal = min( abs(uniqueIdxsVector-midIdx)) + midIdx;
    %idx = find(uniqueIdxsVector == closestVal + midIdx); 
    
    % get unique symbol
    uniqueSymbol = binaryVectorToHex(binaryArray(idx: idx+symLength-1 ));
else
    warning('No unique sequence found.');
end

end

