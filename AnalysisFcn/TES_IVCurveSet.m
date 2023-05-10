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
        YOffset = 0;
        CorrectionMethod = [];
        PN_lowerTol = 0.8;
        PN_upperTol = 1.2;
        PS_lowerTol = 0.95;
        PS_upperTol = 1.05;
    end
    
    properties (Access = private)
        version = 'ZarTES v4.4';
    end
    
    methods
        
        function obj = Constructor(obj,range)
            % Function to generate the class with default values
            
            if ~exist('range','var')
                obj.range = 'PosIbias';
            else
                obj.range = 'NegIbias';
            end
        end
        
        function obj = Update(obj,data)
            % Function to update the class values
            
            FN = properties(obj);
            if nargin == 2
                fieldNames = fieldnames(data);
                for j = 1:length(data)
                    for i = 1:length(fieldNames)
                        if ~isempty(cell2mat(strfind(FN,fieldNames{i})))
                            eval(['obj(j).' fieldNames{i} ' = data(j).' fieldNames{i} ';']);
                        end
                    end
                end
            end
        end
        
        function ok = Filled(obj)
            % Function to check whether the class is filled or empty (all
            % fields must be filled to be considered as filled, except for ttes, rp2, aIV, and bIV)
            
            FN = properties(obj);
            StrNo = {'ttes';'rp2';'aIV';'bIV';'file';'IVsetPath';'CorrectionMethod'};
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
        
    
        function ok = Filled_Imported(obj)
            % Function to check whether the class is filled or empty (all
            % fields must be filled to be considered as filled, except for ttes, rp2, aIV, and bIV)
            
            FN = properties(obj);
            StrNo = {'ibias'};
%             for i = 1:length(FN)
                if ~isempty(cell2mat(strfind(StrNo,FN{1})))
                    if isempty(eval(['obj.' FN{1}]))
                        ok = 0;  % Empty field
                        return;
                    end
                end
            
            ok = 1; % All fields are filled
        end
        
        
        function [obj, pre_Rf] = ImportFullIV(obj,path,fileN)
            % Function to import I-V curves from files
            
            if ~exist('path','var')
                [fileN,path] = uigetfile('C:\Documents and Settings\Usuario\Escritorio\Datos\2016\Noviembre\IVs\*.txt','','multiselect','on');
            elseif ~exist('fileN','var')
                [fileN,path] = uigetfile([path '\*.txt'],'','multiselect','on');
            end
            if isempty(path)
                waitfor(msgbox('Cancelled by user',obj.version));
                pre_Rf = [];
                return;
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
            h = waitbar(0,'Please wait...','Name',[obj.version ' - Loading IV curves']);
            pause(0.05);
            
            
            hfig = findobj('Tag','Raw IV Curves');
            hax = findobj('Tag','Raw IV axes');
            if isempty(hfig)
                fig = figure('Tag','Raw IV Curves','Name','Raw IV Curves');
                hfig = findobj('Tag','Raw IV Curves');
                ax1 = axes('Tag','Raw IV axes');
                xlabel('Ibias (uA)');
                ylabel('Voltaje (V)');
                hold(ax1,'on');
                grid(ax1,'on');
            else
                fig = hfig;
                ax1 = hax;
                grid(ax1,'on');
                xlabel('Ibias (uA)');
                ylabel('Voltaje (V)');
            end      
            
            
            iOK = 1;
            for i = 1:length(T)
                file_upd = fileN{iOK};
                file_upd(file_upd == '_') = ' ';
                waitbar(iOK/length(T),h,file_upd)
                if isempty(strfind(fileN{iOK},'matlab.txt'))
                    continue;
                end
                try
                    data = importdata(T{i});
                catch
                    data = fopen(T{i});
                    continue;
                end      
                ind_i = strfind(fileN{iOK},'mK_Rf');
                ind_f = strfind(fileN{iOK},'K_down_');
                if isempty(ind_f)
                    ind_f = strfind(fileN{iOK},'K_up_');
                end
                pre_Rf(i) = str2double(fileN{iOK}(ind_i+5:ind_f-1))*1000;
                
                if isstruct(data)
                    data = data.data;
                end          
                j = size(data,2);
                switch j
                    case 2
                        Dibias = (data(:,1))*1e-6;
                        Dvout = data(:,4);
                    case 4
                        Dibias = data(:,2)*1e-6;
                        Dvout = data(:,4);                        
                end             
                
                if strfind(fileN{iOK},'_down_p_')
                    obj(iOK).range = 'PosIbias';
                else
                    obj(iOK).range = 'NegIbias';
                end
                obj(iOK).ibias = Dibias;
                obj(iOK).vout = Dvout;
                obj(iOK).file = fileN{iOK};
                obj(iOK).Tbath = sscanf(char(regexp(fileN{iOK},'\d+.?\d+mK*','match')),'%fmK')*1e-3;
                obj(iOK).IVsetPath = path;
                obj(iOK).good = 1;
                                    
