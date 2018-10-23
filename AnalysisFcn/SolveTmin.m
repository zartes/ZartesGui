function Tmin=SolveTmin(TES,R0,Tbath)
%
%Tbath=0e-3;
K=TES.K;n=TES.n;Ic0=TES.Ic0;Tc=TES.Tc;
syms x
Tmin=vpasolve(K*(x.^n-Tbath^n) ==Ic0^2*R0*(1-x/Tc).^3);