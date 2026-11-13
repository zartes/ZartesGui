classdef ModelDependentOperatingPointClass < GeneralDynamicOperatingPointClass
    properties
        fai=0; %%%Alfa
        fCtes=0;
        ftau0=0;
        fL0=0;
        fCarray=[];%%%Array con las Cs de los bloques.C(1):TES, C(2) bloque_1, etc
        fTarray=[];%%%Array con las temperaturas de cada bloque. Idem.
        fLinksList={};
        fGarray=[];
        
        %%%Noise Fit parameters
        fMjohnson=0;
        fMphononArray=[];
        fThResolution=0;
        fExResolution=0;
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=ModelDependentOperatingPointClass(OPstruct,SETUP,PARRAY,modelname)
            obj@GeneralDynamicOperatingPointClass(OPstruct,SETUP,PARRAY);
            ParseModelName(obj,modelname);%%%Actualizamos la lista de links. Redundante.
            switch modelname
                case {'irwin' 'default'}
                    obj.fL0=obj.fLfit;
                    obj.fai=obj.fL0*obj.fG0*obj.fT0./obj.fP0;
                    obj.ftau0=obj.fTaueff*(obj.fL0-1);
                    obj.fCtes=obj.ftau0./obj.fG0;
                case '2TB_hanging'
                    %%%si gtb=GIV=G0:
                    obj.fGarray(1)=obj.fG0;%%%Ver modelo. Primer link TES-B
                    obj.fGarray(2)=obj.fG0*(1/(1-obj.fParray(4)*(obj.fLfit-1))-1);
                    g_1=obj.fGarray(2);
                    obj.fCtes=obj.fTaueff*(obj.fLfit-1)*(g_1+obj.fG0);
                    obj.fCarray(1)=obj.fCtes;%%%En modelo parallel pueden ser distintos.
                    obj.fCarray(2)=obj.fParray(5)*g_1;
                    obj.fTarray(1)=obj.fT0;
                    obj.fTarray(2)=obj.fT0;
                    obj.fai=obj.fLfit*obj.fT0*(g_1+obj.fG0)/obj.fP0;    
                    obj.ftau0=obj.fCtes/obj.fG0;
                    obj.fL0=obj.fLfit*(1-obj.f_dparams(1));
                case '2TB_intermediate'
                    %%%Asumimos Geff=G0.
                    a=obj.f_dparams(1);
                    g_c=(1-a)/a;%%%
                    n=obj.fTES.n;
                    obj.fTarray(1)=obj.fT0;%%%
                    T1=(a*obj.fT0.^n+(1-a)*obj.fTbath.^n).^(1./n);
                    obj.fTarray(2)=T1;%%%
                    g_t1_0=obj.fG0./(1-a); %%% From ec10 Maasilta.Asumimos Geff=G0.
                    g_t1_1=g_t1_0*(T1/obj.fT0).^(n-1);%%%G(T1)=n*K*T1^(n-1)
                    g_1b=g_t1_1*g_c;
                    obj.fGarray(1)=g_t1_0;
                    obj.fGarray(2)=g_1b;
                    obj.fCtes=obj.fTaueff*(obj.fLfit-1)*g_t1_0;
                    obj.fCarray(1)=obj.fCtes;
                    obj.fCarray(2)=obj.fParray(5)*(g_t1_1+g_1b);
                    obj.fai=obj.fLfit*obj.fT0*(g_t1_0)/obj.fP0;
                    obj.ftau0=obj.fCtes/obj.fG0;
                    obj.fL0=obj.fP0*obj.fai/(obj.fT0*obj.fG0);%%%ec.10 p9 Maasilta.
                case '2TB_parallel'
                    %%%Necesitamos hipótesis. Por ejemplo, que los 2 bloques vienen del
                    %%%propio TES y la gt,1 es una g interna que sólo se manifiesta a
                    %%%alta freq. En esas condiciones, la Geff_maasilta(ec14)=gt,b+g1,b
                    %%%(haciendo gt,1->inf). También suponemos T0=T1 aprox. Dependiendo
                    %%%del volúmen de cada bloque se tendrá g1,b=a*gt,b (el mecanismo
                    %%%de conduccion es el mismo pero tienen distinta zona radiante.
                    %%%Desarrollando geffp(el parametro adimensional) y despreciando
                    %%%terminos de gt,1^2 se llega a gt,1=GIV/(1/geffp -1)
                    f=0.2;%%%esta es la fraccion de TES que asignamos al bloque 1.
                    G0=obj.fG0;
                    obj.fTarray(1)=obj.fT0;
                    obj.fTarray(2)=obj.fT0;
                    g_t1=G0/(obj.f_dparams(1).^-1 -1);
                    g_tb=(1-f)*G0;
                    g_1b=f*G0;
                    obj.fGarray(1)=g_tb;%%%'TES-B'
                    obj.fGarray(2)=g_t1;%%%'TES-I'
                    obj.fGarray(3)=g_1b;%%%'I-B'
                    obj.fai=obj.fLfit*obj.fT0.*(g_t1+g_tb)/obj.fP0;
                    obj.fCarray(1)=obj.fTaueff*(obj.fLfit-1)*(g_t1+g_tb);
                    obj.fCarray(2)=obj.fParray(5)*(g_t1+g_1b);
                    obj.fCtes=sum(obj.fCarray);%%%Suponemos que la C total del TES es la suma de los dos bloques
                    obj.ftau0=obj.fCtes/G0;
                    obj.fL0=obj.fP0.*obj.fai./(obj.fT0.*G0);
                case '3TB_2H'
                    error('3TB not implemented yet');
                case '3TB_IH'
                    error('3TB not implemented yet');
            end
        end
        
        function list=ParseModelName(obj,modelname)
            switch modelname
                case {'default' 'irwin'}
                    list={'TES-B'};
                case '2TB_hanging'
                    list={'TES-B' 'TES-H'};
                case '2TB_intermediate'
                    list={'TES-I' 'I-B'};
                case '2TB_parallel'
                    list={'TES-B' 'TES-I' 'I-B'};
                case '3TB_2H'
                    error('3TB not implemented yet');
                case '3TB_IH'
                    error('3TB not implemented yet');
                otherwise
                    error('bad thermal model name')
            end
            obj.fLinksList=list;
        end%%%Función copiada de NoiseThermalModel. Redundante?
        
        %%%Setters
        function SetMjohnson(obj,Mjo)
            obj.fMjohnson=Mjo;
        end
        function SetMphonon(obj,MphArray)
            for i=1:length(obj.fLinksList)
                obj.fMphononArray(i)=MphArray(i);
            end
        end
        function SetThResolution(obj,ThRes)
            obj.fThResolution=ThRes;
        end
        function SetExResolution(obj,ExRes)
            obj.fExResolution=ExRes;
        end
    end

end