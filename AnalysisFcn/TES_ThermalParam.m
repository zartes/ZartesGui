classdef TES_ThermalParam
    % TES device class thermal parameters
    %   Characteristics of TES device
    
    properties
        n;
        n_CI;
        K;
        K_CI;
        T_fit;
        T_fit_CI;        
        G;
        G_CI;
        G100;
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
            for i = 1:length(FN)
                if isempty(eval(['obj.' FN{i}]))
                    ok = 0;  % Empty field
                    return;
                end
            end
            ok = 1; % All fields are filled
        end
        
        function CheckValues(obj,CondStr)
            % Function to check visually the class values
            if exist('CondStr','var')
                h = figure('Visible','off','Tag','TES_ThermalParam','Name',CondStr);
            else
                h = figure('Visible','off','Tag','TES_ThermalParam');
            end
            waitfor(Conf_Setup(h,[],obj));
        end
        
        function G_new = G_calc(obj,Temp)
            % Function to compute G at any Temperature in K
            if nargin < 2
                prompt = {'Enter Temp (K) for compute G value'};
                name = 'G(T)';
                numlines = 1;
                defaultanswer = {'0.1'};
                answer = inputdlg(prompt,name,numlines,defaultanswer);
                if isempty(answer)
                    warndlg('No Temp value selected',obj.version);
                    return;
                else
                    Temp = str2double(answer{1});
                    if isnan(Temp)
                        warndlg('Invalid Temp value',obj.version);
                        return;
                    end
                end
                G_new = obj.n*obj.K*Temp^(obj.n-1);
                uiwait(msgbox(['G(' num2str(Temp) ') = ' num2str(G_new)],obj.version,'modal'));
            end
            try
                G_new = obj.n*obj.K*Temp^(obj.n-1);
                
            catch
                disp('TES Thermal Parameter values are empty.')
            end
        end
        
    end
end

