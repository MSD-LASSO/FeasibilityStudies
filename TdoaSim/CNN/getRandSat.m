function [az,el,rng] = getRandSat(AzimuthRange,ElevationRange,SatelliteRangeRange,P)
%Creates a random set of coordinates based on the input ranges. Assumes a
%uniform distribution. Input ranges are of form [low high].
az=rand(1)*diff(AzimuthRange)+AzimuthRange(1);
el=rand(1)*diff(ElevationRange)+ElevationRange(1);
al=rand(1)*diff(SatelliteRangeRange)+SatelliteRangeRange(1);
rng=RangeApproximate(el,al,P);

end

