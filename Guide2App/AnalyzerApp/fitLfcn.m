function im_tfq=fitLfcn(L,f,TESDATA)
%%%función para ajustar la L del circuito a partir de la tfs y tfn.

Rsh = TESDATA.circuit.Rsh.Value;
Rn = TESDATA.TESParamP.Rn.Value;
% Rn=circuit.Rn;
Rpar = TESDATA.TESParamP.Rpar.Value;
Rth = Rsh+Rpar;

zs = Rth+1i*2*pi*f.*L;
tfq = 1+Rn./zs;
im_tfq = imag(tfq);