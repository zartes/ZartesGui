function plotGeneralParam(P,varargin)
%%%Función para pintar y formatear parámetros a partir de una estructura P.

%xl='ai';
%yl='M';

if nargin ==2
    TES=varargin{1};
end
if nargin>2
    opt=varargin{2};
    optname=[opt.name];
    optvalue=[opt.value];
else
    optname={'markersize'}
    optvalue={15}
end

indx=[1:length(P)];
%indx=1;
for i=indx%length(P),
    %x=eval(strcat('[','P(i).p.',xl,']'));
    %y=eval(strcat('[','P(i).p.',yl,']'));
    ALL=GetAllPparam(P(i));
    %%%%%expand parameters
    rp=ALL.rp;L0=ALL.L0;ai=ALL.ai;bi=ALL.bi;tau0=ALL.tau0;taueff=ALL.taueff;C=ALL.C;Zinf=ALL.Zinf;Z0=ALL.Z0;ExRes=ALL.ExRes;ThRes=ALL.ThRes;M=ALL.M;Mph=ALL.Mph;
    Tb=ALL.Tb;
    %%ecX='ai./sqrt(1+2*bi)';%%%Ecuacion para la X
    %%ecX='ai./bi';
    %%%ecX='ai./L0-1';
    %%%ecX='(1+2*bi)';    
    ecX='rp';
    %ecX='Tb';
    
    x=eval(ecX);
    %ecY='ExRes./ThRes';%%%Ecuacion para la Y
    
    %ecY='abs(tau0)';
    %ecY='ai./L0-1';
    %ecY='ai./(1+bi)';%%alfa_eff_Aprox
    %ecY='ai.*(2*L0+bi)./(2+bi)./L0';%%%alfa_eff1

    %ecY='(bi+2*L0)./(1-L0)';%%%beta_eff
    %ecY='(1-L0)./(bi+2*L0)'; %%%inverse beta_eff
    n=TES.n;K=TES.K
    %ecY='(2+bi)./(n*(1-K*Tb.^n)-ai)'
    RL=2.028e-3;
    %Rn=23.2e-3;
    Rn=TES.Rn;
    Tc=TES.Tc;
    %ecY='ai./(1+bi./(1+RL./(rp*Rn)))';%%%alfa_eff2
    %ecY='tau0./(1+L0.*(1-RL./(rp*Rn))./(1+bi+RL./(rp*Rn)))';
    %ecY='taueff';
    %ecY='ai.*(RL-rp*Rn).*(1-n.*L0./ai)./(L0.*(rp*Rn-RL)+RL+rp*Rn.*(1+bi))';%factor conversión Tbath->Ptes
    %ecY='ai.*(RL-rp*Rn).*((Tb/Tc).^n)./(L0.*(rp*Rn-RL)+RL+rp*Rn.*(1+bi))';%factor conversión Tbath->Ptes v2.sale distinto?
    
    ecY='sqrt((0.5*(1+(Tb./Tc).^(n+2))).^-1-1)*ones(1,length(rp))';%%%M factor for F=1?
    ecY='sqrt(ExRes.^2-ThRes.^2)';
    y=eval(ecY);
    h=plot(x,y,'.-');hold on
    set(h,optname,optvalue);
end

hold off,
grid on
xlabel(ecX,'fontsize',12);
ylabel(ecY,'fontsize',12);
set(gca,'linewidth',2,'fontsize',12);