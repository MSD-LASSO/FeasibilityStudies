function [location, locationError] = TDoA(receiverLocations,distanceDifferences,AcceptanceTolerance,zPlanes,DebugMode)
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

if nargin<3
    AcceptanceTolerance=1e-5;
end

if nargin<4
    zPlanes=0;
end

if nargin<5
    DebugMode=0;
end

%% Identify all combinations of 3 receiving Stations.
receiverSet=cell(n*(n+1)*(n+2)/6,1);
distanceDiffSet=cell(n*(n+1)*(n+2)/6,1);
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

% p=1;
% Hyperboloid=sym(zeros(n*(n-1)/2,1));
% for i=1:n
%     for j=1:n
%         if j>i
%             R1=receiverLocations(i,:);
%             R2=receiverLocations(j,:);
%             %assume SymVars is the same for all cases.
%             [temp,SymVars]=CreateHyperboloid(R1,R2,distanceDifferences(i,j));
%             Hyperboloid(p)=temp;
%             p=p+1;
%         end
%     end
% end
% p=p-1; %number of hyperboloids.

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
        h1=[];
    end
    Locations=solvePlanes(HyperboloidSet{i},zPlanes,SymVars,AcceptanceTolerance,h1);
    if size(Locations,1)==2
        %then we just have 2 points. A single plane. No need to do line
        %fits.
        location=Locations;
        return
    else
        if sum(sum(Locations))==0
            realLines(i,1)=false;
            realLines(i,2)=false;
        else
            %lineFit
            LineFit{i,1}=fitLineParametric(Locations(1:2:end,:));
            LineFit{i,2}=fitLineParametric(Locations(2:2:end,:));
        end
    end
    fprintf(num2str(i))
end

LineFit=LineFit(realLines(:,1),:);
m=size(LineFit,1);
%% Debugging Purposes. Plot all lines
if DebugMode==1
    figure()
    x=1114097.00526875;
    % [1114097.00526875,-5098751.55457051,4881274.05987576]
    tCenter=(x-LineFit{1}(1,1))/LineFit{1}(2,1);
    x=zeros(m,2);
    y=zeros(m,2);
    z=zeros(m,2);
    for i=1:m
        for u=1:1
            Line=LineFit{i,u};
            syms t
            %     fplot3(Line(1,1)+t*Line(2,1),Line(1,2)+t*Line(2,2),Line(1,3)+t*Line(2,3), [0 2.5]);
            t=tCenter;
            x(i,u)=Line(1,1)+t*Line(2,1);
            y(i,u)=Line(1,2)+t*Line(2,2);
            z(i,u)=Line(1,3)+t*Line(2,3);
            plot3(x(i,u),y(i,u),z(i,u),'.','MarkerSize',20);
            hold on
        end
    end
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
elseif sum(LineFit{1}(2,:))>0
    %only 1 line available. Get a direction instead.
    [azimuth, elevation, GeodeticPointXYZ]=findDirection(LineFit{m},receiverLocations(1,:));
    [azimuth2, elevation2, GeodeticPointXYZ2]=findDirection(LineFit{m+1},receiverLocations(1,:));
    location=[azimuth, elevation, 0; GeodeticPointXYZ; azimuth2 elevation2 0; GeodeticPointXYZ2];
    
else
    error('Unexpected case')
end

