function plotNSslopes(Tb,TES,Circuitparam)
Imin=0;Imax=1e-3;
Ib=Imin:1e-3*Imax:Imax;
%parametros
Rsh=Circuitparam.Rsh;
Rpar=Circuitparam.Rpar;
Rn=TES.Rn;
n=TES.n;
K=TES.K;

%N state
ItN=Ib*Rsh/(Rsh+Rpar+Rn);
TtN=(ItN.^2*Rn/K+Tb.^n).^(1/n);
%S state
ItS=Ib*Rsh/(Rsh+Rpar);
TtS=Tb*ones(1,length(Ib));

%[X,Y]=meshgrid(Trange,Irange);
%FtesTI(TtS/TES.Tc,ItS/TES.Ic)
Tt=TtS(FtesTI(TtS/TES.Tc,ItS/TES.Ic)<1e-1);
It=ItS(FtesTI(TtS/TES.Tc,ItS/TES.Ic)<1e-1);
Tt=[Tt TtN(FtesTI(TtN/TES.Tc,ItN/TES.Ic)>0.999)];
It=[It ItN(FtesTI(TtN/TES.Tc,ItN/TES.Ic)>0.999)];

ind=find(Tt<1.3*TES.Tc);
plot(Tt(ind),It(ind),'.r')