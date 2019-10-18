function [timeDifferences] = timeDiff(GROUND, SAT)
%This function inputs the three geographical coordinates of the ground
%stations and a satellite and returns the time differences


%   Returns a 3D matrix of the form:
%     [Sat1(GND A to GND B)           Sat2(GND A to GND B)          Sat3(GND A to GND B)...
%      Sat1(GND A to GND B) error     Sat2(GND A to GND B) error    Sat3(GND A to GND B)...]
%  
%      Sat1(GND A to GND C)           Sat2(GND A to GND C)          Sat3(GND A to GND C)...
%      Sat1(GND A to GND C) error     Sat2(GND A to GND C) error    Sat3(GND A to GND C)...]
%      
%      Sat1(GND B to GND C)           Sat2(GND B to GND C)          Sat3(GND B to GND C)...
%      Sat1(GND B to GND C) error     Sat2(GND B to GND C) error    Sat3(GND B to GND C)...]
%      .
%      .
%      .]

% The matrix will inlcude every time difference combination for every
% satellite for g ground stations and s satellites
    


s = size(SAT, 2);
g = size(GROUND ,2);
k = factorial(g)/factorial(g-2)/2;
timeDifferences = zeros(2, s, k);
count = 1;

for i = 1:s
    for j = 1:g
        for k = j+1:g
            [temp_dist1, temp_error1] = gnd2sat(GROUND(j).coord, GROUND(j).coord_error, SAT(i).coord, SAT(i).coord_error);
            [temp_dist2, temp_error2] = gnd2sat(GROUND(k).coord, GROUND(k).coord_error, SAT(i).coord, SAT(i).coord_error);
            [timeDifferences(1, i, count), timeDifferences(2, i, count)] = dist2time(temp_dist1, temp_error1, temp_dist2, temp_error2, GROUND(j).clk, GROUND(k).clk);
            count = count + 1;
       end
    end
    count=1;
end

end

