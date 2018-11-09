classdef TES_Param
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        n;
        K;
        Tc;
        G;    
        sides;
    end
    
    methods
        function ok = Filled(obj)
            FN = properties(obj);
            StrNo = {'sides'};
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
        function CheckValues(obj)
            h = figure('Visible','off','Tag','TES_Param');
            waitfor(Conf_Setup(h,[],obj));
        end
        
        function G_new = G_calc(obj,Temp)
            % Temp in K
            try
                G_new = obj.n*obj.K*Temp^(obj.n-1);
            catch
                disp('TES values are empty.')
            end
        end
    end
    
end

