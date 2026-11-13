function plotusadel(dn,t,Tc0)
%plotusadel(dn(nm),t,Tc0(mK))
%pintamos las soluciones de Usadel en función de dMo para valores de dn y t
%se pasa dn en nm. 
for i=1:500,Tc(i)=usadelTc(i,dn,t,Tc0);end
%plot(Tc*1e3,'r')
plot(Tc,'r')