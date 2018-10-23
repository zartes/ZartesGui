function Rpar=RparCalc(ms,circuit)
%calculo de la Rpar a partir de la pendiente experimental en estado
%superconductor (ms=Vout/Ibias)

invMf=circuit.invMf;%66;
invMin=circuit.invMin;%24.1;
Rsh=circuit.Rsh;%2e-3;
Rf=circuit.Rf;
Rpar=(Rf*invMf/(ms*invMin)-1)*Rsh;