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
        ERP = {[]};
        Filtered = {[]};
        fileNoise = {[]};
        NoiseModel = {[]};
        fNoise = {[]};
        SigNoise = {[]};
        Tbath;
    end
    
    methods
        
        function obj = Constructor(obj)
            % Function to generate the class with default values
            
            obj.p.rp = [];
            obj.p.L0 = [];
            obj.p.L0_CI = [];
            obj.p.ai = [];
            obj.p.ai_CI = [];
            obj.p.bi = [];
            obj.p.bi_CI = [];
            obj.p.tau0 = [];
            obj.p.tau0_CI = [];
            obj.p.taueff = [];
            obj.p.taueff_CI = [];
            obj.p.C = [];
            obj.p.C_CI = [];
            obj.p.Zinf = [];
            obj.p.Zinf_CI = [];
            obj.p.Z0 = [];
            obj.p.Z0_CI = [];
            obj.p.ExRes = [];
            obj.p.ThRes = [];
            obj.p.M = [];
            obj.p.Mph = [];
        end
        
        function ok = Filled(obj)
            % Function to check whether the class is filled or empty (all
            % fields must be filled to be considered as filled)
            
            for j = 1:length(obj)
                FN = fieldnames(obj(j).p);
                for i = 1:length(FN)
                    if isempty(eval(['obj(j).p.' FN{i}]))
                        ok = 0;  % Empty field
                        return;
                    end
                end
            end
            ok = 1; % All fields are filled
        end
        
        function [val,rp,Tbath] = GetParamVsRn(obj,param,Tbath)
            % Function to obtain any parameter values at selected Tbaths
            % with respect to Rn values
            
            if ~ischar(param)
                warndlg('param must be string','ZarTES v1.0');
                return;
            else
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
                            rp{i} = rp{i}(cell2mat(obj(ind(i)).Filtered) == 1);
                            val{i} = eval(['[obj(ind(i)).p.' param '];']);
                            val{i} = val{i}(cell2mat(obj(ind(i)).Filtered) == 1);
                        end
                    else
                        Tbath = [obj.Tbath];
                        for i = 1:length(Tbath)
                            rp{i} = [obj(i).p.rp];
                            rp{i} = rp{i}(cell2mat(obj(i).Filtered) == 1);
                            val{i} = eval(['[obj(i).p.' param '];']);
                            val{i} = val{i}(cell2mat(obj(i).Filtered) == 1);
                        end
                    end
                else
                    warndlg('param not valid!','ZarTES v1.0');
                    return;
                end
            end
        end
        
        function [val,Tbaths,Rns] = GetParamVsTbath(obj,param,Rn)
            % Function to obtain any parameter values at selected Rn values
            % with respect to Tbath values
            
            if ~ischar(param)
                warndlg('param must be string','ZarTES v1.0');
                return;
            else
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
                                warndlg('Rn out of range, Rn must be among 0-1 values!','ZarTES v1.0');
                                return;
                            end
                            Tbaths = [obj.Tbath];
                            val = nan(length(Tbaths),1);
                            Rns = nan(length(Tbaths),1);
                            for i = 1:length(Tbaths)
                                rp = [obj(i).p.rp];
                                rp = rp(cell2mat(obj(i).Filtered) == 1);
                                [~,ind] = min(abs(rp-Rn));
                                data = eval(['[obj(i).p.' param '];']);
                                data = data(cell2mat(obj(i).Filtered) == 1);
                                val(i,:) = data(ind);
                                Rns(i,:) = rp(ind);
                            end
                        else
                            warndlg('Rn value is missed!','ZarTES v1.0');
                            return;
                        end
                    end
                else
                    warndlg('param not valid!','ZarTES v1.0');
                    return;
                end
            end
        end
        
        function [val1,val2,Tbaths1,Tbaths2] = GetParamVsParam(obj,param1,param2)
            % Function to obtain any parameter values with respect to other parameter values
            
            if (~ischar(param1))||(~ischar(param2))
                warndlg('param1 and param2 must be strings','ZarTES v1.0');
                return;
            else
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
                if (ok1_ind)&&(ok2_ind)
                    [val1,Rns1,Tbaths1] = GetParamVsRn(obj,param1);
                    [val2,Rns2,Tbaths2] = GetParamVsRn(obj,param2);
                else
                    val1 = [];
                    val2 = [];
                    Tbaths1 = [];
                    Tbaths2 = [];
                end
            end
        end
        
    end
end

