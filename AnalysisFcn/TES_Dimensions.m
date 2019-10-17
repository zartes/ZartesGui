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
        Abs_bool = 0;
        Abs_sides;
        Abs_hBi = 50e-6;
        Abs_hAu = 50e-6;
        Abs_gammaBi = 0.008e3;
        Abs_gammaAu = 0.729e3;
        Abs_rhoBi = 0.0468;
        Abs_rhoAu = 0.0983;        
    end
    properties (Access = private)
        version = 'ZarTES v2.1';
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
            name = 'Provide bilayer TES dimension (without absorber)';
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
            
            ButtonName = questdlg('Is Absorbent presented in TES?', ...
                obj.version, ...
                'Yes', 'No', 'No');
            switch ButtonName
                case 'Yes'
                    obj.Abs_bool = 1;
                    prompt = {'Enter Absorbent length value (m):','Enter Absorbent width value (m):','Enter Bi thickness value (m):','Enter Au thickness value (m):'};
                    name = 'Provide Absorbent dimensions';
                    numlines = 1;
                    try
                        defaultanswer = {num2str(obj.Abs_sides(1)),num2str(obj.Abs_sides(2)),...
                            num2str(obj.Abs_hBi),num2str(obj.Abs_hAu)};
                    catch
                        defaultanswer = {num2str(25e-6),num2str(25e-6),...
                            num2str(55e-9),num2str(340e-9)};
                    end
                    
                    answer = inputdlg(prompt,name,numlines,defaultanswer);
                    if ~isempty(answer)
                        obj.Abs_sides(1) = str2double(answer{1});
                        obj.Abs_sides(2) = str2double(answer{2});
                        obj.Abs_hBi = str2double(answer{3});
                        obj.Abs_hAu = str2double(answer{4});
                    end
                otherwise
                    
            end % switch
            
            waitfor('Device material dimensions provided',obj.version);
            
        end
    end
end