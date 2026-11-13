function noise=noisesim(model,varargin)
%simulacion de componentes de ruido.
%de donde salen las distintas componentes de la fig13.24 de la pag.201 de
%la tesis de maria? ahi estan dadas en pA/rhz.
%Las ecs 2.31-2.33 de la tesis de Wouter dan nep(f) pero no tienen la
%dependencia con la freq adecuada. Cuadra m谩s con las ecuaciones 2.25-2.27
%que de hecho son ruido en corriente.
%La tesis de Maria hce referencia (p199) al cap铆tulo de Irwin y Hilton
%sobre TES en el libro Cryogenic Particle detection. Tanto en ese cap铆tulo
%como en el Ch1 de McCammon salen expresiones para las distintas
%componentes de ruido. 

%definimos unos valores razonables para los par谩metros del sistema e
%intentamos aplicar las expresiones de las distintas referencias.

gamma=0.5;
Kb=1.38e-23;


%f=1:1e6;
f=logspace(0,6,1000);

if nargin==1
    C=2.3e-15;%p220
    L=77e-9;%400e-9;%inductancia. arbitrario.
    G=310e-12;%1.7e-12;% p220 maria.
    alfa=1;%arbitrario.
    bI=0.96;%p220
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
    M=1;
    Nsquid=3e-12;
    n=3;
else
    TES=varargin{1};
    OP=varargin{2};
    
    %%%%test. Podemos pasar la Ztes experimental del OP como ztes.data
    %%%%ztes.freqs.
    if isfield(OP,'ztes') zexp=interp1(OP.ztes.freqs,OP.ztes.data,f);end
    %%%%

    Circuit=varargin{3};
    %C=TES.OP.C;
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
    M=0;
    %%%Ojo, usaba Nsquid como campo de ruido del squid y si no 3e-12 por
    %%%defecto!
    if isfield(Circuit,'squid') Nsquid=Circuit.squid;else Nsquid=3e-12;end
    if abs(OP.Z0-OP.Zinf)<1.5e-3, 
        %R0=0; L0=0;V0=0;P0=0;
        I0=(Rs/RL)*OP.ibias;
    end
end
if nargin==5
    M=varargin{4};
end

tau=C/G;
taueff=tau/(1+beta*L0);
tauI=tau/(1-L0);
tau_el=L/(RL+R0*(1+bI));

Fmodel='ballistic';%'ballistic';%'diffusive', '1'.
%Modelo de 'F' para 1TB y 2TBhanging.
t=Ts/T0;
switch Fmodel
    case 'ballistic'
        F=(t^(n+1)+1)/2;
    case 'diffusive'
        F=n*(t^(2*n+1)-1)/((2*n+1)*(t^n-1));
    case '1'
        F=1;
        warning('Ojo, usando F=1 en el modelo de ruido');