% %% old.
% %see if there is one solution to all curves
% % solveOutput=Intersect(Hyperboloid,SymVars);
% solveOutput=cell(1,3);
% 
% 
% 
% 
% %% Get the Location.
% %if z is not present, give it a 0. 
% TwoD=0;
% if length(solveOutput)<3
%     solveOutput{3}=sym(zeros(size(solveOutput{1},1),size(solveOutput{1},2)));
%     TwoD=1;
% end
% 
% %if there's not one solution...
% if size(solveOutput{1},1)==0
%     
%     if TwoD==1
%         %we need to approximate the solution the nearest intersections.
%         Intersect2HypersX=cell(p*(p-1)/2,1);
%         Intersect2HypersY=cell(p*(p-1)/2,1);
%         k=1;
% 
%         %intersect the ith hyperboloid with every hypboloid after it.
%         for i=1:p
%             for j=i+1:p
%                 Intersect2Hypers=Intersect([Hyperboloid(i),Hyperboloid(j)],SymVars);
%                 Intersect2HypersX{k}=Intersect2Hypers{1};
%                 Intersect2HypersY{k}=Intersect2Hypers{2};
%     %             plot the intersections.
% 
%     %             fimplicit(Hyperboloid)
%     %             for ii=1:length(Intersect2Hypers{k}{1})
%     %                 fplot(Intersect2Hypers{k}{1}(ii),Intersect2Hypers{k}{2}(ii),'x','MarkerSize',5,'linewidth',3);
%     %                 hold on
%     %             end
%                 k=k+1;
%             end
%         end
%     end
%     
%     %Are the solution points or lines?
%     %assume 2D points, 3D lines
%     if TwoD==1
%         location=findSolnsFromIntersects(Intersect2HypersX, Intersect2HypersY,0);
%         
%         figure(h1)
%         plot(location(:,1),location(:,2),'.','MarkerSize',10,'color','black');
%         h2=gca;
%         X1=h2.XLim;
%         Y1=h2.YLim;
%         fimplicit(Hyperboloid,[X1 Y1])
%         
% 
%         
%         
%         
%         
%     else
%         %%3d
%         h2=gca;
%         X1=h2.XLim;
%         Y1=h2.YLim;
%         Z1=h2.ZLim;
%         fimplicit3(Hyperboloid,[X1 Y1 Z1],'meshdensity',40)
%         for i=1:length(Hyperboloid)
%             figure()
%             fimplicit3(Hyperboloid(i),[X1 Y1 h2.ZLim],'meshdensity',40);
%         end
%         
%         figure()
%         fimplicit(subs(Hyperboloid,SymVars(3),0),[-10 10 -10 10])
%         
% 
%         k=1;
%         %intersect the ith hyperboloid with every hyperboloid after it.
%         %single Test ex.
% %         start=4.349e6;
% %         stop=4.881e6;
% %         step=5320;
%         start=zPlanes(1);
%         stop=zPlanes(end);
%         step=diff(zPlanes);
%         step=step(1);
%         %4 Receivers Ex.
% %         start=0;
% %         stop=100;
% %         step=20;
% 
%         location=zeros(((stop-start)/step+1)*2,3);
%         m=0;
%         for u=start:step:stop
%             Hyperboloidtemp=subs(Hyperboloid,SymVars(3),u); %restrict z to a plane.
%             Intersect2HypersX=cell(p*(p-1)/2,1);
%             Intersect2HypersY=cell(p*(p-1)/2,1);
%             for i=1:p
%                 for j=i+1:p
%                     Intersect2Hypers=Intersect([Hyperboloidtemp(i),Hyperboloidtemp(j)],SymVars);
%                     Intersect2HypersX{k}=Intersect2Hypers{1};
%                     Intersect2HypersY{k}=Intersect2Hypers{2};
%                     %             plot the intersections.
% 
%                     %             fimplicit(Hyperboloid)
%                     %             for ii=1:length(Intersect2Hypers{k}{1})
%                     %                 fplot(Intersect2Hypers{k}{1}(ii),Intersect2Hypers{k}{2}(ii),'x','MarkerSize',5,'linewidth',3);
%                     %                 hold on
%                     %             end
%                     k=k+1;
%                 end
%             end
%             location(2*m+1:2*m+2,:)=findSolnsFromIntersects(Intersect2HypersX,Intersect2HypersY,u,3,10);
%             disp(u)
%             m=m+1;
%         end
%     end
% %     save location
%     figure(h1)
%     plot3(location(:,1),location(:,2),location(:,3),'.','MarkerSize',10,'color','black')
%     figure()
%     plot3(location(:,1),location(:,2),location(:,3),'.','MarkerSize',10,'color','black')
%     hi=1;
% elseif size(solveOutput{1},1)==1 
%     %one unique location
%     location=double([solveOutput{1} solveOutput{2} solveOutput{3}]);
% else
%     %several unique locations. For now plot. 
%     if TwoD==1
%         for i=1:length(solveOutput{1})
%             figure(h1)
%             fplot(solveOutput{1}(i),solveOutput{2}(i),'x','MarkerSize',5,'color','black','linewidth',3);
%         end
%     else
% %         figure()
%         fplot3(solveOutput{1},solveOutput{2},solveOutput{3},'o','MarkerSize',10,'color','black','linewidth',3);
%     end
%     axis square
%     grid on
%     location=double([solveOutput{1} solveOutput{2} solveOutput{3}]);
%     h2=gca;
%     X1=h2.XLim;
%     Y1=h2.YLim;
%     if TwoD==1
%         fimplicit(Hyperboloid,[X1 Y1])
%     else
%         fimplicit3(Hyperboloid,[X1 Y1 h2.ZLim])
%     end
% end
% 
%         
% 
% 
% 

end

function location=solvePlanes(HyperboloidSet,zPlanes,SymVars,AcceptanceTolerance,h1)
%HyperboloidSet should be 3 Hyperboloids
%Zplanes a 1D vector of z values to evaluate at. 
%h1 is the figure handler.

%This function is optimized for p=3. It was programmed to do higher numbers
%as well. 
p=length(HyperboloidSet);
%% Plot of this set of Hyperboloids and Single Hyperboloids.
if isempty(h1)==0
    figure(h1)
    h2=h1.Children;
    X1=h2.XLim;
    Y1=h2.YLim;
    Z1=h2.ZLim;
    fimplicit3(HyperboloidSet,[X1 Y1 Z1],'meshdensity',40)
    for i=1:p
        figure()
        fimplicit3(HyperboloidSet(i),[X1 Y1 h2.ZLim],'meshdensity',40);
    end
end

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
            %             plot the intersections.
            
            %             fimplicit(Hyperboloid)
            %             for ii=1:length(Intersect2Hypers{k}{1})
            %                 fplot(Intersect2Hypers{k}{1}(ii),Intersect2Hypers{k}{2}(ii),'x','MarkerSize',5,'linewidth',3);
            %                 hold on
            %             end
            k=k+1;
        end
    end
    temp=findSolnsFromIntersects(Intersect2HypersX,Intersect2HypersY,zPlanes(u),3,AcceptanceTolerance);
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
    title('System Geometry. Earth Fixed Frame')
    xlabel('x (m)')
    ylabel('y (m)')
    zlabel('z (m)')
    figure()
    plot3(location(:,1),location(:,2),location(:,3),'.','MarkerSize',10,'color','black')
    title('System Solutino. Earth Fixed Frame')
    xlabel('x (m)')
    ylabel('y (m)')
    zlabel('z (m)')
end

end


function location=findSolnsFromIntersects(Intersect2HypersX, Intersect2HypersY,z,pointThreshold,AcceptanceTolerance)
%for Points, the strategy is as follows:
        %1. sort the points and find the points closest together via a finite
        %difference. If the finite difference is less than some threshold,
        %call that the same point.
        %2. figure out how many solutions there are and split up the "same"
        %points into different bins based on the number of solutions
        %3. Average the "same" points together.
        
        
        potentialPoints=real(double([vpa(Intersect2HypersX) vpa(Intersect2HypersY)]));
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
            location=nan(2,3);
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
        
end