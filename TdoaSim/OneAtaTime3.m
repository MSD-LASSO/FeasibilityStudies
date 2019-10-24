function OneAtaTime3(GND,SAT,time,location)
%This function will perform a OneAtaTime uncertainty analysis for the Time
%Difference of Arrival signal. 
%It takes each parameter with a specified error and varies that parameter
%when it calls TDoA. 
%It then creates plots of perturbation amount vs. absolute error.

expected=SAT.coord;

m=length(GND);
LocationErrs=zeros(m,3);
Receivers=zeros(m,3);
timeSyncErrs=zeros(m,1);
GNDforTime=GND;
for i=1:m
    %gather all locations errors.
    LocationErrs(i,:)=GND(i).coord_error;

    Receivers(i,:)=GND(i).coord;
    %for time.
    timeSyncErrs(i)=GND(i).clk;
    GNDforTime(i).clk=0;
    GNDforTime(i).coord_error=[0,0,0];
end


if(location==1)
%% iterate through location errors.
[TimeDiffs,TimeDiffErr]=timeDifftoMatrix(GND,SAT);
test=cell(m,3);
AbsErr=cell(m,3);
AbsTotalErr=cell(m,3);
for i=1:3 %cycle through x,y,z.
    for j=1:m %cycle through each station.
        ErrorMax=LocationErrs(j,i); %get the location error for this test
        test{j,i}=linspace(-ErrorMax,ErrorMax,10); %set up a range.
        test{j,i}=[0 test{j,i}]; %control. no error case.
        AbsErr{j,i}=zeros(length(test),3);
        AbsTotalErr{j,i}=zeros(length(test),1);
        for k=1:length(test{j,i})
            %for that test range, perturbate a GND coordinate, but don't
            %change the time differences.
            RT=Receivers;
            Err=zeros(1,3);
            Err(1,i)=test{j,i}(k);
            RT(j,:)=RT(j,:)+Err;
            locations=TDoA(RT,TimeDiffs*3e8,10,[4.5e6 4.8e6 5.1e6 ]);
            
            %Sat in TDoA generated frame location.
            expectedShifted=expected-locations(2,:);
            [az, el]=getAzEl(expectedShifted);
            expectedAzEl=[az el 0];
            
            %ignore 2nd solution...momentarily. 
            soln1=expectedAzEl-locations(1,:);
%             soln2=expectedAzEl-locations(3,:);
            AbsErr{j,i}(k,:)=soln1;
            AbsTotalErr{j,i}(k)=norm(AbsErr{j,i}(k,:));
        end
        
        %plot results
        figure()
        subplot(2,2,1)
        plot(test{j,i},AbsTotalErr{j,i},'.','MarkerSize',20);
        title(['Total Error based on Error in Receiver: ' num2str(j) ' and Coord: ' num2str(i)])
        
        variable={'az','el','N/A'};
        for k=2:4
            subplot(2,2,k)
            plot(test{j,i},AbsErr{j,i}(:,k-1),'.','MarkerSize',20);
            title(['Resulting Sat Error in Coord: ' variable{k-1}]);
        end
    end
end
end

if time==1
%% Iterate through Time Sync Errors
test=cell(m,3);
AbsErr=cell(m,3);
AbsTotalErr=cell(m,3);
for i=1:1 %cycle through nothing. Clock error is 1D.
    for j=1:m %cycle through each station.
        ErrorMax=timeSyncErrs(j,i); %get the location error for this test
        test{j,i}=linspace(-ErrorMax,ErrorMax,10); %set up a range.
%         test{j,i}=[0 test{j,i}]; %control. no error case.
        AbsErr{j,i}=zeros(length(test),3);
        AbsTotalErr{j,i}=zeros(length(test),1);
        for k=1:length(test{j,i})
            %for that test range, perturbate a GND coordinate, but don't
            %change the time differences.
            GNDt=GNDforTime;
            GNDt(j).clk=test{j,i}(k);
            [TimeDiffs,TimeDiffErr]=timeDifftoMatrix(GNDt,SAT);
            RT=Receivers;
            locations=TDoA(RT,(TimeDiffs+TimeDiffErr)*3e8,100,[4.5e6 4.8e6 5.1e6 ]);
            
            %Sat in TDoA generated frame location.
            expectedShifted=expected-locations(2,:);
            [az, el]=getAzEl(expectedShifted);
            expectedAzEl=[az el 0];
            
            AbsErr{j,i}(k,:)=expectedAzEl-locations(1,:);
            AbsTotalErr{j,i}(k)=norm(AbsErr{j,i}(k,:));
        end
        
        %plot results
        figure()
        subplot(2,2,1)
        plot(test{j,i},AbsTotalErr{j,i},'.','MarkerSize',20);
        title(['Total Error based on Error in Receiver: ' num2str(j) ' and Coord: ' num2str(i)])
        
        variable={'x','y','z'};
        for k=2:4
            subplot(2,2,k)
            plot(test{j,i},AbsErr{j,i}(:,k-1),'.','MarkerSize',20);
            title(['Resulting Sat Error in Coord: ' variable{k-1}]);
        end
    end
end
end



end

%these functions are here because the interface because Andrew's and
%Anthony's code is not seamless...and I (Anthony) didn't want to spend time
%making a generalized converter.
function [TimeDiffs, TimeDiffErr]=timeDifftoMatrix(GND,SAT)
    if length(GND)==3
        [TimeDiffs, TimeDiffErr]=timeDiff3toMatrix(GND,SAT);
    else
        [TimeDiffs, TimeDiffErr]=timeDiff4toMatrix(GND,SAT);
    end
end


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

function [TimeDiffs, TimeDiffErr]=timeDiff4toMatrix(GND,SAT)

    timeDifferences4 = timeDiff(GND, SAT);
    A_B=timeDifferences4(1,1,1);
    A_C=timeDifferences4(1,1,2);
    A_D=timeDifferences4(1,1,3);
    B_C=timeDifferences4(1,1,4);
    B_D=timeDifferences4(1,1,5);
    C_D=timeDifferences4(1,1,6);
    TimeDiffs=abs([0 A_B A_C A_D; 0 0 B_C B_D; 0 0 0 C_D; 0 0 0 0]);
    A_Be=timeDifferences4(2,1,1);
    A_Ce=timeDifferences4(2,1,2);
    A_De=timeDifferences4(2,1,3);
    B_Ce=timeDifferences4(2,1,4);
    B_De=timeDifferences4(2,1,5);
    C_De=timeDifferences4(2,1,6);
    TimeDiffErr=abs([0 A_Be A_Ce A_De; 0 0 B_Ce B_De; 0 0 0 C_De; 0 0 0 0]);
end