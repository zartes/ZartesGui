classdef TES_P
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        p;
        residuo;
        CI;
        fileZ = {[]};
        ElecThermModel = {[]};
        ztes = {[]};
        fZ = {[]};
        ERP = {[]};
        fileNoise = {[]};  
        NoiseModel = {[]};
        fNoise = {[]};
        SigNoise = {[]};
        Tbath;
    end
    
    methods
        function obj = Constructor(obj)
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

        % Metodos para que devuelva cualquier valor a una temperatura
        % determinada. O un valor a un Rp determinado y variando Tbath
        function [val,rp,Tbath] = GetParamVsRn(obj,param,Tbath)
            % Selecion de Tbath y parametro a buscar en funcion de Rn
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
                        ind = find(Tbaths == Tbath);                        
                        for i = 1:length(Tbath)
                            rp{i} = [obj(ind(i)).p.rp];
                            val{i} = eval(['[obj(ind(i)).p.' param '];']);
                        end
%                         val = eval(['[obj(ind).p.' param '];']);
                    else
                        Tbath = [obj.Tbath];
%                         rp = nan(length(Tbaths),1);
%                         val = nan(length(Tbaths),1);
                        for i = 1:length(Tbath)
                            rp{i} = [obj(i).p.rp];
                            val{i} = eval(['[obj(i).p.' param '];']);
                        end
                    end
                else
                    warndlg('param not valid!','ZarTES v1.0');
                    return;
                end
            end                           
        end
        
        function [val,Tbaths,Rns] = GetParamVsTbath(obj,param,Rn)
            % Selecion de Rn y parametro a buscar en funcion de Tbath
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
                        %                 if ~isempty(cell2mat(strfind(ValidParams,param)))
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
                                [~,ind] = min(abs(rp-Rn));
                                val(i,:) = eval(['obj(i).p(ind).' param ';']);
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
        
    end
    
end