%                 plot(ax1,obj(iOK).ibias*1e6,obj(iOK).vout,'DisplayName',[num2str(obj(iOK).Tbath*1e3) ' ' obj(iOK).range])
                iOK = iOK+1;                                
            end
            pre_Rf = unique(pre_Rf);
            if length(pre_Rf) > 1
                warndlg('Unconsistency on Rf values, please check it out',obj.version);
            end
            obj = obj.IV_stable;
                            

            set(hfig,'UserData',obj);
            c = distinguishable_colors(length(obj));
            color_select = [0.8 0.8 0.8];

            % Pintar todas las gráficas IV
            for i = 1:length(obj)
                color = c(i,:);
                plot(ax1,obj(i).ibias*1e6,obj(i).vout,'DisplayName',[num2str(obj(i).Tbath*1e3) ' ' obj(i).range],...
                    'ButtonDownFcn',{@IVSquidStep},'Tag',obj(i).file,'Color',color,'UserData',obj);
            end
            waitfor(msgbox('Before close this window, please select the IV curve you want to correct.',obj(1).version));
            hfig = findobj('Tag','Raw IV Curves');
            obj = get(hfig,'UserData');

            if ishandle(h)
                close(h);
            end
        end
        
        function obj = IV_stable(obj)
            for i = 1:length(obj)
                [obj(i).ibias, Id] = unique(obj(i).ibias,'stable');
                obj(i).vout = obj(i).vout(Id);
                
                % Se reordenan los valores de corriente de
                % menor a mayor
                IndMas = find(sign(obj(i).ibias) ~= -1);
                IndMenos = find(sign(obj(i).ibias) == -1);
                if strcmp(obj(i).range,'PosIbias')
                    [~, Imas] = sort(obj(i).ibias(IndMas),'descend');
                    try
                        [~, Imenos] = sort(obj(i).ibias(IndMenos),'descend');
                    end
                    obj(i).ibias = [obj(i).ibias(IndMas(Imas)); obj(i).ibias(IndMenos(Imenos))];
                    obj(i).vout = [obj(i).vout(IndMas(Imas)); obj(i).vout(IndMenos(Imenos))];
                else
                    [~, Imas] = sort(obj(i).ibias(IndMas),'ascend');
                    try
                        [~, Imenos] = sort(obj(i).ibias(IndMenos),'ascend');
                    end
                    obj(i).ibias = [obj(i).ibias(IndMenos(Imenos)); obj(i).ibias(IndMas(Imas))];
                    obj(i).vout = [obj(i).vout(IndMenos(Imenos)); obj(i).vout(IndMas(Imas))];
                end
            end
        end
        
        function [obj,TES,UserCancel] = IV_correction_methods(obj,TES)
            % Esta función debe corregir o centrar las curvas IV y proporcionar valores de mN y mS              
            
            UserCancel = 0;
            % Avisa al usuario para que sepa que las curvas ya están
            % corregidas y el método empleado
            if ~isempty(obj(1).CorrectionMethod)
                waitfor(warndlg(['IV-Curves have been already centered by: ' obj(1).CorrectionMethod...
                    ', to use another method please import IV curves.'],obj(1).version));
                UserCancel = 1;
                return;
            end
            
            AlgMethdsAvailable = {'Forced zero-zero';'Norm-Sup crossing point';'Set Offset Manually'};
                        
            [SELECTION,OK] = listdlg('ListString',AlgMethdsAvailable,...
                'SelectionMode','single','Name','IV-alignment method',...
                'PromptString','Choose method for the alignment of IV-Curves','ListSize',[300 100]);
            if OK == 0 %             
                msgbox('Cancelled by user',obj(1).version);
                return;
            else
                obj(1).CorrectionMethod = AlgMethdsAvailable{SELECTION};
            end
            
            hfig = findobj('Tag','IV correction');
            hax = findobj('Tag','IV axes');
            if isempty(hfig)
                fig = figure('Tag','IV correction','Name','IV Curves Alignment');
                ax1 = axes('Tag','IV axes');
                hold(ax1,'on');
                grid(ax1,'on');
                xlabel('Ibias (uA)');
                ylabel('Voltaje (V)');
            else
                fig = hfig;
                ax1 = hax;
                grid(ax1,'on');
                xlabel('Ibias (uA)');
                ylabel('Voltaje (V)');
            end         
            
            %% Estimación de las pendientes normal y superconductora
            % Definimos la curva normal como la tomada a mayor
            % temperatura
            [~,indN] = max([obj.Tbath]);
            
            [datafitN,xcrosN,ycrosN,slopeNN,slopeNS] = obj.IV_estimation_mN_mS(obj(indN).ibias,obj(indN).vout,ax1);
            mN = 1/slopeNN;
            
            % Definimos la curva superconductora como la tomada
            % a menor temperatura
            [~,indS] = min([obj.Tbath]);
            
            [datafitS,xcrosS,ycrosS,slopeSN,slopeSS] = obj.IV_estimation_mN_mS(obj(indS).ibias,obj(indS).vout,ax1);
            mS = 1/slopeSS;
            
            switch obj(1).CorrectionMethod
                case AlgMethdsAvailable{1} % 'Forced zero-zero'
                    % En este método, al valor de ibias más cercano al 0 se le fuerza a tener voltaje 0. 
                                                            
                    for i = 1:length(obj)
                        % Se busca el dato de menor valor de corriente en
                        % valor absoluto, que este en cero
                        if strcmp(obj(i).range,'PosIbias')
                            ind = find(obj(i).ibias >= 0,1,'last');
                        else
                            ind = find(obj(i).ibias >= 0,1,'first');
                        end
                        % Se resta el valor de voltaje a cero corriente
                        obj(i).vout = obj(i).vout-obj(i).vout(ind);
                        % Todas las curvas IV se suponen BUENAS
                        obj(i).good = 1;
                        
