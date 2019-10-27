function [TimeDiffs, TimeDiffErr]=timeDiff3toMatrix(GND,SAT)

    timeDifferences = timeDiff(GND, SAT);
    A_B=timeDifferences(1,1,1);
    A_C=timeDifferences(1,1,2);
    B_C=timeDifferences(1,1,3);
    TimeDiffs=abs([0 A_B A_C; 0 0 B_C; 0 0 0]);
    A_Be=timeDifferences(2,1,1);
    A_Ce=timeDifferences(2,1,2);
    B_Ce=timeDifferences(2,1,3);
    TimeDiffErr=abs([0 A_Be A_Ce; 0 0 B_Ce; 0 0 0]);
end