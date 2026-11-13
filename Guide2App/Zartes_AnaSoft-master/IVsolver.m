function Ydot=IVsolver(t,Y,Ib,Tb);
%definicion de las ecuaciones diferenciales electrico-termicas acopladas de
%un TES.
f=1e5;
%%parametros
K=1e-8;n=4;C=0.03e-12;%parametros termicos. C=0.3pico de p179maria.
%Tb=80e-3;
%Ib=10e-6;
Rs=2e-3;Rp=1.5e-3;L=10e-9;%parametros del circuito. L arbitrario.buscar!
%Rn=20e-3;Tc=0.1;Ic=5e-6;DT=0.01;DI=2e-7;%parametros del TES

%varianles de estadp Temperatura y corriente.
Ttes=Y(1);
Ites=Y(2);

%Rtes.Hay que dar una expresión para Rtes(Ites,Ttes).
%defino una superficie tal que la expresion en la dimesion radial
%normalizada tiene una R(x) que es la de la exp en denominador.
%Rtes=Rn./(1+exp(-(sqrt((Ttes/Tc).^2+(Ites/Ic).^2)-1)./sqrt((DT/Tc).^2+(DI/Ic).^2)));
Rtes=RtesTI(Ttes,Ites);

%calculo las derivadas para pasarlas al 'ode' solver en simulateIVs. Son
%las ecuaciones acopladas termico-electricas.
Yd(1)=1/C*(Y(2).^2*Rtes-K*(Y(1).^n-Tb.^n));
Yd(2)=1/L*(Ib*(1+0.1*sin(2*pi*f*t))*Rs*(Rp+Rtes)/(Rp+Rs+Rtes)-Y(2)*(Rp+Rtes));
Ydot=[Yd(1);Yd(2)];