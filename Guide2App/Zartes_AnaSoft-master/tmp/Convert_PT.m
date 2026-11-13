function IVT=Convert_PT(IVP, TbathArray)
%%%Convertir IV a Ptes fija en IV set estándar a Tbath fijas.

for i=1:length(TbathArray)
    Tbath=TbathArray(i);
    for j=1:length(IVP)
        ind=find([IVP(j).Tbath]>0.04);
        if isempty(ind) ind=1;end
        minT=min([IVP(j).Tbath(ind)]);
        maxT=max([IVP(j).Tbath(ind)]);
        if minT>Tbath || maxT<Tbath 
        IVT(i).Ites(j)=0;
        IVT(i).Vtes(j)=0;
        IVT(i).Rtes(j)=0;
        IVT(i).Ttes(j)=0;
        IVT(i).Ptes(j)=0;
        else
        IVT(i).Ites(j)=interp1([IVP(j).Tbath(ind)],[IVP(j).Ites(ind)],Tbath);
        IVT(i).Vtes(j)=interp1([IVP(j).Tbath(ind)],[IVP(j).Vtes(ind)],Tbath);
        IVT(i).Rtes(j)=interp1([IVP(j).Tbath(ind)],[IVP(j).Rtes(ind)],Tbath);
        IVT(i).Ttes(j)=interp1([IVP(j).Tbath(ind)],[IVP(j).Ttes(ind)],Tbath);
        IVT(i).Ptes(j)=IVP(j).Ptes;
        end
    end
    IVT(i).Tbath=Tbath;
end