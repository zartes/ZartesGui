function NoiseHandle=NnoiseModelHandle(circuit,Tbath,varargin)
%%%Función para devolver el modelo de ruido total en estado normal
%%% como un handle.

Kb=1.38e-23;
RL=circuit.Rsh+circuit.Rpar;
RN=circuit.Rn;

if nargin==3 
    Ttes=varargin{1};
else
    Ttes=Tbath;
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
            
Rtes=RN;

Zcirc=@(f) RL+Rtes+1i*2*pi*f*circuit.L;% impedancia del circuito.
v2_sh=4*Kb*Tbath*RL; % ruido voltaje Rsh (mas parasita).
v2_tes=4*Kb*Ttes*Rtes;%ruido voltaje en el TES en estado normal.

i_jo=@(f) sqrt(v2_sh+v2_tes)./abs(Zcirc(f));
NoiseHandle=@(f) sqrt(i_jo(f).^2+cnHandle(f).^2);
