function [Hyperboloid] = ComputeHyperboloid(Station1Coordinates,Station2Coordinates,DifferenceInDistance,fixedCoord)
%This function creates a hyperboloid in the body frame then converts it to
%the fixed frame. It returns the equation that describes that hyperboloid
%in the fixed frame. Expect this expression to be complicated.
%if the DifferenceInDistance is zero, the output will be a plane, not
%a hyperboloid.
%INPUTS: 3D coordinates of stations 1 and 2.
        %The difference in Distance between stations 1 and 2.
%OUTPUTS: symbolic eqn describing Hyperboloid.

%NOTE, the hyperboloid in the body frame is centered at the midpoint of
%station 1 and 2.

%[xb yb zb] are the coordinates in the body frame
%[x y z] are the coordinates in the fixed frame.

[RM,Offset,distance]=getRMandOffsets(Station1Coordinates,Station2Coordinates);
if size(Offset,2)>size(Offset,1)
    Offset=Offset';
end
fixedCoordMoved=fixedCoord-Offset;
xb=dot(RM(:,1),fixedCoordMoved);
yb=dot(RM(:,2),fixedCoordMoved);
zb=dot(RM(:,3),fixedCoordMoved);

if isnumeric(DifferenceInDistance)==1 && abs(DifferenceInDistance)<1.0e-14
    %vertical plane in the body frame
    Hyperboloid=xb;
else
    %hyperboloid.
    a=DifferenceInDistance/2;
    
    if  ((distance/2)^2-a^2)>0
        %if the distance difference is less than the greatest distance
        %between the stations, then we can draw a hyperbola.
    
        b=sqrt((distance/2)^2-a^2);

        %body frame hyperboloid
    %     HyperboloidBody=xb^2/a^2-yb^2/b^2-zb^2/b^2-1;
        %body frame 1 sided hyperboloid
        Hyperboloid=a*sqrt(1+yb^2/b^2+zb^2/b^2)-xb;
        %1 sided Cone
%         Hyperboloid=a*sqrt(yb^2/b^2+zb^2/b^2)-xb;

    else
        %if the distance difference is greater, we cap it at the greatest
        %distance and draw a horizontal line.
        
        Hyperboloid=0-yb;
        if abs(xb)<abs(a)
            %then xb is in the forbidden zone.
            Hyperboloid=1/xb^2-1/a^2;
        end
    end
end

end

