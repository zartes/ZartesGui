classdef TES_Circuit
    %UNTITLED13 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Rsh;
        Rf;
        invMf;
        invMin;
        Rpar;
        Rn;
        mS;
        mN;
        L;
    end
    
    methods
        function obj = Constructor(obj)
            obj.Rsh = 0.002;
            obj.Rf = [];
            obj.invMf = 33.45;
            obj.invMin = 24.1;
            obj.Rpar = [];
            obj.Rn = [];
            obj.mS = [];
            obj.mN = [];
            obj.L = 7.7e-08;
        end        
        
        function obj = IVcurveSlopesFromData(obj,DataPath)
            waitfor(helpdlg('Pick some IV curves to estimate mN (normal state slope) and mS (superconductor state slope)','ZarTES v1.0'));
            if exist('DataPath','var')
                [IVset, pre_Rf] = importIVs(DataPath);
            else
                [IVset, pre_Rf] = importIVs;
            end
            if length(pre_Rf) == 1
                obj.Rf = pre_Rf;
            else
                errordlg('Rf values are unconsistent!','ZarTES v1.0')
                return;
            end
            [obj.mN, obj.mS] = IVs_Slopes(IVset,1);
            [obj.Rn, obj.Rpar] = RnCalc(obj.mN,obj.mS,obj);                        
        end
        
        
        
        
    end
end

