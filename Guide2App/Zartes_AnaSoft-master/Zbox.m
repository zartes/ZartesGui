function zbox=Zbox(f)
%función de transferencia de la Ibox de magnicon.
Rbox=1e4;
Lbox=2e-3;
Cbox=100e-12;
Rp=200;

Zp=Rp+1./(Cbox*2*pi*f*1i);
Zbox=(Rbox*Zp)./(Rbox+Zp)+2*pi*f*1i*Lbox;