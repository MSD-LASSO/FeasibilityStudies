function [POS, Error] = geo2rect(GEO_POS, GEO_Error)
%This function inputs the goegraphical coordinates and outputs the
%rectangular coordinates. It also inputs uncertainty and returns
%uncertainty (error)
%   The errors passed as inputs are + and - values
%   The lat and long are converted to radians
%   The longitude is the azimuth (phi)
%   The latitude is the elevation (theta)
%   The elevation is added to the radius of earth and its the R value
sea_lev = 6371000;

lat_min = deg2rad(GEO_POS(1)-GEO_Error(1));
lat = deg2rad(GEO_POS(1));
lat_max = deg2rad(GEO_POS(1)+GEO_Error(1));

long_min = deg2rad(GEO_POS(2)-GEO_Error(2));
long = deg2rad(GEO_POS(2));
long_max = deg2rad(GEO_POS(2)+GEO_Error(2));

elev_min = GEO_POS(3)+sea_lev-GEO_Error(3);
elev = GEO_POS(3)+sea_lev;
elev_max = GEO_POS(3)+sea_lev+GEO_Error(3);

[x_out, y_out, z_out] = sph2cart(long, lat, elev);
[x_min, y_min, z_min] = sph2cart(long_min, lat_min, elev_min);
[x_max, y_max, z_max] = sph2cart(long_max, lat_max, elev_max);

Error = [abs(x_max-x_min)/2 abs(y_max-y_min)/2 abs(z_max-z_min)/2];
POS = [x_out y_out z_out];
end

