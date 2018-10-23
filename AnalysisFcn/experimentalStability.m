function conds=experimentalStability(p,circuit)

taueff=[p.taueff];
beta=[p.bi];
R0=[p.rp]*circuit.Rn;
L0=[p.L0];
tau0=[p.tau0];
Rdyn=circuit.Rsh+circuit.Rpar+R0.*(1+beta);
tauel=circuit.L./Rdyn;


invtauetc2=(R0/circuit.L).*(2+beta).*(L0./tau0);

%%%TESIS Lindeman p68-69. ecs
%cond1.Stability 1. ec4.23.
conds.stab1=1./taueff<1./tauel;
%1/taueff,1/tauel

%cond2. Stability2. ec4.24.
conds.stab2=1./(taueff.*tauel)<invtauetc2;
%1/(taueff*tauel),invtauetc2

conds.stab=conds.stab1&conds.stab2;

%cond3. Oscillatory/exponential.
conds.expo=(1./taueff+1./tauel).^2>4*invtauetc2;
%(1/taueff+1/tauel)^2,4*invtauetc2