function IVsim=SteadyState_1TBsmart(varargin)
%%%Solver script. arg1:TES, arg2:circuit.

%%%TES info
if nargin==0
    Rsh=2e-3; RL=2.182e-3;
    n=3.067;K=1.769e-9;
    Rn=87.2e-3;
else
    TES=varargin{1};
    circuit=varargin{2};
    Rsh=circuit.Rsh;Rpar=circuit.Rpar;
    RL=Rsh+Rpar;
    n=TES.n;K=TES.K;
end

%TtesArray=0.1:-1e-5:0.04;
TtesArray=0.04:1e-5:0.2;
%TbathArray=[0.04:0.005:0.08 0.082:0.002:0.1];
%I=0:1e-7:50e-6;
Ibias=(500:-1:0)*1e-6;
P=@(x,y) K*(x.^n-y.^n);
Parray=(1e-1:2e-1:5)*1e-12;%%%%Array de valores de potencia a explorar.
for i=1:length(Parray)
    i
    Pw=Parray(i);
    ItesPc=(Ibias*Rsh+sqrt((Ibias*Rsh).^2-4*RL*Pw))/(2*RL);%%%signo?
    ItesPc(imag(ItesPc)~=0)=0;
    Itmin=sqrt(Pw/Rn);
    ItesPc(ItesPc<Itmin)=Itmin;
    RtesPc=Pw./(ItesPc).^2;
    VtesPc=Pw./ItesPc;
    for ind2=1:length(Ibias)
        %f=@(x) GompertzRTI(x,ItesPc(ind2))-RtesPc(ind2);
        %TtesPc(ind2)=fsolve(f,0.12); %%%El fsolve da error para algunos
        %puntos.
        
        mini=min(abs(GompertzRTI(TtesArray,ItesPc(ind2))-RtesPc(ind2)));
        [~,jj]=find(GompertzRTI(TtesArray,ItesPc(ind2))-RtesPc(ind2)==mini);
        if ~isempty(jj) TtesPc(ind2)=TtesArray(jj(1)); else TtesPc(ind2)=0;end
        
        %g=@(x) P(TtesPc(k),x)-Pw;
        TbathPc(ind2)=(K*(TtesPc(ind2)^n)-Pw).^(1/n);
        if imag(TbathPc(ind2))~=0 TbathPc(ind2)=TtesPc(ind2);end
    end
    IVsim(i).Ites=ItesPc;
    IVsim(i).Vtes=VtesPc;
    IVsim(i).Rtes=RtesPc;
    IVsim(i).Ttes=TtesPc;
    IVsim(i).Tbath=TbathPc;
    IVsim(i).ibias=Ibias;
    IVsim(i).Ptes=Pw;
end
