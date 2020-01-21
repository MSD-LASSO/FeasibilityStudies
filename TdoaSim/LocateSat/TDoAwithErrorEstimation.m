function [location, location_error, Data] = TDoAwithErrorEstimation(numTrials,receiverError,distanceDifferenceError,referenceError,receiverLocations,distanceDifferences,Reference,Sphere,AcceptanceTolerance,zPlanes,DebugMode,AdditionalTitleStr,costFunction,plotSavePath)
%Author: Anthony Iannuzzi, P20151 Team LASSO, email: awi7573@rit.edu

%For documentation on I/O, see TDoA.m. 
%Call this function when you have uncertainty in the inputs. 
%This function assumes a normal distribution of each input:
    %Mean: nominal value 
    %Std. Dev: 1/2 the uncertainty. 
    %assumes 95% of the time the true value falls within 1 uncertainty 
    %measure of the nominal value. 

%In addition to TDoA.m inputs, you must also specify the input errors and
%the number of trials to run before estimating uncertainty. This function
%estimates uncertainty following a Monte Carlo approach. Recommended, at
%least 30 times.

%Further Input Desc.
%numTrials >=30
%receiverError: nx3 vector where n=# stations
    %NOTE: if Reference is one of the stations, then the reference station
    %      MUST be 0,0,0 or the error is double counted.
    %      if Reference is anything else, all should be non-zero
%distanceDifferenceError: nxn upper triangular matrix.
%ReferenceError: error in the reference coordinate frame's origin. 1x3
    %vector.
    %NOTE: if reference is center of Earth, then reference error is 0,0,0.
    %      otherwise, it has non-zero values.
%PlotSavePath: denoted as an absolute or relative path.
    %Location histograms will be saved IF debugMode=1
    
%Last Updated: 1/13/2020

numTrials=numTrials+1; %add a trial to try nominal values.

DDs=zeros(numTrials,3);
Rlocations=cell(numTrials,1);
References=cell(numTrials,3);
TDoAsolution=cell(numTrials,1);
EstAzEl=zeros(numTrials,2);
EstRef=zeros(numTrials,3); %measured w.r.t. Reference

%% Nominal test
[actualAzEl,estRef,locations]=doTest(1,receiverLocations,distanceDifferences,Reference,Sphere,AcceptanceTolerance,zPlanes,DebugMode,AdditionalTitleStr,costFunction);
DDs(1,:)=[distanceDifferences(1,2), distanceDifferences(1,3), distanceDifferences(2,3)];
Rlocations{1}=receiverLocations;
TDoAsolution{1}=locations;
EstAzEl(1,:)=actualAzEl(1,1:2);
EstRef(1,:)=estRef;

%% Run tests with perturbations to get an estimate of uncertainty
%can be parfor. 

for i=2:numTrials

    %% Sample from each input distribution to perturbate
    distanceDiff=normrnd(distanceDifferences,distanceDifferenceError/2); %model error as a Gaussian.
    DDs(i,:)=[distanceDiff(1,2), distanceDiff(1,3), distanceDiff(2,3)];
    
    R=normrnd(Reference,referenceError/2);
    References{i}=R;
    
    RL=normrnd(receiverLocations,receiverError/2);
    Rlocations{i}=RL;
    
    [actualAzEl,estRef,locations]=doTest(i,RL,distanceDiff,R,Sphere,AcceptanceTolerance,zPlanes,DebugMode,AdditionalTitleStr,costFunction);
    
    TDoAsolution{i}=locations;
    EstAzEl(i,:)=actualAzEl(1,1:2);
    EstRef(i,:)=estRef;
    
end

%% Determine if the Estimated Azimuth values vary across 0. (i.e. we have 5 degrees and 359 degrees)
[EstAzEl,flag]=moveAzimuthReference(EstAzEl);
%if flag=1, we must convert the final answers back to the original
%reference.

%% Collect nominal values.
nominalAzEl=EstAzEl(1,:);
nominalReference=EstRef(1,:);

