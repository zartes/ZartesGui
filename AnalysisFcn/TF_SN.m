function [tfs,tfn]=TF_SN(f,L,TFout)
%funcion para calcular las TF en esatado superconductor y normal teniendo
%en cuenta la Ibox. Ojo a todas estas funciones, tengo que separar la
%definicion de los parametros, estan reoetidas.

Rsh=2e-3;
%TES.
Rn=25e-3;
Rpar=0.11e-3;
Rth=Rsh+Rpar;

Rf=1e4;%OJO!
invMf=66;
invMin=24.1;

zs=Rth+1i*2*pi*f*L;
zn=Rn+zs;

Rbox=1e4;
Lbox=2e-3;
Cbox=100e-12;
Rp=200;

Zp=Rp+1./(Cbox*2*pi*f*1i);
zbox=(Rbox*Zp)./(Rbox+Zp)+2*pi*f*1i*Lbox;
TFibox=1./(zbox.*(1+Rbox./Zp));
%TFout=1;%si es conocida puedo incluirla.
NUM=Rf*(invMf/invMin).*TFout.*TFibox*Rsh;
tfs = NUM./zs;
tfn = NUM./zn;
