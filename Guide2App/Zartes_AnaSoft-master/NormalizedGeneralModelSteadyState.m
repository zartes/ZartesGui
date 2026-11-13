function [F,J]=NormalizedGeneralModelSteadyState(x,ib,tb,A,rp,rn,n)
%Función para resolver las ecuaciones electricas y termicas en estado
%estacionario despues de adimensionalizar.
%A=Tc^n*K/(Ic^2Rn). tb=Tb/Tc, ib=Ib/Ic, rp=Rp/Rsh, rn=Rn/Rsh. x(1)=it
%(corriente del TES normalizada). x(2)=tt (temperatura del TES
%normalizada).


%x=abs(x);
%adimensional but ill-conditioned?
F(1)=ib-(1+rp+rn*FtesTI(x(2),x(1)))*x(1);%normalizando a Rsh
%F(1)=ib*rsh-(rsh+rp+FtesTI(x(2),x(1)))*x(1);%Normalizando a Rn
%F(2)=FtesTI(x(2),x(1))*x(1).^2-A*(x(2).^n-tb.^n);
F(2)=ib*x(1)/rn-(1+rp)*x(1).^2/rn-A*x(2).^n+A*tb.^n;%normalizando a Rsh
%F(2)=ib*rsh*x(1)-(rsh+rp)*x(1).^2-A*x(2).^n+A*tb.^n;%Normalizando a Rn

if nargout>1
[f,a,b]=FtesTI(x(2),x(1));
J(1,1)=-(1+rp+rn*f)-rn*b*f;
J(1,2)=-rn*x(1)*a*f/x(2);
J(2,1)=ib/rn-2*(1+rp)*x(1)/rn;
J(2,2)=-n*A*x(2)^(n-1);
end


%well-conditioned?u(1)=x(1)=ites; u(2)=x(2).^n=ttes^n;
% u(1)=x(1);u(2)=x(2).^n;
% ub=tb.^n;
% F(1)=ib-(1+rp+rn*FtesTI(log(u(2))/n,u(1)))*u(1);
% aux1=ib*u(1)/rn-A*u(2);
% aux2=A*ub-(1+rp)*u(1).^2/rn;
% F(2)=aux1+aux2;
% %F(2)=ib*u(1)/rn-(1+rp)*u(1).^2/rn-A*u(2)+A*ub;%t^n->u


%F(1)=Ib/Ic-(X(1)/Ic)*(Rth+Rn*FtesTI(X(2)/Tc,X(1)/Ic))/Rs;%divido por Ic*Rs
%F(2)=((X(1)/Ic)^2)*Rn*FtesTI(X(2)/Tc,X(1)/Ic)/Rs-(Tc^N)*K*((X(2)/Tc)^N-(Tb/Tc)^N)/(Ic^2*Rs);