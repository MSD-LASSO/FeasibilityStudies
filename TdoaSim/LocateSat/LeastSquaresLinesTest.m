%% cardinal directions. Should intersect at 0 0 0.
w1=[0 0 0; 1 0 0];
w2=[0 0 0; 0 1 0];
w3=[0 0 0; 0 0 1]; 
LL={w1,w2,w3}';

expected=[0 0 0]';
point1=LeastSquaresLines(LL(1:2));
point2=LeastSquaresLines(LL);

AssertToleranceMatrix(expected,point1,1e-10);
AssertToleranceMatrix(expected,point2,1e-10);

%% 3 3D lines that intersect at a common point.
w1=[4 6 -3; -3 1 -2];
w2=[-6 11 -8; 4 -3 1];
w3=[-8 5 -19; 2 1 4];

expected=[-2 8 -7]';
point1=LeastSquaresLines({w1; w2});
point2=LeastSquaresLines({w1; w2; w3});

AssertToleranceMatrix(expected,point1,1e-10);
AssertToleranceMatrix(expected,point2,1e-10);

%% 3 lines that nearly intersect.
w1=[4 6 -3; -3 1 -2]+[0.000915735525189067,0.000959492426392903,3.57116785741896e-05;0.000792207329559554,0.000655740699156587,0.000849129305868777]; 
w2=[-6 11 -8; 4 -3 1]+[0.000933993247757551,0.000757740130578333,0.000392227019534168;0.000678735154857774,0.000743132468124916,0.000655477890177557];
w3=[-8 5 -19; 2 1 4]+[0.000171186687811562,3.18328463774207e-05,4.61713906311539e-05;0.000706046088019609,0.000276922984960890,9.71317812358475e-05];

expected=[-2 8 -7]';
%notice these points don't explicitly lie on any line. 
point1=LeastSquaresLines({w1; w2});
point2=LeastSquaresLines({w1; w2; w3});

AssertToleranceMatrix(expected,point1,1e-2);
AssertToleranceMatrix(expected,point2,1e-2);
