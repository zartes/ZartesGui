function Hc2=plotHc2(dn,ds,t)
%plotHc2(dn(nm),ds(nm),t)
Tc=usadelTc(dn,ds,t);
T=0:1e-2:Tc;
Hc2=zeros(1,length(T));
for i=1:length(T), haux=usadelHc2(dn,ds,t,T(i));if(~isempty(haux))Hc2(i)=haux;end, end
plot(T,Hc2)