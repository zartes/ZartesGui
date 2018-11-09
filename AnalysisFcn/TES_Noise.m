classdef TES_Noise
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tipo = 'current';  % o nep
        boolcomponents = 0; % 1
        Mjo = 0; % Jonson noise
        Mph = 0; % Phonon noise
        NoiseBaseName = '\HP_noise*';%%%Pattern '\PXI_noise*'
        NoiseModel = 'irwin';  % irwin, wouter, 
    end
    
    methods
        function obj = View(obj)
            h = figure('Visible','off','Tag','TES_Noise_Opt');
            waitfor(Conf_Setup(h,[],obj));
            Noise_Opt = guidata(h);
            if ~isempty(Noise_Opt)
                obj = obj.Update(Noise_Opt);
            end
        end      
        function obj = Update(obj,data)
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

