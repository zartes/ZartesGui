function IV=SteadyStateScript(varargin)
%%%Solver script. arg1:TES, arg2:circuit.

%%%TES info. La R(T,I) que define también al TES hay que modificarla
%%%adecuadamente en GompertzRTI.
if nargin==0
    Rsh=2e-3; RL=2.182e-3;
    n=3.067;K=1.769e-9;
else
    TES=varargin{1};
    circuit=varargin{2};
    Rsh=circuit.Rsh;Rpar=circuit.Rpar;
    RL=Rsh+Rpar;
    n=TES.n;K=TES.K;
end

TtesArray=0.2:-1e-3:0.04;
%TbathArray=0.08:0.002:0.1;
%TbathArray=0.04;%
TbathArray=[0.04:0.005:0.08 0.082:0.002:0.1];
I=(0:1e-3:50)*1e-6;%%%Pruebo step=1e-7 pero genera pequeño artefacto (no es suficiente) y el 1e-8 no alarga sustancialmente el calculo.

P=@(x,y) K*(x.^n-y.^n);
for k=1:length(TbathArray)
    Tbath=TbathArray(k);
    Ites=[];Rtes=[];Ibias=[];
for i=1:length(TtesArray)
    Ttes=TtesArray(i); 
    if Ttes<=TbathArray(k) break;end
    %P=K*(Ttes.^n-Tbath.^n);
    pw=P(Ttes,Tbath);
    F=@(x) x.^2.*GompertzRTI(Ttes,x)-pw;
    %Ites(i)=fsolve(F,5e-6);
    m=min(abs(F(I)));
    j=find(abs(F(I))==m);
    Ites(i)=I(j(1));
    Rtes(i)=GompertzRTI(Ttes,Ites(i));
    G=@(I) I.*(RL+GompertzRTI(Ttes,I));
    Ibias(i)=G(Ites(i))/Rsh;
end
IV(k).Ttes=TtesArray(1:length(Rtes));
IV(k).Ites=Ites;
IV(k).Rtes=Rtes;IV(k).Rtes(Ites==0)=0;%%%Cuando Ttes<Tb ->Ites=0
IV(k).Vtes=Rtes.*Ites;
IV(k).Ptes=Rtes.*Ites.^2;
IV(k).ibias=Ibias;
IV(k).Tbath=TbathArray(k);
end
