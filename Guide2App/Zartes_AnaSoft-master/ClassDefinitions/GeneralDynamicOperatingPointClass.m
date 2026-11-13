classdef GeneralDynamicOperatingPointClass < BasicOperatingPointClass
    %%% Clase para encapsular los parámetros dinámicos generales que son
    %%% comunes a cualquier modelo térmico.
    properties
        %fRp=0;%%% %Rn movida a BasicOP.
        fZinf=0;%%% p(1)
        fZ0=0;%%% p(2)
        fTaueff=0; %%% p(3)
        fbi=0; %%%parametro beta.
        fParray=[]; %%%array del fit.
        fNumBlocks=1;
        fLfit=0;%%% L del fit
        f_dparams=[];%%%Son los parámetros pares que Maasilta define como d_i para más de 1 bloque.
        %%%d_i=p(2i+2)*(Lfit-1).
        
    end
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=GeneralDynamicOperatingPointClass(OPstruct,SETUP,PARRAY)
            obj@BasicOperatingPointClass(OPstruct,SETUP);
            %obj.fR0
            %obj.fTES
            %obj.fRp=obj.fR0/obj.fTES.Rn;
            obj.fParray=PARRAY;
            obj.fZinf=PARRAY(1);
            obj.fZ0=PARRAY(2);
            obj.fTaueff=PARRAY(3);
            obj.fbi=(obj.fZinf/obj.fR0)-1;
            s=numel(PARRAY);
            obj.fNumBlocks=(s-1)/2;
            n=1;
            for i=1:obj.fNumBlocks-1
                n=n+PARRAY(2*i+2);
            end
            Num=(obj.fZ0-obj.fZinf)*n;
            obj.fLfit=Num./(Num-obj.fR0*(2+obj.fbi));
            for i=1:obj.fNumBlocks-1
                obj.f_dparams(i)=PARRAY(2*i+2)*(obj.fLfit-1);
            end
        end
    end
end