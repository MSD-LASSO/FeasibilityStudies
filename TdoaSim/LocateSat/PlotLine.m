function PlotLine(LineBias,LineSlope,range,handler)
%PlotLine visualizes a line fit. IT can be added to a figure or plotted on
%a new figure.

%INPUTS: LineBias of form [x1,y1,z1; x2 y2 z2; etc.] One row for each line.
        %LineSlope        [x1,y1,z1; x2 y2 z2; etc.]
        %handler          Figure or empty
        %range            [-t t; -s s]. Dictated for each line or once.
        
if nargin<4
    handler=figure();
end

%% plot lines of form [x y z] = [x0 y0 z0] + t * [xd yd zd].

n=size(LineBias,1);
m=size(range,1);
if n>m
    %if range was not specified for every line. Make it the same.
    range=ones(n,2).*range;
end
figure(handler)
for i=1:n
    t=linspace(range(i,1),range(i,2),100);
    x=LineBias(i,1)+t*LineSlope(i,1);
    y=LineBias(i,2)+t*LineSlope(i,2);
    z=LineBias(i,3)+t*LineSlope(i,3);
    plot3(x,y,z,'Linewidth',3);
    hold on
end
grid on

    
end

