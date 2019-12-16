function [location, locationError] = TDoA(receiverLocations,distanceDifferences,Reference,Sphere,AcceptanceTolerance,zPlanes,DebugMode,AdditionalTitleStr)
%INPUTS: nx3 vector of receiver Locations (x,y,z) pairs, measured from a
        %fixed reference.
        %nxn upper triangular matrix of all combinations of 
        %distanceDifferences. The diagonals and lower triangle all have 0's.
        %for 3 station it looks something like
        % 0 d12 d13
        % 0  0  d23
        % 0  0   0
        %zPlanes is a vector of all planes to solve for. If left blank, the
        %code will only solve for the plane z=0. 
%OUTPUTS: Location of the transmitter.

options = optimoptions('fminunc','Display','none');
n=size(receiverLocations,1);

if isempty(Reference)==1
    %then ReceiverLocations are in Earth Centered Frame
    Reference=[0 0 0];
end

if nargin<4
    Sphere=referenceSphere('Earth');
end

if nargin<5
    AcceptanceTolerance=1e-5;
end

if nargin<6
    zPlanes=0;
end

if nargin<7
    DebugMode=1;
end

if nargin<8
    AdditionalTitleStr='';
end

%% Identify all combinations of 3 receiving Stations.
receiverSet=cell(n*(n-1)*(n-2)/6,1);
distanceDiffSet=cell(n*(n-1)*(n-2)/6,1);
%the series looks something like 1,4,10,20,35,56,84 for n=[3 4 5 6 7 8 9].
m=0;
for i=1:n
    for j=i+1:n
        for k=j+1:n
            m=m+1;
            receiverSet{m}=receiverLocations([i j k],:);
            distanceDiffSet{m}=[0 distanceDifferences(i,j) distanceDifferences(i,k); 0 0 distanceDifferences(j,k); 0 0 0];
        end
    end
end



%% for debugging purposes. Plot all intersections.
if DebugMode==1
    % figure()
    h1=gcf;
    RL=receiverLocations;
    RL(end+1,:)=RL(1,:);
    plot3(RL(:,1),RL(:,2),RL(:,3),'linewidth',3);
else
    h1=[];
end


%% Solve each Receiver Set for 3-4 different planes. Fit a Line to it.
LineFit=cell(m,2); %expect two directions per 3 Hyperboloids/ReceiverSet.
realLines=true(m,2);
for i=1:m
    if m>1
        %Don't plot the solvePlanes if the number of sets is greater than
        %1, even if debug mode is on.
        h1=[];
    end
    
    x0=[0;0];
    Locations=zeros(length(zPlanes)*2,3);
    for z=1:length(zPlanes)
        HyperCost=@(x) (HyperCostFunc(x,zPlanes(z),receiverSet{m},distanceDiffSet{m}));
        temp=fminunc(HyperCost,x0,options);
        temp=[temp' zPlanes(z)];
        Locations(2*z-1:2*z,:)=[temp; temp];
    end
    
    if size(Locations,1)==2 || isempty(Locations)
        %then we just have 2 points. A single plane. No need to do line
        %fits.
        %Locations can also be empty if the solution did not converge.
        location=Locations;
        return
    else
        %if nothing is returned from Locations, mark as false so we remove
        %this lines later.
        if sum(sum(Locations))==0
            realLines(i,1)=false;
            realLines(i,2)=false;
        else
            %lineFit
            LineFit{i,1}=fitLineParametric(Locations(1:2:end,:));
            LineFit{i,2}=fitLineParametric(Locations(2:2:end,:));
        end
    end
    fprintf(num2str(i)) %progress report.
end

LineFit=LineFit(realLines(:,1),:); %remove fake lines.
m=size(LineFit,1); %adjust m to reflect the number of successful sets.
%% Debugging Purposes. Plot all lines
if DebugMode==1
    for i=1:m
        for j=1:2
            LineBias=LineFit{m,j}(1,:);
            LineSlope=LineFit{m,j}(2,:);
            rangeLower=(receiverLocations(1,3)-LineBias(3))/LineSlope(3);
            if rangeLower>0
                range=[rangeLower rangeLower*5.1];
            else
                range=[rangeLower abs(rangeLower)*5.1];
            end
            PlotLine(LineBias,LineSlope,range,h1)
        end
    end
    
    
%     figure()
%     x=1114097.00526875;
%     % [1114097.00526875,-5098751.55457051,4881274.05987576]
%     tCenter=(x-LineFit{1}(1,1))/LineFit{1}(2,1);
%     x=zeros(m,2);
%     y=zeros(m,2);
%     z=zeros(m,2);
%     for i=1:m
%         for u=1:1
%             Line=LineFit{i,u};
%             syms t
%             %     fplot3(Line(1,1)+t*Line(2,1),Line(1,2)+t*Line(2,2),Line(1,3)+t*Line(2,3), [0 2.5]);
%             t=tCenter;
%             x(i,u)=Line(1,1)+t*Line(2,1);
%             y(i,u)=Line(1,2)+t*Line(2,2);
%             z(i,u)=Line(1,3)+t*Line(2,3);
%             plot3(x(i,u),y(i,u),z(i,u),'.','MarkerSize',20);
%             hold on
%         end
%     end
%     title(['Lines at Z = 4881274.05987576 - ' AdditionalTitleStr]);
end

%% Solve for single point or Direction. 
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
    %instead of finding an "imaginary" ground station by intersecting the
    %line with Earth...
%     [azimuth, elevation, GeodeticPointXYZ]=findDirection(LineFit{m},Reference);
%     [azimuth2, elevation2, GeodeticPointXYZ2]=findDirection(LineFit{m+1},Reference);
%     location=[azimuth, elevation, 0; GeodeticPointXYZ; azimuth2 elevation2 0; GeodeticPointXYZ2];

    
    %Let us use the bias term.
    [azimuth, elevation]=geo2AzEl(LineFit{m}(2,:)+LineFit{m}(1,:),LineFit{m}(1,:),Reference,Sphere);
    [azimuth2, elevation2]=geo2AzEl(LineFit{m+1}(2,:)+LineFit{m+1}(1,:),LineFit{m+1}(1,:),Reference,Sphere);
    location=[azimuth, elevation, 0; LineFit{m}(1,:); azimuth2 elevation2 0; LineFit{m+1}(2,:)];
    
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

function OutCost=HyperCostFunc(x,zPlane,RL,DD)
%Inputs:
%A set of receivers
%A set of distance differences
%The (x,y) guess and the zPlane we are on. 

%% we construct 3 hyperboloids for each Receiver Set.

%NOTES: this is a non-optimal process.
%For Receivers ABCD, I have triangles ABC, ABD, ACD, BCD. The triangles
%have common elements with each other. I currently create the same
%hyperboloid multiple times instead of reusing the elements.


   %for each set of receivers. Get the Hyperboloids, put them in a set.
   Hyperboloid=zeros(3,1);
   p=1;
   for i=1:3
       for j=1:3
           if j>i
               R1=RL(i,:);
               R2=RL(j,:);
               %assume SymVars is the same for all cases.
               temp=ComputeHyperboloid(R1,R2,DD(i,j),[x;zPlane]);
               Hyperboloid(p)=temp;
               p=p+1;
           end
       end
   end
   
   OutCost=sqrt((Hyperboloid(1)-Hyperboloid(2))^2+(Hyperboloid(3)-Hyperboloid(2))^2+(Hyperboloid(1)-Hyperboloid(3))^2);


end