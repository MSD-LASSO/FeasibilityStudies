function [ digitalData ] = AskModulation8Levels( data )

lengthData = length(data);
shortData = data(1:lengthData);

%need to filter the signal
[peaks, peakIdx] = findpeaks(data);
period = mean(diff(peakIdx)); % approximate period

ampMax = max(shortData);
ampMin = min(shortData);

%8 amplitude levels
threshold1 = ampMin + (ampMax - ampMin)*1/8;
threshold2 = ampMin + (ampMax - ampMin)*2/8;
threshold3 = ampMin + (ampMax - ampMin)*3/8;
threshold4 = ampMin + (ampMax - ampMin)*4/8;
threshold5 = ampMin + (ampMax - ampMin)*5/8;
threshold6 = ampMin + (ampMax - ampMin)*6/8;
threshold7 = ampMin + (ampMax - ampMin)*7/8;

digitalData = zeros(1, length(shortData));

for i = 1:length(shortData)
    if (shortData(i) < threshold1)
        digitalData(i) = 0;
    elseif (shortData(i) < threshold2)
        digitalData(i) = 1;
    elseif (shortData(i) < threshold3)
        digitalData(i) = 2;
    elseif (shortData(i) < threshold4)
        digitalData(i) = 3;
    elseif (shortData(i) < threshold5)
        digitalData(i) = 4;
    elseif (shortData(i) < threshold6)
        digitalData(i) = 5;
    elseif (shortData(i) < threshold7)
        digitalData(i) = 6;
    else
        digitalData(i) = 7;
    end
end

end