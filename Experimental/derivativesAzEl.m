syms x y z

az=atan(x/y);
el=atan(z/sqrt(x^2+y^2));

dazdx=diff(az,x);
dazdy=diff(az,y);

deldx=diff(el,x);
deldy=diff(el,y);
deldz=diff(el,z);

disp(dazdx)
disp(dazdy)
disp(deldx)
disp(deldy)
disp(deldz)
