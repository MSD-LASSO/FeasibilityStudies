function [location, locationError] = TDoA(receiverLocations,distanceDifferences,Reference,AcceptanceTolerance,zPlanes,DebugMode,AdditionalTitleStr)
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

n=size(receiverLocations,1);

if nargin<4
    AcceptanceTolerance=1e-5;
end

if nargin<5
    zPlanes=0;
end

if nargin<6
    DebugMode=0;
end

if nargin<7
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

%% we construct 3 hyperboloids for each Receiver Set.

%NOTES: this is a non-optimal process.
%For Receivers ABCD, I have triangles ABC, ABD, ACD, BCD. The triangles
%have common elements with each other. I currently create the same
%hyperboloid multiple times instead of reusing the elements.

HyperboloidSet=cell(m,1);
for u=1:m
   %for each set of receivers. Get the Hyperboloids, put them in a set.
   Hyperboloid=sym(zeros(3,1));
   p=1;
   for i=1:3
       for j=1:3
           if j>i
               R1=receiverSet{u}(i,:);
               R2=receiverSet{u}(j,:);
               %assume SymVars is the same for all cases.
               [temp,SymVars]=CreateHyperboloid(R1,R2,distanceDiffSet{u}(i,j));
               Hyperboloid(p)=temp;
               p=p+1;
           end
       end
   end
   
   HyperboloidSet{u}=Hyperboloid;
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
    Locations=solvePlanes(HyperboloidSet{i},zPlanes,SymVars,AcceptanceTolerance,h1,AdditionalTitleStr);
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
    [azimuth elevation]=geo2AzEl(2.285*LineFit{m}(2,:)+LineFit{m}(1,:),LineFit{m}(1,:));
%     [azimuth2 elevation2]=geo2AzEl(LineFit{m+1}(2,:)+LineFit{m+1}(1,:),LineFit{m+1}(1,:));
    azimuth2=0;
    elevation2=0;
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

function location=solvePlanes(HyperboloidSet,zPlanes,SymVars,AcceptanceTolerance,h1,AdditionalTitleStr)
%HyperboloidSet should be 3 Hyperboloids
%Zplanes a 1D vector of z values to evaluate at. 
%h1 is the figure handler.

% GTaroundRIT1stpass=[773985.116196977,-6336267.04597780,2542303.67225501];
% vpa(subs(HyperboloidSet(3),SymVars,[773985.116196977,-6336267.04597780,2542303.67225501]))
%GTSentinelSat=[1115209.69912918,-5103843.88452363,4886149.18623531]
% vpa(subs(HyperboloidSet(3),SymVars,[1115209.69912918,-5103843.88452363,4886149.18623531]))

%This function is optimized for p=3. It was programmed to do higher numbers
%as well. 
p=length(HyperboloidSet);
%% Plot of this set of Hyperboloids and Single Hyperboloids.
if isempty(h1)==0
    figure(h1)
    h2=h1.Children;
    X1=h2.XLim*2;
    Y1=h2.YLim*2;
    Z1=h2.ZLim;
    fimplicit3(HyperboloidSet(1))%[X1 Y1 Z1],'meshdensity',40
    fimplicit3(HyperboloidSet(2))
    fimplicit3(HyperboloidSet(3))
%     fimplicit(HyperboloidSet,[-30 30 -30 30])
%     xlim([-30 30])
%     ylim([-30 30])
%     for i=1:p
%         figure()
%         fimplicit3(HyperboloidSet(i));%,[X1 Y1 h2.ZLim],'meshdensity',40
%     end
end

%% Solve on each plane.
k=1; %Counter for intersection number.
location=zeros(length(zPlanes)*2,3); %Expect 2 points in every plane.
m=0; %Counter for Locations number.

for u=1:length(zPlanes)
    if length(SymVars)==3
        %3D case.
        Hyperboloidtemp=subs(HyperboloidSet,SymVars(3),zPlanes(u)); %restrict z to a plane.
    else
        %2D case. z already taken care of. 
        Hyperboloidtemp=HyperboloidSet;
    end
    Intersect2HypersX=cell(p*(p-1)/2,1);
    Intersect2HypersY=cell(p*(p-1)/2,1);
    %intersect the ith hyperboloid with every hyperboloid after it.
    for i=1:p
        for j=i+1:p
            Intersect2Hypers=Intersect([Hyperboloidtemp(i),Hyperboloidtemp(j)],SymVars);
            Intersect2HypersX{k}=Intersect2Hypers{1};
            Intersect2HypersY{k}=Intersect2Hypers{2};
            k=k+1;
        end
    end 
    [temp,AllPts]=findSolnsFromIntersects(Intersect2HypersX,Intersect2HypersY,zPlanes(u),3,AcceptanceTolerance);
    
    %debugging around RIT. 
    %1e6.
