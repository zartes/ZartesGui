function Lc=Lcrit(TES,param)
%%funcion para calcular la Lcritica del circuito para un set de parametros
%%del TES. Irwin book. p16. ec45.

RL=TES.Rsh+TES.Rpar;
Rn=TES.Rn;
R0=(param.rp*Rn);
p1=(3+param.bi-RL./R0);
p2=(1+param.bi+RL./R0);
sqr=sqrt(param.L0*(2+param.bi)*(param.L0*(1-RL./R0)+p2));

Lc=(param.L0.*p1+p2-2*sqr).*R0.*param.tau0./(param.L0-1).^2;