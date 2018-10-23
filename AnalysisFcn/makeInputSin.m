function [u,t]=makeInputSin(f,varargin)
%Para el circuito de polarización de nuestros TES genera la entrada 'u' de
%corriente para un sistema linealizado. Se hace la entrada de potencia
%cero.
Rsh=2e-3;L=77e-9;
dI=5e-6;%amplitud en corriente.
A=dI*Rsh/L;
A=1;%no cambia nada pasar amplitud A=1 porque se compara salida y entrada.
%tomamos unos 10 ciclos y mil puntos
%nargin
if(nargin>1) N=varargin{1};else N=10;end
t=0:1e-3*(N/f):N/f;
u(:,1)=A*sin(2*pi*t*f);
u(:,2)=zeros(1,length(t));