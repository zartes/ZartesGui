function NoiseHandle=SnoiseModelHandle(circuit, Tbath,varargin)
%%%Función para devolver el modelo de ruido total en estado
%%%superconductor en unidades de A/sqrt(Hz) como un fhandle

Kb=1.38e-23;
RL=circuit.Rsh+circuit.Rpar;

if nargin>2
    Tshunt=varargin{1};
else
    Tshunt=Tbath;
end
if isfield(circuit,'squid')
    i_squid=circuit.squid;
else
    i_squid=3e-12;
end

if isfield(circuit,'circuitnoiseHandle')
    cnHandle=circuit.circuitnoiseHandle;
%elseif length(i_squid==1)
    %cnHandle=@(f) circuitnoise;
else
    cnHandle=@(f) i_squid;
%    cnHandle=@(f) interp1(obj.freqs,circuitnoise,f);
end

Tc=0;
Rtes=0; %TES estado superconductor.
Ttes=max(Tbath,Tc);%Es irrelevante porque sólo actúa RL.

Zcirc=@(f) RL+Rtes+1i*2*pi*f*circuit.L;% impedancia del circuito.
v2_sh=4*Kb*Tshunt*RL; % ruido voltaje Rsh (mas parasita).
v2_tes=4*Kb*Ttes*Rtes;%%%Esto es cero.

i_jo=@(f) sqrt(v2_sh+v2_tes)./abs(Zcirc(f));
NoiseHandle=@(f) sqrt(i_jo(f).^2+cnHandle(f).^2);