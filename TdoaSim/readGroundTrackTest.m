close all
clearvars
Folder='Data';
[stations,satellites,satellitesGT,GTframe,Time]=readGroundTrack(Folder);

SE=[0.750	0.698	0.000;
0.925	0.873	0.000;
1.047	0.873	0.000];

GT=[
-0.000	0.115	3009768.419;	
0.069	0.081	2606212.748;
0.151	0.033	2209520.948;
0.253	6.243	1826259.444;
0.385	6.124	1469039.124;
0.559	5.905	1164016.961;	
0.746	5.471	963625.315;
0.782	4.796	938155.438;
0.620	4.280	1099610.891];

SS=[
1.186	0.883	674810.489;	
1.126	0.826	677121.865;	
1.065	0.782	679502.649;	
1.004	0.747	681956.221;	
0.942	0.718	684486.817;	
0.879	0.694	687099.269;	
0.817	0.673	689798.725;		
0.754	0.654	692590.364;	
0.691	0.638	695479.105];		

TT=[
'2019-10-20T23:42:25.227 ';	
'2019-10-20T23:43:25.227 ';	
'2019-10-20T23:44:25.227 ';	
'2019-10-20T23:45:25.227 ';	
'2019-10-20T23:46:25.227 ';	
'2019-10-20T23:47:25.227 ';
'2019-10-20T23:48:25.227 ';
'2019-10-20T23:49:25.227 ';	
'2019-10-20T23:50:25.227 '];

addpath('LocateSat')

AssertToleranceMatrix(SE,stations{1},0);
AssertToleranceMatrix(SS,satellites{1},0);
AssertToleranceMatrix(GT,satellitesGT{1},0);
% AssertToleranceMatrix(TT,Time{1},0) %don't feel like making a string comparer right now.
AssertToleranceMatrix(SE(1,:),GTframe{1},0);