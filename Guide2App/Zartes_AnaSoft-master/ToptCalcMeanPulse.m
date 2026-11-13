function [Topt,ResT]=ToptCalcMeanPulse(MeanPulse)
%%%Calcular el Topt de integracion para un Mean pulse generico
%Generaliza ToptCalc del directorio de analisis de pulsos.
T=MeanPulse(:,1);
tini=0.1;
ResT=zeros(1,length(T));
dc=mean(MeanPulse(1:tini*length(T)/2,2));
for i=tini*length(T):length(T)
    ResT(i)=sqrt(T(i)-T(tini*length(T)))./trapz(MeanPulse(tini*length(T)-1:i,1),MeanPulse(tini*length(T)-1:i,2)-dc);
    %ResT(i)=trapz(MeanPulse(tini*length(T)-1:i,1),MeanPulse(tini*length(T)-1:i,2)-dc);
end
ResT(1)=ResT(2);
%plot(T,ResT)
[~,ii]=min(ResT(tini*length(T)+1:length(T)));
Topt=T(ii);%ojo,ese es el Topt desde tini, para Topt total sumar tini*Tend.