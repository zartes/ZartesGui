classdef IV_Delay
    % Class defining a IV_Delay class.
    
    properties              
        FirstDelay;           % First Delay in seconds until the first measurement
        StepDelay;             % Delay in seconds between measurements 
    end
    
    methods        
        function obj = Constructor(obj)
            obj.FirstDelay = 2;
            obj.StepDelay = 1.5;
        end
        function obj = View(obj)
            % Function to check visually the class values
            
            h = figure('Visible','off','Tag','Param_Delay');
            waitfor(Conf_Setup(h,[],obj));
            PD = guidata(h);
            if ~isempty(PD)
                obj = obj.Update(PD);
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