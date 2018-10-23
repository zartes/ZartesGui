function [R,varargout]=fitTc(p,T) %,varargin
%p=(RR,Tc,DeltaT)
%R=p(1)*(atan(((T-p(2)))/p(3))+pi/2)/pi;
%alfaT4=T.*p3(3).*(atan((T-p3(2))/p3(3))+pi/2)./(p3(3)^2+(T-p3(3).^2);
%if nargin==3,
%    f=varargin{1};
%else
%    f='erf';
%end


f='erf'; %erf,e+r,exp, log,atan, asy.
if strcmp(f,'e+r')
    %p=[R0 Top DT];
    R=heaviside(T-p(2)).*(p(1)+p(1)*(T-p(2))/p(3))+p(1)*(1-heaviside(T-p(2))).*exp((T-p(2))/p(3));
    %si forzamos f(Tc)=g(Tc) y f'(Tc)=g'(Tc) se reduce de 5 a 3 parámetros los
    %2 ajustes.
    %T1/2=p(2)+p(3)*(Rn/(2*p(1))-1)
    param.alfai=p(2)/p(3);
    param.model='e+r';
end
if strcmp(f,'erf')
    %p=[Rn Tc1/2 DT offset];
    R=p(1)*(erf((T-p(2))/p(3))+1)/2+p(4);%%%
    param.alfaTc=2*p(2)/(sqrt(pi)*p(3));
    param.alfaT=2*T/(sqrt(pi)*p(3)).*(exp(-((T-p(2))/p(3)).^2))./(erf((T-p(2))/p(3))+1);
    param.alfaOp=2*(p(2)-p(3)/sqrt(2))/(p(3)*sqrt(pi*exp(1))*(1+erf(-1/sqrt(2))));
    param.model='erf';
    %defino en este caso alfaop como el alfa a la Temp a la que la segunda
    %derivada de la R(T) alcanza un extremo.
end
if strcmp(f,'log')
    R=p(1)./(1+exp(-(T-p(2))/p(3)));
    %DT(10-90)=2*p(3)*log(9);
    %alfa(T)=(R*T/(p(1)*p(3)))*exp(-(T-p(2))/p(3)); alfa(Tc)=p(2)/(2*p(3));
end
if strcmp(f,'exp')
    R=p(1)*(1-exp(-((T-p(2)))/p(3))).^2.*heaviside(T-p(2));
end
if strcmp(f,'atan')
    R=p(1)*(atan((T-p(2))/p(3))+pi/2)/pi;
    %alfaT4=T.*p(3).*(atan((T-p(2))/p(3))+pi/2)./(p(3)^2+(T-p(3).^2);
end
if strcmp(f,'asy')%pruebas con funciones asimétricas de pocos parámetros.
    %R=p(1)*(1-exp(-(T-p(2)).^2/(2*p(3)^2))).*heaviside(T-p(2cdf.rayleigh
    R=p(1)*(1-exp(-((T-p(2))/p(3)).^p(4))); %cdf.weibull
end
if strcmp(f,'ere')%exp + recta + exp. funcion a 6 parametros.
    %p=[R0,Tc1,D1,Rn,Tc2,D2];
    T3=p(5)-p(6)*log(p(3)*p(4)/(p(6)*p(1)));
    R=p(1)*(1-heaviside(T-p(2))).*exp((T-p(2))/p(3))+...
        p(1)*(heaviside(T-p(2))-heaviside(T-p(5))).*(1+(T-p(2))/p(3))+...
        p(4)*heaviside(T-p(5)).*(1-exp(-(T-T3)/p(6)));
    
    param.alfai=p(2)/p(3);
    param.model='ere';
end
varargout{1}=param;