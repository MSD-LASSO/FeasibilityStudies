function [SensitivityLocation, SensitivityTime]=OneAtaTime3(GND,SAT,time,location,folderName,Frame,DebugMode,numSamples,earthModel,solver)
%This function will perform a OneAtaTime uncertainty analysis for the Time
%Difference of Arrival signal. 
%It takes each parameter with a specified error and varies that parameter
%when it calls TDoA. 
%It then creates plots of perturbation amount vs. absolute error.

%For high errors, which we have, its recommended to use MonteCarlo.m for
%uncertainty predictions; however, one-at-a-time can help predict sensitive
%areas of the sky. 

%THIS FUNCTION needs a little work.
%it does NOT calculate sensitivity of the output reference, only the
%azimuth and elevation. 
%we could combine redundant code between location and time. 

%INPUTS:
%GND object containing all stations

%SAT object containing the satellite location

%time switch function. =1 run sensitivity on clock error. =0 skip clock
%sensitivity

%location switch function. =1 run sensitivity on location error. =0 skip.

%folderName to save plots to.

%Frame. Solve TDoA in Topocentric (=1, recommended) or ECEF Frame (=2)

%DebugMode =1 to see ALL plots. =0 to see FINAL plots. =-1 to see NO plots.
%numSamples: number of samples to take before estimating the uncertainty.
%One sample works just fine, but more samples will better estimate the
%derivative and hence the sensitivity. Recommended 1 for speed and 7 for a
%good visual of the surfaces we are approximating. 

%earthModel: the model used for Earth. WGS84 or a sphere, for example.

%solver: what method TDoA should use. =0 symbolic, =1 distance least
%squares (recommended), =2 time difference least squares. 

%OUTPUT are the sensitivities with respect to each input in a cell array
%format.
%Both outputs are a 2x2 cell array, Azimuth col 1, Elevation col 2,
%the 1st row is forward difference, the 2nd row is backward difference and
%is only filled in for odd Samples >1
%SensitivityLocation{1} is the sensitivity of Azimuth to Station 1 X, Y, Z
                                                        %Station 2 X, Y, Z,
                                                        %etc...
%SensitivityTime{2} is the sensitivity of Elevation to Station 1 Clk err,
%Station 2 Clk error, etc...

%get the correct answer.
if Frame==1
    expected=SAT.Topocoord;
else
    expected=SAT.ECFcoord;
end

%m is the number of stations
m=length(GND);

%Gathers all errors. Again, we assume a rectilinear error on station location.
LocationErrs=zeros(m,3);
Receivers=zeros(m,3);
timeSyncErrs=zeros(m,1);
GNDforTime=GND;
Reference=GND(1).RelativeToECF;
for i=1:m
    %gather all locations errors.
    LocationErrs(i,:)=GND(i).ECFcoord_error;

    if Frame==1
        Receivers(i,:)=GND(i).Topocoord;
    else
        Receivers(i,:)=GND(i).ECFcoord;
    end
    %for time.
    timeSyncErrs(i)=GND(i).clk;
    GNDforTime(i).clk=0;
    GNDforTime(i).ECFcoord_error=[0,0,0];
end


SensitivityLocation=cell(2,1);
SensitivityTime=cell(2,1);

%For the ECEF frame (largely deprecated), we have different planes that we
%solve on. NOTE: these plane choices are heuristic. 
if Frame==1
    zPlanes=[50e3 400e3 1200e3];
else
    zPlanes=[4.5e6 4.8e6 5.1e6];
end

if numSamples==1
    %then we are only doing a forward difference.
    
    %get the nominal answer with no error.
    [TimeDiffs,TimeDiffErr]=timeDifftoMatrix(GND,SAT);
    locations=TDoA(Receivers,TimeDiffs*3e8,Reference,earthModel,10,zPlanes,DebugMode,'No error nominal run',solver);
    [az, el]=geo2AzEl(expected,locations(2,:),Reference);
    expectedAzEl=[az el 0];
    actualAzEl=locations(1,:);
    

    soln1=expectedAzEl-actualAzEl;
    %If using 2 sided hyperboloids (unsigned time differences, you'd need
    %to account for both solutions. This is deprecated). 
    %             soln2=expectedAzEl-locations(3,:);
    AbsErrControl=soln1;
    AbsTotalErrControl=norm(AbsErrControl);
    AngleSensitivityOutControl=locations(1,1:2);
