function im_tfq=fitLfcn(L,f,TESDATA)
%%%función para ajustar la L del circuito a partir de la tfs y tfn.

Rsh = TESDATA.circuit.Rsh;
Rn = TESDATA.TESP.Rn;
% Rn=circuit.Rn;
Rpar = TESDATA.TESP.Rpar;
Rth = Rsh+Rpar;

zs = Rth+1i*2*pi*f.*L;
tfq = 1+Rn./zs;
im_tfq = imag(tfq);