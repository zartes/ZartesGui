function varargout=plotTransitions(varargin) %T,R1,R2,ind
%version preliminar para pintar transiciones. Puede hacer falta pasar
%indices separados para cada canal y generalizar a varios ficheros. Tambien
%añadir el fit.

if nargin==0
    [~,data]=loadppms();
    T=data.T;R1=data.R1;R2=data.R2;ind=1:length(data.T);
    fit=0;
    varargout{1}=data;
    hold off;
else
    data=varargin{1};
    T=data.T;R1=data.R1;R2=data.R2;ind=data.ind;
    p01=varargin{2}.p01;p02=varargin{2}.p02;
    fit=1;
end

plot(T(ind),R1(ind),'.')
hold on
plot(T(ind),R2(ind),'r.')
h=get(gca,'children');
set(h(1),'MarkerSize',15)
set(h(2),'MarkerSize',15)
grid on
set(gca,'fontsize',11)
set(gca,'fontweight','bold')
legend('R1','R2')
xlabel('T(K)')
ylabel('R(\Omega)')

%primera version para incluir tambien fit. De momento requiere poner
%manualmente los p0 y solo sirve para 2 CH.

if fit
    %definición manual de p0. Va mal con 'ere'.Mejorar.
   % p01=[0.1 0.89 0.01 1.7 0.9 0.01];
    %p01=[0.015 0.116 0.01 0.002];%%%p(4) es un offset para el dilucion.
    %p02=[0.1 0.96 0.01 1.1 0.97 0.01];
    %p02=[1.1 0.96 0.01 0.002];
    
    [p1,aux1,aux2,aux3,out]=lsqcurvefit(@fitTc,p01,T(ind),R1(ind));
    [p2,aux1,aux2,aux3,out]=lsqcurvefit(@fitTc,p02,T(ind),R2(ind));
    y=min(T(ind)):1e-4:max(T(ind));%remuestreamos para el fit.
    plot(y,fitTc(p1,y),'b');
    plot(y,fitTc(p2,y),'r');
    legend('R1','R2','fit R1','fit R2')
    varargout{1}=p1;
    varargout{2}=p2;
end
hold off