classdef TES_Circuit
    %UNTITLED13 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Rsh;  %Ohm
        Rf;   %Ohm
        invMf;  % uA/phi
        invMin; % uA/phi
        Rpar;  %Ohm
        Rn;  % (%)
        mS;  % Ohm
        mN;  % Ohm
        L;  % H
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
        function ok = Filled(obj)
            FN = properties(obj);
            for i = 1:length(FN)
                if isempty(eval(['obj.' FN{i}]))
                    ok = 0;  % Empty field
                    return;
                end
            end
            ok = 1; % All fields are filled
        end
        function obj = Update(obj,data)
            FN = properties(obj);
            if nargin == 2
                fieldNames = fieldnames(data);
                for i = 1:length(fieldNames)
                    if ~isempty(cell2mat(strfind(FN,fieldNames{i})))
                        eval(['obj.' fieldNames{i} ' = data.' fieldNames{i} ';']);
                    end
                end
                
            end
        end        
        function obj = IVcurveSlopesFromData(obj,DataPath,fig)
            waitfor(helpdlg('Pick some IV curves to estimate mN (normal state slope) and mS (superconductor state slope)','ZarTES v1.0'));
            if exist('DataPath','var')
                [IVset, pre_Rf] = importIVs(DataPath);
            else
                [IVset, pre_Rf] = importIVs;
            end
            if isempty(IVset)
                return;
            end
            if length(pre_Rf) == 1
                obj.Rf = pre_Rf;
            else
                errordlg('Rf values are unconsistent!','ZarTES v1.0')
                return;
            end
            if exist('fig','var')
                [obj.mN, obj.mS] = IVs_Slopes(IVset,fig);
            else
                [obj.mN, obj.mS] = IVs_Slopes(IVset);
            end
            [obj.Rn, obj.Rpar] = RnCalc(obj.mN,obj.mS,obj);                        
        end
        
        
        
        
    end
end

