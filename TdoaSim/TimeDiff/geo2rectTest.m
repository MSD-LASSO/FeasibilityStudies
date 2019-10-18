%tester for geo2rect
%the distance between rochester and buffalo (107km) is found by converitng
%their lat, long, elevation to x y z and then doing a distance formula

lat_er = 0.00003; %assuming n degree of error
long_er = 0.00003; %assuming n degree of error
elev_er = 5; %assuming 5 meters of elevation error

%rochester

roc_lat = 43.1566; %latitude in degrees
roc_long = 77.6088; %longitude in degrees
roc_elev = 154; %in meters

[POS_r, Error_r] = geo2rect([roc_lat, roc_long, roc_elev], [lat_er, long_er, elev_er]);

%buffalo

buff_lat = 42.8864; %latitude in degrees
buff_long = 78.8784; %longitude in degrees
buff_elev = 183; %in meters

[POS_b, Error_b] = geo2rect([buff_lat, buff_long, buff_elev], [lat_er, long_er, elev_er]);
% 
% roc = [x_roc y_roc z_roc];
% roc_max = [x_roc+xr_er y_roc+yr_er z_roc+zr_er]; %max values are calculated  by adding error
% roc_min = [x_roc-xr_er y_roc-yr_er z_roc-zr_er]; %min values are calculated by subtracting error
% 
% buff = [x_buff y_buff z_buff];
% buff_max = [x_buff+xb_er y_buff+yb_er z_buff+zb_er]; %max values are calculated  by adding error
% buff_min = [x_buff-xb_er y_buff-yb_er z_buff-zb_er]; %min values are calculated by subtracting error


distance = norm(POS_r - POS_b); %distance forumal in 3d space

d1 = norm((POS_r+Error_r) - (POS_b+Error_r));
d2 = norm((POS_r+Error_r) - (POS_b-Error_r));
d3 = norm((POS_r-Error_r) - (POS_b+Error_r));
d4 = norm((POS_r-Error_r) - (POS_b-Error_r));

AssertTolerance(1.075e+05,distance,100)

