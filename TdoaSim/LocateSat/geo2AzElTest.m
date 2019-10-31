%From Orekit textFile 'TestOrbitDataAroundRIT.txt' 
long=-1.355756142252390;	
lat=0.751981147060969;
al=6371e3;
[x,y,z]=sph2cart(long,lat,al);

longSat=-1.213034173979802;	
latSat=0.068130851072552;	
alSat=792374.431137860500000+6371e3;
[xs,ys,zs]=sph2cart(longSat,latSat,alSat);

el_expected=0.000346536730923;	
az_expected=2.333636230550186;
rng_expected=3279177.472030736500000;

S=getAzElRotationMatrix(az_expected,el_expected)*[rng_expected;0;0];

norm(S)
norm([x y z]-[xs ys zs])

[az el]=geo2AzEl([xs ys zs],[x y z]);

AssertTolerance(az_expected,az,1e-10)
AssertTolerance(el_expected,el,1e-10)