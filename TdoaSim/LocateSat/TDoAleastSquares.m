function [location, planarPoints, locationError] = TDoAleastSquares(receiverLocations,distanceDifferences,Reference,Sphere,AcceptanceTolerance,zPlanes,DebugMode,AdditionalTitleStr)
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


%% Identify all combinations of 3 receiving Stations.
[receiverSet, distanceDiffSet, m]=getReceiverSet(n,receiverLocations,distanceDifferences);

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
    planarPoints=zeros(length(zPlanes)*2,3);
    for z=1:length(zPlanes)
        HyperCost=@(x) (HyperCostFunc(x,zPlanes(z),receiverSet{m},distanceDiffSet{m}));
        temp=fminunc(HyperCost,x0,options);
        temp=[temp' zPlanes(z)];
        planarPoints(2*z-1:2*z,:)=[temp; temp];
    end
    
    if size(planarPoints,1)==2 || isempty(planarPoints)
        %then we just have 2 points. A single plane. No need to do line
        %fits.
        %Locations can also be empty if the solution did not converge.
        location=planarPoints;
        return
    else
        %if nothing is returned from Locations, mark as false so we remove
        %this lines later.
        if sum(sum(planarPoints))==0
            realLines(i,1)=false;
            realLines(i,2)=false;
        else
            %lineFit
            LineFit{i,1}=fitLineParametric(planarPoints(1:2:end,:));
            LineFit{i,2}=fitLineParametric(planarPoints(2:2:end,:));
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
location=computeDirection(m,LineFit,Reference,Sphere);

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
   HyperboloidError=zeros(3,1);
   %HyperboloidError is a measure of how close to the selected point is to
   %the hyperboloid equation. A value of 0 means it is on the Hyperboloid. 
   p=1;
   for i=1:3
       for j=1:3
           if j>i
               R1=RL(i,:);
               R2=RL(j,:);
               %assume SymVars is the same for all cases.
               temp=ComputeHyperboloid(R1,R2,DD(i,j),[x;zPlane]);
               HyperboloidError(p)=temp;
               p=p+1;
           end
       end
   end
   
   %Appears to lie below the triangle in all instances.
%    OutCost=sqrt((Hyperboloid(1)-Hyperboloid(2))^2+(Hyperboloid(3)-Hyperboloid(2))^2+(Hyperboloid(1)-Hyperboloid(3))^2);

    OutCost=sqrt(HyperboloidError(1)^2+HyperboloidError(2)^2+HyperboloidError(3)^2);


end