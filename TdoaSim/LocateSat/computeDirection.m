function location=computeDirection(m,LineFit,Reference,Sphere)
%Get the solution for the satellite.
%Currently implemented: Intersect all lines to get a point. 4+ stations
%Transform line fit into azimuth and elevation. 3 stations. 

if m>1
    %single point. Multiple lines available.
    
    %Non-optimal Solution. We test every possible combination of lines.
    NumPossible=2^m; 
    locations=zeros(NumPossible,3);
    Error=zeros(NumPossible,1);
    IterMatrix=zeros(m,NumPossible);
    for i=1:NumPossible
        SolnChoice=cell(m,1);
        d=zeros(m,1);
        for j=1:m
            %For 4 lines. This looks something like:
            %1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 iteration #
            
            %1  2  1  2  1  2  1  2  1  2  1  2  1  2  1  2 mod(iter,2)
            %1  1  2  2  1  1  2  2  1  1  2  2  1  1  2  2 mod(ceil(iter/2),2)
            %1  1  1  1  2  2  2  2  1  1  1  1  2  2  2  2 mod(ceil(iter/4),2)
            %1  1  1  1  1  1  1 1   2  2  2  2  2  2  2  2 mod(ceil(iter/8).2)
            d(j)=mod(ceil(i/2^(j-1)),2)+1; %for testing purposes.
            SolnChoice{j}=LineFit{j,d(j)};
        end
        IterMatrix(:,i)=d;
        [Pit,err]=LeastSquaresLines(SolnChoice);
        locations(i,:)=Pit;
        Error(i)=err;
    end
    %get the 2 lowest errors. Those are our solutions. 
    location=zeros(2,3);
    [minEr,I]=min(Error);
    location(1,:)=locations(I,:);
    Error(I)=inf;
    [minEr,I]=min(Error);
    location(2,:)=locations(I,:);
    
    Real=true(2,1);
    for i=1:2
        if location(i,3)<receiverLocations(1,3)
            Real(i)=false;
        end
    end
    location=location(Real,:);
%     location=LeastSquaresLines(LineFit);
elseif abs(sum(LineFit{1}(2,:)))>0
    %only 1 line available. Get a direction instead.

    
    %Let us use the bias term.
    [azimuth, elevation]=geo2AzEl(LineFit{m}(2,:)+LineFit{m}(1,:),LineFit{m}(1,:),Reference,Sphere);
    [azimuth2, elevation2]=geo2AzEl(LineFit{m+1}(2,:)+LineFit{m+1}(1,:),LineFit{m+1}(1,:),Reference,Sphere);
    location=[azimuth, elevation, 0; LineFit{m}(1,:); azimuth2 elevation2 0; LineFit{m+1}(1,:)];
    
    %Debugging Purposes.
%     figure()
%     expected=[1115209.69912918,-5103843.88452363,4886149.18623531];
%     [az, el]=geo2AzEl(expected,location(2,:));
%     expectedAzEl=[az el 0];
%     plot3([0 500],[0 0],[0 0],'linewidth', 3,'color','black')
%     plot3([0 0],[0 500],[0 0],'linewidth', 3,'color','black')
%     plot3([0 0],[0 0],[0 5e5],'linewidth', 3,'color','black')
%     grid on
%     legend('Soln1','Correct')
% 
%     %ignore 2nd solution...momentarily.
%     soln1=expectedAzEl-location(1,:);
%     
%     PlotLine(LineFit{m}(1,:),expected-LineFit{m}(1,:),range,h1);
%     
%     temp=expected-location(2,:);
%     [azex,elex]=getAzEl([temp(2) temp(1) temp(3)]);
%     temp=2.285*LineFit{m}(2,:)+LineFit{m}(1,:)-LineFit{m}(1,:);
%     [az,el]=getAzEl([temp(2) temp(1) temp(3)]);
    
else
    error('Unexpected case')
end

end