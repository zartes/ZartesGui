function param=GetModelParameters(p,IVmeasure,Ib,TES,Circuit,varargin)
%extrae los paraetros termicos del sistema a partir de un modelo termico y
%conociendo el punto de operacion y la 'G'

if nargin==5%%%Esto en realidad es obsoleto, porque puedo calcular los parametros con Cfixed siempre.
    opt.boolC=0;
    opt.model='irwin';
else
    opt=varargin{1}; %%si quiero fijar o no la C
    %%%opt.boolC={1,0}
    %%%opt.C=TES.CN;
    %%%opt.model=modelo_termico
end

Rn=TES.Rn;
T0=TES.Tc;
G0=TES.G0;
[iaux,ii]=unique(IVmeasure.ibias,'stable');
vaux=IVmeasure.vout(ii);
[~,i3]=min(diff(vaux)./diff(iaux));
Ibiasmin=iaux(i3);
pp=spline(iaux(1:i3),vaux(1:i3));%%ojo, el spline no es bueno fuera de la transiciÃ³n.
Vout=ppval(pp,Ib);
%ind=find(abs(IVmeasure.ib-Ib)<1e-10);
%Vout=IVmeasure.vout(ind);
%[I0,V0]=GetIVTES(Vout,Ib,Rf);

IVaux.ibias=Ib;
IVaux.vout=Vout;

IVaux.Tbath=IVmeasure.Tbath;
Tb=IVaux.Tbath;
IVstruct=GetIVTES(Circuit,IVaux);%%%

I0=IVstruct.ites;
V0=IVstruct.vtes;
if abs(Ib)<abs(Ibiasmin) V0=0;end %%%identificamos puntos de operación en estado S para que la R0 no de valores anómalos. Ojo, pq esto va a dar ai,etc Inf.
%R0=0.46*Rn;%0.0147;
%T0=145e-3;
%V0=0.507e-6;I0=43.78e-6;
P0=V0.*I0;
%G=716e-12;
R0=V0/I0;

%%%%%test
%G0=spline([TES.Gset.rp],[TES.Gset.G],R0/Rn)*1e-12
%T0=spline([TES.Gset.rp],[TES.Gset.Tc],R0/Rn)
%pause(1)
%R0/Rn
if isfield(TES,'Ttes')
    T0=TES.Ttes(P0,IVaux.Tbath);
end
if isfield(TES,'Gtes')
    G0=TES.Gtes(T0);
end