end
switch model
    case 'wouter'
    %%%ecuaciones 2.25-2.27 Tesis de Wouter.
    i_ph=sqrt(4*gamma*Kb*T0^2*G)*alfa*I0*R0./(G*T0*(R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));
    i_jo=sqrt(4*Kb*T0*R0)*sqrt(1+4*pi^2*tau^2.*f.^2)./((R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));
    i_sh=sqrt(4*Kb*Ts*Rs)*sqrt((1-L0)^2+4*pi^2*tau^2.*f.^2)./((R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));%%%
    noise.ph=i_ph;noise.jo=i_jo;noise.sh=i_sh;noise.sum=sqrt(i_ph.^2+i_jo.^2+i_sh.^2);

    case {'irwin','default'}
    %%% ecuaciones capitulo Irwin
    func=@(p,f)([p(1)-(p(1)-p(2))./(1+((2*pi*f).^2)*(p(3).^2)) ...
                    -abs(-(p(1)-p(2))*(2*pi*f)*p(3)./(1+((2*pi*f).^2)*(p(3).^2)))]);
                if nargin>1
                    p0=[OP.Zinf OP.Z0 OP.P.taueff];%%%Ojo a OP, no incluye taueff
                    zdata=func(p0,f);%%%p0=[p1 p2 p3 p4 p5];!!!!!ojo al formato!
                    ztes=zdata(1:end/2)+1i*zdata(end/2+1:end);
                    %ztes=zexp;
                    zcirc=ztes+RL+1i*2*pi*f*L;
                    sI=(ztes-R0*(1+bI))./(zcirc*V0*(2+bI));
                end
    sI=-(1/(I0*R0))*(L/(tau_el*R0*L0)+(1-RL/R0)-L*tau*(2*pi*f).^2/(L0*R0)+1i*(2*pi*f)*L*tau*(1/tauI+1/tau_el)/(R0*L0)).^-1;%funcion de transferencia.
    
    %sIHandle=@(f)-(1/(I0*R0))*(L/(tau_el*R0*L0)+(1-RL/R0)-L*tau*(2*pi*f).^2/(L0*R0)+1i*(2*pi*f)*L*tau*(1/tauI+1/tau_el)/(R0*L0)).^-1;%No
    %usado.
    
    %%%calculo factor F. See McCammon p11.
    %n=3.1;
    %t=Ts/T0;
    %F=t^(n+1)*(t^(n+2)+1)/2;%F de boyle y rogers. n= exponente de la ley de P(T). El primer factor viene de la pag22 del cap de Irwin.
    %%%%UPDATE.23-Oct-2019. Adem醩 de eliminar el factor t^(n+1) que era el
    %%%%responsable de que F tendiese a cero en lugar de 1/2 el uso del
    %%%%exponente estaba mal, las expresiones de McCammon no usan el 'n'
    %%%%nuestro, sino el exponente de la ley de G, es decir, 'n-1'. Esto
    %%%%cambia las expresiones y cambia la estimaci髇 de 'F', sobre todo a Tbath baja.
    %%%%De hecho, la diferencia entre el specular y el diffusive puede llegar tambi閚 al 10%
    %bb=n-1;
    %F=(t^(bb+2)+1)/2;%%%ballistic limit. Ojo a la definicion de 't'. McCammon:t=Tc/Tbath.
    %F=(bb+1)*(t^(2*bb+3)-1)/((2*bb+3)*(t^(bb+1)-1));%F de Mather.%diffusive limit
    %%%La diferencia entre las dos f贸rmulas es menor del 1%.
    %F=(n+1)*(t^(2*n+3)-1)/((2*n+3)*(t^(n+1)-1));%%%diffusive limit.
    
    stfn=4*Kb*T0^2*G*abs(sI).^2*F;%Thermal Fluctuation Noise
    ssh=4*Kb*Ts*I0^2*RL*(L0-1)^2*(1+4*pi^2*f.^2*tau^2/(1-L0)^2).*abs(sI).^2/L0^2; %Load resistor Noise
    %M=1.8;
    stes=4*Kb*T0*I0^2*R0*(1+2*bI)*(1+4*pi^2*f.^2*tau^2).*abs(sI).^2/L0^2*(1+M^2);%%%Johnson noise at TES.
    if ~isreal(sqrt(stes)) stes=zeros(1,length(f));end
    smax=4*Kb*T0^2*G.*abs(sI).^2;
    
    %sfaser=0;%21/(2*pi^2)*((6.626e-34)^2/(1.602e-19)^2)*(10e-9)*P0/R0^2/(2.25e-8)/(1.38e-23*T0);%%%eq22 faser
    %sext=(18.5e-12*abs(sI)).^2;
    
    NEP_tfn=sqrt(stfn)./abs(sI);
    NEP_ssh=sqrt(ssh)./abs(sI);
    NEP_tes=sqrt(stes)./abs(sI);
    Res_tfn=2.35/sqrt(trapz(f,1./NEP_tfn.^2))/2/1.609e-19;
    Res_ssh=2.35/sqrt(trapz(f,1./NEP_ssh.^2))/2/1.609e-19;
    Res_tes=2.35/sqrt(trapz(f,1./NEP_tes.^2))/2/1.609e-19;
    Res_tfn_tes=2.35/sqrt(trapz(f,1./(NEP_tes.*NEP_tfn)))/2/1.609e-19;
    Res_tfn_ssh=2.35/sqrt(trapz(f,1./(NEP_ssh.*NEP_tfn)))/2/1.609e-19;
    Res_ssh_tes=2.35/sqrt(trapz(f,1./(NEP_tes.*NEP_ssh)))/2/1.609e-19;
    
    NEP=sqrt(stfn+ssh+stes)./abs(sI);
    Res=2.35/sqrt(trapz(f,1./NEP.^2))/2/1.609e-19;%resoluci贸n en eV. Tesis Wouter (2.37).
    
    %stes=stes*M^2;
    i_ph=sqrt(stfn);
    i_jo=sqrt(stes); if ~isreal(i_jo) i_jo=zeros(1,length(f));end
    i_sh=sqrt(ssh);
    %G*5e-8
    %(n*TES.K*Ts.^n)*5e-6
    %i_temp=(n*TES.K*Ts.^n)*0e-6*abs(sI);%%%ruido en Tbath.(5e-4=200uK, 5e-5=20uK, 5e-6=2uK)
    
    noise.f=f;
    noise.ph=i_ph;noise.jo=i_jo;noise.sh=i_sh;noise.sum=sqrt(stfn+stes+ssh);%noise.sum=i_ph+i_jo+i_sh;
    noise.sI=abs(sI);noise.NEP=NEP;noise.max=sqrt(smax);noise.Res=Res;%noise.tbath=i_temp;
    noise.Res_tfn=Res_tfn; noise.Res_ssh=Res_ssh; noise.Res_tes=Res_tes;
    noise.Res_tfn_tes=Res_tfn_tes;noise.Res_tfn_ssh=Res_tfn_ssh;noise.Res_ssh_tes=Res_ssh_tes;
    noise.squid=Nsquid;noise.squidarray=Nsquid*ones(1,length(f));

    case '2TB_hanging'
        %model=BuildThermalModel('2TB_1');
        %func=model.function;
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
        %t=Ts/T0;
        %bb=n-1;
        %F=(t^(bb+2)+1)/2;%%%specular limit
        %F=(bb+1)*(t^(2*bb+3)-1)/((2*bb+3)*(t^(bb+1)-1));%F de Mather.
        g0=G;
        g1=OP.P.g_1;
        stfn_b=4*Kb*T0^2*g0*abs(sI).^2*F;%%%ruido t閞mico al ba駉
        stfn_1=4*Kb*T0^2*g1*abs(sI).^2.*(w*tau_1).^2./(1+(w*tau_1).^2);%%%ruido termico absorbente-TES
        stes=(4*Kb*T0*R0*(1+2*bI)).*abs(ztes+R0).^2./(R0^2*(2+bI).^2*abs(zcirc).^2);%%%ruido johnson
        ssh=4*Kb*Ts*RL./abs(zcirc).^2;%%%johnson en la shunt
        
        NEP=sqrt(stfn_b+stfn_1+ssh+stes)./abs(sI);
        Res=2.35/sqrt(trapz(f,1./NEP.^2))/2/1.609e-19;%resoluci贸n en eV. Tesis Wouter (2.37).
        
        %%%...noise.definir estructura noise
        noise.f=f;
        noise.sI=abs(sI);
        noise.ph_b=sqrt(stfn_b);noise.ph_1=sqrt(stfn_1);noise.jo=sqrt(stes);noise.sh=sqrt(ssh);
        noise.sum=sqrt(stfn_b+stfn_1+stes+ssh);
        noise.NEP=NEP;noise.Res=Res;
        noise.squid=Nsquid;noise.squidarray=Nsquid*ones(1,length(f));
        
    case '2TB_intermediate'
        %model=BuildThermalModel('2TB_1');
        %func=model.function;
        func=@(p,f)[real(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)...
            imag(p(1)+(p(2)-p(1)).*(1+p(4)).*(1-1i*(2*pi*f)*p(3)+p(4)./(1+1i*(2*pi*f)*p(5))).^-1)];
        
        %param%!!!%%%necesitamos los p0 para ztes, RL, L, R0, bi, V0, Ts, T0, n,G, tau_1
        p0=OP.parray;
        tau_1=p0(5);
        zdata=func(p0,f);%%%p0=[p1 p2 p3 p4 p5];!!!!!ojo al formato!
        ztes=zdata(1:end/2)+1i*zdata(end/2+1:end);
        %figure(14),plot(ztes,'m')
        %ztes=zexp;%%%
        zcirc=ztes+RL+1i*2*pi*f*L;
        sI=(ztes-R0*(1+bI))./(zcirc*V0*(2+bI));
        w=2*pi*f;
        t=Ts/T0;
        T1=OP.P.T1;%%%Temperatura del bloque1
        t_1b=Ts/T1;%%%%cociente temperaturas bloque1/ba駉
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
        stfn_1b=P2_1b*abs(sI).^2*g_t_b^2*1./(1+(w*tau_1).^2);%%%ruido t閞mico de bloque 1 al ba駉
        stfn_t1=P2_t1*abs(sI).^2.*((1-g_t_b)^2+(w*tau_1).^2)./(1+(w*tau_1).^2);%%%ruido termico TES-bloque1
        stes=(4*Kb*T0*R0*(1+2*bI)).*abs(ztes+R0).^2./(R0^2*(2+bI).^2*abs(zcirc).^2)*(1+M^2);%%%ruido johnson
        ssh=4*Kb*Ts*RL./abs(zcirc).^2;%%%johnson en la shunt
        
        NEP=sqrt(stfn_1b+stfn_t1+ssh+stes)./abs(sI);
        Res=2.35/sqrt(trapz(f,1./NEP.^2))/2/1.609e-19;%resoluci贸n en eV. Tesis Wouter (2.37).
        
        %%%...noise.definir estructura noise
        noise.f=f;
        noise.sI=abs(sI);
        noise.ph_1b=sqrt(stfn_1b);noise.ph_t1=sqrt(stfn_t1);noise.jo=sqrt(stes);noise.sh=sqrt(ssh);
        noise.sum=sqrt(stfn_1b+stfn_t1+stes+ssh);
        noise.NEP=NEP;noise.Res=Res;
        noise.squid=Nsquid;noise.squidarray=Nsquid*ones(1,length(f));
        
     case '2TB_parallel'
        %model=BuildThermalModel('2TB_1');
        %func=model.function;
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
        %T1=OP.P.T1;%%%Temperatura del bloque1
        T1=T0;%%Suponemos los dos bloques a igual T.
        t_1b=Ts/T1;%%%%cociente temperaturas bloque1/ba駉
        t_t1=T1/T0;%%%% cociente temperaturas tes-bloque1
        bb=n-1;
        F_1b=(t_1b^(bb+2)+1)/2;%%%specular limit
        F_t1=(t_t1^(bb+2)+1)/2;%%%specular limit. Va a ser 1.
        F_tb=F_1b;%%%specular limit. Igual a Ftb
        %F=(bb+1)*(t^(2*bb+3)-1)/((2*bb+3)*(t^(bb+1)-1));%F de Mather.
        %F=(bb+1)*(t^(2*bb+3)-1)/((2*bb+3)*(t^(bb+1)-1));%F de Mather.
        g_t_b=OP.P.a;%%(este cociente se usa directamente en las expresiones)(ojo a la denominacion)
        
        g1b=OP.P.g_1b;
        gt1=OP.P.g_t1;
        gtb=OP.P.g_tb;
        P2_1b=4*Kb*T1^2*g1b*F_1b;
        P2_t1=4*Kb*T0^2*gt1*F_t1;
        P2_tb=4*Kb*T0^2*gtb*F_tb;
        
        gb_1b=OP.P.g_t1/(OP.P.g_t1+OP.P.g_1b);
        gb_t1=OP.P.g_1b/(OP.P.g_t1+OP.P.g_1b);%%=1-gb_1b
        stfn_1b=P2_1b*abs(sI).^2*gb_1b^2*1./(1+(w*tau_1).^2);%%%ruido t閞mico de bloque 1 al ba駉
        stfn_t1=P2_t1*abs(sI).^2.*(gb_t1^2+(w*tau_1).^2)./(1+(w*tau_1).^2);%%%ruido termico TES-bloque1
        stfn_tb=P2_tb*abs(sI).^2;%%%ruido termico TES-ba駉.
        stes=(4*Kb*T0*R0*(1+2*bI)).*abs(ztes+R0).^2./(R0^2*(2+bI).^2*abs(zcirc).^2);%%%ruido johnson
        ssh=4*Kb*Ts*RL./abs(zcirc).^2;%%%johnson en la shunt
        
        NEP=sqrt(stfn_1b+stfn_t1+stfn_tb+ssh+stes)./abs(sI);
        Res=2.35/sqrt(trapz(f,1./NEP.^2))/2/1.609e-19;%resoluci贸n en eV. Tesis Wouter (2.37).
        
        %%%...noise.definir estructura noise
        noise.f=f;
        noise.sI=abs(sI);
        noise.ph_1b=sqrt(stfn_1b);noise.ph_t1=sqrt(stfn_t1);noise.ph_tb=sqrt(stfn_tb);noise.jo=sqrt(stes);noise.sh=sqrt(ssh);
        noise.sum=sqrt(stfn_1b+stfn_t1+stes+ssh);
        noise.NEP=NEP;noise.Res=Res;
        noise.squid=Nsquid;noise.squidarray=Nsquid*ones(1,length(f));
        
    otherwise
        error('no valid model')
end
