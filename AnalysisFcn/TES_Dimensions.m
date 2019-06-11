classdef TES_Dimensions
    % TES device class thermal parameters
    %   Characteristics of TES device
    
    properties
        sides = [25e-6 25e-6];        
        hMo = 55e-9;
        hAu = 340e-9;
        gammaMo = 2e3;
        gammaAu = 0.729e3;
        rhoMo = 0.107;
        rhoAu = 0.0983;
    end
    
    methods
        
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
        function obj = EnterDimensions(obj)
            % Function to set TES dimensions
            %
            % If this data is available, then theoretical C value could
            % be analytically determined
            
            prompt = {'Enter TES length value (m):','Enter TES width value (m):','Enter Mo thickness value (m):','Enter Au thickness value (m):'};
            name = 'Provide bilayer TES dimension (without absorver)';
            numlines = 1;
            try
                defaultanswer = {num2str(obj.sides(1)),num2str(obj.sides(2)),...
                    num2str(obj.hMo),num2str(obj.hAu)};
            catch
                defaultanswer = {num2str(25e-6),num2str(25e-6),...
                    num2str(55e-9),num2str(340e-9)};
            end
            
            answer = inputdlg(prompt,name,numlines,defaultanswer);
            if ~isempty(answer)
                obj.sides(1) = str2double(answer{1});
                obj.sides(2) = str2double(answer{2});
                obj.hMo = str2double(answer{3});
                obj.hAu = str2double(answer{4});
            end
        end
    end
end