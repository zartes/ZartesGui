classdef TES_Gset
    % Class Gset for TES data
    %   Data derived from P-Tbath curve fitting at Rn values
    
    properties
        n;      % a.u.
        K;      % nW/K^n
        Tc;     % K
        G;      % pW/K
        rp;     % Normalized units
        model;
        ERP;    % Normalized units
    end
    
    methods
        
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

