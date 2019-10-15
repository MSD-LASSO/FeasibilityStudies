function location = TDoA(receiverLocations,distanceDifferences)
%INPUTS: nx3 vector of receiver Locations (x,y,z) pairs, measured from a
        %fixed reference.
        %nxn upper triangular matrix of all combinations of 
        %distanceDifferences. The diagonals and lower triangle all have 0's.
        %for 3 station it looks something like
        % 0 d12 d13
        % 0  0  d23
        % 0  0   0
%OUTPUTS: Location of the transmitter.

n=size(receiverLocations,1);

%we construct n*(n-1)/2 hyperboloids.
p=1;
Hyperboloid=sym(zeros(n*(n-1)/2,1));
for i=1:n
    for j=1:n
        if j>i
            R1=receiverLocations(i,:);
            R2=receiverLocations(j,:);
            %assume SymVars is the same for all cases.
            [temp,SymVars]=CreateHyperboloid(R1,R2,distanceDifferences(i,j));
            Hyperboloid(p)=temp;
            p=p+1;
        end
    end
end
p=p-1; %number of hyperboloids.

%see if there is one solution to all curves
solveOutput=Intersect(Hyperboloid,SymVars);

%% for debugging purposes. Plot all intersections.
% figure()
h1=gcf;
RL=receiverLocations;
RL(end+1,:)=RL(1,:);
plot(RL(:,1),RL(:,2),'linewidth',3);
% hold on
% figure()



%% Get the Location.
%if z is not present, give it a 0. 
TwoD=0;
if length(solveOutput)<3
    solveOutput{3}=sym(zeros(size(solveOutput{1},1),size(solveOutput{1},2)));
    TwoD=1;
end

%if there's not one solution...
if size(solveOutput{1},1)==0
    %we need to approximate the solution the nearest intersections.
    Intersect2HypersX=cell(p*(p-1)/2,1);
    Intersect2HypersY=cell(p*(p-1)/2,1);
    k=1;
    
    %intersect the ith hyperboloid with every hypboloid after it.
    for i=1:p
        for j=i+1:p
            Intersect2Hypers=Intersect([Hyperboloid(i),Hyperboloid(j)],SymVars);
            Intersect2HypersX{k}=Intersect2Hypers{1};
            Intersect2HypersY{k}=Intersect2Hypers{2};
            %plot the intersections.
%             for ii=1:length(Intersect2Hypers{k}{1})
%                 fplot(Intersect2Hypers{k}{1}(ii),Intersect2Hypers{k}{2}(ii),'x','MarkerSize',5,'linewidth',3);
%                 hold on
%             end
            k=k+1;
        end
    end
    
    %Are the solution points or lines?
    %assume 2D points, 3D lines
    if TwoD==1
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
        Indices=find(abs(differences(:,1))<1.0e-10 & abs(differences(:,2))<1.0e-10);
        %Decide the number of solutions
        IndicesDifferences=diff(Indices)-1;
        numSolns=sum(IndicesDifferences>0)+1;
        dividingIndices=find(IndicesDifferences>0);
        dividingIndices=[0; dividingIndices; length(Indices)];
        
        %now get the points associated with differences below that
        %threshold.
        soln=cell(numSolns,1);
        location=zeros(numSolns,3);
        for i=1:numSolns
            pointsForThisSolution=Indices(dividingIndices(i)+1:dividingIndices(i+1));
            pointsForThisSolution=[pointsForThisSolution; pointsForThisSolution(end)+1];
            soln{i}=potentialPoints(pointsForThisSolution,:);
            %average those points together
            location(i,1:2)=mean(soln{i});
        end
        
        figure(h1)
        plot(location(:,1),location(:,2),'.','MarkerSize',10,'color','black');
        h2=gca;
        X1=h2.XLim;
        Y1=h2.YLim;
        fimplicit(Hyperboloid,[X1 Y1])
        

        
        
        
        
    else
        error('3D not implemented yet')
    end
    
elseif size(solveOutput{1},1)==1 
    %one unique location
    location=double([solveOutput{1} solveOutput{2} solveOutput{3}]);
else
    %several unique locations. For now plot. 
    if TwoD==1
        for i=1:length(solveOutput{1})
            figure(h1)
            fplot(solveOutput{1}(i),solveOutput{2}(i),'x','MarkerSize',5,'color','black','linewidth',3);
        end
    else
%         figure()
        fplot3(solveOutput{1},solveOutput{2},solveOutput{3},'o','MarkerSize',10,'color','black','linewidth',3);
    end
    axis square
    grid on
    location=double([solveOutput{1} solveOutput{2} solveOutput{3}]);
    h2=gca;
    X1=h2.XLim;
    Y1=h2.YLim;
    if TwoD==1
        fimplicit(Hyperboloid,[X1 Y1])
    else
        fimplicit3(Hyperboloid,[X1 Y1 h2.ZLim])
    end
end

        




end

