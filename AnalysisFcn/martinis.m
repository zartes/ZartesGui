function Tc=martinis(varargin);
%Formula de Martinis para bicapa de Mo/Au. 
%Si no se pasan todos los parámetros se toman unos por defecto
%T0=915mK, t=0.3, dn=115nm, ds=50nm
if nargin==0
    
    disp('martinis(ds(nm),dn(nm),t,Tc0(mK),bool);');
    disp('default: martinis(50,115,0.3,0.915,1)');
    
end
%Parametros de entrada por defecto
        dn=115e-9; %espesor oro por defecto;
        ds=50e-9; %espesor Mo por defecto.
        t=0.3; %transparencia por defecto
        T0=915; %Tbulk por defecto.
        bool=1; %0: formula simple, 1:formula con t'.
        RRRs=2;
        
%Parametros globales
ns=0.29e29/1.602e-19; %densidad de estados pasado a st/Jm3
nn=0.107e29/1.602e-19;
Lf=0.524e-9; %longitud de fermi en Au
Kb=1.38e-23; %cte boltzman

nn_nounits=0.107;
ns_nounits=0.29;
Gk=7.748e-5;  %quantum conductance as 2*e2/h
%%%Conductividades y resistividades%%%
sn=1.72e8;%50e8; %conductividad del Au a 1K en (ohm*m)^-1
ss=0.167e8;%15e8; %valor razonable? para la conductividad del Mo a 1K.
rhon=4.0e-9;%5.8e-9;
rhos=120e-9;%60e-9;
rhon0=10.5e-9;
rhos0=130e-9;
      
try
    ds=varargin{1}*1e-9;%pasamos input en nm, convertimos a metros
    dn=varargin{2}*1e-9;%pasamos input en nm, convertimos a metros
    t=varargin{3};
    T0=varargin{4}*1e-3;%pasamos input en mK, convertimos a K.
    bool=varargin{5};
    RRRs=varargin{6};
catch
    %ds;dn;t;T0;
end

%taumar= (t/(2*pi*(Lf/2)^2)*(1./(dn*nn)+1./(ds*ns)))%debug

%ds/ss,dn/sn;
[Ds,Dn]=meshgrid(ds,dn);
alfa=Dn*nn_nounits./(Ds*ns_nounits);
%dn*nn./(ds*ns);
d0=1./((pi/2)*(T0*ns*Lf^2*Kb));
%nch=2*(Dn+Ds)./Lf*1e15;%A
%d0=nch./((2*pi)*(Kb*T0*ns))

%tau=(2*t./(pi*Lf^2)).*(1./(Dn*nn)+1./(Ds*ns)),E=Kb*0,alfa
%tau/Kb
%(Lf^2)*1e6*ns*1.05e-34/(4*t)%resistivity in Fominov.
%(1+(tau/Kb/380)^2)
%integrand=(alfa./(1+alfa))*(1./(1+(E./tau)^2))

%tprime=1./(1./t + bool*Dn*Gk/(3*sn*(Lf/2)^2));%0.32;
%dn*Gk/(3*sn*(Lf/2)^2);
%t2=1./(1./t+bool*(1/3).*(ds*60/(130*13e-9)+(dn*5.8/(10.5*153e-9)))); %%ec. 11.3 tesis maria (11) de Martinis. 
%Se sustituye 0.0405um por 0.153...
%... con los valores de rho0 de la p156 de maria los 0.013um(13nm) y 0.153um(153nm) hay
%que cambiarlos por 6.8nm y 84.4nm.
%t2=1./(1./t + bool*((4/3)*Gk/Lf^2)*(Dn/sn+Ds/ss)); %Ojo a la def de Gk=2e^2/h. tb se define como e^2/h.
%RRRs=2.16;RRRn=5.96; %sustituimos el cociente de conductividades por los RRR. Podemos poner valores razonables y ver el efecto. 
%También se puede intentar dejar como parámetros libres.

%ss0=1.89e7; %(martinis: 1.89e7 (1/52.91e-9) maria:1/130e-9:0.77e7);
%fs=ss0/(4*Gk/(Lf)^2);
f=1/(4*Gk/(Lf)^2); %hay un factor 2 de diferencia con el Gk de Martinis.
%fs=f/rhos0;
%RRRn=2;%RRRn=2;
%rhon=60e-9;rhon0=rhon*RRRn;
%fn=f/rhon0;
%RRRs=rhos0/rhos;RRRn=rhon0/rhon;

%t2=1./(1./t+bool*(1/3).*(ds/(RRRs*fs)+dn/(RRRn*fn))); %+0*(dn/(RRRn*84.4e-9)) eliminamos la parte de dn en los ajustes porque esta sí es despreciable
t2=1./(1./t+bool*(1/3).*(ds*rhos+dn*rhon)/f);
% rho0s=130e-9(maria) -> f=6.8nm; rho0s=52.91 (martinis)-> f=16.75nm;
%t2=1./(1./t+bool*(1/3).*(ds/(RRRs*13e-9)+dn/(RRRn*152e-9)));

%size(Ds),size(alfa),size(t2)
Tc=T0.*(Ds./(d0*1.13.*(1+1./alfa).*t2)).^alfa;