function Hc2=usadelHc2(dn,ds,t,Th)
%Intento de resolver numéricamente ec.(79) de Fominov para sacar el campo crítico.
... usadelHc2(dn(nm),ds(nm),t,Th(K)).
dn=dn*1e-9;ds=ds*1e-9; %convertimos a metros.


%constantes:
h=6.626e-34; %Planck's constant.
hb=h/(2*pi);
e=1.602e-19;
c=3e8;
Lf=0.524e-9; %Fermi length. 0.524e-9 en Au.
ns=0.29e29/e; %densidad de estados pasado a st/Jm3
nn=0.107e29/e;
vs=1/(ns*(Lf/2)^2); %fermi velocity Mo. in units of hbar=1.si no, dividir pot hbar.
vn=vs*nn/ns; %fermi velocity Au
Kb=1.38e-23; %boltzman constant
ED=380*Kb; %Debye energy for molibdenum.in units of hbar=1 o en julios.

Tc0=0.790;

%variables:
%tauN=2*pi*vn*dn./(t*vs^2); %fominov
%tauSF=2*pi*ds./(t*vs) %in J.
tauN=1./(2*t./(dn*nn*pi*(Lf)^2)); %martinis
tauS=1./(2*t./(ds*ns*pi*(Lf)^2)); %martinis
%numericamente coinciden.

% 
%resolucion numerica ec(79) Hc2(T)
oc=0.01256637061436; %conversion AT/m <-> Oersted.
Hmax=5;%definir el valor del campo maximo en AT/m
%Th=Tc/2;
H=Hmax/1e6:Hmax/1e6:Hmax;
%H=Hmax/1e3;
sn=1.7e8;% 1.7e8...50e8  %conductividad del Au a 1K en (ohm*m)^-1
ss=.16e8;% 0.16e8...15e8 %valor razonable? para la conductividad del Mo a 1K.
Ds=ss/(ns*e^2);
Dn=sn/(nn*e^2);
%sn*vn,vn
%ss*vs,vs
%1/tauN,1/tauS
%Es=1*1*H/(ns*e^1)+1/tauS;%check units.2*pi/h.. ss*H/(ns*e)
%En=1*1*H/(nn*e^1)+1/tauN;
Es=Ds*(e/(c))*H+1/tauS;%(vs/hb)%vs*ss
En=Dn*(e/(c))*H+1/tauN;%(vn/hb)

f3=log(Tc0/Th)+(tauN/(tauS+tauN))*log(sqrt(1+((tauN+tauS)/(tauN*tauS*ED))^2))-1.9635;%psi(1/2)
sq1=sqrt((Es-En).^2+4/(tauS*tauN));

%aproximate psi(x)=log(x)-0.5/x-1/(12*x^2)+1/(120*x^4)-1/(256*x^6)
%esta aproximación funciona para baja T, pero no con T->Tc. aunque reduce a
%1/3 aprox el tiempo de cálculo. ejecutar psi(x) cuesta bastante.
x1=.5+(Es+En+sq1)/(4*pi*Th*Kb);
%ps1=log(x1)-0.5./x1-1./(12*x1.^2)+1./(120*x1.^4)-1./(256*x1.^6);
f4=.5*(1+(Es-En)./sq1).*psi(x1); %psi(x1);%ojo units.
x2=.5+(Es+En-sq1)/(4*pi*Th*Kb);
%ps2=log(x2)-0.5./x2-1./(12*x2.^2)+1./(120*x2.^4)-1./(256*x2.^6);
f5=.5*(1-(Es-En)./sq1).*psi(x2); %psi(x2);
%size(H),size(f3),size(f4),size(f5)
%figure,plot(H,f3*ones(length(H)),H,f4+f5)
%min(abs(f3-f4-f5));
%plot(f3*ones(1,length(H))),hold on,plot(f4+f5,'r'),plot(f5,'k')
m=min(abs(f3-f4-f5));
Hc2=H(find((abs(f3-f4-f5))==m));%*oc;%Hc2 en oersted

%%aproximate expression for pho->inf
g1=log(Tc0/Th)-psi(0.5+(1)*(Ds*H/(ns*e*ss*vs))/(2*pi*Th*Kb));%2*pi/h
Haprx=H(find(abs(g1-psi(.5))==min(abs(g1-psi(.5)))))*oc;
