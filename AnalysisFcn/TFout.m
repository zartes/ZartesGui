function tfout=TFout(TFSstr,circuit)
%funcion de transferencia del circuito de salida deducida a partir de
%medidas en estado superconductor y L.

Rsh=circuit.Rsh;
Rf=circuit.Rf;
invMf=circuit.invMf;
invMin=circuit.invMin;
L=circuit.L;
%TES.
Rn=circuit.Rn;
Rpar=circuit.Rpar;
Rth=Rsh+Rpar;

%IBOX
Rbox=1e4;
Lbox=2e-3;
Cbox=100e-12;
Rp=200;

f=TFSstr.f;
TFS=TFSstr.tf;

Zp=Rp+1./(Cbox*2*pi*f*1i);
zbox=(Rbox*Zp)./(Rbox+Zp)+2*pi*f*1i*Lbox;

zs=Rth+1i*2*pi*f*L;
TFibox=1./(zbox.*(1+Rbox./Zp));
tfout.tf = TFS .* zs ./ (Rf*(invMf/invMin)* TFibox*Rsh);
tfout.f=f;
tfout.re=real(tfout.tf);
tfout.im=imag(tfout.tf);

