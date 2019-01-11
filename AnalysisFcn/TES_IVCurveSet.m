classdef TES_IVCurveSet
    % Class IVCurveSet for TES data
    %   Contains data from the I-V curves
    
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
            % Function to generate the class with default values
            
            if ~exist('range','var')
                obj.range = 'positive';
            else
                obj.range = 'negative';
            end
        end
        
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
            % fields must be filled to be considered as filled, except for ttes, rp2, aIV, and bIV)
            
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
            % Function to import I-V curves from files
            
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
                
                data = importdata(T{i});
                if isstruct(data)
                    data = data.data;
                end
                j = size(data,2);
                switch j
                    case 2
                        obj(i).ibias = data(:,1)*1e-6;
                        if data(1,1) == 0
                            obj(i).vout = data(:,2)-data(1,2);
                        else
                            obj(i).vout = data(:,2)-data(end,2);
                        end
                    case 4
                        obj(i).ibias = data(:,2)*1e-6;
                        if data(1,2) == 0
                            obj(i).vout = data(:,4)-data(1,4);
                        else
                            obj(i).vout = data(:,4)-data(end,4);
                        end
                end
                clear data;
                
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
            % Function to estimate ptes, Rtes and rtes from I-V curves
            
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
            % Function to import I-V curves from Path restricting
            % temperature range.
            
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
            IVsPath = uigetdir(DataPath, 'Pick a Data path named IVs');
            if IVsPath ~= 0
                IVsPath = [IVsPath filesep];
            else
                errordlg('Invalid Data path name!','ZarTES v1.0','modal');
                return;
            end
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
                    elseif ~isempty(strfind(eval([upper(StrRange{j}) 'files(i,:)']),'('))
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
        
        function fig = plotIVs(obj,varargin)
            % Function to visualize Vout-Ibias, Ites-Vtes, Ptes-Vtes, and
            % Ptes-rtes. Right-Clicking options are available to filter I-V
            % curves.
            
            if nargin == 1
                fig.hObject = figure;
            elseif nargin == 2
                fig = varargin{1};
                if isempty(fig)
                    fig.hObject = figure;
                end
            end
            if isfield(fig,'subplots')
                h = fig.subplots;
            end
            j = 1;
            for i = 1:length(obj)
                if obj(i).good
                    Ibias = obj(i).ibias;
                    Vout = obj(i).vout;
                    
                    %curva Vout-Ibias
                    if ~isfield(fig,'subplots')
                        h(1) = subplot(2,2,1);
                    end
                    h_ib(j) = plot(h(1),Ibias*1e6,Vout,'.--','DisplayName',num2str(obj(i).Tbath),...
                        'ButtonDownFcn',{@ChangeGoodOpt},'Tag',obj(i).file);
                    grid on,hold on
                    xlim(h(1),[min(0,sign(Ibias(1))*500) 500]) %%%Podemos controlar apariencia con esto. 300->500
                    xlabel(h(1),'Ibias(\muA)','fontweight','bold');ylabel(h(1),'Vout(V)','fontweight','bold');
                    set(h(1),'fontsize',12,'linewidth',2,'fontweight','bold')
                    %Curva Ites-Vtes
                    if ~isfield(fig,'subplots')
                        h(3) = subplot(2,2,3);
                    end
                    h_ites(j) = plot(h(3),obj(i).vtes*1e6,obj(i).ites*1e6,'.--','DisplayName',num2str(obj(i).Tbath),...
                        'ButtonDownFcn',{@ChangeGoodOpt},'Tag',obj(i).file);
                    grid on,hold on
                    xlim(h(3),[min(0,sign(Ibias(1))*.5) .5])
                    xlabel(h(3),'V_{TES}(\muV)','fontweight','bold');ylabel(h(3),'Ites(\muA)','fontweight','bold');
                    set(h(3),'fontsize',12,'linewidth',2,'fontweight','bold')
                    %Curva Ptes-Vtes
                    if ~isfield(fig,'subplots')
                        h(2) = subplot(2,2,2);
                    end
                    h_ptes(j) = plot(h(2),obj(i).vtes*1e6,obj(i).ptes*1e12,'.--','DisplayName',num2str(obj(i).Tbath),...
                        'ButtonDownFcn',{@ChangeGoodOpt},'Tag',obj(i).file);
                    grid on,hold on
                    xlim(h(2),[min(0,sign(Ibias(1))*1.0) 1.0])%%%Podemos controlar apariencia con esto. 0.5->1.0
                    xlabel(h(2),'V_{TES}(\muV)','fontweight','bold');ylabel(h(2),'Ptes(pW)','fontweight','bold');
                    set(h(2),'fontsize',12,'linewidth',2,'fontweight','bold')
                    %Curva Ptes-rtes
                    if ~isfield(fig,'subplots')
                        h(4) = subplot(2,2,4);
                    end
                    h_rtes(j) = plot(h(4),obj(i).rtes,obj(i).ptes*1e12,'.--','DisplayName',num2str(obj(i).Tbath),...
                        'ButtonDownFcn',{@ChangeGoodOpt},'Tag',obj(i).file);
                    grid on,hold on
                    xlim(h(4),[0 1]), ylim(h(4),[0 20]);
                    xlabel(h(4),'R_{TES}/R_n','fontweight','bold');ylabel(h(4),'Ptes(pW)','fontweight','bold');
                    set(h(4),'fontsize',12,'linewidth',2,'fontweight','bold')
                    
                    j = j+1;
                end
            end
            axis(h,'tight');
            set([h_ib h_ites h_ptes h_rtes],'UserData',obj);
            linkprop([h_ib h_ites h_ptes h_rtes],'Color');
            set(fig.hObject,'UserData',obj);
        end
        
    end
end

