function G=SquareMaskG(T)
%geometría membraba cuadrada: h=1um, D=[0.5 1 2 3 ]*1e-3, d=[50 100 150 200 250]*1e-6;

h=1e-6;
D=[0.5 1 2 3 ]*1e-3;
d=[50 100 150 200 250]*1e-6;
S=4*pi*h./log(1+pi*((D'*(1./d)).^2-1)/4);

k=[12]*T.^2.2*1e-3;%conductividad del nitruro de silicio.
G=k*S;