function cv=GoldCv(T)
%calor especifico del Au a temperatura T
R=8.31;
Ef=5.53; %eV
Tf=6.42e4; %k
TD=165; %K
d=19.3*1e6; %densidad en g/m^3
M=196.967; %masa molar en g/mol
%cve=8.31*pi^2*(.5*(T/Tf))
cv=8.31*pi^2*(.5*(T/Tf)+(12*pi^2/5)*(T/TD).^3); % J/K*mol
%definimos sensitivity as T/E (incremento de temperatura esperado para un
%determinado depósito de energía). De Q=cv(g)*m*T=E -> S=1/cv(g)*M
% m=d*A*h
A=(300e-6)^2; %area
h=3.500e-6;   %altura.
%S=M/(cv*d*A*h)*1.602e-19 *1e3; %K/keV
alfa=400;
Emax=10; %keV
Tc=0.1;%K
rango=8; %= 0.8Rn/0.1Rn (rango lineal / pto operacion). En tesis wouter usa 0.8Rn/0.5Rn=1.6;

hmin=1.602e-19 *1e3*(alfa*Emax/(rango*Tc))*M/(cv*d*A)
[cv*d*A*h/M,alfa*Emax*1.602e-19 *1e3/(rango*Tc)]














