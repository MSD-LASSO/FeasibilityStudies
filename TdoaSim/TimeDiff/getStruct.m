function [a] = getStruct(Objects, Error)
%This function inputs the lat, long and elevation as well and an error vector and creates
%a structure with fields for all of the ground station parameters


% Objects [ [lat long elev] [lat long elev] [lat long elev]....]
% Error [ [lat_error long_error elev_error clock] [lat_error long_error ele

n = size(Objects, 1);

for i = 1:n
    a(i).name = ['Object' '_' num2str(i,'%02d')];
    a(i).lat = Objects(i, 1);
    a(i).long = Objects(i, 2);
    a(i).elev = Objects(i, 3);
    a(i).lat_er = Error(i, 1);
    a(i).long_er = Error(i, 2);
    a(i).elev_er = Error(i, 3);
    [a(i).coord, a(i).coord_error] = geo2rect(Objects(i,:), Error(i,:));
    a(i).clk = Error(i, 4);
end

end

