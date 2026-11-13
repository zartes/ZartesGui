function TES=BuildTESStructFromRp(rp,Gset)
%%%Genera la estructura TES a partir del Gset y de un porcentaje.

ind=find(round(100*[Gset.rp])==100*rp);%%%Ojo si rp no está entre el rango de valores de Gset.rp

TES=Gset(ind);
%Generalizar para P(T) de 1 o 2 terminos.
if isfield(TES,'K')
    TES.K=TES.K*1e-12;%En algunos modelos no esta definida.
end
TES.G=TES.G*1e-12;
TES.G100=TES.G100*1e-12;
TES.G0=TES.G;
TES.CN=100e-12;%default value.

vars=evalin('caller','who');

if sum(strcmp(vars,'circuit'))
    circuit=evalin('caller','circuit');
    TES.Rn=circuit.Rn;
end

if isfield(TES,'K')
    TES.Ttes=@(P,Tbath)((P./TES.K+Tbath.^(TES.n)).^(1./(TES.n)));
    TES.Gtes=@(Ttes)(TES.n*TES.K*Ttes.^(TES.n-1));
end
if isfield(TES,'Ns')
    TES.Ttes=@(P,Tbath)(fzero(@(x) A*(x.^4-Tbath.^4)+B*(x-Tbath)-P,TES.Tc));
    TES.Gtes=@(Ttes)(TES.Ns(1)*TES.A*Ttes.^(TES.Ns(1)-1)+...
        TES.Ns(2)*TES.B*Ttes.^(TES.Ns(2)-1));
end