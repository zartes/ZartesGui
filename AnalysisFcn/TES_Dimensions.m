classdef TES_Dimensions
    % TES device class thermal parameters
    %   Characteristics of TES device
    
    properties
        sides  = PhysicalMeasurement;        
        hMo = PhysicalMeasurement;
        hAu = PhysicalMeasurement;
        gammaMo = PhysicalMeasurement;
        gammaAu = PhysicalMeasurement;
        rhoMo = PhysicalMeasurement;
        rhoAu = PhysicalMeasurement; 
        Abs_bool = 0;
        Abs_sides = PhysicalMeasurement;
        Abs_hBi = PhysicalMeasurement; 
        Abs_hAu = PhysicalMeasurement; 
        Abs_gammaBi = PhysicalMeasurement; 
        Abs_gammaAu = PhysicalMeasurement;
        Abs_rhoBi = PhysicalMeasurement;
        Abs_rhoAu = PhysicalMeasurement;
    end
    properties (Access = private)
        version = 'ZarTES v2.1';
    end
    
    methods
        function obj = Constructor(obj)
            obj.sides.Value = [25e-6 25e-6];
            obj.sides.Units = {'m';'m'};
            obj.hMo.Value = 55e-9;
            obj.hMo.Units = 'm';
            obj.hAu.Value = 340e-9;
            obj.hAu.Units = 'm';
            obj.gammaMo.Value = 2e3;
            obj.gammaMo.Units = 'J/moleK^2';
            obj.gammaAu.Value = 0.729e3;
            obj.gammaAu.Units = 'J/moleK^2';
            obj.rhoMo.Value = 0.107;
            obj.rhoMo.Units = 'mole/cm^3';
            obj.rhoAu.Value = 0.0983;
            obj.rhoAu.Units = 'mole/cm^3';
            
            obj.Abs_sides.Value = [25e-6 25e-6];
            obj.Abs_sides.Units = {'m';'m'};
            obj.Abs_hBi.Value = 50e-6;
            obj.Abs_hBi.Units = 'm';
            obj.Abs_hAu.Value = 50e-6;
            obj.Abs_hAu.Units = 'm';
            obj.Abs_gammaBi.Value = 0.008e3;
            obj.Abs_gammaBi.Units = 'J/moleK^2';
            obj.Abs_gammaAu.Value = 0.729e3;
            obj.Abs_gammaAu.Units = 'J/moleK^2';
            obj.Abs_rhoBi.Value = 0.0468;
            obj.Abs_rhoBi.Units = 'mole/cm^3';
            obj.Abs_rhoAu.Value = 0.0983;  
            obj.Abs_rhoAu.Units = 'mole/cm^3';
            
        end
        
        function obj = Update(obj,data)
            % Function to update the class values
            
            FN = properties(obj);
            if nargin == 2
                fieldNames = fieldnames(data);
                for i = 1:length(fieldNames)
                    if ~isempty(cell2mat(strfind(FN,fieldNames{i})))
                        if isa(fieldNames{i},'PhysicalMeasurement')
                            eval(['obj.' fieldNames{i} '.Value = data.' fieldNames{i} '.Value;']);
                        else
                            eval(['obj.' fieldNames{i} ' = data.' fieldNames{i} ';']);
                        end
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
                defaultanswer = {num2str(obj.sides.Value(1)),num2str(obj.sides.Value(2)),...
                    num2str(obj.hMo.Value),num2str(obj.hAu.Value)};
            catch
                defaultanswer = {num2str(25e-6),num2str(25e-6),...
                    num2str(55e-9),num2str(340e-9)};
            end
            
            answer = inputdlg(prompt,name,numlines,defaultanswer);
            if ~isempty(answer)
                obj.sides.Value(1) = str2double(answer{1});
                obj.sides.Value(2) = str2double(answer{2});
                obj.hMo.Value = str2double(answer{3});
                obj.hAu.Value = str2double(answer{4});
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
                        defaultanswer = {num2str(obj.Abs_sides.Value(1)),num2str(obj.Abs_sides.Value(2)),...
                            num2str(obj.Abs_hBi.Value),num2str(obj.Abs_hAu.Value)};
                    catch
                        defaultanswer = {num2str(25e-6),num2str(25e-6),...
                            num2str(55e-9),num2str(340e-9)};
                    end
                    
                    answer = inputdlg(prompt,name,numlines,defaultanswer);
                    if ~isempty(answer)
                        obj.Abs_sides.Value(1) = str2double(answer{1});
                        obj.Abs_sides.Value(2) = str2double(answer{2});
                        obj.Abs_hBi.Value = str2double(answer{3});
                        obj.Abs_hAu.Value = str2double(answer{4});
                    end
                otherwise
                    
            end % switch
            
            waitfor('Device material dimensions provided',obj.version);
            
        end
    end
end