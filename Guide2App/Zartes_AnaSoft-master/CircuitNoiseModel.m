function noise=CircuitNoiseModel(circuitdata)
%%% Intento de modela el ruido total del circuito incluyendo también el
%%% ruido en voltaje y corriente del PRE.
invMin=circuitdata.invMin;
invMf=circuitdata.invMf;
Vphi=circuitdata.Vphi;%sensibilidad voltaje/flujo
Rdyn=circuitdata.Rdyn;%Resistencia dinámica Squid. Sensibilidad Voltaje/corriente
Mdyn=circuitdata.Mdyn;%sensibilidad flujo/corriente
SVamp=circuitdata.Vamp.^2;%Vamp:ruido en voltajedel PRE
SIamp=circuitdata.Iamp.^2;%Iamp: ruido en corriente del PRE
SIsquid=circuitdata.Isquid.^2;%Isquid: ruido en corriente del squid (los habituales 3pA)
if isfield(circuitdata,'Phisquid')
    SPhisquid=circuitdata.Phisquid.^2;%Phisquid: ruido en flujo del squid.
else
    SPhisquid=SIsquid/invMin^2;
end

SPhitotal=SPhisquid+SVamp/Vphi^2+SIamp*Mdyn^2;
nphitotal=sqrt(SPhitotal);
%SItotal=SIsquid+SVamp*(invMin/Vphi)^2+SIamp*(Mdyn*invMin)^2;
SItotal=SPhitotal*invMin^2;
nItotal=sqrt(SItotal);%%%ruido en corriente equivalente en la rama del TES.
nVouttotal=I2V(nItotal,circuitdata); %Ruido en Voltaje a la salida 
%nphitotal=nItotal/invMin; % Ruido total en flujo a la entrada.
noise.nItes=nItotal;
noise.nVout=nVouttotal;
noise.nPhi=nphitotal;