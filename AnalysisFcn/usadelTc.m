function Tc=usadelTc(ds,dn,t,Tc0)
%usadelTc(ds(nm),dn(nm),t,Tc0(mK))
%vamos a intentar resolver la ecuacion (30) del articulo de Fominov que 
...parece tener validez en todo rango de 't' para compararla con
    ...la ecuacion de Martinis. usadelTc(dn(nm),ds(nm),t)
dn=dn*1e-9;ds=ds*1e-9; %convertimos a metros.
Tc0=Tc0*1e-3;
%constantes:
h=6.626e-34; %Planck's constant.
e=1.602e-19;
Lf=0.524e-9; %Fermi length. 0.524e-9 en Au.
ns=0.29e29/e; %densidad de estados pasado a st/Jm3
nn=0.107e29/e;
vs=1/(ns*(Lf/2)^2); %fermi velocity Mo. in units of hbar=1.si no, dividir pot hbar.
%vs=1.98e6*(h/(2*pi))
vn=vs*nn/ns; %fermi velocity Au
%vn=0.28e6*(h/(2*pi)); %tesis maria 1.38e6
Kb=1.38e-23; %boltzman constant
ED=380*Kb;%*2*pi/h; %Debye energy for molibdenum.in units of hbar=1.

%Tc0=0.790;
%Tc0=1.1;
%variables:
tauN=2*pi*vn*dn./(t*vs^2);
tauS=2*pi*ds./(t*vs);
%tau_inv=1./tauS+1./tauN%debug.
% Kf=(2*pi/t)*(Lf/2)^2;
% tauN=Kf*dn*nn;
% tauS=Kf*ds*ns;
% tau_inv=1./tauS+1./tauN

%ec.30 fominov. psi is the digamma function. ojo a las unidades. multiplico
%Tc*Kb en psi respecto a fominov.
%solve('log(Tc0/Tc)=tauN./(tauN+tauS).*(psi(1/2+(tauN+tauS)./(2*pi*Tc*tauN.*tauS))-psi(1/2)-log(sqrt(1+((tauN+tauS)./(tauN.*tauS*ED)).^2)))','Tc');
%solve('psi(1/2+(tauN+tauS)/(2*pi*Tc*Kb*tauN*tauS))-(1+tauS/tauN)*log(Tc0/Tc)=psi(1/2)+log(sqrt(1+((tauN+tauS)/(tauN*tauS*ED))^2))','Tc')
%x=(tauN+tauS)./(2*pi*Tc0*Kb*(tauN.*tauS))
%y=(tauN+tauS)./(tauN*tauS*ED)
%resolucion numerica ec(30)Tc(t) a campo cero.
T=0:1e-3:2;
f1=-1.9635+log(sqrt(1+((tauN+tauS)./(tauN*tauS*ED)).^2));%psi(1/2)=-1.9635
f2=psi(1/2+(tauN+tauS)./(2*pi*T*Kb*(tauN.*tauS)))-(1+tauS./tauN).*log(Tc0./T);
Tc=T(find((abs(f1-f2))==min(abs(f1-f2))));
% 
% %resolucion numerica ec(79) Hc2(T)
% Hmax=500/1e4;%definir el valor del campo maximo. unidades?gauss=1e4*Tesla.
% %Th=Tc/2;
% H=0:Hmax/1e6:Hmax;
% sn=50e8; %conductividad del Au a 1K en (ohm*m)^-1
% ss=15e8; %valor razonable? para la conductividad del Mo a 1K.
% %'hola'
% Es=ss*H/(ns*e)*1+1/tauS;%check units.2*pi/h
% %Es([1:10]),1/tauS
% En=sn*H/(nn*e)*1+1/tauN;
% %En([1:10]),1/tauN
% %'hola'
% f3=log(Tc0/Th)+(tauN/(tauS+tauN))*log(sqrt(1+((tauN+tauS)/(tauN*tauS*ED))^2))+psi(1/2);
% sq1=sqrt((Es-En).^2+4/(tauS*tauN));
% f4=(1+(Es-En)./sq1).*psi(.5+(Es+En+sq1)/(4*pi*Th*Kb))/2;%ojo units.
% f5=(1-(Es-En)./sq1).*psi(.5+(Es+En-sq1)/(4*pi*Th*Kb))/2;
% %size(H),size(f3),size(f4),size(f5)
% %figure,plot(H,f3*ones(length(H)),H,f4+f5)
% min(abs(f3-f4-f5));
% Hc2=H(find((abs(f3-f4-f5))==min(abs(f3-f4-f5))))*1e4;%Hc2 en gauss

