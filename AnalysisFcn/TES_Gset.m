classdef TES_Gset
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        n;
        K;
        Tc;
        G;
        rp;
        model;
        ERP;
    end
    
    methods
        function ok = Filled(obj)
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

