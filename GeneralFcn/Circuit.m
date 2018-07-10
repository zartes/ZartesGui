classdef Circuit
    properties
        Rf;             % Impedance of FLL
        Rpar;           % Parasitic Impedance (TES branch)
        Rn;             % Impedance of TES in Normal state
        Rsh;            % Impedance of the resistive divisor
        invMf;          % Inverse of the relation between Amplitude and flux (input)
        invMin;         % Inverse of the relation between Amplitude and flux (feedback)
        L;              % Inductance of the circuit 
        mN;             % Slope of the IV characterization during Normal state (TES)
        mS;             % Slope of the IV characterization during Superconductor state (TES)
    end
    
    methods        
        function obj = Constructor(obj)
            obj.Rf = 10000;
            obj.Rpar = 2.035e-05;
            obj.Rn = 0.0232;
            obj.Rsh = 0.002;
            obj.invMf = 66;
            obj.invMin = 24.1;
            obj.L = 7.7e-08;
            obj.mN = 650.7;
            obj.mS = 8133;
        end
    end
    
end