%                         % Se estiman las pendientes en función de los
%                         % últimos y primeros 5 puntos.
%                         mN(i) = mean(obj(i).vout(1:5)./obj(i).ibias(1:5));
%                         mS(i) = nanmean(obj(i).vout(end-5:end-1)./obj(i).ibias(end-5:end-1));
                    end
%                     mN = prctile(mN,75);
%                     mS = prctile(mS,75);
                    
                case AlgMethdsAvailable{2} % 'Norm-Sup crossing point'
                    %                                       
                                       
                    % Se hace una estimación del offset entre ambas curvas
                    [~, indmin] = min(abs(datafitS.SLine-datafitN.NLine));
                    TES.circuit.CurrOffset.Value = datafitN.Xdata(indmin);
                    YOffset = datafitN.NLine(indmin);
                    XOffset = TES.circuit.CurrOffset.Value;
                    
                    plot(ax1,(datafitN.Xdata-XOffset)*1e6,datafitN.NLine-YOffset,'.g')
                    
                    for i = 1:length(obj)
                        
                        % Se corrige el offset de cada curva IV                        
                        obj(i).ibias = obj(i).ibias-XOffset;
                        obj(i).vout = obj(i).vout-YOffset;
                        obj(i).YOffset = YOffset;
                        
                        plot(ax1,obj(i).ibias*1e6,obj(i).vout,'DisplayName',[num2str(obj(i).Tbath*1e3) ' ' obj(i).range])
                        if strcmp(obj(i).range,'NegIbias')
                            plot(ax1,obj(i).ibias*1e6,obj(i).vout,'DisplayName',[num2str(obj(i).Tbath*1e3) ' ' obj(i).range])
                        end
                        obj(i).good = 1;
                    end                                                                                          
                    %pause;
                case AlgMethdsAvailable{3} % 'Set Offset Manually'
                
                    for i = 1:length(obj)                                                                        
                        plot(ax1,obj(i).ibias*1e6,obj(i).vout,'DisplayName',[num2str(obj(i).Tbath*1e3) ' ' obj(i).range])
                        if strcmp(obj(i).range,'NegIbias')
                            plot(ax1,obj(i).ibias*1e6,obj(i).vout,'DisplayName',[num2str(obj(i).Tbath*1e3) ' ' obj(i).range])
                        end                        
                    end    
                    
                    waitfor(msgbox('Zoom in around crossing IV-curves to improve accuracy before close this window.',obj(1).version));
                    [XOffset, YOffset] = ginput(1);
                    TES.circuit.CurrOffset.Value = XOffset*1e-6;
                    cla(ax1)
                    for i = 1:length(obj)                        
                        % Se corrige el offset de cada curva IV                        
                        obj(i).ibias = obj(i).ibias-XOffset*1e-6;
                        obj(i).vout = obj(i).vout-YOffset;
                        obj(i).YOffset = YOffset;
                        
                        plot(ax1,obj(i).ibias*1e6,obj(i).vout,'DisplayName',[num2str(obj(i).Tbath*1e3) ' ' obj(i).range])
                        if strcmp(obj(i).range,'NegIbias')
                            plot(ax1,obj(i).ibias*1e6,obj(i).vout,'DisplayName',[num2str(obj(i).Tbath*1e3) ' ' obj(i).range])
                        end
                        obj(i).good = 1;
                    end     
