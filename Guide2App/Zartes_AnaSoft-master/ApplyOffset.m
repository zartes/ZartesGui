function IVset=ApplyOffset(auxS,circuit)
%%funcion para aplicar un offset a las IVs.
%suponemos que se han centrado previamente en el cero.
%%%eligiendo ioff y voff se puede usar para aplicar voff vertical o
%%%desplazamiento a lo largo de mS (o mN).

IVset=auxS;
if isfield(circuit,'ioffset')
    ioff=circuit.ioffset;
else
    ioff=0;
end

m=circuit.mS;%%Dependiendo de la forma de corregir, podemos aplicar mS o mN.

if isfield(circuit,'voffset')
    voff=circuit.voffset;
else
    voff=ioff*m;
end
for i=1:length(auxS) %%%si lo aplico al IVset completo hay que hacer bucle.
    IVset(i).ibias=auxS(i).ibias-ioff;
    IVset(i).vout=auxS(i).vout-voff;
    IVset(i).ioffset=ioff;
end