function [Fig1,Fig2] = PlotIntersect(Surf,SymbolicEqns,Labels)
%Plot Intersect will produce 2 figures. The first is a plot of just the
%intersections. The 2nd is a plot of the intersection superimposed on the
%input surfaces.
%INPUTS:
    %Surfaces 
    %x,y,z solutions
    %Labels for x,y,z axes.
    %z may be empty. 

    %PROBLEMS: not sure how to tell it to plot when it doesn't know the
    %variable names under Surf
    
% if(nargin==4)
%     Fig1=figure();
%     plot(x,y)
%     Fig2=figure();
%     plot(x,y)
%     hold on
%     fimplicit(Surf);
%     addLabels(Labels,Fig1,Fig2)
% else
%     Fig1=figure();
%     plot3(x,y,z)
%     Fig2=figure();
%     plot3(x,y,z)
%     hold on
%     fimplicit(Surf);
%     addLabels(Labels,Fig1,Fig2)
% end
% 
% end
% 
% function addLabels(Labels,Fig1,Fig2)
% h=[Fig1,Fig2];
% 
% for i=1:length(h)
%     figure(h(i))
%     xlabel(Labels{1})
%     ylabel(Labels{2})
%     if length(Labels)==3
%         zlabel(Labels{3});
%     end
% end



end

