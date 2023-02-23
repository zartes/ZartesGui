classdef TES_Circuit
    % Class Circuit for TES data
    %   Circuit represents the electrical components in the TES
    %   characterization.
    
    properties
        
        Rf = PhysicalMeasurement;   %Ohm
        Rsh = PhysicalMeasurement;  %Ohm
        invMf = PhysicalMeasurement;  % uA/phi
        invMin = PhysicalMeasurement; % uA/phi        
        L = PhysicalMeasurement;  % H
        Nsquid = PhysicalMeasurement; % 'pA/Hz^{0.5}'
        
        Rpar = PhysicalMeasurement;  %Ohm
        Rn = PhysicalMeasurement;  % (%)
        mS = PhysicalMeasurement;  % Ohm
        mN = PhysicalMeasurement;  % Ohm
        CurrOffset = PhysicalMeasurement;
    end
    
    
    methods
        
        function obj = Constructor(obj)
            % Function to generate the class with default values
            
            obj.Rsh.Value = 0.002;
            obj.Rsh.Units = 'Ohm';
            obj.Rf.Value = 1e4;
            obj.Rf.Units = 'Ohm';
            obj.invMf.Value = 66;
            obj.invMf.Units = 'uA/phi';
            obj.invMin.Value = 24.1;     
            obj.invMin.Units = 'uA/phi';            
            obj.L.Value = 7.7e-08;
            obj.L.Units = 'H';
            obj.Nsquid.Value = 3e-12;
            obj.Nsquid.Units = 'A/Hz^{0.5}';
            obj.CurrOffset.Value = 0;
            obj.CurrOffset.Units = 'A';
            
            obj.Rpar.Value = 2.035e-05;
            obj.Rpar.Units = 'Ohm';
            obj.Rn.Value = 0.0232;
            obj.Rn.Units = 'Ohm';
            obj.mS.Value = 8133;
            obj.mS.Units = 'V/uA';
            obj.mN.Value = 650.7;
            obj.mN.Units = 'V/uA';
            
        end
        
        function ok = Filled(obj)
            % Function to check whether the class is filled or empty (all
            % fields must be filled to be considered as filled)
            
            FN = properties(obj);
            for i = 1:length(FN)
                if isempty(eval(['obj.' FN{i} '.Value']))
                    ok = 0;  % Empty field
                    return;
                end
            end
            ok = 1; % All fields are filled
        end
        
        function obj = Update(obj,data)
            % Function to update the class values
            if isa(data,'TES_ElectricalNoise')
                if data.Selected_Tipo == 1
                    if ~isempty(data.Value)                    
                        obj.Nsquid.Value = data.Value;
                    end
                elseif data.Selected_Tipo == 2                
                    obj.Nsquid.Value = data.Array;
                end
            else            
                FN = properties(obj);
                if nargin == 2
                    fieldNames = fieldnames(data);
                    for i = 1:length(fieldNames)
                        if ~isempty(cell2mat(strfind(FN,fieldNames{i})))
                            if isa(data,'Circuit')
                                eval(['obj.' fieldNames{i} '.Value = data.' fieldNames{i} '.Value;']);
                            else
                                try
                                    eval(['obj.' fieldNames{i} '.Value = data.' fieldNames{i} '.Value;']);
                                catch
                                    if strcmp(fieldNames{i},'squid')
                                        eval(['obj.Nsquid.Value = data.' fieldNames{i} ';']);
                                    else
                                        eval(['obj.' fieldNames{i} '.Value = data.' fieldNames{i} ';']);
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
    end
end

