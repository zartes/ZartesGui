classdef TES_Gset
    % Class Gset for TES data
    %   Data derived from P-Tbath curve fitting at Rn values
    
    properties
        n;      % a.u.
        n_CI;
        K;      % nW/K^n
        K_CI;
        Tc;     % K
        Tc_CI;
        G;      % pW/K
        G_CI;
        G100;
        rp;     % Normalized units
        model;
        ERP;    % Normalized units
        R2;     % Determination coefficient
    end
    
    methods
        
        function obj = Constructor(obj)
            % Function to generate the class with default values
            n = [];      % a.u.
            n_CI = [];
            K = [];      % nW/K^n
            K_CI = [];
            Tc = [];     % K
            Tc_CI = [];
            G = [];      % pW/K
            G_CI = [];
            G100 = [];
            rp = [];     % Normalized units
            model = [];
            ERP = [];    % Normalized units
            R2 = [];     % Determination coefficient            
        end
        
        function obj = Update(obj,data)
            % Function to update the class values
            
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
        
        function ok = Filled(obj)
            % Function to check whether the class is filled or empty (all
            % fields must be filled to be considered as filled, except for ERP)
            
            FN = properties(obj);
            StrNo = {'ERP'};
            for i = 1:length(FN)
                if isempty(cell2mat(strfind(StrNo,FN{i})))
                    if isempty(eval(['obj.' FN{i}]))
                        ok = 0;  % Empty field
                        return;
                    end
                end
            end
            ok = 1; % All fields are filled
        end
        
    end
end

