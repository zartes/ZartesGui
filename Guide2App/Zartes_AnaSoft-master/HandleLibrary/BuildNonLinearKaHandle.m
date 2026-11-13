function NLKaHandle=BuildNonLinearKaHandle(param)
%%%funcion para simular el efecto de la no-linealidad sobre el complejo Ka
%Hay que pasar en param:
%%%  -param.a (parametro de no lienalidad) y param
%%%  -param.Res (resolucion)
A=100;
E=5700:0.1:6000;%ref E array.
E0=5898.75;%Ka2.

Kafhandle=BuildMnKaHandle();%f([Amp Res],E)
if isstruct(param)
    a=param.a;
    %Res=param.Res;
    RPw=param.RPw;%%%cambiamos Res por resolving power.
elseif isnumeric(param)
    a=param(1);%pasamos vector con p(1)=a p(2)=Res
    %Res=param(2);
    RPw=param(2);%pasamos RPw en lugar de Res pq no estamos realmente con escala lineal en eV sino pseudo eV.
end

p=[a E0];
NonLinCal=@(E) E.*(1+p(1)*(E-p(2)));
Res=E0/RPw;%%%
sigma=Res/2.355;
Low=-10*sigma;High=10*sigma;
step=(E(2)-E(1));
npdf=normpdf([Low:step:High],0,sigma);
NLE=NonLinCal(E);
UNLE=NLE(1):step:NLE(end);%uniform vector.
NLKa=interp1(NLE,Kafhandle([A .01],E),UNLE);%espaciar uniformemente Enl.
NLKa(isnan(NLKa))=0;
NLKaG=A*conv(NLKa,npdf,'same')./max(conv(NLKa,npdf,'same'));
NLKaHandle=@(x)interp1(UNLE,NLKaG,x);