function IV=SteadyStateScript_2TB_interm(varargin)
%%%Solver script. arg1:TES, arg2:circuit.
%%%Es una adaptacion del script original para resolver el caso 2TB_interm,
%%%pero lo unico que cambia es el calculo de T1. Podría generalizarse? Aquí
%%%ademas estamos suponiendo n=m, pero podríamos también ver el efecto de
%%%hacerlos distintos. Tenemos que convertir los valores de los fits g_i en
%%%los correspondientes valores K y B.

%%%Para poner valores razonables, tengo en cuenta que
%%%K=gtes_1(T0)/n*T0^(n-1) B=gb_1/m*T1^(m-1). Miro en el 2Z4 25x100(4) y
%%%veo que al 50%Rn gtes_1=1e-10, g1_b=5e-11 y T1=0.08. Asumo n=m=3.15, el
%%%valor fijado en TES. Ojo porque el valor de K que sale de ahí es
%%%diferente al extraído de los fits P-T.

%%%TES info
if nargin==0
    Rsh=2e-3; 
    RL=2.182e-3;
    n=3.15;
    K=5.3e-9;
    B=3.6e-9;
    Ks=K+B;
else
    TES=varargin{1};
    circuit=varargin{2};
    Rsh=circuit.Rsh;Rpar=circuit.Rpar;
    RL=Rsh+Rpar;
    n=TES.n;K=TES.K;
    B=TES.B;
    Ks=K+B;
end

%TtesArray=0.12:-1e-3:0.06;
%TbathArray=0.08:0.002:0.1;
TtesArray=0.2:-1e-3:0.04;
TbathArray=[0.04:0.005:0.08 0.082:0.002:0.1];
I=(0:1e-2:50)*1e-6;

P=@(x,y) K*(x.^n-y.^n);
for k=1:length(TbathArray)
    Tbath=TbathArray(k);
    Ites=[];Rtes=[];Ibias=[];
for i=1:length(TtesArray)
    Ttes=TtesArray(i); 
    if Ttes<=TbathArray(k) break;end
    %P=K*(Ttes.^n-Tbath.^n);
    T1=(K*(Ttes.^n)/Ks+B*(Tbath.^n)/Ks).^(1/n);%%%Asumiendo n=m despejamos T1. Se podría hacer también conociendo n y m, pero en el 2TB_interm hacemos esa hipótesis para extraer los parametros.
    pw=P(Ttes,T1);
    F=@(I) I.^2.*GompertzRTI(Ttes,I)-pw;
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
end

end

