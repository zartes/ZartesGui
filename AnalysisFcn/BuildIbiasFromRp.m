function Ibs=BuildIbiasFromRp(IVset,rp)
%%%Función para devolver un vector de valores de Ibias en uA para unos %Rn dados
%%% v0: solo una IV
%%% v1: todo el IVset y devuelve IZvalues. falla.

for i=1:length(IVset)
    
    [iaux,ii]=unique(IVset.ibias,'stable');
    vaux=IVset.vout(ii);
    raux=IVset.rtes(ii);
    %itaux=IVset.ites(ii);
    %vtaux=IVset.vtes(ii);
    %paux=IVset.ptes(ii);
    [m,i3]=min(diff(vaux)./diff(iaux));
    %[m,i3]=min(diff(IV.vout)./diff(IV.ibias));%%%Calculamos el índice del salto de estado N->S.
    
%     OP.vout=ppval(spline(iaux(1:i3),vaux(1:i3)),Ib);
%     OP.ibias=Ib;

    %ind=find(IVset(i).rtes>0.01);
    %Ibs=round(spline(IVset(i).rtes(ind),IVset(i).ibias(ind),rp)*1e6);
    %Ibs=round(spline(raux(1:i3),iaux(1:i3),rp)*1e6);
    Ibs=spline(raux(1:i3),iaux(1:i3),rp)*1e6;
    
    %f=strcat('i',num2str(IVset(i).Tbath*1e3))
    %cmd=strcat('setfield(IZvalues,',f,',Ibs',');')
    %eval(cmd)
    %assignin('caller',cmd,Ibs)
end
