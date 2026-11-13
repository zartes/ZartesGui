function [tfs,tfn]=TF_SN(f,circuit,varargin)
%funcion para calcular las TF en esatado superconductor y normal teniendo
%en cuenta la Ibox. Ojo a todas estas funciones, tengo que separar la
%definicion de los parametros, estan repetidas.

Rsh=circuit.Rsh;%2e-3;
%TES.
Rn=circuit.Rn;%25e-3;
Rpar=circuit.Rpar;%0.11e-3;
Rth=Rsh+Rpar;

Rf=circuit.Rf;%1e4;
invMf=circuit.invMf;%66;
invMin=circuit.invMin;%24.1;
L=circuit.L;

zs=Rth+1i*2*pi*f*L;
zn=Rn+zs;

%Ibox parameters
Rbox=1e4;
Lbox=2e-3;
Cbox=100e-12;
Rp=200;

Zp=Rp+1./(Cbox*2*pi*f*1i);
zbox=(Rbox*Zp)./(Rbox+Zp)+2*pi*f*1i*Lbox;
TFibox=1./(zbox.*(1+Rbox./Zp));
if nargin>2
    TFout=varargin{1};
else
    TFout=1;%si es conocida puedo incluirla.
end

NUM=Rf*(invMf/invMin).*TFout.*TFibox*Rsh;
tfs.f = f;
tfs.tf = NUM./zs;
tfs.re = real(tfs.tf);
tfs.im = imag(tfs.tf);
tfn.f = f;
tfn.tf = NUM./zn;
tfn.re = real(tfn.tf);
tfn.im = imag(tfn.tf);
