classdef TES_Param
    % TES device class thermal parameters
    %   Characteristics of TES device
    
    properties
        n;
        n_CI;
        K;
        K_CI;        
        Tc;
        Tc_CI;
        G;
        G_CI;
        G100;        
        rp;
%         sides = [25e-6 25e-6];
%         gammaMo = 2e3;
%         gammaAu = 0.729e3;
%         rhoMo = 0.107;
%         rhoAu = 0.0983;
%         hMo = 55e-9;
%         hAu = 340e-9;
        Rpar;  %Ohm
        Rn;  % (%)
        mS;  % Ohm
        mN;  % Ohm
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
        
        function CheckValues(obj,CondStr)
            % Function to check visually the class values
            if exist('CondStr','var')
                h = figure('Visible','off','Tag','TES_Param','Name',CondStr);
            else
                h = figure('Visible','off','Tag','TES_Param');
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
                    warndlg('No Temp value selected','ZarTES v2.0');
                    return;
                else
                    Temp = str2double(answer{1});
                    if isnan(Temp)
                        warndlg('Invalid Temp value','ZarTES v2.0');
                        return;
                    end
                end
                G_new = obj.n*obj.K*Temp^(obj.n-1);
                uiwait(msgbox(['G(' num2str(Temp) ') = ' num2str(G_new)],'ZarTES v2.0','modal'));
            end
            try
                G_new = obj.n*obj.K*Temp^(obj.n-1);
                
            catch
                disp('TES values are empty.')
            end
        end
        
        function obj = RnRparCalc(obj,circuit)
            % Function to compute Rn and Rpar trough the values of the
            % circuit.
            
            obj.Rpar = (circuit.Rf*circuit.invMf/(obj.mS*circuit.invMin)-1)*circuit.Rsh;
            obj.Rn = (circuit.Rsh*circuit.Rf*circuit.invMf/(obj.mN*circuit.invMin)-circuit.Rsh-obj.Rpar);
            
        end
    end
    
end

