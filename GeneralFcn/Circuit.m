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
            obj.Rf = PhysicalMeasurement;            
            obj.Rf.Value = 10000;
            obj.Rf.Units = '';
            
            obj.Rpar = PhysicalMeasurement;            
            obj.Rpar.Value = 2.035e-05;
            obj.Rpar.Units = '';
            
            obj.Rn = PhysicalMeasurement;
            obj.Rn.Value = 0.0232;
            obj.Rn.Units = '';
            
            obj.Rsh = PhysicalMeasurement;
            obj.Rsh.Value = 0.002;
            obj.Rsh.Units = '';
            
            obj.invMf = PhysicalMeasurement;
            obj.invMf.Value = 66;
            obj.invMf.Units = '';
            
            obj.invMin = PhysicalMeasurement;
            obj.invMin.Value = 24.1;
            obj.invMin.Units = '';
            
            obj.L = PhysicalMeasurement;
            obj.L.Value = 7.7e-08;
            obj.L.Units = '';
            
            obj.mN = PhysicalMeasurement;
            obj.mN.Value = 650.7;
            obj.mN.Units = '';
            
            obj.mS = PhysicalMeasurement;
            obj.mS.Value = 8133;
            obj.mS.Units = '';
        end
    end
    
end