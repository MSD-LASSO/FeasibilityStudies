diff = zeros([1 length(temp)]);
diffIdx = 1;

count = 0;
for k = keys(temp)
    count = count + 1;
    myK = k{:};
    idxPv = temp(myK);
    symbol = digitalData_pv(idxPv:idxPv+symLength-1);
    idxMs = FindUniqueSymbolIndex (digitalData_ms, symbol);
    if (idxMs ~= int32(-1))
        diff(diffIdx) = abs(idxPv - idxMs);
        diffIdx = diffIdx + 1;
    end
end

plot(diff);
title('Sample Difference (80 bit symbol)');
xlabel('symbol');