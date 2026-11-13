function OutNoise=fitnoise(M,f,varargin)

% %%%funcion para tratar de ajustar el excess jhonson noise
% auxnoise=noisesim('irwin',TES,OP,circuit,M);
% ff=logspace(0,6,1000);
% for i=1:length(f)
% findx(i)= find((abs(ff-f(i)))==(min(abs(ff-f(i)))));
% end
% noise=auxnoise.sum(findx);
% size(noise)


%%%TES,OP,circuit
gamma=0.5;
Kb=1.38e-23;
model='irwin';
if nargin==2
    C=2.3e-15;%p220
    L=77e-9;%400e-9;%inductancia. arbitrario.
    G=310e-12;%1.7e-12;% p220 maria.
    alfa=1;%arbitrario.
    bI=0.96;%p220
    n=3.2;
    Rn=15e-3;%32.7e-3;%p220.
    Rs=1e-3;%Rshunt.
    Rpar=0.12e-3;%0.11e-3;%R parasita.
    RL=Rs+Rpar;
    R0=0.00000001*Rn;%pto. operacion.
    %R0=0.5*Rn;
    R0=Rn;
    beta=(R0-Rs)/(R0+Rs);
    T0=0.06;%0.42;%0.07
    Ts=0.06;%0.20;
    %P0=77e-15;
    %I0=(P0/R0)^.5;
    I0=50e-6;%1uA. deducido de valores de p220.
    V0=I0*R0;%
    P0=I0*V0;
    L0=P0*alfa/(G*T0);
else
    TES=varargin{1};
    OP=varargin{2};
    Circuit=varargin{3};
    %C=TES.OP.C;
    C=OP.C;
    L=Circuit.L;
    G=TES.G;
    %alfa=TES.OP.ai;
    alfa=OP.ai;
    %bI=TES.OP.bi;
    bI=OP.bi;
    Rn=TES.Rn;
    Rs=Circuit.Rsh;
    Rpar=Circuit.Rpar;
    RL=Rs+Rpar;
    R0=OP.R0;
    beta=(R0-Rs)/(R0+Rs);
    %T0=OP.T0;
    T0=TES.Tc;
    Ts=OP.Tbath
    P0=OP.P0;
    I0=OP.I0;
    V0=OP.V0;
    L0=P0*alfa/(G*T0);
    n=TES.n;
end

tau=C/G;
taueff=tau/(1+beta*L0);
tauI=tau/(1-L0);
tau_el=L/(RL+R0*(1+bI));

%f=1:1e6;
%f=logspace(0,6,1000);
if strcmp(model,'wouter')
%%%ecuaciones 2.25-2.27 Tesis de Wouter.
i_ph=sqrt(4*gamma*Kb*T0^2*G)*alfa*I0*R0./(G*T0*(R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));
i_jo=sqrt(4*Kb*T0*R0)*sqrt(1+4*pi^2*tau^2.*f.^2)./((R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2))*(1+M^2);
i_sh=sqrt(4*Kb*Ts*Rs)*sqrt((1-L0)^2+4*pi^2*tau^2.*f.^2)./((R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));%%%
noise.ph=i_ph;noise.jo=i_jo;noise.sh=i_sh;noise.sum=i_ph+i_jo+i_sh;

elseif strcmp(model,'irwin') 
%%% ecuaciones capitulo Irwin

sI=-(1/(I0*R0))*(L/(tau_el*R0*L0)+(1-RL/R0)-L*tau*(2*pi*f).^2/(L0*R0)+1i*(2*pi*f)*L*tau*(1/tauI+1/tau_el)/(R0*L0)).^-1;%funcion de transferencia.

