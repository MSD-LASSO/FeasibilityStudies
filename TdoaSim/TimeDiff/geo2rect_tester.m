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

[x_roc, y_roc, z_roc, xr_er, yr_er, zr_er] = geo2rect(roc_lat, lat_er, roc_long, long_er, roc_elev, elev_er);

%buffalo

buff_lat = 42.8864; %latitude in degrees
buff_long = 78.8784; %longitude in degrees
buff_elev = 183; %in meters

[x_buff, y_buff, z_buff, xb_er, yb_er, zb_er] = geo2rect(buff_lat, lat_er, buff_long, long_er, buff_elev, elev_er);

roc = [x_roc y_roc z_roc];
roc_max = [x_roc+xr_er y_roc+yr_er z_roc+zr_er]; %max values are calculated  by adding error
roc_min = [x_roc-xr_er y_roc-yr_er z_roc-zr_er]; %min values are calculated by subtracting error

buff = [x_buff y_buff z_buff];
buff_max = [x_buff+xb_er y_buff+yb_er z_buff+zb_er]; %max values are calculated  by adding error
buff_min = [x_buff-xb_er y_buff-yb_er z_buff-zb_er]; %min values are calculated by subtracting error


distance = norm(roc - buff); %distance forumal in 3d space

d1 = norm(roc_max - buff_max);
d2 = norm(roc_max - buff_min);
d3 = norm(roc_min - buff_max);
d4 = norm(roc_min - buff_min);



