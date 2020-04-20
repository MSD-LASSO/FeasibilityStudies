function plotHistograms(Data,correct,location,save)
%This is called by MonteCarlo, TDoAwithErrorEstimation in DebugMode
%and could be called by senitivityAnalysisNet, TDoAexploration

% Plot histograms, usually from a Monte Carlo
%Data is a structure of the Monte Carlo results. 
% Data.DistanceDiff distance difference matrix
% Data.ReceiverLocations reciever locations
% Data.TDoAlocations TDoA raw output
% Data.EstAzEl Estimated Az El converted from TDoA
% Data.Error estimated error using ground truth values or a relative error.


%Data can be sent as an empty...This function will output a blank
%histogram.

%correct is the correst Az El or Nan Nan. 
if nargin<4
    save=1;
end

if nargin<3
   location='Plots/MonteCarlo'; 
end

Az=correct(1);
El=correct(2);
if isempty(Data)==0
    %% Estimate the Error
    numTests=length(Data.EstAzEl);
    % EstAzEl=Data.EstAzEl*180/pi;
    if ~(isnan(Az) || isnan(El))
        Errors=Data.Error*180/pi;
        RefErrors=nan;
    else
        Az=Data.EstAzEl(1,1);
        El=Data.EstAzEl(1,2);
        nominalReference=Data.EstRef(1,:);
        Errors=Data.EstAzEl-[Az El];
        RefErrors=Data.EstRef-nominalReference;
    end
    
    %% Plot Az El Error 
    figure()
    subplot(1,2,1)
    histogram(Errors(:,1))
    hold on
    title([num2str(Az) '&' num2str(El) ' Az Uncertainty from ' num2str(numTests) ' tests. Mean Err ' num2str(nanmean(Errors(:,1)),'%1.3f') ' Std Dev ' num2str(nanstd(Errors(:,1)),'%1.3f')])
    xlabel('Error in Azimuth (deg)')
    ylabel('Likelihood')
    grid on

    subplot(1,2,2)
    histogram(Errors(:,2))
    hold on
    title(['El Uncertainty ' num2str(numTests) ' tests. Mean Err ' num2str(nanmean(Errors(:,2)),'%1.3f') ' Std Dev ' num2str(nanstd(Errors(:,2)),'%1.3f')])
    xlabel('Error in Elevation (deg)')
    ylabel('Likelihood')
    grid on

    figure()
    plot(0,0,'o','linewidth',3)
    hold on
    plot(Errors(:,1),Errors(:,2),'.')
    title(['Error in Azimuth and Elevation Plot for Az ' num2str(Az) ' and El ' num2str(El)])
    xlabel('Error in Azimuth (deg)')
    ylabel('Error in Elevation (deg)')
    
    %% Plot Reference Error. FOR RELATIVE ERROR ONLY
    if ~isnan(RefErrors)
       figure()
       subplot(1,3,1)
       histogram(RefErrors(:,1))
       hold on
       title([num2str(nominalReference(1)) ' Ref X Uncertainty from ' num2str(numTests) ' tests. Std Dev ' num2str(nanstd(RefErrors(:,1)),'%1.3f')])
       xlabel('Error in Reference X coordinate (m)')
       ylabel('Likelihood')
       grid on

       subplot(1,3,2)
       histogram(RefErrors(:,2))
       hold on
       title([num2str(nominalReference(2)) ' Ref X Uncertainty from ' num2str(numTests) ' tests. Std Dev ' num2str(nanstd(RefErrors(:,2)),'%1.3f')])
       xlabel('Error in Reference Y coordinate (m)')
       ylabel('Likelihood')
       grid on

       subplot(1,3,3)
       histogram(RefErrors(:,3))
       hold on
       title([num2str(nominalReference(3)) ' Ref X Uncertainty from ' num2str(numTests) ' tests. Std Dev ' num2str(nanstd(RefErrors(:,3)),'%1.3f')])
       xlabel('Error in Reference Z coordinate (m)')
       ylabel('Likelihood')
       grid on

    end


else 
    %For data=[], make a blank plot. Neccessary since TDoA doesn't always
    %converge and we call this function programmatically. 
    figure()
    histogram(zeros(100,0))
    title([num2str(Az) '&' num2str(El) 'Az El Uncertainty Undefined'])
end


%% Save, close, maximize all plots. 
if save==1
    GraphSaver({'png','fig'},location,1,1);
end
end