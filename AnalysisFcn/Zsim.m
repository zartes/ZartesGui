%Complex Impedance test
%Se pinta la impedancia compleja a partir de valores simulados y exportados
%de Simulink

V0=Vtes.signals.values;
A=1e-7; %Tiene que coincidir con la Amplitud de la señal.
Ites=Vtes.signals.values./Rtes.signals.values;
DItes=max(Ites)-min(Ites);
I0=mean(Ites);
sp=(Ites(1)-I0)*DItes/2;
Z0=2*A/DItes;
Re=Z0*sqrt(1-sp^2);
Im=Z0*sp;
plot(Re,Im,'o')