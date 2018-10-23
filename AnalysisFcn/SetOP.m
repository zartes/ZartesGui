function NEWparam=SetOP(T0,I0,TESparam)

NEWparam=TESparam;
n=NEWparam.n;
K=NEWparam.K;
[r,a,b]=FtesTI(T0/TESparam.Tc,I0/TESparam.Ic);
NEWparam.alfa=a;
NEWparam.beta=b;
NEWparam.R0=NEWparam.Rn*r;
NEWparam.I0=I0;
NEWparam.T0=T0;
lg=(n-1)*log(T0)+log(n)+log(K);
NEWparam.G=exp(lg);
%NEWparam.G=n*K*T0.^(n-1);