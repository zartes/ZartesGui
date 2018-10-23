function Res=Resmodel(T0,Ts)
%%maasilta NIM A 559 706-708 (2006) ec.5-6

%%strong fb limit
e=1.609e-19;
Kb=1.38e-23;
n=4;
alfa=200;
C=5e-12*T0;
NUM=T0.^(2*n)+T0.^(n-1).*Ts.^(n+1)-T0.^n.*Ts.^n-(Ts.^(2*n+1))./T0;
DEN=(T0.^n-Ts.^n).^2;
chi=2*(n/2)^(1/4)*(NUM./DEN).^(1/4)./sqrt(alfa);
Res=2.36*chi.*sqrt(Kb*C).*T0/e;