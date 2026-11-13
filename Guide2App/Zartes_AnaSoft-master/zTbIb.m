function [Tb,Ptes]=zTbIb(Circuit,IVset,rp)
%%Pintamos en el plano Tbath,Ibias los puntos con igual porcentaje de Rtes
for j=1:length(rp)
    %Tb=[];Ib=[];Ptes=[];
for i=1:length(IVset)
    IVaux=IVset(i);
    Tb(i)=IVaux.Tbath
    IVstraux=GetIVTES(Circuit,IVaux);
    ibrp=spline(IVstraux.rtes,IVstraux.ibias);
    ptrp=spline(IVstraux.rtes,IVstraux.ptes);
    Ib(j,i)=ppval(ibrp,rp(j));
    Ptes(i)=ppval(ptrp,rp(j));
end

plot(Tb,Ib,'o-'),hold on, grid on
%plot(Tb,Ptes,'.-r'),hold on, grid on
end

%griddata(Tb,rp,Ib,.077,.77)