%                     pause;

                case AlgMethdsAvailable{4} %'Remove quantum SQUID step'
                    c = distinguishable_colors(length(obj));
                    color_select = [0.8 0.8 0.8];
                    
                    % Pintar todas las gráficas IV
                    for i = 1:length(obj)
                        color = c(i,:);
                        hb(i) = plot(ax1,obj(i).ibias*1e6,obj(i).vout,'DisplayName',[num2str(obj(i).Tbath*1e3) ' ' obj(i).range],...
                            'ButtonDownFcn',{@IVSquidStep},'Tag',obj(i).file,'Color',color,'UserData',obj);
                        if strcmp(obj(i).range,'NegIbias')
                            hbn(i) = plot(ax1,obj(i).ibias*1e6,obj(i).vout,'DisplayName',[num2str(obj(i).Tbath*1e3) ' ' obj(i).range],...
                                'ButtonDownFcn',{@IVSquidStep},'Tag',obj(i).file,'Color',color,'UserData',obj);
                        end
                    end
                    waitfor(msgbox('Before close this window, please select the IV curve you want to correct.',obj(1).version));
                    pause();
                      % Seleccionar la IV que se quiere corregir
                      % Seleccionar un punto de la IV que se quiere
                      % corregir y otro de la IV más Normal (mayor temperatura) para obtener un
                      % valor constante
                      % Este valor se resta a la parte de la transición a
                      % la curva IV a corregir.
                      % Este proceso se puede repetir tantas veces como el
                      % usuario considere necesario

                otherwise                    
            end
            
            
            switch obj(1).range
                case 'PosIbias'
                    StrRange = {'p'};
                case 'NegIbias'
                    StrRange = {'n'};
                otherwise
                    StrRange = {'*'};
            end
            eval(['TES.TESParam' upper(StrRange{1}) '.mN.Value = mN;']);
            eval(['TES.TESParam' upper(StrRange{1}) '.mS.Value = mS;']);
            eval(['TES.TESParam' upper(StrRange{1}) ' = RnRparCalc(TES.TESParam' upper(StrRange{1}) ',TES.circuit);']);
            eval(['obj = obj.GetIVTES(TES.circuit,TES.TESParam' upper(StrRange{1}) ',TES.TESThermal' upper(StrRange{1}) ');']);
        end        
        
        function [DataFit,Xcros,Ycros,SlopeN,SlopeS] = IV_estimation_mN_mS(obj,ibias,vout,ax1)
            
            [ibias, Id] = unique(ibias);
            vout = vout(Id);
            [~, I] = sort(abs(ibias),'descend');
            ibias = ibias(I);
            vout = vout(I);
            
            Xdata = ((5:-0.00001:-5)*1e-6)*median(sign(ibias(1:10)));
            DataFit.Xdata = Xdata;
            
            ind = find(sign(ibias) == median(sign(ibias(1:10))));
            vout = vout(ind);
            ibias = ibias(ind);
            
            pend = diff(vout)./diff(ibias);
