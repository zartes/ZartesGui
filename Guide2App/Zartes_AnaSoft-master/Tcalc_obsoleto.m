%script para pintar martinis. obsoleto.
T0=0.915;    %Tc0 bulk del Molibdeno
T0mK=T0*1000;
ns=0.29e29/1.602e-19; %densidad de estados pasado a st/Jm3
Lf=0.524e-9; %longitud de fermi en Au
Kb=1.38e-23; %cte boltzman
d0=1./((pi/2)*(T0*ns*Lf^2*Kb));

ds=1e-9:1e-9:300e-9;  %espesor molibdeno
%ds=100e-9;
%dn=15e-9:50e-9:1115e-9; %espesor Au
dn=7015e-9;%
nn_nonits=0.107;
ns_nounits=0.29;
%alfa=dn*nn_nounits./(ds*ns_nounits);
Gk=7.748e-5;  %quantum conductance as 2*e2/h
sn=50e8; %conductividad del Au a 1K en (ohm*m)^-1

[Dn,Ds]=meshgrid(dn,ds);
t=0.1;
bool=1;
tprime=1./(1/t+ bool*dn*Gk/(3*sn*(Lf/2)^2));  %0.32;
t2=1./(1/t+(1/3).*(ds*60/(130*13e-9)+(dn*5.8/(10.5*40.5e-9))));
%alfa=Dn*nn_nounits./(Ds*ns_nounits);
alfa=dn*nn_nounits./(ds*ns_nounits);
%alfa./(1+alfa)
Tc=T0.*(ds./(d0*1.13*(1+1./alfa).*tprime)).^alfa;

ds1=dn*nn_nounits./((1/(1/.8-1))*ns_nounits);
Tc1=T0.*(ds1./(d0*1.13*(1+1./1).*tprime)).^1;

tau=1;
%corch=1./((1+1./alfa)*(1+(E/tau)^2))
plot(ds,Tc)
hold on
%plot(ds1,Tc1,'o')
%mesh(Ds,Dn,Tc)
%plot(ds,alfa./(1+alfa))