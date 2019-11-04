%From Orekit textFile 'TestOrbitDataAroundRIT.txt' 
% long=-1.355756142252390;	
% lat=0.751981147060969;
% al=6378137;

% longSat=-1.213034173979802;	
% latSat=0.068130851072552;	
% alSat=792374.431137860500000+al;
% 
% el_expected=0.000346536730923;	
% az_expected=2.333636230550186;
% rng_expected=3279177.472030736500000;

% long=-1.3605;
% lat=0.75414;
% al=6378137;
% 
% longSat=-50.095*pi/180;
% latSat=31.6799*pi/180;
% alSat=646604+al;
% 
% el_expected=0;
% az_expected=108.4176*pi/180;
% rng_expected=2943868;
% 
% northStation=[-0.1429228561;0.6695783846; 0.7288606];
% eastStation=[0.9779691468; 0.208749486; 0];
% ZenithStation=[0.15215; -0.7128; 0.68466];
% E_expected=[eastStation northStation ZenithStation];

lat=0.751334572386275;
long=-1.355399362046697;
al=6378137;

el_expected=0.000617111555499;
az_expected=3.378243548428418;
rng_expected=2551455.318390733600000;	

latSat=0.379014295692151;
longSat=-1.449246893353793;
alSat=492863.000000001300000+al;

[x,y,z]=sph2cart(long,lat,al);
[xs,ys,zs]=sph2cart(longSat,latSat,alSat);


% S=getAzElRotationMatrix(az_expected,el_expected)*[rng_expected;0;0];
% 
% norm(S)
% norm([x y z]-[xs ys zs])

[az el]=geo2AzEl([xs ys zs],[x y z]);

AssertTolerance(az_expected,az,1e-3)
AssertTolerance(el_expected,el,1e-3)