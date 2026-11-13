function im_tfq=fitLfcn(P,f,circuit)
%%%función para ajustar la L del circuito a partir de la tfs y tfn.

L=P(1);
Rn=P(2);
Rsh=circuit.Rsh;
%Rn=circuit.Rn;
Rpar=circuit.Rpar;
Rth=Rsh+Rpar;

zs=Rth+1i*2*pi*f*L;
tfq=1+Rn./zs;
im_tfq=imag(tfq);