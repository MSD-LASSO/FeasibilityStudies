function [a] = getStruct(Objects, geoError, Reference,geo_Reference_Error,Sphere)
%This function inputs the lat, long and elevation as well and an error vector and creates
%a structure with fields for all of the ground station parameters


% Objects [ [lat long elev] [lat long elev] [lat long elev]....]
% Error [ [lat_error long_error elev_error clock] [lat_error long_error ele
%Reference [lat long elev]
%Sphere - Reference Sphereoid. If empty, will use Spherical Earth.

if nargin<3
    Reference=zeros(1,3);
end
if nargin<4
    geo_Reference_Error=zeros(1,3);
end
if nargin<5
    Sphere=referenceSphere('Earth');
end

n = size(Objects, 1);

for i = 1:n
    a(i).name = ['Object' '_' num2str(i,'%02d')];
    a(i).lat = Objects(i, 1);
    a(i).long = Objects(i, 2);
    a(i).elev = Objects(i, 3);
    a(i).geo = Objects(i,1:3);
    a(i).lat_er = geoError(i, 1);
    a(i).long_er = geoError(i, 2);
    a(i).elev_er = geoError(i, 3);
    [a(i).ECFcoord, a(i).ECFcoord_error] = geo2rect(Objects(i,:), geoError(i,:), Sphere);
    [a(i).Topocoord,a(i).Topocoord_error] = measureInTopocentricFrame(a(i).geo,Reference,Sphere,geoError(i,:));
    a(i).RelativeToGeo = Reference;
    [a(i).RelativeToECF a(i).ReferenceError] = geo2rect(Reference, geo_Reference_Error);
    a(i).clk = geoError(i, 4);
end

end

