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

expected=[-2 8 -7]';
point1=LeastSquaresLines({w1; w2});

AssertToleranceMatrix(expected,point1,1e-10);

