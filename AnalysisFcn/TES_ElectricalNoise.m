classdef TES_ElectricalNoise
    % Class Noise for TES data
    %   This class contains options for Noise analysis
    
    properties
        Tipo = {'Manual';'Automatic'};               % current, nep
        Selected_Tipo = 1;
        Value = 6e-12;
        Array = [];
        NoFiltArray = [];
        Freq = logspace(1,5,321);
        File;  
        ModelBased = 0;
    end
    
    methods
        function [obj, TES] = View(obj,TES)
            % Function to check visually the class values
            
            h = figure('Visible','off','Tag','TES_Noise_Opt');
            waitfor(ElectNoiseViewer(TES,h));
            ElectNoise_Opt = h.UserData;
            if ~isempty(ElectNoise_Opt)
                obj = obj.Update(ElectNoise_Opt);
                TES.circuit = TES.circuit.Update(ElectNoise_Opt);
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