%this integration test script will test some 3D TDoA cases.

%% Equilateral triangle point is at the exact center of plane.
X=10;
x=7; %receiver location
y=-4; %receiver location
z=100;
R1=[0,0,0];
R2=[X,0,0.05];
R3=[X/2,X/2*sqrt(3),0.1];
expected=[x y z];

d1=sqrt((R1(1)-x)^2+(R1(2)-y)^2+(R1(3)-z)^2);
d2=sqrt((R2(1)-x)^2+(R2(2)-y)^2+(R2(3)-z)^2);
d3=sqrt((R3(1)-x)^2+(R3(2)-y)^2+(R3(3)-z)^2);

distanceDiffs=abs([0 d1-d2 d1-d3; 0 0 d2-d3; 0 0 0]);

figure()
plot3(x,y,z,'o','linewidth',3);
hold on
location=TDoA([R1;R2;R3],distanceDiffs);
AssertToleranceMatrix(expected,location,0.001);

%% 
% clearvars
% figure()
% start=-100;
% stop=100;
% step=1;
% [x,y,z]=meshgrid(start:step:stop,start:step:stop,start:step:stop);
% V=sqrt(x.^2+y.^2+z.^2)-sqrt((x-10).^2+y.^2+z.^2);
% fv=isosurface(x,y,z,V,(sqrt(10065)-sqrt(10025)));
% p=patch(fv); % This is the key step. It involves getting the part of the volume corresponding to the surface defined by the equation
% set(p,'FaceColor','red','EdgeColor','none');
% daspect([1 1 1])
% view(3);
% camlight
%%
clearvars
syms x y z
Eqn1=sqrt(x^2+y^2+z^2)-sqrt((x-10)^2+y^2+z^2)-(sqrt(10065)-sqrt(10025));
figure()
fimplicit3(Eqn1,[-100 100 -100 100 -100 100])
% clearvars
% % figure()
% step=2;
% x=-100:step:100;
% x=repmat(x,[length(x) 1]);
% y=(-100:step:100)';
% y=repmat(y,[1 length(y)]);
% z=zeros(length(y),length(y));
% 
% for i=1:length(y)
%     for j=1:length(y)
%         z(i,j)=eq1(x(i,j),y(i,j));
%         z2(i,j)=eq2(x(i,j),y(i,j));
%     end
% end
% 
% figure()
% surf(x,y,real(z))
% hold on
% surf(x,y,real(z2))
% 
% %% 
% % syms x y
% % Eqn1=sqrt(x^2+y^2)-sqrt((x-10)^2+y^2)-(sqrt(65)-sqrt(25));
% % Eqn2=x^2-y^2-1;
% figure()
% x=-100:step:100;
% y=zeros(1,length(x));
% y2=zeros(1,length(x));
% for i=1:length(x)
%     y(i)=eq3(x(i));
%     y2(i)=eq3(x(i));
% end
% plot(x,y)
% hold on
% plot(x,y2)
% 
% 
% % fimplicit3(Eqn);
% function out=eq1(x,y)
% %     out=sqrt(x^2+y^2+z^2)-sqrt((x-10)^2+y^2+z^2)-(sqrt(10065)-sqrt(10025));
% 
% %  out=-0.5*(- 3.9914429098230409335948794802614*x^2 + 39.914429098230409335948794802614*x - 4.0*y^2 + 46545.075992287379074203123566807)^(1/2);
%  out= 0.5*(- 3.9914429098230409335948794802614*x^2 + 39.914429098230409335948794802614*x - 4.0*y^2 + 46545.075992287379074203123566807)^(1/2);
% 
% end
% 
% % fimplicit3(Eqn);
% function out=eq2(x,y)
% %     out=sqrt(x^2+y^2+z^2)-sqrt((x-10)^2+y^2+z^2)-(sqrt(10065)-sqrt(10025));
% 
%  out=-0.5*(- 3.9914429098230409335948794802614*x^2 + 39.914429098230409335948794802614*x - 4.0*y^2 + 46545.075992287379074203123566807)^(1/2);
% %  out= 0.5*(- 3.9914429098230409335948794802614*x^2 + 39.914429098230409335948794802614*x - 4.0*y^2 + 46545.075992287379074203123566807)^(1/2);
% 
% end
% 
% function out=eq3(x)
% out=  0.5*(0.0000000000000000000000000078064452122133773877786138087918*(70368744177664.0*x - 459587336936365.0)*(70368744177664.0*x - 244100104840275.0))^(1/2);
% 
% end
% 
% function out=eq4(x)
% out= -0.5*(0.0000000000000000000000000078064452122133773877786138087918*(70368744177664.0*x - 459587336936365.0)*(70368744177664.0*x - 244100104840275.0))^(1/2);
% 
% end