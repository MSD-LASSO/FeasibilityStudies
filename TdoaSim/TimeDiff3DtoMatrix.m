function [timeDiffMatrix] = TimeDiff3DtoMatrix(timeDiff)
%Convert from timeDifferences from TimeDiff to a cell array of
%timeDifferences for each satellite.
%Order is {1} sat 1, {2} sat 2...etc.
%this converter is needed to interface TimeDiff and LocateSat packages.

%work in progress. Will update later.
% n=size(timeDiff,2); %number of satellites.
% m=size(timeDiff,3); %number of stations
% timeDiffMatrix=cell(n,2); %first column are time differences. 2nd column are time errors.
% for i=1:n %number of satellites.
%     timeDiffMatrix{i,1}=zeros(m,m);
%     timeDiffMatrix{i,2}=zeros(m,m);
%     for j=1:m %number of stations
%         timeDiffMatrix{i,1}(p,j
%         
%         A_B=timeDifferences4(1,1,1);
%         A_Berr=timeDifferences4(2,1,1);
%         A_C=timeDifferences4(1,1,2);
%         A_D=timeDifferences4(1,1,3);
%         B_C=timeDifferences4(1,1,4);
%         B_D=timeDifferences4(1,1,5);
%         C_D=timeDifferences4(1,1,6);
%         TimeDiffs=abs([0 A_B A_C A_D; 0 0 B_C B_D; 0 0 0 C_D; 0 0 0 0]);
%     end
% end
% end