%             pend = diff(vout./ibias);
            pend(pend <= 0) = NaN;
            
            MaxP = max(pend);
            MinP = min(pend);
            Thres = (MaxP-MinP)/2 +MinP;
            
            XN = NaN;
            XS = NaN;
            [h1,X] = hist(pend,700);  
%             h1(1) = 0; % Proteccion ante falsas detecciones
            [~,ind] = find(h1 == max(h1(X < Thres)),1,'last');            
            XN = X(ind);
            hL = length(h1(X < Thres));
            [~,ind] = find((h1(X > Thres)));
            XS = nanmean(X(ind+hL));
            
            if isempty(XN)||isempty(XS)
                
                dataPN = vout(1:10);
                dataXPN = ibias(1:10);
                PN = polyfit(dataXPN,dataPN,1);
                NLine = polyval(PN,Xdata);
                DataFit.NLine = NLine;                
                DataFit.PN = PN;
                
                SlopeN = 1/PN(1);
                
                DataFit.SLine = NaN;
                DataFit.PS = [NaN NaN];
                SlopeS = NaN;
                Xcros = NaN;
                Ycros = NaN;
                DataFit.Xcros = NaN;
                DataFit.Ycros = NaN;
                return;
            end
            if ~isempty(XN)
                try
%                     indPN = find(abs((pend-XN)*100/XN) < 5); % 5 porciento de error relativo
%                     dataPN = vout([indPN; indPN(end)+1]);
%                     dataXPN = ibias([indPN; indPN(end)+1]);
                    
                    dataPN = vout;
                    dataXPN = ibias;
                    % Considerando una recta
%                     PN = polyfit(dataXPN,dataPN,1);
%                     SlopeN = 1/PN(1);
                    % Considerando una parábola muy suave
                    PN = polyfit(dataXPN,dataPN,2);
                    SlopeN = 1/PN(2);
                    
                    % Considero una recta
                    NLine = spline(dataXPN,dataPN,Xdata);
%                     NLine = polyval(PN,Xdata);
                    DataFit.NLine = NLine;
                    DataFit.PN = PN;
                    
                catch
                    PN = [NaN NaN];
                    DataFit.NLine = NaN;
                    DataFit.PN = PN;
                    SlopeN = NaN;
                end
            end
            
            if ~isempty(XS)
                try
                    indPS = find(abs((pend-XS)*100/XS) < 5); % 5 porciento de error relativo
                    dataPS = vout([indPS; indPS(end)+1]);
                    dataXPS = ibias([indPS; indPS(end)+1]);
                    PS = polyfit(dataXPS,dataPS,1);
                    SLine = polyval(PS,Xdata);
                    DataFit.SLine = SLine;
                    DataFit.PS = PS;
                    SlopeS = 1/PS(1);
                catch
                    PS = [NaN NaN];
                    DataFit.SLine = NaN;
                    DataFit.PS = PS;
                    SlopeS = NaN;
                end
            else
                PS = [NaN NaN];
                DataFit.SLine = NaN;
                DataFit.PS = PS;
                SlopeS = NaN;
            end
            
            try
                Xcros = (PS(2)-PN(2))/(PN(1)-PS(1));
                Ycros = polyval(PS,Xcros);
            catch
                Xcros = NaN;
                Ycros = NaN;
            end
            DataFit.Xcros = Xcros;
            DataFit.Ycros = Ycros;            
                       
        end

        function obj = GetIVTES(obj,circuit,TESParam,TESThermal)
            % Function to estimate ptes, Rtes and rtes from I-V curves
            
            F = circuit.invMin.Value/(circuit.invMf.Value*circuit.Rf.Value);%36.51e-6;
            for i = 1:length(obj)
                obj(i).ites = obj(i).vout*F;
                Vs = (obj(i).ibias-obj(i).ites)*circuit.Rsh.Value;%(ibias*1e-6-ites)*Rsh;if Ib in uA.
                
                obj(i).vtes = Vs-obj(i).ites*TESParam.Rpar.Value;
                obj(i).ptes = obj(i).vtes.*obj(i).ites;
                obj(i).Rtes = obj(i).vtes./obj(i).ites;
                obj(i).rtes = obj(i).Rtes/TESParam.Rn.Value;
                
