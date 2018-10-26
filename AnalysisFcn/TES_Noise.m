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

