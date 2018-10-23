function [TF,f]=TF_HP(Rtes,Rf,L)
%expected TF from the HP.TF=Vout/Vin
%En primera aproximación Zbox=Rk, pero si se tiene en cuenta la Lbox cambia
%un poco la TF esperada. También se puede añadir la RC en paralelo y se
%nota también un poco, pero sólo a alta frecuencia. 
%sólo funciona para estado normal y superconductor del TES.

invMs=24.1;
invMf=66;
Rsh=2e-3;
Rpar=0.11e-3;
Rth=Rsh+Rpar;
Rk=1e4;
Lbox=2e-3;
f=logspace(1,6,100);
%Zc de la ibox.
Rc=200;Cc=100e-12;
Zc=Rc+1./(2*pi*1i*f*Cc);
Zbox=Rk*Zc./(Rk+Zc)+2*pi*1i*f*Lbox;
TF=Rsh*Rf*(invMf/invMs)./Zbox./(Rth+Rtes+1i*2*pi*f*L)./(1+Rk./Zc);