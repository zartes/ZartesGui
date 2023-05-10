classdef TES_P
    % Class P for TES data
    %   This class contains the Z(w)-Noise analysis data
    
    properties
        p;
        residuo;
        CI;
        fileZ = {[]};
        ElecThermModel = {[]};
        ztes = {[]};
        fZ = {[]};
        fS = {[]};
        ERP = {[]};
        R2 = {[]};
        Filtered = {[]};
        fileNoise = {[]};
        NoiseModel = {[]};
        fNoise = {[]};
        SigNoise = {[]};
        Tbath;
    end
    
    properties (Access = private)
        version = 'ZarTES v4.4';
    end
    
    methods
        
        function obj = Constructor(obj,ETModel)            
            % Function to generate the class with default values
            
            if nargin == 2
                switch ETModel.Zw_Models{ETModel.Selected_Zw_Models}
                    case ETModel.Zw_Models{1}  % 1 TB
                        fieldStr = {'rp';'R0';'Z0Zinf';'Z0R0';'L0';'L0_CI';...
                            'ai';'ai_CI';'bi';'bi_CI';'tau0';'tau0_CI';'taueff';'taueff_CI';...
                            'C';'C_CI';'Zinf';'Zinf_CI';'Z0';'Z0_CI';'ExRes';'ThRes';'M';'Mph'};
                        for i = 1:length(fieldStr)
                            eval(['obj.p.' fieldStr{i} ' = [];']);
                        end
%                        
                    case ETModel.Zw_Models{2}  % 2 TB (Hanging)
                        fieldStr = {'rp';'Zinf';'Zinf_CI';'Z0';'Z0_CI';'taueff';'taueff_CI';...
                            'ca0';'ca0_CI';'tauA';'tauA_CI';'L0';'L0_CI';'ai';'ai_CI';...
                            'bi';'bi_CI';'tau0';'tau0_CI';'C';'C_CI';'CA';'CA_CI';...
                            'GA';'GA_CI';'ExRes';'ThRes';'M';'Mph'};
                        for i = 1:length(fieldStr)
                            eval(['obj.p.' fieldStr{i} ' = [];']);
                        end
                    case ETModel.Zw_Models{3}  % 2 TB (intermediate)
                        
                    case ETModel.Zw_Models{4}
                        
                    otherwise
                end
            else
                fieldStr = {'rp';'R0';'Z0Zinf';'Z0R0';'L0';'L0_CI';...
                    'ai';'ai_CI';'bi';'bi_CI';'tau0';'tau0_CI';'taueff';'taueff_CI';...
                    'C';'C_CI';'Zinf';'Zinf_CI';'Z0';'Z0_CI';'ExRes';'ThRes';'M';'Mph'};
                for i = 1:length(fieldStr)
                    eval(['obj.p.' fieldStr{i} ' = [];']);
                end                
            end
                    
        end
        
        function obj = Update(obj,data)
            % Function to update the class values
            
            if isa(data,'TES_P')
                FN = properties(obj);
                if nargin == 2
                    fieldNames = fieldnames(data);
                    for i = 1:length(fieldNames)
                        if ~isempty(cell2mat(strfind(FN,fieldNames{i})))
                            for j = 1:size(data,2)
                                eval(['obj(j).' fieldNames{i} ' = data(j).' fieldNames{i} ';']);
                            end
                        end
                    end
                end
            else
                % Pasamos de estructura (Carlos) a clase
                FN = fieldnames(obj.p);
                fieldNames = fieldnames(data(1).p);
                for j1 = 1:size(data,2)
                    for i = 1:length(FN)
                        % Busqueda de Campos compartidos
                        for k = 1:length(fieldNames)
                            if isequal(FN{i},fieldNames{k})
                                for j = 1:size([data(1).p.rp],2)
                                    eval(['obj(j1).p(j).' FN{i} ' = data(j1).p(j).' fieldNames{k} ';']);
                                end
                                obj(j1).Tbath = data(j1).Tbath;
                            end
                        end
                    end
                end

            end
        end

        function ok = Filled(obj)
            % Function to check whether the class is filled or empty (all
            % fields must be filled to be considered as filled)
            
            for j = 1:length(obj)
                if ~isempty(obj(j).p)
                    FN = fieldnames(obj(j).p);
                    StrNo = {'L0_CI';'ai_CI';'bi_CI';'tau0_CI';'taueff_CI';'C_CI';'Zinf_CI';'Z0_CI';'Z0Zinf';'Z0R0'};
                    for i = 1:length(FN)
                        for k = 1:length(StrNo)
                            if isequal(FN{i},StrNo{k})
                                if isempty(eval(['obj(j).p.' FN{i}]))
                                    ok(j) = 1;  % Empty field
                                    continue;
                                else
                                    ok(j) = 1;
                                end
%                             else
%                                 if isempty(eval(['obj(j).p.' FN{i}]))
%                                     ok(j) = 0;  % Empty field
%                                     continue;
%                                 else
%                                     ok(j) = 1;
%                                 end
                            end
                        end
                    end
                end
            end
