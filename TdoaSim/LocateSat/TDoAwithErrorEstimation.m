function [location, location_error, rawData] = TDoAwithErrorEstimation(numTrials,receiverError,distanceDifferenceError,referenceError,receiverLocations,distanceDifferences,Reference,Sphere,AcceptanceTolerance,zPlanes,DebugMode,AdditionalTitleStr,costFunction,plotSavePath)
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

%Data structure for easy reference
rawData.DistanceDiff=DDs;
rawData.ReceiverLocations=Rlocations;
rawData.References=References;
rawData.TDoAlocations=TDoAsolution;
rawData.EstAzEl=EstAzEl;
rawData.EstRef=EstRef;

%Estimate uncertainty
nominalAzEl=EstAzEl(1,:);
nominalReference=EstRef(1,:);
estUncertaintyAzEl=nanstd(EstAzEl)*2;
estUncertaintyReference=nanstd(EstRef)*2;


%Return in TDoA.m's return format.
location=[nominalAzEl 0; nominalReference];
location_error=[estUncertaintyAzEl 0; estUncertaintyReference];


if DebugMode>0
    plotHistograms(rawData,nan,plotSavePath,1);
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

