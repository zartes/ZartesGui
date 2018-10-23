function Vout=I2V(ites,Rf)
%convert ites to Vout 
invMf=66;
invMs=24.1;
Vout=ites.*invMf*Rf/invMs;