%             ok = 1; % All fields are filled
        end
        
        function [val,rp,Tbath] = GetParamVsRn(obj,param,Tbath)
            % Function to obtain any parameter values at selected Tbaths
            % with respect to Rn values
            
            if ~ischar(param)
                warndlg('param must be string',obj.version);
                return;
            else
                val = {[]};
                rp = {[]};
                ValidParams = fieldnames(obj(1).p);
                ok_ind = 0;
                for i = 1:length(ValidParams)
                    if strcmp(ValidParams{i},param)
                        ok_ind = 1;
                    end
                end
                if ok_ind
                    if exist('Tbath','var')
                        if ischar(Tbath) % Transformar en valor numerico '50.0mK'
                            Tbath = str2double(Tbath(1:end-2))*1e-3;
                        end
                        Tbaths = [obj.Tbath];
                        [~,ind] = intersect(Tbaths,Tbath);
                        for i = 1:length(ind)
                            rp{i} = [obj(ind(i)).p.rp];
                            val{i} = eval(['[obj(ind(i)).p.' param '];']);
                            if ~isempty(obj(ind(i)).Filtered{1})                                
                                rp{i} = rp{i}(cell2mat(obj(ind(i)).Filtered) == 0);                            
                                val{i} = val{i}(cell2mat(obj(ind(i)).Filtered) == 0);                            
                            end
                        end
                    else
                        Tbath = [obj.Tbath];
                        for i = 1:length(Tbath)
                            rp{i} = [obj(i).p.rp];
                            val{i} = eval(['[obj(i).p.' param '];']);
                            if ~isempty(obj(i).Filtered{1})    
                                rp{i} = rp{i}(cell2mat(obj(i).Filtered) == 0);                            
                                val{i} = val{i}(cell2mat(obj(i).Filtered) == 0);
                            end
                        end
                    end
                else
                    if isempty(strfind(param,'_CI'))
                        warndlg('param not valid!',obj.version);
                        return;
                    end
                end
            end
        end
        
        function [val,Tbaths,Rns] = GetParamVsTbath(obj,param,Rn)
            % Function to obtain any parameter values at selected Rn values
            % with respect to Tbath values
            
            if ~ischar(param)
                warndlg('param must be string',obj.version);
                return;
            else
                val = [];
                ValidParams = fieldnames(obj(1).p);
                ok_ind = 0;
                for i = 1:length(ValidParams)
                    if strcmp(ValidParams{i},param)
                        ok_ind = 1;
                    end
                end
                if ok_ind
                    if length(Rn) > 1
                        for i = 1:length(Rn)
                            [val(i,:),Tbaths(i,:),Rns(i,:)] = GetParamVsTbath(obj,param,Rn(i));
                        end
                    else
                        if exist('Rn','var')
                            if Rn <= 0 || Rn > 1
                                warndlg('%Rn out of range, %Rn must be among 0-1 values!',obj.version);
                                return;
                            end
                            Tbaths = [obj.Tbath];
                            %                             val = nan(length(Tbaths),1);
                            %                             Rns = nan(length(Tbaths),1);
                            for i = 1:length(Tbaths)

                                try
                                    rp = [obj(i).p.rp];
                                    data = eval(['[obj(i).p.' param '];']);
                                    rp = rp(cell2mat(obj(i).Filtered) == 0);
                                    [~,ind] = min(abs(rp-Rn));

                                    data = data(cell2mat(obj(i).Filtered) == 0);
                                    val(i,:) = data(ind);
                                    Rns(i,:) = rp(ind);
                                catch
                                    rp = [obj(i).p.rp];
                                    [~,ind] = min(abs(rp-Rn));
                                    data = eval(['[obj(i).p.' param '];']);
                                    val(i,:) = data(ind);
                                    Rns(i,:) = rp(ind);
                                end
                            end
                        else
                            warndlg('%Rn value is missed!',obj.version);
                            return;
                        end
                    end
                else
                    warndlg('param not valid!',obj.version);
                    return;
                end
            end
        end
        
        function [val1,val2,Tbaths1,Tbaths2] = GetParamVsParam(obj,param1,param2)
            % Function to obtain any parameter values with respect to other parameter values
            
            if (~ischar(param1))||(~ischar(param2))
                warndlg('param1 and param2 must be strings',obj.version);
                return;
            else
                val1 = [];
                val2 = [];
                ValidParams = fieldnames(obj(1).p);
                ok1_ind = 0;
                ok2_ind = 0;
                for i = 1:length(ValidParams)
                    if strcmp(ValidParams{i},param1)
                        ok1_ind = 1;
                    end
                    if strcmp(ValidParams{i},param2)
                        ok2_ind = 1;
                    end
                end
                if (ok1_ind)
                    [val1,Rns1,Tbaths1] = GetParamVsRn(obj,param1);
                else
                    val1 = {[]};
                    Tbaths1 = {[]};
                end
                if (ok2_ind)                    
                    [val2,Rns2,Tbaths2] = GetParamVsRn(obj,param2);
                else
                    val2 = cell(1,length(val1));
                    Tbaths2 = cell(1,length(val1));
                end
                if ~ok1_ind
                    val1 = cell(1,length(val2));
                    Tbaths1 = cell(1,length(val2));
                end                
            end
        end
        
    end
end

