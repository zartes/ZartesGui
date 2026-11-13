function IV=SteadyState_1TBfromR0Ib(varargin)
%%%funcion para resolver las IVs para 1TB fijando valores de R0 e Ibias.

if nargin==0
    Rsh=2e-3; RL=2.182e-3;
    n=3.067;K=1.769e-9;
    Tc=0.0927;Rn=87.2e-3;
else
    TES=varargin{1};
    circuit=varargin{2};
    Rsh=circuit.Rsh;Rpar=circuit.Rpar;
    RL=Rsh+Rpar;
    n=TES.n;K=TES.K;
    Rn=TES.Rn;
    Tc=TES.Tc;
end
rp=[0:1e-3:1];
IbiasArray=[500:-1:0]*1e-6;
TtesArray=[0.09:1e-4:0.11];
for i=1:length(rp)
    R0=Rn*rp(i);
    I0array=IbiasArray*Rsh/(RL+R0);
    V0array=I0array*R0;
    P0array=V0array.*I0array;
    for j=1:length(IbiasArray)
        f=@(x) GompertzRTI(x,I0array(j))-R0;
        %T0array(j)=fsolve(f,Tc);%%%solve tarda mucho.
        m=min(abs(f(TtesArray)));
        kk=find(abs(f(TtesArray))==m);
        T0array(j)=TtesArray(kk(1));
        Tbatharray(j)=(T0array(j)^n-P0array(j)/K).^(1/n);
    end
end
IV.R0=R0;
IV.I0array=I0array;
IV.V0array=V0array;
IV.P0array=P0array;
IV.T0array=T0array;
IV.Tbatharray=Tbatharray;