rp=p;
%rp(3)=abs(rp(3));
switch opt.model
    case {'irwin','default'}
        %derived parameters
        %for simple model p(1)=Zinf, p(2)=Z0, p(3)=taueff
        %rp=real(p);
        %El orden importa a la hora de exportar los datos.
        param.rp=R0/Rn;
        param.L0=(rp(2)-rp(1))/(rp(2)+R0);
        param.ai=param.L0*G0*T0/P0;
        param.bi=(rp(1)/R0)-1;
        param.tau0=rp(3)*(param.L0-1);
        param.taueff=rp(3);
        param.C=param.tau0*G0;        
        param.Zinf=rp(1);
        param.Z0=rp(2);
        param.R0=R0;
        param.I0=I0;
        param.T0=T0;
        param.parray=[rp(1) rp(2) rp(3)];
        %%%%fixed C=1.2pJ/K.
        if isfield(TES,'Cabs') C1fx=TES.Cabs;else C1fx=TES.CN;end
        param.C_fixed=C1fx;%%%%En TES.CN guardo la estimación teórica de la Ctotal.
        param.tau0_fixed=param.C_fixed/G0;
        param.L0_fixed=param.C_fixed/(G0*param.taueff)-1;
        param.ai_fixed=param.L0_fixed*G0*T0/P0;
        if(0) % (opt.boolC). No necesito reanalizar todo con Cfixed, puedo calcular los parametros con C libre y fija a la vez.
            %C=1.2e-12;%%%%1.2e-12
            %C=0.75e-12;
            %C=10e-15;%2Z4_64.
            C=opt.C;
            %C=15e-15;%%%1Z11_46A
            param.tau0=C/G0;
            param.L0=C/(G0*param.taueff)-1;%%%OJO AL SIGNO
            param.ai=param.L0*G0*T0/P0;
            param.C=C;
        end
    case '1TB_reactancia'%%%1TB con reactancia. NO IMPLEMENTADO REALMENTE
        %derived parameters
        %for simple model p(1)=Zinf, p(2)=Z0, p(3)=taueff
        %rp=real(p);
        %El orden importa a la hora de exportar los datos.
        param.rp=R0/Rn;
        param.L0=(rp(2)-rp(1))/(rp(2)+R0);
        param.ai=param.L0*G0*T0/P0;
        param.bi=(rp(1)/R0)-1;
        param.tau0=rp(3)*(param.L0-1);
        param.taueff=rp(3);
        param.C=param.tau0*G0;        
        param.Zinf=rp(1);
        param.Z0=rp(2);
        param.Lt=p(4);
     
    case '2TB_hanging'
        %derived parameters for 2 block model case A
        param.rp=R0/Rn;
        param.bi=(rp(1)/R0)-1;  
        param.Zinf=p(1);
        param.Z0=p(2);
        param.t_1=p(5);
        param.geff=p(4);%%%gt1/((gt1+gtb)(Lh-1))
        param.taueff=rp(3);
        param.Lh=(p(2)-p(1))*(1+p(4))/((R0+p(1))+(p(2)-p(1))*(1+p(4)));%%%Esto es común a todos los modelos        
        param.parray=p;
        param.R0=R0;
        param.I0=I0;
        param.V0=V0;
        param.P0=P0;
        
        %%%Hanging Model
        %%%si gtb=GIV=G0:
        param.g_1=G0*(1/(1-p(4)*(param.Lh-1))-1);
        param.C=p(3)*(param.Lh-1)*(param.g_1+G0);
        param.C_1=p(5)*param.g_1;
        param.ai=param.Lh*T0*(param.g_1+G0)/P0;    
        param.tau0=param.C/G0;
        %param.a=1/(1-param.Z0*(1+1/param.geff)/param.Zinf);%%%wtf! esto
        %esta mal
        param.a=p(4)*(param.Lh-1);%%% definimos 'a' como el cociente g1/(g1+G0).
        param.L0=param.Lh*(1-param.a);
        %%%%%Parametros con C_1 fija
        if isfield(TES,'Cabs') C1fx=TES.Cabs;else C1fx=TES.CN;end
        param.C_1_fixed=C1fx;%800e-15;
        param.g_1_fixed=param.C_1_fixed/p(5);
        param.a_fixed=param.g_1_fixed/(param.g_1_fixed+G0);
        param.Lh_fixed=param.a_fixed/p(4)+1;
        param.ai_fixed=param.Lh_fixed*T0*(param.g_1_fixed+G0)/P0;   
        param.C_fixed=p(3)*(param.Lh_fixed-1)*(param.g_1_fixed+G0);
        param.L0_fixed=param.Lh_fixed*(1-param.a_fixed);
    case '2TB_hanging_Lh-a'
        %derived parameters for 2 block model case A expresado en función
        %de Lh (p(2)) y 'a'(p(4)) (cociente de conductancias).
        param.rp=R0/Rn;
        param.bi=(rp(1)/R0)-1;  
        param.Zinf=p(1);
        param.Lh=p(2);
        param.t_1=p(5);
        param.geff=p(4)/(p(2)-1);%%%gt1/((gt1+gtb)(L-1))
        param.a=p(4);
        param.taueff=rp(3);
        param.parray=p;
        param.Z0=p(1)*(1-p(4))/(1-p(4)-p(2));
        %%%Hanging Model
        %%%si gtb=GIV=G0:
        param.g_1=G0*param.a/(1-param.a);
        param.C=p(3)*(param.Lh-1)*(param.g_1+G0);
        param.C_1=p(5)*param.g_1;
        param.ai=param.Lh*T0*(param.g_1+G0)/P0;    
        param.tau0=param.C/G0;
        param.L0=param.Lh*(1-param.a);
    case '2TB_intermediate'    
        %derived parameters for 2 block model case A
        param.rp=R0/Rn;
        param.bi=(rp(1)/R0)-1;  
        param.Zinf=p(1);
        param.Z0=p(2);
        param.t_1=p(5);
        param.geff=p(4);%%%gt1/((gt1+gtb)(L-1))
        param.taueff=rp(3);
        param.L=(p(2)-p(1))*(1+p(4))/((R0+p(1))+(p(2)-p(1))*(1+p(4)));%%%Esto es común a todos los modelos
        param.parray=p;
        
        %%%Intermediate Model
        %%% n=m, K1=K2, -> g1,b=gt,1(T1) -> p(4)*(L-1)=0.5;g_c=1
        %%% n=m K1!=K2. -> g_c=g1,b/gt,1(T1).
        param.a=p(4)*(param.L-1);%%%cociente. gt,1(T1)/(gt,1(T1)+g1,b)
        param.g_c=(1-param.a)/param.a;%%%
        param.T1=(param.a*T0.^TES.n+(1-param.a)*Tb.^TES.n).^(1./TES.n);
        param.g_t1_0=G0./(1-param.a); %%% From ec10 Maasilta.Asumimos Geff=G0.
        param.g_t1_1=param.g_t1_0*(param.T1/T0).^(TES.n-1);%%%G(T1)=n*K*T1^(n-1)
        param.g_1b=param.g_t1_1*param.g_c;
        param.C=p(3)*(param.L-1)*param.g_t1_0;
        param.C_1=p(5)*(param.g_t1_1+param.g_1b);
        param.ai=param.L*T0*(param.g_t1_0)/P0;
        param.tau0=param.C/G0;
        param.L0=P0*param.ai/(T0*G0);%%%ec.10 p9 Maasilta.
        
    case '2TB_parallel'    
        %derived parameters for 2 block model case A
        param.rp=R0/Rn;
        param.bi=(rp(1)/R0)-1;  
        param.Zinf=p(1);
        param.Z0=p(2);
        param.t_1=p(5);
        param.geff=p(4);%%%gt1/((gt1+gtb)(L-1))
        param.taueff=rp(3);
        param.L=(p(2)-p(1))*(1+p(4))/((R0+p(1))+(p(2)-p(1))*(1+p(4)));%%%Esto es común a todos los modelos
        %param.L=(p(2)-p(1))*(1+p(4))/(p(1)+(p(2)-p(1))*(1+p(4)));
        param.parray=p;
        %%%Parallel Model
        %%%%Parametros especificos del Parallel model
        %%%...
        param.a=p(4)*(param.L-1);%%%Es el parametro adimensional cociente de Gs
        %%%Necesitamos hipótesis. Por ejemplo, que los 2 bloques vienen del
        %%%propio TES y la gt,1 es una g interna que sólo se manifiesta a
        %%%alta freq. En esas condiciones, la Geff_maasilta(ec14)=gt,b+g1,b
        %%%(haciendo gt,1->inf). También suponemos T0=T1 aprox. Dependiendo
        %%%del volúmen de cada bloque se tendrá g1,b=a*gt,b (el mecanismo
        %%%de conduccion es el mismo pero tienen distinta zona radiante.
        %%%Desarrollando geffp(el parametro adimensional) y despreciando
        %%%terminos de gt,1^2 se llega a gt,1=GIV/(1/geffp -1)
        a=0.2;%%%esta es la fraccion de TES que asignamos al bloque 1.
        param.g_t1=G0/(param.a.^-1 -1);
        param.g_tb=(1-a)*G0;
        param.g_1b=a*G0;
        param.ai=param.L*T0.*(param.g_t1+param.g_tb)/P0;
        param.C_1=p(5)*(param.g_t1+param.g_1b);
        param.C_t=param.taueff*(param.L-1)*(param.g_t1+param.g_tb);
        param.C=param.C_1+param.C_t;%%%Suponemos que la C total del TES es la suma de los dos bloques
        param.tau0=param.C/G0;
        param.L0=P0.*param.ai./(T0.*G0);%%%seguimos definiendo estos parametros por completitud.
        
    otherwise
        param=nan;
end


