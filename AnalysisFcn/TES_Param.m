classdef TES_Param
    % TES device class thermal parameters
    %   Characteristics of TES device
    
    properties
        
        Rpar;  %Ohm
        Rn;  % Ohm
        mS;  % 1/Ohm
        mN;  % 1/Ohm
        Tc_RT; % mK
        IV_Tc; % # 
    end
    properties (Access = private)
        version = 'ZarTES v2.1';
    end
    
    methods
        
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
        
        function ok = Filled(obj)
            % Function to check whether the class is filled or empty (all
            % fields must be filled to be considered as filled, except for sides)
            
            FN = properties(obj);
%             StrNo = {'sides';'Tc_RTs';'IV_Tc'};
            for i = 1:length(FN)
%                 if isempty(cell2mat(strfind(StrNo,FN{i})))
                    if isempty(eval(['obj.' FN{i}]))
                        ok = 0;  % Empty field
                        return;
                    end
%                 end
            end
            ok = 1; % All fields are filled
        end
        
        function CheckValues(obj,CondStr)
            % Function to check visually the class values
            if exist('CondStr','var')
                h = figure('Visible','off','Tag','TES_Param','Name',CondStr);
            else
                h = figure('Visible','off','Tag','TES_Param');
            end
            waitfor(Conf_Setup(h,[],obj));
        end
        
        
        function obj = RnRparCalc(obj,circuit)
            % Function to compute Rn and Rpar trough the values of the
            % circuit.
            
            obj.Rpar = (circuit.Rf*circuit.invMf/(obj.mS*circuit.invMin)-1)*circuit.Rsh;
            obj.Rn = (circuit.Rsh*circuit.Rf*circuit.invMf/(obj.mN*circuit.invMin)-circuit.Rsh-obj.Rpar);
            
        end
        
        function obj = Tc_EstimationFromRTs(obj,IVset)
            
            try
                Rn50 = obj.Rn/2;
                T_IVs = NaN(1,length(IVset));
                for i = 1:length(IVset)
                    if IVset(i).good
                        indup = find(IVset(i).Rtes > Rn50, 1);
                        inddown = find(IVset(i).Rtes < Rn50, 1);
                        if ~isempty(indup)&&~isempty(inddown)
                            T_IVs(i) = IVset(i).ttes(inddown(1));
                        end
                    end
                end
                [val, ind] = max(T_IVs);
                obj.Tc_RT = val;
                obj.IV_Tc = ind;
            catch
            end
        end
    end
end

