function Rps=BuildRpFromIbias(IVset,ibias)
%%%Función para devolver un vector de valores de Ibias en uA para unos %Rn dados
%%% v0: solo una IV
%%% v1: todo el IVset y devuelve IZvalues. falla.
%%% v1.1 añado unique al final y limpio comments.

for i=1:length(IVset)
    
    [iaux,ii]=unique(IVset.ibias,'stable');
    vaux=IVset.vout(ii);
    raux=IVset.rtes(ii);
    [~,i3]=min(diff(vaux)./diff(iaux));
    
    i3=i3-1;%
    %Ibs=spline(raux(1:i3),iaux(1:i3),rp)*1e6;
    Rps=spline(iaux(1:i3),raux(1:i3),ibias*1e-6);
    Rps(ibias*1e-6<iaux(i3))=0;%%%Los rps por debajo del mínimo van a dar Ibias absurdos.
    Rps=unique(Rps,'stable');%Puede haber varios Ibs en cero y eso ralentiza luego las medidas!

end