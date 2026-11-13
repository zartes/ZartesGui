function ivsplit=SplitIV(IV)
%%%funcion para separar una IV en sus dos tramos Superconductor y
%%%transicion.
SslopeTHR=60e-6;%En los squids C7 hay doble slope superconductora. Hay que eliminar una parte para no distorsionar el fit.
for i=1:length(IV)
    d=(diff([IV(i).vout])./diff([IV(i).ibias])<0);%%%
    dd=diff(d);%%%El salto se produce donde se pasa de slope neg a pos.
    index=find(dd==-1);
    if isempty(index) index=length(IV(i).ibias);end
    ivsplit(i).transicion.ibias=IV(i).ibias(1:index);
    ivsplit(i).transicion.vout=IV(i).vout(1:index);
    ivsplit(i).Sstate.ibias=IV(i).ibias(index+1:end);
    ivsplit(i).Sstate.vout=IV(i).vout(index+1:end);
    Sslopeindex=find(abs(ivsplit(i).Sstate.ibias)<SslopeTHR);
    p=polyfit(ivsplit(i).Sstate.ibias(Sslopeindex),ivsplit(i).Sstate.vout(Sslopeindex),1);%%%El primer punto no suele ser bueno
    %p=polyfit(ivsplit(i).Sstate.ibias(2:end),ivsplit(i).Sstate.vout(2:end),1);%%%El primer punto no suele ser bueno
    ivsplit(i).mS=p(1);
end