%these appear to be very similar to averaging line slopes then converting
%to az el. 
meanAzEl=nanmean(EstAzEl);
uncerAzEl=nanstd(EstAzEl)*2;



%% Get output distributions and estimated error

RefAz=EstAzEl(:,1);
RefEl=EstAzEl(:,2);
Rng=2500e3; %Range is a free variable. Pick anything desired. A large number makes the graph look nicer. 

LineEndPoint=[Rng*cos(RefEl).*sin(RefAz) Rng*cos(RefEl).*cos(RefAz) Rng*sin(RefEl)]+EstRef;
LineSlopes=LineEndPoint-EstRef;

meanRef=nanmean(EstRef);
StdRef=nanstd(EstRef);
uncertaintyRef=StdRef*2;


%covariance calculations
%we had a free parameter in range. So its no surprise the covariance result
%is a rank 4 matrix.
allData=[EstAzEl EstRef];
allDataNormalized=[EstAzEl(:,1)/meanAzEl(1) EstAzEl(:,2)/meanAzEl(2) EstRef(:,1)/meanRef(1) EstRef(:,2)/meanRef(2) EstRef(:,3)/meanRef(3)];
covariance=cov(allData);
covarianceNormalized=cov(allDataNormalized);


%for graphing
meanLineSlope=nanmean(LineSlopes);

%this is unneccessary. Taking the mean of the Az El points is good enough.
% StdLineSlope=nanstd(LineSlopes);
% uncertaintyLineSlope=StdLineSlope*2;
% meanAzEl=[atan2(meanLineSlope(1),meanLineSlope(2)) atan2(meanLineSlope(3),sqrt(sum(meanLineSlope(1:2).^2)))];
%         uncertaintyDirection=

%some calculus to calculate the uncertainty in azimuth and elevation from
%the line slope.
% dx=uncertaintyLineSlope(1);
% dy=uncertaintyLineSlope(2);
% dz=uncertaintyLineSlope(3);
% x=meanLineSlope(1);
% y=meanLineSlope(2);
% z=meanLineSlope(3);
% dazdx=1/(y*(x^2/y^2 + 1));
% dazdy=-x/(y^2*(x^2/y^2 + 1));
% deldx=-(x*z)/((z^2/(x^2 + y^2) + 1)*(x^2 + y^2)^(3/2));
% deldy=-(y*z)/((z^2/(x^2 + y^2) + 1)*(x^2 + y^2)^(3/2));
% deldz=1/((z^2/(x^2 + y^2) + 1)*(x^2 + y^2)^(1/2));
% 
% daz=sqrt((dazdx*dx)^2+(dazdy*dy)^2);
% del=sqrt((deldx*dx)^2+(deldy*dy)^2+(deldz*dz)^2);

%% Plot
if DebugMode>0
    figure()
    plot3(EstRef(1,1),EstRef(1,2),EstRef(1,3),'o','linewidth',4,'color','green')
    hold on
    plot3(meanRef(1,1),meanRef(1,2),meanRef(1,3),'s','linewidth',4,'color','green')
    plot3([EstRef(1,1) LineEndPoint(1,1)], [EstRef(1,2) LineEndPoint(1,2)], [EstRef(1,3) LineEndPoint(1,3)], 'color','red','linewidth',3)
    plot3([meanRef(1,1) meanLineSlope(1)+meanRef(1,1)], [meanRef(1,2) meanRef(1,2)+meanLineSlope(2)], [meanRef(1,3) meanRef(1,3)+meanLineSlope(3)], 'color',[0.545,0,0],'linewidth',3)

    plot3(EstRef(2:end,1),EstRef(2:end,2),EstRef(2:end,3),'.','linewidth',3,'color','blue');
    % title(['Reference Errors: ' num2str(uncertaintyRef) 'm and AzEl Errors: ' num2str(daz*180/pi) '&' num2str(del*180/pi) ' deg'])
    title(['Reference Errors: ' num2str(uncertaintyRef) 'm and AzEl Errors: ' num2str(uncerAzEl(1)*180/pi) '&' num2str(uncerAzEl(2)*180/pi) ' deg'])
    xlabel('X east (m)')
    ylabel('Y north (m)')
    zlabel('Z zenith (m)')
    grid on


    for jj=1:length(LineEndPoint)
        plot3([EstRef(jj,1) LineEndPoint(jj,1)], [EstRef(jj,2) LineEndPoint(jj,2)], [EstRef(jj,3) LineEndPoint(jj,3)],'.-', 'color','cyan')
    end

