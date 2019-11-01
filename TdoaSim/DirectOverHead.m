clearvars
clc
syms rs w om in th0 t la ph Re d sz ug

E=[-sin(la) cos(la) 0; -sin(ph)*cos(la) -sin(ph)*sin(la) cos(ph); cos(ph)*cos(la) cos(ph)*sin(la) sin(ph)];
R=Re*[cos(ph)*cos(la); cos(ph)*sin(la); sin(ph)];

th=sqrt(t^2*ug/rs^3)+th0;
u=th+w;
HA=(280.4606 + 360.9856473 * t/(24 * 3600))*pi/180;
RzHA=[cos(HA) sin(HA) 0; -sin(HA) cos(HA) 0; 0 0 1];
r=rs*[cos(u)*cos(om)-sin(u)*cos(in)*sin(om) ;cos(u)*sin(om)+sin(u)*cos(in)*cos(om); sin(u)*sin(in)];

%% Let elevation = 90 deg.
lat=0.751981147060969;	
long=-1.355756142252390;
t_Oct30th11amUTC=7241.959084409722*24*3600; %from  https://currentmillis.com/?1572433200709
th_orbit=0;

Re_model=6371e3;
a_orbit=500e3+Re_model;
sz_actual=500e3;
ug_actual=3.986004418e14;

satTop=[0;0;sz];
Cons=simplify(E*R,'steps',10);
b=satTop+Cons;
A=E*RzHA;
rResult=A\b;
R=subs(R,[ph la t th0 rs Re sz ug],[lat long t_Oct30th11amUTC th_orbit a_orbit Re_model sz_actual ug_actual]);
th=subs(th,[ph la t th0 rs Re sz ug],[lat long t_Oct30th11amUTC-3600 th_orbit a_orbit Re_model sz_actual ug_actual]);
th=th-floor(th/(2*pi))*2*pi
r=subs(r,[ph la t th0 rs Re sz ug],[lat long t_Oct30th11amUTC th_orbit a_orbit Re_model sz_actual ug_actual]);
rResult=subs(rResult,[ph la t th0 rs Re sz ug],[lat long t_Oct30th11amUTC th_orbit a_orbit Re_model sz_actual ug_actual]);
Eqn=simplify(r-rResult,'steps',10);
out=solve(Eqn,[in,om,w]);

J2000coord=vpa(rResult);
norm(J2000coord)
[longitude latitude altitude]=cart2sph(J2000coord(1),J2000coord(2),J2000coord(3));
longitude=vpa(longitude*180/pi)
latitude=vpa(latitude*180/pi)

%parameters to try
i=out.in
om=out.om
w=out.w
th0=vpa(th_orbit)
a_orbit=500e3+Re_model
e=0
t=vpa(t_Oct30th11amUTC)

la=vpa(lat)
lo=vpa(long)
Re_model=6371e3
sz_actual=500e3

ug_actual=3.986004418e14