%                 figure,plot(obj(i).rtes,obj(i).ptes*1e12)
%                 if min(obj(i).rtes) > 0.05 || max(obj(i).rtes) > 1
%                     obj(i).good = 0;
%                 end
%                 if min(obj(i).rtes) > 0.5 || max(obj(i).rtes) > 1.1
%                     obj(i).good = 0;
%                 end
                if ~isempty(TESThermal.n.Value)
                    obj(i).ttes = (obj(i).ptes./[TESThermal.K.Value]+obj(i).Tbath.^([TESThermal.n.Value])).^(1./[TESThermal.n.Value]);
                    smT = smooth(obj(i).ttes,3);
                    smI = smooth(obj(i).ites,3);
                    %%%%alfa y beta from IV
                    obj(i).rp2 = 0.5*(obj(i).rtes(1:end-1) + obj(i).rtes(2:end));%%% el vector de X.
                    obj(i).aIV = diff(log(obj(i).Rtes))./diff(log(smT));
                    obj(i).bIV = diff(log(obj(i).Rtes))./diff(log(smI));
                end
            end
%             pause;
        end
        
        function [obj,TempLims,TESDATA] = ImportFromFiles(obj,TESDATA,DataPath,TempLims)
            % Function to import I-V curves from Path restricting
            % temperature range.
            
            if ~exist('DataPath','var')
                DataPath = [];
            end
            
            if ~exist('TempLims','var')
                prompt = {'Mimimun temperature (mK):','Maximum temperature (mK):'};
                name = 'Input for limiting Temp for analysis';
                numlines = 1;
                defaultanswer = {'10','250'};
                answer = inputdlg(prompt,name,numlines,defaultanswer);
                
                if isempty(char(answer))
                    waitfor(msgbox('Cancelled by user',obj.version));
                    TempLims = [];
                    return;
