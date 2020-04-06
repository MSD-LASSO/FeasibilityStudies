%% Sat single location example.

R0=[0.751334572386275*180/pi	-1.355399362046697*180/pi	0.000000000000000]; 
el=0.292895241810439;
az=3.416045894350267;
rng=1308270.348140666300000;
Rsat=[0.573939693534438*180/pi	-1.414266121072615*180/pi	492863.000000000900000];
zUp=rng*sin(el);
a=rng*cos(el);
xEast=a*sin(az);
yNorth=a*cos(az);

out_ex=[xEast,yNorth,zUp];

Sphere=referenceSphere('Earth');
Sphere2=referenceEllipsoid('Earth');
Sphere.Radius=Sphere2.SemimajorAxis;

Out=measureInTopocentricFrame(Rsat,R0,Sphere,zeros(1,3));
AssertToleranceMatrix(out_ex,Out,1e-4);

%% Many Sat locations.
[stations,satellites,satellitesGT,GTframe,Time,names]=readGroundTrack('../TestScripts/TestData');

I=find(strcmp(names,'ForTopocentricTestLargeEarthRadius.txt'));

el=satellitesGT{I}(:,1);
az=satellitesGT{I}(:,2);
rng=satellitesGT{I}(:,3);

Sphere=referenceSphere('Earth');
Sphere2=referenceEllipsoid('Earth');
Sphere.Radius=Sphere2.SemimajorAxis;

zUp=rng.*sin(el);
a=rng.*cos(el);
xEast=a.*sin(az);
yNorth=a.*cos(az);

out_ex=[xEast,yNorth,zUp];

Rsat=[satellites{I}(:,1)*180/pi satellites{I}(:,2)*180/pi satellites{I}(:,3)];
R0=[GTframe{I}(1)*180/pi GTframe{I}(2)*180/pi GTframe{I}(3)];
Out=measureInTopocentricFrame(Rsat,R0,Sphere,zeros(1,3));
AssertToleranceMatrix(out_ex,Out,1e-4);