end



if(location==1)
%% iterate through location errors.
[TimeDiffs,TimeDiffErr]=timeDifftoMatrix(GND,SAT);
test=cell(m,3);
AbsErr=cell(m,3);
AbsTotalErr=cell(m,3);
AngleSensitivityOut=cell(m,3); %azimuth and elevation output
AngleSensitivityIn=cell(m,3); %whatever parameter we are currently varying. 

Axis={'x','y','z'};
for i=1:3 %cycle through x,y,z.
    for j=1:m %cycle through each station.
        ErrorMax=LocationErrs(j,i); %get the location error for this test
        test{j,i}=linspace(-ErrorMax,ErrorMax,numSamples); %set up a range.
        if DebugMode>=0 && numSamples~=1
            test{j,i}=[0 test{j,i}]; %0 is the control. no error case. used only when numSamples>1. largely deprecated.
        end
        
        AbsErr{j,i}=zeros(length(test{j,i}),3);
        AbsTotalErr{j,i}=zeros(length(test{j,i}),1);
        AngleSensitivityOut{j,i}=zeros(length(test{j,i}),2);
        AngleSensitivityIn{j,i}=zeros(length(test{j,i}),1);

        for k=1:length(test{j,i})
            %for that test range, perturbate a single GND coordinate, but
            %don't change the time differences or other coordinates.
            RT=Receivers;
            Err=zeros(1,3);
            Err(1,i)=test{j,i}(k);
            RT(j,:)=RT(j,:)+Err;
            AngleSensitivityIn{j,i}(k)=RT(j,i);
            if DebugMode==1
                figure()
                plot3(expected(1),expected(2),expected(3),'.','MarkerSize',100,'color','green');
                title(['3 Stations Direction Test - ' 'With Receiver ' num2str(j) ' Location Error = ' num2str(Err)])
                grid on
                hold on
            end
            
            ErrStr=num2str(Err);
            %estimate the direction with the single perturbation.
            locations=TDoA(RT,TimeDiffs*3e8,Reference,earthModel,10,zPlanes,DebugMode,['Run ' num2str(k) ' With Receiver ' num2str(j) ' Location Error = ' ErrStr],solver);
            
            if isempty(locations)==0 && size(locations,1)==4
                %if we don't have lineFits, then we don't have a solution.

                %Sat in TDoA generated frame location.
                [az, el]=geo2AzEl(expected,locations(2,:),Reference);
                expectedAzEl=[az el 0];
                actualAzEl=locations(1,:);
                
                soln1=expectedAzEl-actualAzEl;
                AbsErr{j,i}(k,:)=soln1;
                AbsTotalErr{j,i}(k)=norm(AbsErr{j,i}(k,:));
                AngleSensitivityOut{j,i}(k,:)=locations(1,1:2);
            else
                %nan will get ignored in the plot. 
                AbsErr{j,i}(k,:)=nan;
                AbsTotalErr{j,i}(k)=nan;
                AngleSensitivityOut{j,i}(k,:)=nan;
            end
        end
        
        %plot results
        if DebugMode>=0
            figure()
            subplot(2,2,1)
            plot(test{j,i},AbsTotalErr{j,i},'.','MarkerSize',20);
            title(['Total Error based on Error in Receiver: ' num2str(j) ' and Coord: ' num2str(i)]) 

            variable={'Az','El','N/A'};
            for k=2:3
                subplot(2,2,k)
                plot(test{j,i},AbsErr{j,i}(:,k-1),'.','MarkerSize',20);
                title(['Resulting Sat Error in Coord: ' variable{k-1}]);
            end

            figure()
        end
        
        for k=1:2   
            %fit half the points to a line.
            %For forward difference, this doesn't matter. For higher order
            %methods, i.e. numSamples>1, we choose only one side since
            %sometimes the shape of the surface is a "v" or like abs(x). If
            %we used both sides, we'd get a slope of 0!
            if numSamples>2
                M=[AngleSensitivityIn{j,i},AngleSensitivityOut{j,i}(:,k)];
                [~,idx] = sort(M(:,1)-mean(M(:,1))); % sort just the first column
                sortedMat = M(idx,:);
                halfway=ceil(size(sortedMat,1)/2);
                [temp, tempStruct]=polyfit(sortedMat(1:halfway,1),sortedMat(1:halfway,2),1);
                SensitivityLocation{1,k}(j,i)=temp(1);
                SensitivityLocation{2,k}(j,i)=tempStruct.normr;
                %fit the other half
                [temp, tempStruct]=polyfit(sortedMat(halfway:end,1),sortedMat(halfway:end,2),1);
                %choose the line with the steeper slope.
                if abs(temp(1))>abs(SensitivityLocation{1,k}(j,i))
                    SensitivityLocation{1,k}(j,i)=temp(1);
                    SensitivityLocation{2,k}(j,i)=tempStruct.normr;
                end
            elseif numSamples==2
                %not recommended because of the abs(x) shape that is
                %observed sometimes. 
                %equivalent to dfdx=(f(x+h)-f(x-h))/(2h)
                SensitivityLocation{1,k}(j,i)=(AngleSensitivityOut{j,i}(end-1,k)-AngleSensitivityOut{j,i}(end,k))/...
                    (AngleSensitivityIn{j,i}(end-1)-AngleSensitivityIn{j,i}(end));
            else
                %forward difference.
                SensitivityLocation{1,k}(j,i)=(AngleSensitivityOutControl(k)-AngleSensitivityOut{j,i}(end,k))/...
                    (-AngleSensitivityIn{j,i}(end));
            end
            
            
            if DebugMode>=0
                subplot(1,2,k)
                plot(AngleSensitivityIn{j,i}/1000,AngleSensitivityOut{j,i}(:,k),'.','MarkerSize',20);
                
                title([variable{k} ' Output w.r.t. Receiver ' num2str(j) ' coord: ' Axis{i}]);
                xlabel(['R' num2str(j) 'coord ' Axis{i} ' (km)']);
                ylabel([variable{k} ' (rad)']);
            end
        end

        if DebugMode==1
            GraphSaver({'png'},['Plots/' folderName '/' Axis{i} 'Receiver' num2str(j)],1);
        end            
    end
