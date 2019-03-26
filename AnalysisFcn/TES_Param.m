classdef TES_Param
    % TES device class thermal parameters
    %   Characteristics of TES device
    
    properties
        n;
        K;
        Tc;
        G;
        G100;
        sides = [25e-6 25e-6];
        gammaMo = 2e3;
        gammaAu = 0.729e3;
        rhoMo = 0.107;
        rhoAu = 0.0983;
        hMo = 55e-9;
        hAu = 340e-9;
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
            StrNo = {'sides'};
            for i = 1:length(FN)
                if isempty(cell2mat(strfind(StrNo,FN{i})))
                    if isempty(eval(['obj.' FN{i}]))
                        ok = 0;  % Empty field
                        return;
                    end
                end
            end
            ok = 1; % All fields are filled
        end
        
        function CheckValues(obj)
            % Function to check visually the class values
            
            h = figure('Visible','off','Tag','TES_Param');
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
                    warndlg('No Temp value selected','ZarTES v1.0');
                    return;
                else
                    Temp = str2double(answer{1});
                    if isnan(Temp)
                        warndlg('Invalid Temp value','ZarTES v1.0');
                        return;
                    end
                end
                G_new = obj.n*obj.K*1e3*Temp^(obj.n-1);
                uiwait(msgbox(['G(' num2str(Temp) ') = ' num2str(G_new)],'ZarTES v1.0','modal'));
            end
            try
                G_new = obj.n*obj.K*1e3*Temp^(obj.n-1);
                
            catch
                disp('TES values are empty.')
            end
        end
    end
    
end

