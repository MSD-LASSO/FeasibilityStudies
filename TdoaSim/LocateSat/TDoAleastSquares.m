function [location, planarPoints] = TDoAleastSquares(receiverLocations,distanceDifferences,Reference,Sphere,AcceptanceTolerance,zPlanes,DebugMode,AdditionalTitleStr,costFunction)
%Author: Anthony Iannuzzi, P20151 Team LASSO, email: awi7573@rit.edu

%For documentation on I/O, see TDoA.m. Its recommended you call TDoA
%instead of this function. TDoA will call this function with proper inputs
%to it.

%Last Updated: 1/13/2020



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
        if costFunction==1
            HyperCost=@(x) (HyperCostFunc(x,zPlanes(z),receiverSet{m},distanceDiffSet{m}));
        elseif costFunction==2
            HyperCost=@(x) (TimeDifferenceComparison(x,zPlanes(z),receiverSet{m},distanceDiffSet{m}));
        else
            error('Unrecognized Cost Function')
        end
        
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
%     fprintf(num2str(i)) %progress report.
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

function OutCost=TimeDifferenceComparison(x,zPlane,RL,DD)
%This is an alternative cost function. It computes what the time
%differences would be if the receiver was at the guessed point, (x,y,z). It
%compares these to the the measured time differences.

EmitterLocation=[x' zPlane];

m = size(RL ,2);
% k = factorial(m)/(factorial(m-2)*2);
EstDistanceDifferences = zeros(m,m);
SquaredError=zeros(m,m); %represents the error in estimated and actual time difference.

for j = 1:m
    for k = j+1:m
        temp_dist1 = gnd2sat(RL(j,:), RL(j,:)*0, EmitterLocation, EmitterLocation*0);
        temp_dist2 = gnd2sat(RL(k,:), RL(k,:)*0, EmitterLocation, EmitterLocation*0);
        EstDistanceDifferences(j,k)=temp_dist1-temp_dist2;
        %empirically this results in a slightly worse solution. 
%         maxDD=norm(RL(j,:)-RL(k,:)); 
%         if abs(DD(j,k))>maxDD
%             %it is physically not possible to have a distance difference
%             %greater than the the distance between the receivers. We can
%             %safetly set any greater distance difference to the max. 
%             DD(j,k)=maxDD;
%         end
        SquaredError(j,k)=(DD(j,k)-EstDistanceDifferences(j,k))^2;
    end
end

OutCost=sqrt(sum(sum(SquaredError)));

end