function Vout=I2V(ites,circuit)
%convert ites to Vout 
%invMf=66;
%invMs=24.1;
Rf=circuit.Rf;
invMf=circuit.invMf;
invMin=circuit.invMin;
Vout=ites.*invMf*Rf/invMin;