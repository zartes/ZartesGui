function noise = noisesim(model,varargin)
%simulacion de componentes de ruido.
%de donde salen las distintas componentes de la fig13.24 de la pag.201 de
%la tesis de maria? ahi estan dadas en pA/rhz.
%Las ecs 2.31-2.33 de la tesis de Wouter dan nep(f) pero no tienen la
%dependencia con la freq adecuada. Cuadra más con las ecuaciones 2.25-2.27
%que de hecho son ruido en corriente.
%La tesis de Maria hce referencia (p199) al capítulo de Irwin y Hilton
%sobre TES en el libro Cryogenic Particle detection. Tanto en ese capítulo
%como en el Ch1 de McCammon salen expresiones para las distintas
%componentes de ruido.

%definimos unos valores razonables para los parámetros del sistema e
%intentamos aplicar las expresiones de las distintas referencias.

gamma = 0.5;
Kb = 1.38e-23;

if nargin == 1
    C = 2.3e-15;%p220
    L = 77e-9;%400e-9;%inductancia. arbitrario.
    G = 310e-12;%1.7e-12;% p220 maria.
    alfa = 1;%arbitrario.
    bI = 0.96;%p220
    Rn = 15e-3;%32.7e-3;%p220.
    Rs = 1e-3;%Rshunt.
    Rpar = 0.12e-3;%0.11e-3;%R parasita.
    RL = Rs+Rpar;
    %     R0 = 0.00000001*Rn;%pto. operacion.
    %R0 = 0.5*Rn;
    R0 = Rn;
    beta = (R0-Rs)/(R0+Rs);
    T0 = 0.06;%0.42;%0.07
    Ts = 0.06;%0.20;
    %P0 = 77e-15;
    %I0 = (P0/R0)^.5;
    I0 = 50e-6;%1uA. deducido de valores de p220.
    V0 = I0*R0;%
    P0 = I0*V0;
    L0 = P0*alfa/(G*T0);
    M = 1;
    Nsquid = 3e-12;
else
    TES = varargin{1};
    OP = varargin{2};
    Circuit = varargin{3};
    %C = TES.OP.C;
    C = OP.C;
    L = Circuit.L;
    G = TES.G;
    %alfa = TES.OP.ai;
    alfa = OP.ai;
    %bI = TES.OP.bi;
    bI = OP.bi;
    Rn = Circuit.Rn;
    Rs = Circuit.Rsh;
    Rpar = Circuit.Rpar;
    RL = Rs+Rpar;
    R0 = OP.R0;
    beta = (R0-Rs)/(R0+Rs);
    %T0 = OP.T0;
    T0 = TES.Tc;
    Ts = OP.Tbath;
    P0 = OP.P0;
    I0 = OP.I0;
    V0 = OP.V0;
    L0 = P0*alfa/(G*T0);
    n = TES.n;
    M = 0;
    if isfield(Circuit,'Nsquid')
        Nsquid = Circuit.Nsquid;
    else
        Nsquid = 3e-12;
    end
    if abs(OP.Z0-OP.Zinf) < 1.5e-3
        %R0 = 0; L0 = 0;V0 = 0;P0 = 0;
        I0 = (Rs/RL)*OP.ibias;
    end
end
if nargin == 5
    M = varargin{4};
end

tau = C/G;
taueff = tau/(1+beta*L0);
tauI = tau/(1-L0);
tau_el = L/(RL+R0*(1+bI));

%f = 1:1e6;
f = logspace(0,6,1000);
if strcmp(model,'wouter')
    %%%ecuaciones 2.25-2.27 Tesis de Wouter.
    i_ph = sqrt(4*gamma*Kb*T0^2*G)*alfa*I0*R0./(G*T0*(R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));
    i_jo = sqrt(4*Kb*T0*R0)*sqrt(1+4*pi^2*tau^2.*f.^2)./((R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));
    i_sh = sqrt(4*Kb*Ts*Rs)*sqrt((1-L0)^2+4*pi^2*tau^2.*f.^2)./((R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));%%%
    noise.ph = i_ph;noise.jo = i_jo;noise.sh = i_sh;noise.sum = sqrt(i_ph.^2+i_jo.^2+i_sh.^2);
    
