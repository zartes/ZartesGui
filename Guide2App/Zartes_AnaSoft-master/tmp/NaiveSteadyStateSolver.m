function IV=NaiveSteadyStateSolver(Tb,varargin)
%%%solver directo de las ecuaciones 1TB en estado estacionario.
%TbathArray=[0.04:0.005:0.08 0.082:0.002:0.1];

%%%TES info
if nargin==1
    Rsh=2e-3; RL=2.182e-3;
    n=3.067;K=1.769e-9;
    Rn=87.2e-3;
    Tc=0.0927;
    Ic=1e-1;
else
    TES=varargin{1};
    circuit=varargin{2};
    Rsh=circuit.Rsh;Rpar=circuit.Rpar;
    RL=Rsh+Rpar;
    n=TES.n;K=TES.K;
end

Ib=[500:-1:35]*1e-6;
%P=@(x,y) K*(x.^n-y.^n);

%out(1)=K*(Tc^n-Tb^n)/(Ib(1)*Rsh*Rn/(RL+Rn))/Ic;
out(1)=3.9e-6;
out(2)=0.2;%%%1.2

%options = optimset( 'TolFun', 1.0e-15, 'TolX',1.0e-15,'jacobian','off','algorithm','trust-region-reflective');%{'levenberg-marquardt',0.001});
options = optimset( 'TolFun', 1.0e-15, 'TolX',1.0e-15,'jacobian','off','algorithm','levenberg-marquardt','MaxFunEval',400);
ites=zeros(1,length(Ib));
ttes=zeros(1,length(Ib));

global Ites_f Ttes_f
for i=1:length(Ib)%i=length(Ib):-1:1
     
     %it0=abs(out(1));
     %tt0=abs(out(2));
     it0=Ites_f(Ib(i));%%%global interp 
     tt0=Ttes_f(Ib(i));
     y0down=[it0 tt0];     
     y0=y0down;
     
    f = @(y) Ecs1TB_SteadyState(y,Tb,Ib(i)); % function of dummy variable y
    [out,fval,flag]=fsolve(f,y0,options);
    ites(i)=out(1);
    ttes(i)=out(2);
    rtes(i)=GompertzRTI(ttes(i),ites(i));
end

IV.Ites=ites;
IV.Ttes=ttes;
IV.Rtes=rtes;
IV.Vtes=ites.*rtes;
IV.Ptes=IV.Vtes.*ites;
IV.ibias=Ib;
IV.Tbath=Tb;