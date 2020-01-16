function [EstAzEl,flag] = moveAzimuthReference(EstAzEl)
%Moves the azimuth starting reference if the values of Azimuth wrap around
%360 / 0 degrees. If you don't do this, it will throw off the average.
%Ex. dataset of Azimuths: 14, 7, 2, 359, 343 degrees
%to take averages this read: 14, 7, 2, -1, -17
%INPUTS: EstAzEl in radians
%OUTPUTS: EstAzEl with new reference.
         %flag =1 if using a new reference
         %flag =0 if nothing changed.

flag=0;
Az=EstAzEl(:,1);
Az2=Az;

for i=1:length(Az2)
    if Az2(i)>pi
        Az2(i)=Az2(i)-2*pi;
    end
end

numOutliersOriginal=sum(isoutlier(Az));
numOutliersShifted=sum(isoutlier(Az2));

if numOutliersShifted<numOutliersOriginal
    flag=1;
    EstAzEl(:,1)=Az2;
end


%not accurate enough
% numBelow90=sum(Az<pi/2);
% numAbove270=sum(Az>3*pi/2);
% totalNum=length(Az);
% 
% if (numBelow90+numAbove270)>totalNum/2 && numBelow90>totalNum/10 && numAbove270>totalNum/10
%     %at least 50% of the data must be between 270 and 90 degrees
%     %at least 10% of the data must be below 90 and 10% above 270.
%     flag=1;
%     Az=180-Az;
% end

% EstAzEl(:,1)=Az;

end

