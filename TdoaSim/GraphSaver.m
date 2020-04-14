%Author Anthony Iannuzzi, email awi7573@rit.edu
%This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
% https://creativecommons.org/licenses/by-nc-sa/4.0/
%Please cite LASSO and Anthony Iannuzzi if you use this script. 

function []=GraphSaver(formats,location,closing,MaximizeAll,plots)
%INPUTS: formats is a cell array of all requested formats. Location is
%where these plots will be saved.

%closing = 1 will close all figures as they are saved.
%        = 0 will maintain figures.

%OPTIONAL:


%MaximizeAll = 1 will maximize each plot as its saved. NOTE: at the end of
%GraphSaver, ALL plots are automatically resized to their default size

%plots. Specify w an array of the figure numbers to save. If left empty,
%GraphSaver will start with Figure(1) and continue until it doesn't find a
%figure within N tries, where N is the persistance.

%Notes. Plots with more than 1 subplot or in 3 dimensions are automically
%maximized when saving. Plots that are maximized have their font sizes
%increased. The plot MUST have a title. If not, GraphSaver will throw an
%error.

defaultSize=get(0,'defaultfigureposition');
if nargin<4
    MaximizeAll=0;
end
if nargin<5
    plots=1;
end

%Create the target directory if it doesn't exist.
if exist(location,'dir')==0
    mkdir(location);
end

i=1;
persistance=0; %if there is a gap of N figures that don't exist and no figure array was given, stop saving
while i<=length(plots)
    
    %If no plot array given, plus it up until we don't find a figure.
    if nargin<5
        plots(i+1)=i+1;
    end
    
    %If we find a plot with the name figure(i).
    if ishandle(plots(i))==1
        figure(plots(i))
        h1=gcf;
        [~,el]=view;
        n=length(h1.Children);
        success=0;
        failure=0;
        if n>=3 || el~=90 || MaximizeAll==1 %if figure is a subplot or 3D, make it big.
            for j=1:n
                %we use the try catch to figure out if the figure we have
                %actually has subplots or just several children aside, like
                %legends, etc.
                try
                    %Increase the font size.
                    success=success+1;
                    h2=h1(j).Children;
                    set(h2,'FontSize',18);
                    title=h2.Title;
                    title.FontSize=20;
                catch
                    failure=failure+1;
                end
            end
            if success>=2 || MaximizeAll==1 %then we found 2 Axes. Maximize.
                set(gcf, 'Position', get(0, 'Screensize'));
            end

        end %End of logic for maximizing a figure.
        
        
        for j=1:length(formats)
            Figtitle=h1.Children(end).Title.String; %take first title for name
            if isempty(Figtitle)==0
                Figtitle=strrep(Figtitle,'.','_');
                Figtitle=strrep(Figtitle,':','_');
                Figtitle=strrep(Figtitle,'/','_');
                try
                    saveas(gcf,[location '/' Figtitle],formats{j});
                catch ME
                    disp(['Erred on Figure Number: ' num2str(i)])
                    rethrow(ME);
                end
            else
                warning(['Figure Number: ' num2str(i) ' does NOT have a title, skipping'])
            end
        
            persistance=0; %set persistance to 0 when we find a figure.
        end
        
        if closing==1 %close the figure.
            close(h1)
        else %If not closing figure, reset size.
            set(h1,'Position',defaultSize)
        end
    else %We failed to find a figure at this number, increment persistance.
        persistance=persistance+1;
        if persistance>5 %We did not find any handles the past N times, quit.
            break
        end
    end
    i=i+1; %Increment figure number. 
end
        