%either does not work as intended or just doesn't look pretty.
%         for i1=-1:2:1
%             for j1=-1:2:1
%                 for k1=-1:2:1
%                     for L1=-1:2:1
%                         for m1=-1:2:1
%                             refBound=meanRef+[i1 j1 k1].*uncertaintyRef;
%                             elBound=location(1,2)+L1*del;
%                             azBound=location(1,1)+m1*daz;
%                             LineEndPointBound=[Rng*cos(elBound).*sin(azBound) Rng*cos(elBound).*cos(azBound) Rng*sin(elBound)]+refBound;
%                             plot3([refBound(1) LineEndPointBound(1)], [refBound(2) LineEndPointBound(2)], [refBound(3) LineEndPointBound(3)],'o-', 'color','blue','linewidth',2)
%                         end
%                     end
%                 end
%             end
%         end

    legend('Nominal Reference','mean Reference','Nominal Direction','mean Direction','Reference Points','Directions')

end



%% Return in TDoA.m's return format.
if flag==1
    if nominalAzEl(1)<0
        nominalAzEl(1)=nominalAzEl(1)+2*pi;
    end
    if meanAzEl(1)<0
        meanAzEl(1)=meanAzEl(1)+2*pi;
    end
end


%Data structure for easy reference
rawData.DistanceDiff=DDs;
rawData.ReceiverLocations=Rlocations;
rawData.References=References;
rawData.TDoAlocations=TDoAsolution;
rawData.EstAzEl=EstAzEl;
rawData.EstRef=EstRef;
Data.rawData=rawData;
Data.nominalAzEl=nominalAzEl;
Data.nominalReference=nominalReference;
Data.meanAzEl=meanAzEl;
Data.meanReference=meanRef;
Data.AzElstandardDeviation=uncerAzEl/2;
Data.RefstandardDeviation=uncertaintyRef/2;
Data.AzEluncertainty95percent=uncerAzEl;
Data.Refuncertainty95percent=uncertaintyRef;
Data.covarianceMixedUnits=covariance; %not much phyiscal meaning
Data.covarianceNormalized=covarianceNormalized;
Data.movedAzimuthReference=flag;


location=[nominalAzEl 0; nominalReference; meanAzEl 0; meanRef];
% location_error=[daz del 0; uncertaintyRef; daz del 0; uncertaintyRef];
location_error=[uncerAzEl 0; uncertaintyRef; uncerAzEl 0; uncertaintyRef];

if DebugMode>0
    plotHistograms(rawData,nan(1,2),plotSavePath,1);
end

end


function [actualAzEl,estRef,locations]=doTest(i,RL,distanceDiff,Reference,Sphere,AcceptanceTolerance,zPlanes,DebugMode,AdditionalTitleStr,costFunction)

locations=TDoA(RL,distanceDiff,Reference,Sphere,AcceptanceTolerance,zPlanes,DebugMode,[AdditionalTitleStr '. Iter: ' num2str(i)],costFunction);
    
    if isempty(locations)==0 && size(locations,1)==4
        %if we don't have lineFits, then we don't have a solution
        
        actualAzEl=locations(1,:);
        estRef=locations(2,:);
        
    else
        %nan will get ignored in the plot.
        actualAzEl=nan(1,3);
        estRef=nan(1,3);
    end
    
end

