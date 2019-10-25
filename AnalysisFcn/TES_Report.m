classdef TES_Report
    % Class Report for TES data
    %   Options for generation a word file report
    
    properties
        IV_Curves = 1;
        FitPTset = 1;
        NKGTset = 1;
        ABCTset = 1;
        FitZset = 1;
        NoiseSet = 1;
        RTs = 1;
        IV_Z = 1;
        ICs = 0;
        BVscan = 0;
    end
    
    methods
        
        function obj = View(obj)
            % Function to check visually the class values
            
            h = figure('Visible','off','Tag','TES_Report_Opt');
            waitfor(Conf_Setup(h,[],obj));
            Report_Opt = guidata(h);
            if ~isempty(Report_Opt)
                obj = obj.Update(Report_Opt);
            end
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
        
    end
end