t=Ts/T0;
%n=3.1;
%F=t^(n+1)*(t^(n+2)+1)/2;%F de boyle y rogers. n= exponente de la ley de P(T). El primer factor viene de la pag22 del cap de Irwin.
%F=t^(n+1)*(n+1)*(t^(2*n+3)-1)/((2*n+3)*(t^(n+1)-1));%F de Mather. La
%diferencia entre las dos fÃ³rmulas es menor del 1%.
F=(t^(n+2)+1)/2;%%%specular limit. OJO! la expresion que usaba de Irwin no tiende a 1/2!!! 
stfn=4*Kb*T0^2*G*abs(sI).^2*F*(1+M(1)^2);%Thermal Fluctuation Noise
ssh=4*Kb*Ts*I0^2*RL*(L0-1)^2*(1+4*pi^2*f.^2*tau^2/(1-L0)^2).*abs(sI).^2/L0^2; %Load resistor Noise
%M=1.8;
stes=4*Kb*T0*I0^2*R0*(1+2*bI)*(1+4*pi^2*f.^2*tau^2).*abs(sI).^2/L0^2*(1+M(2)^2);%%%Johnson noise at TES.
smax=4*Kb*T0^2*G.*abs(sI).^2;
sfaser=0;%21/(2*pi^2)*((6.626e-34)^2/(1.602e-19)^2)*(10e-9)*P0/R0^2/(2.25e-8)/(1.38e-23*T0);%%%eq22 faser


% NEP=sqrt(stfn+ssh+stes)./abs(sI);
% Res=2.35/sqrt(trapz(f,1./NEP.^2))/2/1.609e-19;%resoluciÃ³n en eV. Tesis Wouter (2.37).
% M=1.;

%stes=stes*M^2;
i_ph=sqrt(stfn);
i_jo=sqrt(stes);
i_sh=sqrt(ssh);
%G*5e-8
%(n*TES.K*Ts.^n)*5e-6
i_temp=(n*TES.K*Ts.^n)*0e-6*abs(sI);%%%ruido en Tbath.(5e-4=200uK, 5e-5=20uK, 5e-6=2uK)
%NEP=sqrt(smax+ssh+stes)./abs(sI);%%%Si ajusto sólo Mjo forzando Mph para stfn=smax.
NEP=sqrt(stfn+ssh+stes)./abs(sI);

i_squid=3e-12;
noise.ph=i_ph;noise.jo=i_jo;noise.sh=i_sh;noise.sum=sqrt(smax+stes+ssh+i_temp.^2+sfaser+i_squid^2);%noise.sum=i_ph+i_jo+i_sh;
noise.sI=abs(sI);
noise.NEP=NEP;
noise.max=sqrt(smax);
%noise.Res=Res;
noise.tbath=i_temp;
OutNoise=noise.NEP*1e18;
elseif strcmp(model,'2TB_1')
    func=@(p,f)[real(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)...
                 imag(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)];
    
    %param%!!!%%%necesitamos los p0 para ztes, RL, L, R0, bi, V0, Ts, T0, n,G, tau_1
    p0=OP.parray;
    tau_1=p0(5);
    zdata=func(p0,f);%%%p0=[p1 p2 p3 p4 p5];!!!!!ojo al formato!
    ztes=zdata(1:end/2)+1i*zdata(end/2+1:end);
    zcirc=ztes+RL+1i*2*pi*f*L;
    sI=(ztes-R0*(1+bI))./(zcirc*V0*(2+bI));
    w=2*pi*f;
    t=Ts/T0;
    F=(t^(n+2)+1)/2;%%%specular limit
    stfn_b=4*Kb*T0^2*G*abs(sI).^2*F;%%%ruido térmico al baño
    stfn_1=4*Kb*T0^2*G*abs(sI).^2.*(w*tau_1).^2./(1+(w*tau_1).^2);%%%ruido termico absorbente-TES
    stes=(4*Kb*T0*R0*(1+2*bI)).*abs(ztes+R0).^2./(R0^2*(2+bI).^2*abs(zcirc).^2)*(1+M^2);%%%ruido johnson
    ssh=4*Kb*Ts*RL./abs(zcirc).^2;%%%johnson en la shunt
    
    NEP=sqrt(stfn_b+stfn_1+ssh+stes)./abs(sI);
    OutNoise=NEP*1e18;
else
    error('no valid model')
end