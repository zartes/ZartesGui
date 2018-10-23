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
    end
    
end

