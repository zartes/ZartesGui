function IVP=Convert(IVT, Parray)
%%%Convertir IV a Tbath fija en IV set a Pfija

for i=1:length(Parray)
    Pw=Parray(i);
    for j=1:length(IVT)
        IVP(i).Ites(j)=interp1([IVT(j).Ptes],[IVT(j).Ites],Pw);
        IVP(i).Vtes(j)=interp1([IVT(j).Ptes],[IVT(j).Vtes],Pw);
        IVP(i).Rtes(j)=interp1([IVT(j).Ptes],[IVT(j).Rtes],Pw);
        IVP(i).Ttes(j)=interp1([IVT(j).Ptes],[IVT(j).Ttes],Pw);
        IVP(i).Tbath(j)=IVT(j).Tbath;
    end
end
