function Ekev= ekev(T)
%calculo de energía del máximo de emision en kev en funcion de la
%temperatura
%E=c*h/L   Lmax=wien_c/T. wien_c=2.9e-3
L=2.9e-3/T
Ekev=3e8*6.55e-34/L/1.602e-19*1e-3;