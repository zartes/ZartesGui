function Taus=GetTaus(Tbath,Ib,IVset,P,circuit)
%%%Calculamos las Taus relevantes a partir de un punto de operación

    [~,Tind]=min(abs([IVset.Tbath]-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IVstr=IVset(Tind);
    [~,Tind]=min(abs([P.Tbath]-Tbath));
    p=P(Tind).p;
    
OP=setTESOPfromIb(Ib,IVstr,p);

RL=circuit.Rsh+circuit.Rpar;
Req=RL+OP.R0*(1+OP.bi);
beta=(OP.R0-RL)/Req;

tau_I=OP.tau0/(1-OP.L0);
tau_el=circuit.L/Req;
tau_eff=OP.tau0/(1+beta*OP.L0);

sqr=sqrt((tau_I^-1+tau_el^-1)^2-4*OP.R0*OP.L0*(2+OP.bi)/circuit.L/OP.tau0);

tau_Mas=2*(tau_I^-1+tau_el^-1+sqr)^-1;
tau_Menos=2*(tau_I^-1+tau_el^-1-sqr)^-1;

Taus.tau_I=tau_I;
Taus.tau_el=tau_el;
Taus.tau_eff=tau_eff;
Taus.tau_Mas=tau_Mas;
Taus.tau_Menos=tau_Menos;