end
end

if time==1
%% Iterate through Time Sync Errors
test=cell(m,1);
AbsErr=cell(m,1);
AbsTotalErr=cell(m,1);
AngleSensitivityOut=cell(m,1); %azimuth and elevation output
AngleSensitivityIn=cell(m,1); %whatever parameter we are currently varying. 

for i=1:1 %cycle through nothing. Clock error is 1D.
    for j=1:m %cycle through each station.
        ErrorMax=timeSyncErrs(j,i); %get the clock error for this test.
        if numSamples~=1
            test{j,i}=linspace(-ErrorMax,ErrorMax,numSamples-1); %set up a range.
            if  DebugMode>=0 || numSamples==2
                test{j,i}=[0 test{j,i}]; %=0 is the no error case. Not recommended. 
            end
        else
            test{j,i}=ErrorMax;
        end
        AbsErr{j,i}=zeros(length(test{j,i}),3);
        AbsTotalErr{j,i}=zeros(length(test{j,i}),1);
        AngleSensitivityOut{j,i}=zeros(length(test{j,i}),2);
        AngleSensitivityIn{j,i}=zeros(length(test{j,i}),1);

        
        for k=1:length(test{j,i})
            %for that test range, perturbate a clock error.
            GNDt=GNDforTime;
            GNDt(j).clk=test{j,i}(k);
            AngleSensitivityIn{j,i}(k)=test{j,i}(k);
            [TimeDiffs,TimeDiffErr]=timeDifftoMatrix(GNDt,SAT);
            RT=Receivers;
            ErrStr=num2str(num2str([TimeDiffErr(1,2) TimeDiffErr(1,3) TimeDiffErr(2,3)]));

            
            if DebugMode==1
                figure()
                plot3(expected(1),expected(2),expected(3),'.','MarkerSize',100,'color','green');
                title(['3 Stations Direction Test - ' 'With Receiver ' num2str(j) ' Time Error = ' ErrStr])
                grid on
                hold on
            end
            
            locations=TDoA(RT,(TimeDiffs+TimeDiffErr)*3e8,Reference,earthModel,100,zPlanes,DebugMode,['Run ' num2str(k) ' With Time Error = ' ErrStr],solver);
            
            if isempty(locations)==0
                [az, el]=geo2AzEl(expected,locations(2,:),Reference);
                expectedAzEl=[az el 0];

                AbsErr{j,i}(k,:)=expectedAzEl-locations(1,:);
                AbsTotalErr{j,i}(k)=norm(AbsErr{j,i}(k,:));
                AngleSensitivityOut{j,i}(k,:)=locations(1,1:2);
            else
                %nan will get ignored in the plot. 
                AbsErr{j,i}(k,:)=nan;
                AbsTotalErr{j,i}(k)=nan;
                AngleSensitivityOut{j,i}(k,:)=nan;
            end
        end
        
        if DebugMode>=0
            %plot results
            figure()
            subplot(2,2,1)
            plot(test{j,i},AbsTotalErr{j,i},'.','MarkerSize',20);
            title(['Total Error based on Error in Receiver: ' num2str(j) ' and Clock Error: ' num2str(j)])
            
            variable={'Az','El','N/A'};
            for k=2:4
                subplot(2,2,k)
                plot(test{j,i},AbsErr{j,i}(:,k-1),'.','MarkerSize',20);
                title(['Resulting Sat Error from Clk Coord: ' variable{k-1}]);
            end
            
            figure()
        end
        variable={'Az','El','N/A'};
        for k=1:2
            if numSamples>2
                %fit half the points to a line.
                M=[AngleSensitivityIn{j,i},AngleSensitivityOut{j,i}(:,k)];
                [~,idx] = sort(M(:,1)); % sort just the first column
                sortedMat = M(idx,:);
                halfway=ceil(size(sortedMat,1)/2);
                [temp, tempStruct]=polyfit(sortedMat(1:halfway,1),sortedMat(1:halfway,2),1);
                SensitivityTime{1,k}(j,i)=temp(1);
                SensitivityTime{2,k}(j,i)=tempStruct.normr;
                %fit the other half
                [temp, tempStruct]=polyfit(sortedMat(halfway:end,1),sortedMat(halfway:end,2),1);
                %choose the line with the steeper slope.
                if abs(temp(1))>abs(SensitivityTime{1,k}(j,i))
                    SensitivityTime{1,k}(j,i)=temp(1);
                    SensitivityTime{2,k}(j,i)=tempStruct.normr;
                end
            
            elseif numSamples==2
                %not recommended
                %equivalent to dfdx=(f(x+h)-f(x-h))/(2h)
                SensitivityTime{1,k}(j,i)=(AngleSensitivityOut{j,i}(end-1,k)-AngleSensitivityOut{j,i}(end,k))/...
                    (AngleSensitivityIn{j,i}(end-1)-AngleSensitivityIn{j,i}(end));
            else
                %Forward difference
                SensitivityTime{1,k}(j,i)=(AngleSensitivityOutControl(k)-AngleSensitivityOut{j,i}(end,k))/...
                    (-AngleSensitivityIn{j,i}(end));
            end
            
            if DebugMode>=0
                subplot(1,2,k)
                plot(AngleSensitivityIn{j,i}/1000,AngleSensitivityOut{j,i}(:,k),'.','MarkerSize',20);
                title([variable{k} ' Output w.r.t. Receiver ' num2str(j) ' Clk Error']);
                xlabel(['R' num2str(j) 'CLk Error (s)']);
                ylabel([variable{k} ' (rad)']);
            end
        end
        
        
        if DebugMode==1
            GraphSaver({'png'},['Plots/' folderName '/ClockErrInReceiver' num2str(j)],1);
        end
    end
end
end

if DebugMode==0
    GraphSaver({'png'},['Plots/' folderName],1);
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