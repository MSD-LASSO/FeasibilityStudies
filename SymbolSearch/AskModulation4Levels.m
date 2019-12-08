function [ digitalData ] = AskModulation4Levels( data )

lengthData = length(data);
shortData = data(1:lengthData);

%need to filter the signal
[peaks, peakIdx] = findpeaks(data);
period = mean(diff(peakIdx)); % approximate period

ampMax = max(shortData);
ampMin = min(shortData);

%4 amplitude levels
threshold1 = ampMin + (ampMax - ampMin)*1/4;
threshold2 = ampMin + (ampMax - ampMin)*2/4;
threshold3 = ampMin + (ampMax - ampMin)*3/4;

digitalData = zeros(1, length(shortData));

for i = 1:length(shortData)
    if (shortData(i) < threshold1)
        digitalData(i) = 0;
    elseif (shortData(i) < threshold2)
        digitalData(i) = 1;
    elseif (shortData(i) < threshold3)
        digitalData(i) = 2;
    else
        digitalData(i) = 3;
    end
end

end

