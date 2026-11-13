function N=NnoiseModel(circuit, Tbath, varargin)
%%%Función para devolver el modelo de ruido total en estado normal o
%%%superconductor

Kb=1.38e-23;
RL=circuit.Rsh+circuit.Rpar;
RN=circuit.Rn;

if isfield(circuit,'squid')
    i_squid=circuit.squid;
else
    i_squid=3e-12;
end

%tau=circuit.L/(RL+RN);
f=logspace(0,6,1000);
w=2*pi*f;

Rtes=RN;
if nargin==3 
    Ttes=varargin{1};
else
    Ttes=Tbath;
end 
%Ttes=max(Tbath,Tc);

if nargin==4%%%Intento de calcular también una contribución phonon.
    TES=varargin{2};
    n=TES.n;
    G=TES.Gtes(Ttes);
else
    n=3;
    G=100e-12;%%%arbitrario.
end
bb=n-1;
t=Tbath/Ttes;
F=(t^(bb+2)+1)/2;%%%specular limit

Zcirc=RL+Rtes+1i*w*circuit.L;% impedancia del circuito.
v2_sh=4*Kb*Tbath*RL; % ruido voltaje Rsh (mas parasita).
v2_tes=4*Kb*Ttes*Rtes;%ruido voltaje en el TES en estado normal.

G=0;
v2_tfn=sqrt(4*Kb*Ttes^2*G*F)*Rtes;%%%%ojo.
i2_tfn=sqrt(4*Kb*Ttes^2*G*F)/Rtes;

i_jo=sqrt(v2_sh+v2_tes+0*v2_tfn)./abs(Zcirc);%%%%He probado a incorporar el TFN, pero no salen valores que puedan explicar la diferencia th-ex.
%%i_jo=sqrt(4*Kb*Tbath/(RTES))./sqrt(1+(tau*w).^2);%%%06-04-20.no elevaba al cuadrado tau*w!!!
%i_jo=sqrt(4*Kb*Tbath/(RTES))./(1+tau*w);
%[sqrt(4*Kb*Tbath/RL) sqrt(4*Kb*Tbath/RN) sqrt(4*Kb*Tbath/RTES)]
%N=sqrt(i_sh.^2+i_jo.^2+i_squid^2);
N=sqrt(i_jo.^2+i_squid^2+0*i2_tfn*ones(1,length(Zcirc)));