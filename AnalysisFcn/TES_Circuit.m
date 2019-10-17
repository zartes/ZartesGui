classdef TES_Circuit
    % Class Circuit for TES data
    %   Circuit represents the electrical components in the TES
    %   characterization.
    
    properties
        
        Rf;   %Ohm
        Rsh;  %Ohm
        invMf;  % uA/phi
        invMin; % uA/phi        
        L;  % H
        Nsquid; % 'pA/Hz^{0.5}'
        
        Rpar;  %Ohm
        Rn;  % (%)
        mS;  % Ohm
        mN;  % Ohm
    end
    
    
    methods
        
        function obj = Constructor(obj)
            % Function to generate the class with default values
            
            obj.Rsh = 0.002;
            obj.Rf = 1e4;
            obj.invMf = 66;
            obj.invMin = 24.1;            
            obj.L = 7.7e-08;
            obj.Nsquid = 3e-12;
            
            obj.Rpar = 2.035e-05;
            obj.Rn = 0.0232;
            obj.mS = 8133;
            obj.mN = 650.7;
        end
        
        function ok = Filled(obj)
            % Function to check whether the class is filled or empty (all
            % fields must be filled to be considered as filled)
            
            FN = properties(obj);
            for i = 1:length(FN)
                if isempty(eval(['obj.' FN{i}]))
                    ok = 0;  % Empty field
                    return;
                end
            end
            ok = 1; % All fields are filled
        end
        
        function obj = Update(obj,data)
            % Function to update the class values
            
            FN = properties(obj);
            if nargin == 2
                fieldNames = fieldnames(data);
                for i = 1:length(fieldNames)
                    if ~isempty(cell2mat(strfind(FN,fieldNames{i})))
                        if isa(data,'Circuit')
                            eval(['obj.' fieldNames{i} ' = data.' fieldNames{i} '.Value;']);
                        else
                            eval(['obj.' fieldNames{i} ' = data.' fieldNames{i} ';']);
                        end
                    end
                end
                
            end
        end
        
    end
end

