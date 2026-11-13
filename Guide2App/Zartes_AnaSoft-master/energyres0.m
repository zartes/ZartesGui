function efwhm=energyres0(par)
%energy resolution zero aproximation Irwin ec 102

Kb=1.38e-23;
e=1.602e-19;

Tc=par.Tc;
%C=par.C;
alfa=par.alfa;

optic=0;
if(optic)
    daux=[15:500]';%necesita vector columna!?
    taux=martinis(55,daux,0.09,915,0);
    %size(taux)
    DAU=spline(taux',daux',Tc)
    %plot(taux,daux,'.-',Tc,DAU,'.-')
    par.hAu=DAU*1e-9;
    C=CthCalc(par);
%    [Tc' DAU' C'*1e15]
end

%par.hAu=300e-9;
C=CthCalc(par);
%C=0.72e-15;%for W.
%C*1e15
%[Tc' DAU' C'*1e15]

n=par.n;%3.2;
%n=5;%for W.
M=0;

Ts=0.7*Tc;
if isfield(par,'Tbath') Ts=par.Tbath;end

t=Ts./Tc;
F=(t.^(n+2)+1)/2;%%%specular limit
F2=F./(1-t.^n);

if isfield(par,'M') M=par.M;end

efwhm=2*sqrt(2*log(2))*sqrt(4*Kb*C.*sqrt(n*(1+M^2).*F2)/alfa).*Tc/e;
%%%amplitud
E0=1*e;%1eV.
I0=50e-6;
DI=-alfa*E0*I0/(C*Tc);
Rf=1e4;
DV=DI*3*Rf