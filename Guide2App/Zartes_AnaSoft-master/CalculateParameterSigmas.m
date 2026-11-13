function sigmas=CalculateParameterSigmas(P,IV,TES)
%%%%calcular las sigma del resto de parametros deducidos.

Rn=TES.Rn;
G0=TES.G;
T0=TES.Tc;
%P0=IV.ptes;
for ii=1:length([P.p.rp])
    rp=P.p(ii).rp;
    P0=spline(IV.rtes,IV.ptes,rp);
 R0=P.p(ii).rp*Rn;
 bi=P.p(ii).bi;
 Z0=P.p(ii).Z0;
 L0=P.p(ii).L0;
 Zinf=P.p(ii).Zinf;
 taueff=P.p(ii).taueff;
 s_zinf(ii)=P.residuo(ii).ci(1,2)-P.residuo(ii).ci(1,1);
 s_z0(ii)=P.residuo(ii).ci(2,2)-P.residuo(ii).ci(2,1);
 s_taueff(ii)=P.residuo(ii).ci(3,2)-P.residuo(ii).ci(3,1);
 
 %s_L0(ii)=sqrt(((R0*bi)/(Z0-R0)^2)^2*s_z0(ii)^2+(1/(Z0-R0)^2)*s_zinf(ii)^2);%%%sigma de L0
 s_L0(ii)=sqrt(((Zinf+R0)/(Z0+R0)^2)^2*s_z0(ii)^2+(1/(Z0+R0)^2)*s_zinf(ii)^2);%%%sigma de L0
 s_alfa(ii)=(G0*T0/P0)*s_L0(ii);%%% sigma alpha
 s_beta(ii)=s_zinf(ii)/R0;
 s_tau0(ii)=sqrt((L0-1)^2*s_taueff(ii)^2+taueff^2*s_L0(ii)^2);
 s_C(ii)=G0*s_tau0(ii);
 %definir resto de sigmas
end

sigmas.rp=[P.p.rp];
sigmas.s_zinf=s_zinf;
sigmas.s_z0=s_z0;
sigmas.s_taueff=s_taueff;
sigmas.s_L0=s_L0;
sigmas.s_alfa=s_alfa;
sigmas.s_beta=s_beta;
sigmas.s_tau0=s_tau0;
sigmas.s_C=s_C;