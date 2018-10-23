function conds=StabilityCheck(varargin)
%check de las condiciones de estabilidad de los TES
%El punto de operación va ya codificado en los parametros del TES. 
%hay que llamar antes a SetOP().

if nargin==0

    %default parameters.
    C=2.3e-15;
    G=1.7e-12;
    T0=0.15;
    R0=80e-3;
    I0=1e-6;
    L=400e-9;
    Rsh=2e-3;
    Rpar=0.5e-3;
    alfa=100;
    beta=0.96;

else
    TESparam=varargin{1}
    Circuitparam=varargin{2};
    C=TESparam.C;G=TESparam.G;%realmente no son constantes.
    L=Circuitparam.L;Rsh=Circuitparam.Rsh;Rpar=Circuitparam.Rpar;%parametros del circuito.
    T0=TESparam.T0;I0=TESparam.I0;%punto de operacion.
    Tc=TESparam.Tc;Ic=TESparam.Ic;Rn=TESparam.Rn;
    %[r0,alfa,beta]=FtesTI(T0/Tc,I0/Ic);
    %R0=Rn*r0;
    R0=TESparam.R0;alfa=TESparam.alfa;beta=TESparam.beta;
end

Rdyn=Rsh+Rpar+R0.*(1+beta);
tau0=C./G;
L0=I0.^2.*R0.*alfa./(G.*T0);
taueff=tau0./(L0-1);
tauel=L./Rdyn;
invtauetc2=(R0/L).*(2+beta).*(L0./tau0);

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
