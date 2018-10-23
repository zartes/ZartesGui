function tfq=TFQuotient(f,L)

Rsh=2e-3;
%TES.
Rn=25e-3;
Rpar=0.12e-3;
Rth=Rsh+Rpar;

%f=logspace(1,6,100);
%tfq=(Rth+Rn+1i*2*pi*f*L)./(Rth+1i*2*pi*f*L);
zs=Rth+1i*2*pi*f*L;
tfq=1+Rn./zs;