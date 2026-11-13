function s=SolveIbTb(Ib,Tb,ZTES18)
%%%numerical sol. electrothermal circuit.
p=0.82;
delta=0.1;
Tc=ZTES18.Tc;
Ic=ZTES18.Ic0;
Rn=ZTES18.Rn;
n=ZTES18.n;
K=ZTES18.K;

Rsh=2e-3;Rpar=0.6e-3;
%Ib=100e-6;Tb=80e-3;

syms x y;

%r==((x/Ic)^p+(y/Tc)^p)^(1/p);
%z==Rn*(erf((((x/Ic)^p+(y/Tc)^p)^(1/p)-1)/delta)+1)/2;

s=vpasolve(Ib*Rsh==x*(Rsh+Rpar+Rn*(erf((((x/Ic)^p+(y/Tc)^p)^(1/p)-1)/delta)+1)/2),x.^2*Rn*(erf((((x/Ic)^p+(y/Tc)^p)^(1/p)-1)/delta)+1)/2==K*(y.^n-Tb.^n));