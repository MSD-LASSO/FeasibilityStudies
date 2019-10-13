function [x, y, z, x_er, y_er, z_er] = geo2rect(latitude, lat_er, longitude, long_er, elevation, elev_er)
%This function inputs the goegraphical coordinates and outputs the
%rectangular coordinates. It also inputs uncertainty and returns
%uncertainty (error)
%   The errors passed as inputs are + and - values
%   The lat and long are converted to radians
%   The longitude is the azimuth (phi)
%   The latitude is the elevation (theta)
%   The elevation is added to the radius of earth and its the R value
sea_lev = 6371000;

lat_min = deg2rad(latitude-lat_er);
lat = deg2rad(latitude);
lat_max = deg2rad(latitude+lat_er);

long_min = deg2rad(longitude-long_er);
long = deg2rad(longitude);
long_max = deg2rad(longitude+long_er);

elev_min = elevation+sea_lev-elev_er;
elev = elevation+sea_lev;
elev_max = elevation+sea_lev+elev_er;


[x_out, y_out, z_out] = sph2cart(long, lat, elev);
[x_min, y_min, z_min] = sph2cart(long_min, lat_min, elev_min);
[x_max, y_max, z_max] = sph2cart(long_max, lat_max, elev_max);

x_er = abs(x_max-x_min);
y_er = abs(y_max-y_min);
z_er = abs(z_max-z_min);
x = x_out;
y = y_out;
z = z_out;
end

