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

%for debugging purposes. Plot all intersections.
% figure()
h1=gcf;
RL=receiverLocations;
RL(end+1,:)=RL(1,:);
plot(RL(:,1),RL(:,2),'linewidth',3);
% hold on
fimplicit(Hyperboloid,[0 15 0 15])
% figure()
solveOutputMini=cell(p*(p-1)/2,1);
k=1;
for i=1:p
    for j=i+1:p
        solveOutputMini{k}=Intersect([Hyperboloid(i),Hyperboloid(j)],SymVars);
        for ii=1:length(solveOutputMini{k}{1})
            fplot(solveOutputMini{k}{1}(ii),solveOutputMini{k}{2}(ii),'x','MarkerSize',5,'linewidth',3);
            hold on
        end
        k=k+1;
    end
end


%% 
%if z is not present, give it a 0. 
if length(solveOutput)<3
    solveOutput{3}=sym(zeros(size(solveOutput{1},1),size(solveOutput{1},2)));
    TwoD=1;
end

%if there's not one solution...
if size(solveOutput{1},1)==0
    for i=1:p
        for j=i+1:p
            error('No solution. Not implemented yet')
            %to be implemented. 
        end
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
        figure()
        fplot3(solveOutput{1},solveOutput{2},solveOutput{3},'.','MarkerSize',5,'color','black');
    end
    axis square
    location=double([solveOutput{1} solveOutput{2} solveOutput{3}]);
end

        




end

