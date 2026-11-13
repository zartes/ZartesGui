function Rn=RnCalc(mN,mS,circuit)
%calcula la Rn a partir de las pendientes en estado normal y
%superconductor.
%OJO, la Rf del fichero S puede ser distinta de la del fichero N.

Rpar=RparCalc(mS,circuit);
% Rsh=2e-3;
% invMs=24.1;
% invMf=66;
invMf=circuit.invMf;%66;
invMin=circuit.invMin;%24.1;
Rsh=circuit.Rsh;%2e-3;
Rf=circuit.Rf;
Rn=(Rsh*Rf*invMf/(mN*invMin)-Rsh-Rpar);

