classdef TES_Noise
    % Class Noise for TES data
    %   This class contains options for Noise analysis
    
    properties
        tipo = 'current';               % current, nep
        boolcomponents = 0;             % 0,1
        Mjo = 0;                        % Jonson noise 0,1
        Mph = 0;                        % Phonon noise 0,1
        NoiseBaseName = '\HP_noise*';   % \HP_noise*, \PXI_noise*
        NoiseModel = 'irwin';           % irwin, wouter
    end
    
    methods
        function obj = View(obj)
            % Function to check visually the class values
            
            h = figure('Visible','off','Tag','TES_Noise_Opt');
            waitfor(Conf_Setup(h,[],obj));
            Noise_Opt = guidata(h);
            if ~isempty(Noise_Opt)
                obj = obj.Update(Noise_Opt);
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

