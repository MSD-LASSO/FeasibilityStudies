function [TimeDiffs, TimeDiffErr]=timeDiff3toMatrix(GND,SAT)
%Translator function. timeDiff returns a 3D matrix of the time difference.
%This function, used for 1 satellite and 3 receivers, reshapes the data
%into a 2D matrix as dictated by TDoA.m.

    timeDifferences = timeDiff(GND, SAT);
    A_B=timeDifferences(1,1,1);
    A_C=timeDifferences(1,1,2);
    B_C=timeDifferences(1,1,3);
    TimeDiffs=[0 A_B A_C; 0 0 B_C; 0 0 0];
    A_Be=timeDifferences(2,1,1);
    A_Ce=timeDifferences(2,1,2);
    B_Ce=timeDifferences(2,1,3);
    TimeDiffErr=[0 A_Be A_Ce; 0 0 B_Ce; 0 0 0];
end