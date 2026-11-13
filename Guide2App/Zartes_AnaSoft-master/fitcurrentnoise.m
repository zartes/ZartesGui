function pArHz=fitcurrentnoise(M,f,PARAMETERS,varargin)
%%%%Función para ajustar simultáneamente el ruido experimental
%%%%expresado en pArHz con la Mph y la Mjo al modelo de IRwin!
%%%Irwin: M(1)=Mph, M(2)=Mjo.
%%%2TB_intermediate: M(1)=Mph_t_1, M(2)=Mph_1_b, M(3)=Mjo.


Kb=1.38e-23;

OP=PARAMETERS.OP;
Circuit=PARAMETERS.circuit;
TES=PARAMETERS.TES;

if nargin==3
    model='default';
else
    model=varargin{1};
end

%%%%%%%%Parametros basicos
    C=OP.C;
    L=Circuit.L;
    
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
    
    Ts=OP.Tbath;
    P0=OP.P0;
    I0=OP.I0;
    V0=OP.V0;
    T0=TES.Tc;
    G=TES.G;
    if isfield(TES,'Ttes')
        T0=TES.Ttes(P0,Ts);
    end
    if isfield(TES,'Gtes')
        G=TES.Gtes(T0);
    end
    %T0=OP.T0;

    L0=P0*alfa/(G*T0);
    n=TES.n;
    %if isfield(Circuit,'Nsquid') Nsquid=Circuit.Nsquid;else Nsquid=3e-12;end
    if abs(OP.Z0-OP.Zinf)<1.5e-3, 
        %R0=0; L0=0;V0=0;P0=0;
        I0=(Rs/RL)*OP.ibias;
    end
    if isfield(Circuit,'squid')
        ssquid=Circuit.squid.^2*ones(1,length(f));
    else
        ssquid=(3e-12).^2*ones(1,length(f));
    end
     %if isfield('Circuit','circuitnoise')
     %    ssquid=Circuit.circuitnoise(:,2);
     %end
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

M=real(M);%forzamos valores reales.

if strcmp(model,'default')
    tau=C/G;
    taueff=tau/(1+beta*L0);
    tauI=tau/(1-L0);
    tau_el=L/(RL+R0*(1+bI));
    
    t=Ts/T0;
    F=(t^(n+1)+1)/2;%%%specular limit
    
    sI=-(1/(I0*R0))*(L/(tau_el*R0*L0)+(1-RL/R0)-L*tau*(2*pi*f).^2/(L0*R0)+1i*(2*pi*f)*L*tau*(1/tauI+1/tau_el)/(R0*L0)).^-1;
    
    if isfield(OP,'ztes')
        ztes=interp1(OP.ztes.freqs,OP.ztes.data,f);
        zcirc=ztes+RL+1i*2*pi*f*L;
        sI=(ztes-R0*(1+bI))./(zcirc*V0*(2+bI));
    end
    %F=1;M(1)=0;%%%para forzar Mph constante e igual al maximo de F.
    stfn=4*Kb*T0^2*G*abs(sI).^2*F*(1+M(1)^2);
    stes=4*Kb*T0*I0^2*R0*(1+2*bI)*(1+4*pi^2*f.^2*tau^2).*abs(sI).^2/L0^2*(1+M(2)^2);
    ssh=4*Kb*Ts*I0^2*RL*(L0-1)^2*(1+4*pi^2*f.^2*tau^2/(1-L0)^2).*abs(sI).^2/L0^2; %Load resistor Noise
    %size(ssquid)
    pArHz=1e12*sqrt(stfn(:)+stes(:)+ssh(:)+ssquid(:));
    %NEP=1e18*sqrt(stes+stfn+ssh)./abs(sI);
elseif strcmp(model,'2TB_intermediate')
            %model=BuildThermalModel('2TB_1');
        %func=model.function;
        func=@(p,f)[real(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)...
            imag(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)];
        
        %param%!!!%%%necesitamos los p0 para ztes, RL, L, R0, bi, V0, Ts, T0, n,G, tau_1
        p0=OP.parray;
        tau_1=p0(5);
        zdata=func(p0,f);%%%p0=[p1 p2 p3 p4 p5];!!!!!ojo al formato!
        ztes=zdata(1:end/2)+1i*zdata(end/2+1:end);
        ztes=ztes(:);
        %ztes=zexp;%%%
        zcirc=ztes+RL+1i*2*pi*f*L;
        sI=(ztes-R0*(1+bI))./(zcirc*V0*(2+bI));
        w=2*pi*f;
        t=Ts/T0;
        T1=OP.P.T1;%%%Temperatura del bloque1
        t_1b=Ts/T1;%%%%cociente temperaturas bloque1/baño
        t_t1=T1/T0;%%%% cociente temperaturas tes-bloque1
        bb=n-1;
        F_1b=(t_1b^(bb+2)+1)/2;%%%specular limit
        F_t1=(t_t1^(bb+2)+1)/2;%%%specular limit
        %F=(bb+1)*(t^(2*bb+3)-1)/((2*bb+3)*(t^(bb+1)-1));%F de Mather.
        %F=(bb+1)*(t^(2*bb+3)-1)/((2*bb+3)*(t^(bb+1)-1));%F de Mather.
        g_t_b=OP.P.a;%%(este cociente se usa directamente en las expresiones)(ojo a la denominacion)
        
        g_t1=OP.P.g_t1_0;
        g_1b=OP.P.g_1b;
        P2_1b=4*Kb*T1^2*g_1b*F_1b;%%%%%%Update.06/04/20. Estaba usando G de las IVs en lugar de g_1b y g_t1. Como afecta?
        P2_t1=4*Kb*T0^2*g_t1*F_t1;
        stfn_t1=P2_t1*abs(sI).^2.*((1-g_t_b)^2+(w*tau_1).^2)./(1+(w*tau_1).^2)*(1+M(1)^2);%%%ruido termico TES-bloque1
        stfn_1b=P2_1b*abs(sI).^2*g_t_b^2*1./(1+(w*tau_1).^2)*(1+M(2)^2);%%%ruido térmico de bloque 1 al baño
        stes=(4*Kb*T0*R0*(1+2*bI)).*abs(ztes+R0).^2./(R0^2*(2+bI).^2*abs(zcirc).^2)*(1+M(3)^2);%%%ruido johnson
        ssh=4*Kb*Ts*RL./abs(zcirc).^2;%%%johnson en la shunt
        pArHz=1e12*sqrt(stfn_1b+stfn_t1+stes+ssh+ssquid);
        %NEP=sqrt(stfn_1b+stfn_t1+ssh+stes)./abs(sI);
    
end