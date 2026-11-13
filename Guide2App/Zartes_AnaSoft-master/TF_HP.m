function TF=TF_HP(Rtes,circuit)
%expected TF from the HP.TF=Vout/Vin
%En primera aproximación Zbox=Rk, pero si se tiene en cuenta la Lbox cambia
%un poco la TF esperada. También se puede añadir la RC en paralelo y se
%nota también un poco, pero sólo a alta frecuencia. 
%sólo funciona para estado normal y superconductor del TES.

f=logspace(1,5,1e6);

invMs=circuit.invMin;
invMf=circuit.invMf;
Rsh=circuit.Rsh;
Rpar=circuit.Rpar;
Rth=Rsh+Rpar;
Rf=circuit.Rf;
L=circuit.L;

Rk=1e4;
Lbox=2e-3;
%Zc de la ibox.
Rc=200;Cc=100e-12;
Zc=Rc+1./(2*pi*1i*f*Cc);
Zbox=Rk*Zc./(Rk+Zc)+2*pi*1i*f*Lbox;

TF.tf=Rsh*Rf*(invMf/invMs)./Zbox./(Rth+Rtes+1i*2*pi*f*L)./(1+Rk./Zc);
TF.f=f;
TF.re=real(TF.tf);
TF.im=imag(TF.tf);