%                     TempLims = [0 Inf];
                else
                    TempLims(1) = str2double(answer{1});
                    TempLims(2) = str2double(answer{2});
                end
                if any(isnan(TempLims))
                    errordlg('Invalid temperature values!',obj.version, 'modal');
                    return;
                end
            end
            if nargin ~= 4
                IVsPath = uigetdir(DataPath, 'Pick a Data path named IVs');
                if IVsPath ~= 0
                    IVsPath = [IVsPath filesep];
                else
                    errordlg('Invalid Data path name!',obj.version,'modal');
                    return;
                end
                obj(1).IVsetPath = IVsPath;
            else
                IVsPath = DataPath;
                obj(1).IVsetPath = DataPath;
            end
            switch obj(1).range
                case 'PosIbias'
                    StrRange = {'p'};
                    IdRange = 1;
                case 'NegIbias'
                    StrRange = {'n'};
                    IdRange = 1;
                otherwise
                    StrRange = {'*'};
                    IdRange = 1;                    
            end
            
            for j = IdRange
                
                eval([upper(StrRange{j}) 'files = ls(''' IVsPath '*_' StrRange{j} '_matlab.txt'');']);
                
                if isempty(eval([upper(StrRange{j}) 'files']))
                    eval([upper(StrRange{j}) 'files = ls(''' IVsPath '*_' StrRange{j} '_*'');']);
                end
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
                eval(['[obj, Rf] = obj.ImportFullIV(''' IVsPath ''',' upper(StrRange{j}) 'files);']);
%                 if isempty(mN)
%                     return;
%                 end
                TESDATA.circuit.Rf.Value = Rf;
%                 mN = 1938;
%                 mS = 25280;
                
            end
        end
        
        function [obj,mN, mS] = IVs_Slopes(obj,fig)
            % Function to estimate mN and mS from I-V curve data
            %
            % The method is based on the derivative I-V curve. There,
            % variations greater than a tolerance are enough to discard
            % I-V curve transition phase values. Then, a threshold value
            % separates data into two clusters. Values greater than
            % threshold correspond to mS, mS is computed as the median value of
            % data distribution. Values below the threshold
            % are related to mN. mN is computed as the
            % (3er-quartile-median)/2, since distribution is corrupted by
            % transition phase values that shift the distribution to lower
            % values. In addition, mN could be computed by a zero cross
            % linear fitting.
            
            if nargin == 2
                fig = figure;
            end
            if exist('fig','var')
                ax(1) = subplot(1,2,1);
                hold(ax(1),'on');
                grid(ax(1),'on');
                ax(2) = subplot(1,2,2);
                hold(ax(2),'on');
                grid(ax(2),'on');
            end
            tolerance = 4;
            
            iOK = 1;
            for i = 1:length(obj)
                try
                ibias = obj(iOK).ibias;
                vout = obj(iOK).vout;
                
                Derv = diff(vout)./diff(ibias);
                Dervx = ibias(2:end);
                
                Diffs = diff(Derv);
                Diffsx = ibias(3:end);
                ind = find(abs(Diffs) <= tolerance);
                
                Derivada{iOK} = Derv(ind);
                Derivadax{iOK} = Dervx(ind);
                
                ind_erase = find(Derv(ind) <= 0);
                Derivada{iOK}(ind_erase) = [];
                ind(ind_erase) = [];
                indx{iOK} = ibias(ind(1:end-1));
                indy{iOK} = vout(ind(1:end-1));
                
                indxS{iOK} = ibias(ind(end));
                indyS{iOK} = vout(ind(end));
                iOK = iOK+1;
                catch
                    
                end
                
                if nargin == 2
                    plot(ax(1),ibias*1e6,vout)
                    plot(ax(1),ibias(ind+1)*1e6,vout(ind+1),'.r')
                    
                    xlabel(ax(1),'I_{bias} (\muA)','FontSize',12,'FontWeight','bold');
                    ylabel(ax(1),'Vout (V)','FontSize',12,'FontWeight','bold');
                    set(ax(1),'FontSize',12,'FontWeight','bold','LineWidth',2,'Box','on');
                end
            end
            
            Pendientes = cell2mat(Derivada');
            MaxP = max(Pendientes);
            MinP = min(Pendientes);
            Thres = (MaxP-MinP)/2;
            
            mNvalues = Pendientes(Pendientes < Thres);
            mSvalues = Pendientes(Pendientes > Thres);
            
            Values = nan(max(length(mNvalues),length(mSvalues)),2);
            Values(1:length(mNvalues),1) = mNvalues;
            Values(1:length(mSvalues),2) = mSvalues;
            if nargin == 2
                boxplot(ax(2),Values);
                set(ax(2),'XTick',[1 2],'XTickLabel',{'Normal';'SuperC'})
                ylabel(ax(2),'Slopes (V/\muA)','FontSize',12,'FontWeight','bold');
                set(ax(2),'FontSize',12,'FontWeight','bold','LineWidth',2,'Box','on');
            end
            
            mN1 = (prctile(Pendientes(Pendientes < Thres),75)-nanmedian(Pendientes(Pendientes < Thres)))/2+nanmedian(Pendientes(Pendientes < Thres));
            mS = nanmedian(Pendientes(Pendientes > Thres));            
            mN = mN1;
            if nargin == 2
                plot(ax(1),sort(unique(cell2mat(indx')))*1e6,sort(unique(cell2mat(indx')))*mN,'-m')
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
            
            c = distinguishable_colors(length(obj));
            for i = 1:length(obj)
                if obj(i).good
                    color = c(i,:);
                else
                    color = [0.8 0.8 0.8];
                end
                    
                    Ibias = obj(i).ibias;
                    Vout = obj(i).vout;
                    Vtes = obj(i).vtes;
                    Ites = obj(i).ites;
                    
                    %curva Vout-Ibias
                    if ~isfield(fig,'subplots')
                        h(1) = subplot(2,2,1);
                    end
                    try
                        h_ib(j) = plot(h(1),Ibias*1e6,Vout,'.--','DisplayName',[num2str(obj(i).Tbath*1e3) ' mK -' obj(1).range],...
                            'ButtonDownFcn',{@ChangeGoodOpt},'Tag',obj(i).file,'Color',color);
                    catch
                        h_ib(j) = plot(h(1),Ibias*1e6,Vout,'.--','DisplayName',[num2str(obj(i).Tbath*1e3) ' mK -' obj(1).range],...
                            'ButtonDownFcn',[],'Tag','','Color',color);
                    end
                    grid(h(1),'on'),hold(h(1),'on');
                    xlim(h(1),[min(0,sign(Ibias(1))*500) 500]) %%%Podemos controlar apariencia con esto. 300->500
                    xlabel(h(1),'Ibias(\muA)','FontWeight','bold');ylabel(h(1),'Vout(V)','FontWeight','bold');
                    if strcmp(h(1).Box,'off')
                        set(h(1),'FontSize',12,'FontWeight','bold','Box','on','LineWidth',2)
                    end
                    %Curva Ites-Vtes
                    if ~isfield(fig,'subplots')
                        h(3) = subplot(2,2,3);
                    end
                    try
                        h_ites(j) = plot(h(3),obj(i).vtes*1e6,obj(i).ites*1e6,'.--','DisplayName',[num2str(obj(i).Tbath*1e3) ' mK -' obj(1).range],...
                            'ButtonDownFcn',{@ChangeGoodOpt},'Tag',obj(i).file,'Color',color);
                    catch
                        h_ites(j) = plot(h(3),obj(i).vtes*1e6,obj(i).ites*1e6,'.--','DisplayName',[num2str(obj(i).Tbath*1e3) ' mK -' obj(1).range],...
                            'ButtonDownFcn',[],'Tag','','Color',color);
                    end

                    grid(h(3),'on'),hold(h(3),'on');
                    xlim(h(3),[min(0,sign(Ibias(1))*.5) .5])
                    xlabel(h(3),'V_{TES}(\muV)','FontWeight','bold');ylabel(h(3),'Ites(\muA)','FontWeight','bold');
                    if strcmp(h(3).Box,'off')
                        set(h(3),'FontSize',12,'LineWidth',2,'Box','on','FontWeight','bold')
                    end
                    %Curva Ptes-Vtes
                    if ~isfield(fig,'subplots')
                        h(2) = subplot(2,2,2);
                    end
                    try
                        h_ptes(j) = plot(h(2),obj(i).vtes*1e6,obj(i).ptes*1e12,'.--','DisplayName',[num2str(obj(i).Tbath*1e3) ' mK -' obj(1).range],...
                            'ButtonDownFcn',{@ChangeGoodOpt},'Tag',obj(i).file,'Color',color);
                    catch
                        h_ptes(j) = plot(h(2),obj(i).vtes*1e6,obj(i).ptes*1e12,'.--','DisplayName',[num2str(obj(i).Tbath*1e3) ' mK -' obj(1).range],...
                            'ButtonDownFcn',[],'Tag','','Color',color);
                    end
                    grid(h(2),'on'),hold(h(2),'on');
                    xlim(h(2),[min(0,sign(Ibias(1))*1.0) 1.0])%%%Podemos controlar apariencia con esto. 0.5->1.0
                    xlabel(h(2),'V_{TES}(\muV)','FontWeight','bold');ylabel(h(2),'Ptes(pW)','FontWeight','bold');
                    if strcmp(h(2).Box,'off')
                        set(h(2),'FontSize',12,'LineWidth',2,'Box','on','FontWeight','bold')
                    end
                    %Curva Ptes-rtes
                    if ~isfield(fig,'subplots')
                        h(4) = subplot(2,2,4);
                    end
                    try
                        h_rtes(j) = plot(h(4),obj(i).rtes,obj(i).ptes*1e12,'.--','DisplayName',[num2str(obj(i).Tbath*1e3) ' mK -' obj(1).range],...
                            'ButtonDownFcn',{@ChangeGoodOpt},'Tag',obj(i).file,'Color',color);
                    catch
                        h_rtes(j) = plot(h(4),obj(i).rtes,obj(i).ptes*1e12,'.--','DisplayName',[num2str(obj(i).Tbath*1e3) ' mK -' obj(1).range],...
                            'ButtonDownFcn',[],'Tag','','Color',color);
                    end
                    grid(h(4),'on'),hold(h(4),'on');
                    xlim(h(4),[0 1]), ylim(h(4),[0 20]);
                    xlabel(h(4),'R_{TES}/R_n','FontWeight','bold');ylabel(h(4),'Ptes(pW)','FontWeight','bold');
                    if strcmp(h(4).Box,'off')
                        set(h(4),'FontSize',12,'LineWidth',2,'Box','on','FontWeight','bold')
                    end
                    
                    
                    j = j+1;
%                 end
                    set(h,'FontUnits','Normalized');
                    if ~isfield(fig,'subplots')
                        fig.subplots = h;
                    end
            end
            try
                axis(h,'tight');
                set([h_ib h_ites h_ptes h_rtes],'UserData',obj);
                %             linkprop([h_ib h_ites h_ptes h_rtes],'Color');
                set(fig.hObject,'UserData',obj);
                xlim(h(4),[0 1]);
            end
        end              
        
    end
end

