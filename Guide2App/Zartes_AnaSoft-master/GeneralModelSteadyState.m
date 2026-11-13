function F=GeneralModelSteadyState(X,Ib,Tb)

%Electric parameters
%Rs=2e-3;Rpar=0.5e-3;
%K=1e-8;

%TES parameters
N=3.2;%adimensional.
Tc=0.1;Ic=1e-3;
%X(2)=X(2)/Tc;X(1)=X(1)/Ic;

%change units.
Rs=2;Rpar=0.4;Rth=Rs+Rpar;
Rn=20;
%K=1e-2/10^(1*N);%3-1
K=1e-11;

%Operating Point
%Ib=1000e-6;
%Tb=80e-3;

F(1)=Ib/Ic-(X(1)/Ic)*(Rth+Rn*FtesTI(X(2)/Tc,X(1)/Ic))/Rs;%divido por Ic*Rs
F(2)=((X(1)/Ic)^2)*Rn*FtesTI(X(2)/Tc,X(1)/Ic)/Rs-(Tc^N)*K*((X(2)/Tc)^N-(Tb/Tc)^N)/(Ic^2*Rs);