classdef BasicOperatingPointClass < handle
    %%%%%Propuesta de clase para encapsular un punto de operación básico
    %%%%%del TES sin parámetros dinámicos. Requiere todavía del circuit y
    %%%%%del TES en formato struct. Es análoga al GetIVTES.
    
    properties
        %%%circuit
        fCircuit=[];
        fTES=[];
        %%%Direct Experimental
        fTbath=0.1;
        fIbias=100e-6;
        fVout=0;
        %%%Deduced
        fR0=0;
        fRp=0;
        fI0=0;
        fV0=0;
        fP0=0;
        fT0=0;
        fG0=0;

    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=BasicOperatingPointClass(OPstruct,SETUP)
            %%%Pasamos Tb,Ib,Vo como structura y circuit y TES tb.
           
            obj.fTES=SETUP.TES;
            obj.fCircuit=SETUP.circuit;
            obj.fTbath=OPstruct.Tbath;
            obj.fIbias=OPstruct.ibias;
            obj.fVout=OPstruct.vout;
            
            obj.fI0=V2I(obj.fVout,obj.fCircuit);
            Vs=(obj.fIbias-obj.fI0)*obj.fCircuit.Rsh;%(ibias*1e-6-ites)*Rsh;if Ib in uA.
            obj.fV0=Vs-obj.fI0*obj.fCircuit.Rpar;
            obj.fP0=obj.fV0.*obj.fI0;
            obj.fR0=obj.fV0./obj.fI0;
            obj.fRp=obj.fR0./obj.fCircuit.Rn;%%%La Rn está tanto en circuit como en TES. Ojo al cambiar a clases.
            obj.fT0=obj.fTES.Tc;%%%
            %fT0=(fP0./[fTES.K]+fTbath.^([fTES.n])).^(1./[fTES.n]);
            obj.fG0=obj.fTES.G0;
            if isfield(obj.fTES,'Ttes')
                obj.fT0=obj.fTES.Ttes(obj.fP0,obj.fTbath);
            end
            if isfield(obj.fTES,'Gtes')
                obj.fG0=obj.fTES.Gtes(obj.fT0);
            end
        end
    end
end