function N=SnoiseModel(circuit, Tbath,varargin)
%%%Función para devolver el modelo de ruido total en estado normal o
%%%superconductor en unidades de A/sqrt(Hz).
Kb=1.38e-23;
RL=circuit.Rsh+circuit.Rpar;

if isfield(circuit,'squid')
    i_squid=circuit.squid;
else
    i_squid=3e-12;
end

%tau=circuit.L/RL;
f=logspace(0,6,1000);
w=2*pi*f;

Tc=0;
Rtes=0; %TES estado superconductor.
Ttes=max(Tbath,Tc);

if nargin==3
    TES=varargin{1};
    n=TES.n;
    G=TES.Gtes(Ttes);
else
    n=3;
end
bb=n-1;
t=Tbath/Ttes;
F=(t^(bb+2)+1)/2;%%%specular limit. En estado superconductor F=1.

Zcirc=RL+Rtes+1i*w*circuit.L;% impedancia del circuito.
v2_sh=4*Kb*Tbath*RL; % ruido voltaje Rsh (mas parasita).
v2_tes=4*Kb*Ttes*Rtes;%ruido voltaje en el TES en estado superconductor. En realidad es cero, lo pongo así por mantener la misma estructura del ruido en estado normal.
%v2_tfn=4*Kb*Ttes^2*G*F;
i_jo=sqrt(v2_sh+v2_tes)./abs(Zcirc);

%(Rf*invMf/invMin) factor para convertir en Voltaje.
%i_jo=sqrt(4*Kb*Tbath/RL)./sqrt(1+(tau*w).^2);

N=sqrt(i_jo.^2+i_squid^2);