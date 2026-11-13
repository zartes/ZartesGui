function z=Z()
%Expresión teórica para la impedancia compleja en función de parámetros
%básicos del sistema. Representa un modelo termico simple. Es la 
%ecuacion (8) del articulo de Liderman: 
%Rev. Sci.Instrum. 75, 1283 (2004);doi:10.1063/1.1711144
%Es equivalente a la expr (6) de Khosropanah que es la misma de la 14.3 de
%la tesis de maria o la que usa Takei, y esta ultima es mas sencilla.
%incorporo la posibilidad de añadir ruido.

%Valores tomados de la tesis de maria, tabla 14.1 pag.220 o de Khosropanah
%table 6.
global R0 P0 I0 T0 G C ai bi
%base param
R0=79e-3;%210e-3;%79e-3; % R de equilibrio
P0=77e-15;%80e-15;%77e-15; % potencia disipada en equilibrio
%I0=1e-8;
I0=(P0/R0)^.5; % corriente de equilibrio
T0=  0.155;%0.07; %pto. operacion.aprox Tc.
G=1.7e-12;%1.66e-12;%1.7e-12; %conductancia termica con el baño

%sim param
C=2.3e-15;%3e-15;%2.3e-15; % capacidad termica del TES
ai=131;%100;%131; % sensibilidad logaritmica de R vs T.
bi=0.96;%1;%0.96; % parametro entre 0 y 1. sensibilidad logaritmica de R vs I.

%deduced param
L0=P0*ai/(G*T0) % low freq loop gain.
%tau=1/(I0^2*R0*ai/(C*T)-G/C) %constante de tiempo efectiva
tau0=C/G;
tau=tau0/(L0-1)

f=logspace(0,6); %rango de frecuencias.
zinf=R0*(1+bi)
z0=R0*(1+bi+L0)/(1-L0)
%f=0:100:100000;
%Z=R0*((1+bi)+(1+bi/2)*(I0^2*R0*ai*tau/(C*T0))*(-1+((1+1i*2*pi.*f*tau)./(-1+1i*2*pi*f*tau))));
%z1=R0*((1+bi)+(1+bi/2)*(I0^2*R0*ai*tau/(C*T0))*(-1+((1+1i*2*pi.*f*tau)./(-1+1i*2*pi*f*tau))));
z=zinf+(zinf-z0)./(-1+1i*2*pi*f*tau);%+2e-3+1i*2*pi*f*10e-9; %+Rth+iwL
z=z+0.001.*randn(1,length(z))*(1+1i);
plot(real(z),imag(z),'or')