function [SensitivityLocation, SensitivityTime]=OneAtaTime3(GND,SAT,time,location,folderName,Frame,DebugMode,numSamples)
%This function will perform a OneAtaTime uncertainty analysis for the Time
%Difference of Arrival signal. 
%It takes each parameter with a specified error and varies that parameter
%when it calls TDoA. 
%It then creates plots of perturbation amount vs. absolute error.

if nargin<6
    Frame=1; %use Topo Frame. 
end

if Frame==1
    expected=SAT.Topocoord;
else
    expected=SAT.ECFcoord;
end

m=length(GND);
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

SensitivityLocation=cell(m,3);
SensitivityTime=cell(m,1);

if(location==1)
%% iterate through location errors.
[TimeDiffs,TimeDiffErr]=timeDifftoMatrix(GND,SAT);
test=cell(m,3);
AbsErr=cell(m,3);
AbsTotalErr=cell(m,3);
AngleSensitivityOut=cell(m,3); %azimuth and elevation output
AngleSensitivityIn=cell(m,3); %whatever parameter we are currently varying. 

Axis={'x','y','z'};
for i=1:1%3 %cycle through x,y,z.
    for j=1:m %cycle through each station.
        ErrorMax=LocationErrs(j,i); %get the location error for this test
        test{j,i}=linspace(-ErrorMax,ErrorMax,numSamples); %set up a range.
        test{j,i}=[0 test{j,i}]; %control. no error case.
        AbsErr{j,i}=zeros(length(test),3);
        AbsTotalErr{j,i}=zeros(length(test),1);
        AngleSensitivityOut{j,i}=zeros(length(test),2);
        AngleSensitivityIn{j,i}=zeros(length(test),1);

        for k=1:length(test{j,i})
            %for that test range, perturbate a GND coordinate, but don't
            %change the time differences.
            RT=Receivers;
            Err=zeros(1,3);
            Err(1,i)=test{j,i}(k);
            RT(j,:)=RT(j,:)+Err;
            AngleSensitivityIn{j,i}(k)=RT(j,i);
            if DebugMode==1
                figure()
    %             expected=[1114097.00526875,-5098751.55457051,4881274.05987576];
                plot3(expected(1),expected(2),expected(3),'.','MarkerSize',100,'color','green');
                title(['3 Stations Direction Test - ' 'With Receiver ' num2str(j) ' Location Error = ' num2str(Err)])
                % plot3(
                grid on
                hold on
            end
            
            ErrStr=num2str(Err);
%             ErrStr=strrep(ErrStr,'-','a');
            if Frame==1
                zPlanes=[0 50e3 100e3 200e3 500e3 2000e3];
            else
                zPlanes=[4.5e6 4.8e6 5.1e6];
            end
            locations=TDoA(RT,TimeDiffs*3e8,Reference,10,zPlanes,DebugMode,['Run ' num2str(k) ' With Receiver ' num2str(j) ' Location Error = ' ErrStr]);
            
            if isempty(locations)==0 && size(locations,1)==4
                %if we don't have lineFits, then we don't have a solution.
                %not needed. ---
%                 if Frame==1 
%                     temp=locations([2 4],:);
%                     tempGeo=SAT(1).RelativeToGeo;
%                     Sphere=referenceSphere('Earth');
% %                     Sphere.Radius=6378137;
%                     [xE, yN, zU]=ecef2enu(temp(:,1),temp(:,2),temp(:,3),tempGeo(1),tempGeo(2),tempGeo(3),Sphere);
%                 end
%               ---

                %Sat in TDoA generated frame location.
    %             expectedShifted=expected-locations(2,:);
    %             [az, el]=getAzEl(expectedShifted);
                [az, el]=geo2AzEl(expected,locations(2,:));
                expectedAzEl=[az el 0];
                actualAzEl=locations(1,:);
                
                %ignore 2nd solution...momentarily. 
                soln1=expectedAzEl-actualAzEl;
    %             soln2=expectedAzEl-locations(3,:);
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
        figure()
        subplot(2,2,1)
        plot(test{j,i},AbsTotalErr{j,i},'.','MarkerSize',20);
        title(['Total Error based on Error in Receiver: ' num2str(j) ' and Coord: ' num2str(i)])
        SensitivityLocation{j,i}=zeros(2,2); %azimuth and elevation slopes. 
        
        variable={'Az','El','N/A'};
        for k=2:3
            subplot(2,2,k)
            plot(test{j,i},AbsErr{j,i}(:,k-1),'.','MarkerSize',20);
            title(['Resulting Sat Error in Coord: ' variable{k-1}]);
        end
        
        figure()
        for k=1:2
            subplot(1,2,k)
            plot(AngleSensitivityIn{j,i}/1000,AngleSensitivityOut{j,i}(:,k),'.','MarkerSize',20);
            [temp tempStruct]=polyfit(AngleSensitivityIn{j,i},AngleSensitivityOut{j,i}(:,k),1);
            SensitivityLocation{j,i}(k,1)=temp(1);
            SensitivityLocation{j,i}(k,2)=tempStruct.normr;
            title([variable{k} ' Output w.r.t. Receiver ' num2str(j) ' coord: ' Axis{i}]);
            xlabel(['R' num2str(j) 'coord ' Axis{i} ' (km)']);
            ylabel([variable{k} ' (rad)']);
        end

        if DebugMode==1
            %Separate folders.
%             GraphSaver({'png'},['Plots/' folderName '/OneAtaTime3Stations/' Axis{i} 'Receiver' num2str(j)],1);
            GraphSaver({'png'},['Plots/' folderName '/' Axis{i} 'Receiver' num2str(j)],1);
%         else
%             %same folder.
%             GraphSaver({'png'},['Plots/' folderName '/OneAtaTime3Stations/'],1);
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
        test{j,i}=linspace(-ErrorMax,ErrorMax,numSamples); %set up a range.
        test{j,i}=[0 test{j,i}]; %control. no error case.
        AbsErr{j,i}=zeros(length(test),3);
        AbsTotalErr{j,i}=zeros(length(test),1);
        AngleSensitivityOut{j,i}=zeros(length(test),2);
        AngleSensitivityIn{j,i}=zeros(length(test),1);

        
        for k=1:length(test{j,i})
            %for that test range, perturbate a clock error.
            GNDt=GNDforTime;
            GNDt(j).clk=test{j,i}(k);
            AngleSensitivityIn{j,i}(k)=test{j,i}(k);
            [TimeDiffs,TimeDiffErr]=timeDifftoMatrix(GNDt,SAT);
            RT=Receivers;
            ErrStr=num2str(num2str([TimeDiffErr(1,2) TimeDiffErr(1,3) TimeDiffErr(2,3)]));
%             ErrStr=strrep(ErrStr,'-','a');

            if Frame==1
                zPlanes=[0 50e3 100e3 200e3 500e3 2000e3];
            else
                zPlanes=[4.5e6 4.8e6 5.1e6];
            end
            
            if DebugMode==1
                figure()
                %             expected=[1114097.00526875,-5098751.55457051,4881274.05987576];
                plot3(expected(1),expected(2),expected(3),'.','MarkerSize',100,'color','green');
                title(['3 Stations Direction Test - ' 'With Receiver ' num2str(j) ' Time Error = ' ErrStr])
                grid on
                hold on
            end
            
            locations=TDoA(RT,(TimeDiffs+TimeDiffErr)*3e8,Reference,100,zPlanes,DebugMode,['Run ' num2str(k) ' With Time Error = ' ErrStr]);
            
            if isempty(locations)==0
                %Sat in TDoA generated frame location.
    %             expectedShifted=expected-locations(2,:);
    %             [az, el]=getAzEl(expectedShifted);
                [az, el]=geo2AzEl(expected,locations(2,:));
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
        
        %plot results
        figure()
        subplot(2,2,1)
        plot(test{j,i},AbsTotalErr{j,i},'.','MarkerSize',20);
        title(['Total Error based on Error in Receiver: ' num2str(j) ' and Clock Error: ' num2str(j)])
        
        variable={'x','y','z'};
        for k=2:4
            subplot(2,2,k)
            plot(test{j,i},AbsErr{j,i}(:,k-1),'.','MarkerSize',20);
            title(['Resulting Sat Error from Clk Coord: ' num2str(j)]);
        end
        
        figure()
        variable={'Az','El','N/A'};
        for k=1:2
            subplot(1,2,k)
            plot(AngleSensitivityIn{j,i}/1000,AngleSensitivityOut{j,i}(:,k),'.','MarkerSize',20);
            [temp tempStruct]=polyfit(AngleSensitivityIn{j,i},AngleSensitivityOut{j,i}(:,k),1);
            SensitivityTime{j,i}(k,1)=temp(1);
            SensitivityTime{j,i}(k,2)=tempStruct.normr;
            title([variable{k} ' Output w.r.t. Receiver ' num2str(j) ' Clk Error']);
            xlabel(['R' num2str(j) 'CLk Error (s)']);
            ylabel([variable{k} ' (rad)']);
        end
        
        
        if DebugMode==1
            %Separate folders.
            GraphSaver({'png'},['Plots/' folderName '/ClockErrInReceiver' num2str(j)],1);
%         else
%             %same folder.
%             GraphSaver({'png'},['Plots/' folderName '/OneAtaTime3Stations/'],1);
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