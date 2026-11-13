function tfq=TFQuotient(L,f,circuit)
%%%Devuelve la parte imaginaria de TFS/TFN para hacer fit de L.
Rsh=circuit.Rsh;%2e-3;
%TES.
%Rn=0.1063;%25e-3;
%Rpar=7.3546e-05;%0.12e-3;
Rn=circuit.Rn;
Rpar=circuit.Rpar;
Rth=Rsh+Rpar;

%f=logspace(1,6,100);
%tfq=(Rth+Rn+1i*2*pi*f*L)./(Rth+1i*2*pi*f*L);
zs=Rth+1i*2*pi*f*L;
tfq=imag(1+Rn./zs);%%%tfs/tfn