elseif strcmp(model,'irwin')
    %%% ecuaciones capitulo Irwin
    
    sI = -(1/(I0*R0))*(L/(tau_el*R0*L0)+(1-RL/R0)-L*tau*(2*pi*f).^2/(L0*R0)+1i*(2*pi*f)*L*tau*(1/tauI+1/tau_el)/(R0*L0)).^-1;%funcion de transferencia.
    
    t = Ts/T0;
    %%%calculo factor F. See McCammon p11.
    %n = 3.1;
    %F = t^(n+1)*(t^(n+2)+1)/2;%F de boyle y rogers. n =  exponente de la ley de P(T). El primer factor viene de la pag22 del cap de Irwin.
    F = (t^(n+2)+1)/2;%%%specular limit
    %F = t^(n+1)*(n+1)*(t^(2*n+3)-1)/((2*n+3)*(t^(n+1)-1));%F de Mather. La
    %diferencia entre las dos fórmulas es menor del 1%.
    %F = (n+1)*(t^(2*n+3)-1)/((2*n+3)*(t^(n+1)-1));%%%diffusive limit.
    
    stfn = 4*Kb*T0^2*G*abs(sI).^2*F;%Thermal Fluctuation Noise
    ssh = 4*Kb*Ts*I0^2*RL*(L0-1)^2*(1+4*pi^2*f.^2*tau^2/(1-L0)^2).*abs(sI).^2/L0^2; %Load resistor Noise
    %M = 1.8;
    stes = 4*Kb*T0*I0^2*R0*(1+2*bI)*(1+4*pi^2*f.^2*tau^2).*abs(sI).^2/L0^2*(1+M^2);%%%Johnson noise at TES.
    if ~isreal(sqrt(stes))
        stes = zeros(1,length(f));
    end
    smax = 4*Kb*T0^2*G.*abs(sI).^2;
    
    sfaser = 0;%21/(2*pi^2)*((6.626e-34)^2/(1.602e-19)^2)*(10e-9)*P0/R0^2/(2.25e-8)/(1.38e-23*T0);%%%eq22 faser
    sext = (18.5e-12*abs(sI)).^2;
    
    NEP_tfn = sqrt(stfn)./abs(sI);
    NEP_ssh = sqrt(ssh)./abs(sI);
    NEP_tes = sqrt(stes)./abs(sI);
    Res_tfn = 2.35/sqrt(trapz(f,1./NEP_tfn.^2))/2/1.609e-19;
    Res_ssh = 2.35/sqrt(trapz(f,1./NEP_ssh.^2))/2/1.609e-19;
    Res_tes = 2.35/sqrt(trapz(f,1./NEP_tes.^2))/2/1.609e-19;
    Res_tfn_tes = 2.35/sqrt(trapz(f,1./(NEP_tes.*NEP_tfn)))/2/1.609e-19;
    Res_tfn_ssh = 2.35/sqrt(trapz(f,1./(NEP_ssh.*NEP_tfn)))/2/1.609e-19;
    Res_ssh_tes = 2.35/sqrt(trapz(f,1./(NEP_tes.*NEP_ssh)))/2/1.609e-19;
    
    NEP = sqrt(stfn+ssh+stes)./abs(sI);
    Res = 2.35/sqrt(trapz(f,1./NEP.^2))/2/1.609e-19;%resolución en eV. Tesis Wouter (2.37).
    
    %stes = stes*M^2;
    i_ph = sqrt(stfn);
    i_jo = sqrt(stes);
    if ~isreal(i_jo)
        i_jo = zeros(1,length(f));
    end
    i_sh = sqrt(ssh);
    %G*5e-8
    %(n*TES.K*Ts.^n)*5e-6
    %i_temp = (n*TES.K*Ts.^n)*0e-6*abs(sI);%%%ruido en Tbath.(5e-4 = 200uK, 5e-5 = 20uK, 5e-6 = 2uK)
    
    noise.f = f;
    noise.ph = i_ph;noise.jo = i_jo;noise.sh = i_sh;noise.sum = sqrt(stfn+stes+ssh);%noise.sum = i_ph+i_jo+i_sh;
    noise.sI = abs(sI);noise.NEP = NEP;noise.max = sqrt(smax);noise.Res = Res;%noise.tbath = i_temp;
    noise.Res_tfn = Res_tfn; noise.Res_ssh = Res_ssh; noise.Res_tes = Res_tes;
    noise.Res_tfn_tes = Res_tfn_tes;noise.Res_tfn_ssh = Res_tfn_ssh;noise.Res_ssh_tes = Res_ssh_tes;
    noise.squid = Nsquid;noise.squidarray = Nsquid*ones(1,length(f));
    
else
    error('no valid model')
end