%     AllPts=[2609336.27447559,-4465985.03031150;3123096.09255623,-5678570.99208825;5691569.43165977,-9791094.78373877;16652500.7721629,-24649300.3029585]
% AllPts=[1647440.63595431,-4517237.67132255;1855079.49953290,-5007104.42806191;2892441.75243371,-6668082.13052221;7319973.30647300,-12669995.2141345];   

%Debugging Purposes
    h2=figure();
%     fimplicit(Hyperboloidtemp,[min(AllPts(:,1)) max(AllPts(:,1)) min(AllPts(:,2)) max(AllPts(:,2))]);
%     hold on
    plot(AllPts(:,1),AllPts(:,2),'*');
    hold on
    fimplicit(Hyperboloidtemp);
    title(['ZPlane = ' num2str(zPlanes(u)) ' - ' AdditionalTitleStr]);

    %continue with code.
    if size(temp,1)==1
       %only 1 point was found.
       temp=[temp; temp];
    elseif size(temp,1)>2
       %more than 2 points were found.
       error('TDoA 2D solution failed to converge to 2 values')
    end
    location(2*m+1:2*m+2,:)=temp;
%     disp(zPlanes(u))
    m=m+1;
end

%Remove locations that didn't converge. Marked as nan. 
location=location(~isnan(location(:,1)),:);

if isempty(h1)==0
    figure(h1)
    plot3(location(:,1),location(:,2),location(:,3),'.','MarkerSize',10,'color','black')
    title('System Geometry - Earth Fixed Frame')
    xlabel('x (m)')
    ylabel('y (m)')
    zlabel('z (m)')
%     figure()
%     plot3(location(:,1),location(:,2),location(:,3),'.','MarkerSize',10,'color','black')
%     title('System Solution - Earth Fixed Frame')
%     xlabel('x (m)')
%     ylabel('y (m)')
%     zlabel('z (m)')
end

end


function [location,potentialPoints]=findSolnsFromIntersects(Intersect2HypersX, Intersect2HypersY,z,pointThreshold,AcceptanceTolerance)
%for Points, the strategy is as follows:
        %1. sort the points and find the points closest together via a finite
        %difference. If the finite difference is less than some threshold,
        %call that the same point.
        %2. figure out how many solutions there are and split up the "same"
        %points into different bins based on the number of solutions
        %3. Average the "same" points together.
        
        %% remove non-real intersections.
        potentialPoints=double([vpa(Intersect2HypersX) vpa(Intersect2HypersY)]);
        realPoints=true(length(potentialPoints),1);
        for i=1:length(potentialPoints)
            if isreal(potentialPoints(i,:))==0
                %not a real intersection
                realPoints(i)=false;
            end
        end
        potentialPoints=potentialPoints(realPoints,:);
        
        try
            %% Solve. 
            %Sort by X.
            potentialPoints=sortrows(potentialPoints);
            %get the differences and find the ones below a certain threshold.
            differences=diff(potentialPoints);
    %         Indices=find(abs(differences(:,1))<AcceptanceTolerance & abs(differences(:,2))<AcceptanceTolerance);

            normDiffs=vecnorm(differences,2,2);
            normDiffSorted=sort(normDiffs);
            vals=normDiffSorted(1:4);
            Indices=find(normDiffs==vals(1) | normDiffs==vals(2) | normDiffs==vals(3)| normDiffs==vals(4));

            if isempty(Indices)
                warning('Tolerance may be set too low. No common solutions were found.')
                location=nan(1,3);
                return
            end
            %Decide the number of solutions
            IndicesDifferences=diff(Indices)-1;
            numSolns=sum(IndicesDifferences>0)+1;
            dividingIndices=find(IndicesDifferences>0);
            dividingIndices=[0; dividingIndices; length(Indices)];

            %now get the points associated with differences below that
            %threshold.
            soln=cell(numSolns,1);
            location=zeros(numSolns,3);
            RealSolns=true(numSolns,1);
            for i=1:numSolns
                pointsForThisSolution=Indices(dividingIndices(i)+1:dividingIndices(i+1));
                pointsForThisSolution=[pointsForThisSolution; pointsForThisSolution(end)+1];
                if length(pointsForThisSolution)>=pointThreshold
                    soln{i}=potentialPoints(pointsForThisSolution,:);
                    %average those points together
                    location(i,1:2)=mean(soln{i});
                    location(i,3)=z;
                else
                    %not enough points converged there.
                    RealSolns(i)=false;
                end
            end
            location=location(RealSolns,:);
        catch ME
            location=nan(1,3);
            warning('No locations found...see below.')
            warning([ME.message ' first instance at ' num2str(ME.stack(1).line)])
        end
            
        
end