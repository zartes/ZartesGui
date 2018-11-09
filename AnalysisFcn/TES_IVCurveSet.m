classdef TES_IVCurveSet
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ibias;
        vout;
        range;
        Rtes;
        rtes;
        ites;
        vtes;
        ptes;
        ttes;
        rp2;
        aIV;
        bIV;
        file;
        good;
        Tbath;
        IVsetPath;
    end
    
    methods
        
        function obj = Constructor(obj,range)
            if ~exist('range','var')
                obj.range = 'positive';
            else
                obj.range = 'negative';
            end            
        end
        
        function ok = Filled(obj)
            FN = properties(obj);
            StrNo = {'ttes';'rp2';'aIV';'bIV'};
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
        
        function obj = ImportFullIV(obj,path,fileN)
            %%%Nueva versión de la funcion de importacion de IVs con alguna
            %%%modificacion.
            if ~exist('path','var')            
                [fileN,path] = uigetfile('C:\Documents and Settings\Usuario\Escritorio\Datos\2016\Noviembre\IVs\*','','multiselect','on');
            elseif ~exist('fileN','var')                
                [fileN,path] = uigetfile([path '\*'],'','multiselect','on');
            end                                    
            
            T = strcat(path,fileN);
            if ~iscell(T)
                [ii,~] = size(T);
                T2 = {[]};
                for i = 1:ii
                    T2{i} = T(i,:);
                end
                T=T2;
            end
            if ~iscell(fileN)
                [ii,~] = size(fileN);
                file2 = {[]};
                for i = 1:ii
                    file2{i} = fileN(i,:);
                end
                fileN = file2;
            end
            h = waitbar(0,'Please wait...','Name','ZarTES v1.0 - Loading IV curves');
            pause(0.05);
            for i = 1:length(T)
                
                %cargamos datos.Ojo al formato.
                %data=importdata(T{i},'\t');%%%si hay header hace falta skip.
                data = importdata(T{i});
                if isstruct(data)
                    data = data.data;
                end
                %corregir el vout.
                %auxS=corregir4ramas(data);%%para importar ficheros con 4 ramas (sin header)
                auxS = corregir1rama(data);%% para importar ficheros con 1 rama.
                obj(i).ibias = auxS.ibias;
                obj(i).vout = auxS.vout;
                obj(i).good = 1;
                obj(i).file = fileN{i};
                obj(i).Tbath = sscanf(char(regexp(fileN{i},'\d+.?\d+mK*','match')),'%fmK')*1e-3;
                obj(i).IVsetPath = path;
                file_upd = fileN{i};
                file_upd(file_upd == '_') = ' ';
                waitbar(i/length(T),h,file_upd)
            end
            if ishandle(h)
                close(h);
            end
        end
        
        
        function obj = GetIVTES(obj,TESDATA)
            
            F = TESDATA.circuit.invMin/(TESDATA.circuit.invMf*TESDATA.circuit.Rf);%36.51e-6;
            for i = 1:length(obj)     
                obj(i).ites = obj(i).vout*F;
                Vs = (obj(i).ibias-obj(i).ites)*TESDATA.circuit.Rsh;%(ibias*1e-6-ites)*Rsh;if Ib in uA.
                obj(i).vtes = Vs-obj(i).ites*TESDATA.circuit.Rpar;
                obj(i).ptes = obj(i).vtes.*obj(i).ites;
                obj(i).Rtes = obj(i).vtes./obj(i).ites;
                obj(i).rtes = obj(i).Rtes/TESDATA.circuit.Rn;                
                
                if ~isempty(TESDATA.TES.n)
                    obj(i).ttes = (obj(i).ptes./[TESDATA.TES.K]+obj(i).Tbath.^([TESDATA.TES.n])).^(1./[TESDATA.TES.n]);
                    smT = smooth(obj(i).ttes,3);
                    smI = smooth(obj(i).ites,3);
                    %%%%alfa y beta from IV
                    obj(i).rp2 = 0.5*(obj(i).rtes(1:end-1) + obj(i).rtes(2:end));%%% el vector de X.
                    obj(i).aIV = diff(log(obj(i).Rtes))./diff(log(smT));
                    obj(i).bIV = diff(log(obj(i).Rtes))./diff(log(smI));
                end 
            end                                    
        end
        
        function [obj,TempLims] = ImportFromFiles(obj,TESDATA,DataPath,TempLims) 
            if ~exist('DataPath','var')
                DataPath = [];
            end
            
            if ~exist('TempLims','var')
                prompt = {'Mimimun temperature (mK):','Maximum temperature (mK):'};
                name = 'Input for limiting Temp for analysis';
                numlines = 1;
                defaultanswer = {'20','100'};
                answer = inputdlg(prompt,name,numlines,defaultanswer);
                
                if isempty(answer)
                    TempLims = [0 Inf];
                else
                    TempLims(1) = str2double(answer{1});
                    TempLims(2) = str2double(answer{2});
                end
                if any(isnan(TempLims))
                    errordlg('Invalid temperature values!', 'ZarTES v1.0', 'modal');
                    return;
                end
            end
            
%             if isempty(obj(1).IVsetPath)
                IVsPath = uigetdir(DataPath, 'Pick a Data path named IVs');
                if IVsPath ~= 0
                    IVsPath = [IVsPath filesep];
                else
                    errordlg('Invalid Data path name!','ZarTES v1.0','modal');
                    return;
                end
%             end
            obj(1).IVsetPath = IVsPath;                        
            
            StrRange = {'p';'n'};
            switch obj(1).range
                case 'positive'
                    StrRange = {'p'};
                case 'negative'
                    StrRange = {'n'};
            end
                        
            for j = 1:length(StrRange)                
                eval([upper(StrRange{j}) 'files = ls(''' IVsPath '*_' StrRange{j} '_matlab.txt'');']);
                % Erase those that are not valid
                TempStr = nan(1,size(eval([upper(StrRange{j}) 'files']),1));
                i = 1;
                while i <= size(eval([upper(StrRange{j}) 'files']),1)
                    if isnan(str2double(eval([upper(StrRange{j}) 'files(i,1)'])))
                        eval([upper(StrRange{j}) 'files(i,:) = [];'])
                    elseif ~isempty(strfind(eval([upper(StrRange{j}) 'files(i,:)']),'(')) %#ok<STREMP>
                        eval([upper(StrRange{j}) 'files(i,:) = [];'])
                    else
                        Value = str2double(eval([upper(StrRange{j}) 'files(i,1:strfind(' upper(StrRange{j}) 'files(i,:),''mK_'')-1)']));
                        
                        if or(Value < TempLims(1),Value > TempLims(2))
                            eval([upper(StrRange{j}) 'files(i,:) = [];'])
                        else
                            TempStr(i) = Value;
                            i = i+1;
                        end
                    end
                end                
                TempStr(isnan(TempStr)) = [];
                % Sortening in ascending mode
                [Val,Ind] = sort(TempStr); %#ok<ASGLU>
                eval([upper(StrRange{j}) 'files = ' upper(StrRange{j}) 'files(Ind,:);']);                                
                eval(['obj = obj.ImportFullIV(''' IVsPath ''',' upper(StrRange{j}) 'files);']);
                obj = obj.GetIVTES(TESDATA);
            end            
        end
        
        
        
    end
    
end

