classdef TES_Struct
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        circuit;
        TFS;
        IVsetP;
        IVsetN;
        GsetP;
        GsetN;
        TFOpt;
        NoiseOpt;        
        PP;
        PN;
        TES;
        JohnsonExcess = [1e4 4.5e4];
        PhononExcess = [1e2 1e3];
        Report;
    end
    
    methods
        function obj = Constructor(obj)
            obj.circuit = TES_Circuit;
            obj.circuit = obj.circuit.Constructor;
            obj.TFS = TES_TFS;
            obj.IVsetP = TES_IVCurveSet;
            obj.IVsetP = obj.IVsetP.Constructor;
            obj.IVsetN = TES_IVCurveSet;
            obj.IVsetN = obj.IVsetN.Constructor(1);
            obj.GsetP = TES_Gset;
            obj.GsetN = TES_Gset;
            obj.TFOpt = TES_TF_Opt;
            obj.NoiseOpt = TES_Noise;
            obj.PP = TES_P;
            obj.PP = obj.PP.Constructor;
            obj.PN = TES_P;
            obj.PN = obj.PN.Constructor;
            obj.TES = TES_Param;
            obj.Report = TES_Report;
        end        
        
        function obj = CheckIVCurvesVisually(obj)
            
            figIV = []; %#ok<NASGU>
            StrRange = {'p';'n'};
            for j = 1:length(StrRange)
                eval(['figIV = plotIVs(obj.IVset' upper(StrRange{j}) ',figIV);']);
                
                % Revisar las curvas IV y seleccionar aquellas para eliminar del
                % analisis
                h = helpdlg('Before closing this message, please check the IV curves','ZarTES v1.0');
                true = 1;
                while true
                    pause(0.1);
                    if ~ishandle(h)
                        true = 0;
                    end
                    pause(0.1);
                end
                eval(['obj.IVset' upper(StrRange{j}) ' = get(figIV.hObject,''UserData'');']); %#ok<UNRCH>
            end
        end                       
        
        function obj = fitPvsTset(obj,perc,model)
            %funcion para ajustar automaticamente curvas P-Tbath a un valor o valores
            %de porcentaje de Rn. Ojo al uso de cells o arrays en IVset.
            % varargin{1}=modelo [1, 2 o 3].
            if ~exist('perc','var')
                % Extracting the range automatically
                j = 1;
                for i = 1:size(obj.IVsetP,2)+size(obj.IVsetN,2)
                    if i <= size(obj.IVsetP,2)
                        diffptes = abs(diff(obj.IVsetP(j).ptes));
                        x = obj.IVsetP(j).rtes;
                        indx = find(obj.IVsetP(j).rtes > 0.005);
                        x = x(indx);
                    else
                        diffptes = abs(diff(obj.IVsetN(j).ptes));
                        x = obj.IVsetN(j).rtes;
                        indx = find(obj.IVsetN(j).rtes > 0.005);
                        x = x(indx);
                    end
                    diffptes = diffptes(indx);
                    range = find(diffptes > nanmedian(diffptes)+0.01*max(diffptes));
                    minrange(i,1) = x(range(end));
                    maxrange(i,1) = x(range(end-1));
                    %                 figure,plot(x(find(diffptes > nanmedian(diffptes)+0.005*max(diffptes))),diffptes(find(diffptes > nanmedian(diffptes)+0.005*max(diffptes))),'r*')
                    %                 hold on
                    %                 plot(x,diffptes)
                    if i == size(obj.IVsetP,2)
                        j = 1;
                    else
                        j = j+1;
                    end
                end
                minrange = min(ceil(max(minrange)*1e2)/1e2,0.2);
                maxrange = max(floor(min(maxrange)*1e2)/1e2,0.85);
                %             perc = (minrange:0.01:maxrange);
                
                warning off;
                
                prompt={'Enter the Rn range:'};
                name='Rn range to automatically fit P(Tbath) data';
                numlines=[1 70];
                defaultanswer={[num2str(minrange) ':0.01:' num2str(maxrange)]};
                answer=inputdlg(prompt,name,numlines,defaultanswer);
                perc = eval(answer{1});
                if ~isnumeric(perc)
                    warndlg('Invalid Rn values','ZarTES v1.0');
                    return;
                end
                
            end
            
            if ~exist('model','var')
                model = 1;
            end
            fig = figure('Name','fitP vs. Tset');
            StrRange = {'P';'N'};
            for k = 1:2
                if isempty(eval(['obj.IVset' StrRange{k} '.ibias']))
                    continue;
                end
                ax = subplot(1,2,k); hold(ax,'on');
                IVTESset = eval(['obj.IVset' StrRange{k}]);                
                for jj = 1:length(perc)
                    Paux = [];
                    Iaux = [];
                    Tbath = [];
                    kj = 1;
                    for i = 1:length(IVTESset)
                        if IVTESset(i).good                                                         
                            ind = find(IVTESset(i).rtes > 0.1 & IVTESset(i).rtes < 0.8);%%%algunas IVs fallan.
                            if isempty(ind)
                                continue;
                            end
                            Paux(kj) = ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ptes(ind)),perc(jj)); %#ok<AGROW>
                            Iaux(kj) = ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ites(ind)),perc(jj));%#ok<AGROW> %%%
                            Tbath(kj) = IVTESset(i).Tbath; %#ok<AGROW>
                            kj = kj+1;
                        else
                            Paux(kj) = nan;
                            Iaux(kj) = nan;
                            Tbath(kj) = nan;
                        end
                    end
                    Paux(isnan(Paux)) = [];
                    Iaux(isnan(Iaux)) = [];
                    Tbath(isnan(Tbath)) = [];                                                            
                    plot(ax,Tbath,Paux*1e12,'bo','markerfacecolor','b'),hold(ax,'on');
                    
                    switch model
                        case 1
                            X0 = [-500 3 1];
                            XDATA = Tbath;
                            LB = [-Inf 2 0 ];%%%Uncomment for model1
                        case 2
                            X0 = [-6500 3.03 13 1.9e4];
                            XDATA = [Tbath;Iaux*1e6];
                            LB = [-1e5 2 0 0];
                        case 3
                            auxtbath = min(Tbath):1e-4:max(Tbath);
                            auxptes = spline(Tbath,Paux,auxtbath);
                            gbaux = abs(diff(auxptes)./diff(auxtbath));
                            opts = optimset('Display','off');
                            fit2 = lsqcurvefit(@(x,tbath)x(1)+x(2)*tbath,[3 2], log(auxtbath(2:end)),log(gbaux),[],opts); %#ok<NASGU>
                            eval(['obj.Gset' StrRange{k} '(jj).n = (fit2(2)+1);']);
                            eval(['obj.Gset' StrRange{k} '(jj).K = exp(fit2(1))/obj.Gset' StrRange{k} '(jj).n;']);
                            
                            plot(ax,log(auxtbath(2:end)),log(gbaux),'.-')
                    end
                    if model ~= 3
                        opts = optimset('Display','off');
                        %                         [beta,R,J,CovB,MSE,ErrorModelInfo] = nlinfit(XDATA,Paux*1e12,@fitP,X0,opts)
                        [fit,resnorm,residual,exitflag,output,lambda,jacob] = lsqcurvefit(@fitP,X0,XDATA,Paux*1e12,LB,[],opts); %#ok<ASGLU>
                        
                        %                         MSE = (residual*residual')/(length(XDATA)-length(fit));
                        %                         ci = nlparci(fit,residual,'jacobian',jacob);
                        %                         CI = ci-fit';
                        %                         CI = abs(CI(:,1)).*sign(fit)';
                        
                        plot(ax,Tbath,fitP(fit,XDATA),'-r','linewidth',1)
                        
                        Gaux(jj) = GetGfromFit(fit);%#ok<AGROW,NASGU> %%antes se pasaba fitaux.
                        eval(['obj.Gset' StrRange{k} '(jj).n = Gaux(jj).n;']);
                        eval(['obj.Gset' StrRange{k} '(jj).K = Gaux(jj).K;']);
                        eval(['obj.Gset' StrRange{k} '(jj).Tc = Gaux(jj).Tc;']);
                        eval(['obj.Gset' StrRange{k} '(jj).G = Gaux(jj).G;']);
                    end
                    eval(['obj.Gset' StrRange{k} '(jj).rp = perc(jj);']);
                    eval(['obj.Gset' StrRange{k} '(jj).model = model;']);
                end
                xlabel(ax,'T_{bath}(K)','fontsize',11,'fontweight','bold')
                ylabel(ax,'P_{TES}(pW)','fontsize',11,'fontweight','bold')
                %title('P vs T fits','fontsize',11,'fontweight','bold')
                set(ax,'fontsize',12,'linewidth',2,'fontweight','bold')
            end
        end
        
        function obj = plotNKGTset(obj) 
            
            MS = 10; %#ok<NASGU>
            LS = 1; %#ok<NASGU>
            color{1} = [0 0.447 0.741];
            color{2} = [1 0 0]; %#ok<NASGU>
            StrField = {'n';'Tc';'K';'G'};
            StrMultiplier = {'1';'1';'1e-3';'1'}; %#ok<NASGU>
            StrLabel = {'n';'Tc(K)';'K(nW/K^n)';'G(pW/K)'};
            StrRange = {'P';'N'};
            StrIbias = {'Positive';'Negative'};
            for k = 1:2
                if isempty(eval(['obj.Gset' StrRange{k} '.n']))
                    continue;
                end
                if ~exist('fig','var')
                    fig.hObject = figure;
                end
                Gset = eval(['obj.Gset' StrRange{k}]);     %#ok<NASGU>
                if isfield(fig,'subplots')
                    h = fig.subplots;
                end
                for j = 1:length(StrField)
                    if ~isfield(fig,'subplots')
                        h(j) = subplot(2,2,j);
                        hold(h(j),'on');
                        grid(h(j),'on');
                    end
                    eval(['plot(h(j),[Gset.rp],[Gset.' StrField{j} '],''.-'','...
                        '''color'',color{k},''linewidth'',LS,''markersize'',MS,''DisplayName'',''' StrIbias{k} ''');']);
                    xlim(h(j),[0.15 0.9]);
                    xlabel(h(j),'R_{TES}/R_n','fontsize',11,'fontweight','bold');
                    ylabel(h(j),StrLabel{j},'fontsize',11,'fontweight','bold');
                    set(h(j),'linewidth',2,'fontsize',11,'fontweight','bold')
                end
                
                fig.subplots = h;
            end
            if ~exist('fig','var')
                warndlg('TESDATA.fitPvsTset must be firstly applied.','ZarTES v1.0')
                fig = [];
            end
            pause(0.2)
            waitfor(helpdlg('After closing this message, select a point for TES characterization','ZarTES v1.0'));
            figure(fig.hObject);
            [X,~] = ginput(1);
            ind_rp = find([obj.GsetP.rp] > X,1); %#ok<NASGU>

            StrField = {'n';'Tc';'K';'G'};
            TESmult = {'1';'1';'1e-12';'1e-12';};
            for i = 1:length(StrField)
                eval(['val = [obj.GsetP.' StrField{i} '];']);
                eval(['obj.TES.' StrField{i} ' = val(ind_rp)*' TESmult{i} ';']);
                
                eval(['plot(h(i),obj.GsetP(ind_rp).rp,val(ind_rp),''.-'','...
                    '''color'',''g'',''linewidth'',LS,''markersize'',1.5*MS,''DisplayName'',''Operating Point'');']);
            end
            uiwait(msgbox({['n: ' num2str(obj.TES.n)];['K: ' num2str(obj.TES.K)];...
                ['Tc: ' num2str(obj.TES.Tc) 'mK'];['G: ' num2str(obj.TES.G)]},'TES Operating Point','modal'));
        end
        
        function obj = EnterDimensions(obj)
            prompt = {'Enter height value:','Enter width value:'};
            name = 'Provide TES dimension';
            numlines = [1 50; 1 50];
            defaultanswer = {'25e-6','25e-6'};
            % De momento está para que el TES sea cuadrado
            
            answer = inputdlg(prompt,name,numlines,defaultanswer);
            if ~isempty(answer)
                obj.TES.sides = sqrt(str2double(answer{1})*str2double(answer{2}));
            end            
            
        end        
        
        function obj = FitZset(obj)
            %%%Ajuste automático de Z(w) para varias temperaturas de baño
            
            ButtonName = questdlg('Select Files Acquisition device', ...
                'ZarTES v1.0', ...
                'PXI', 'HP', 'PXI');
            switch ButtonName
                case 'PXI'
                    obj.TFOpt.TFBaseName = '\PXI_TF*';
                    obj.NoiseOpt.NoiseBaseName = '\PXI_noise*';%%%'\HP*'
                    
                case 'HP'
                    obj.TFOpt.TFBaseName = '\TF*';
                    obj.NoiseOpt.NoiseBaseName = '\HP_noise*';%%%'\HP*'
                otherwise
                    disp('PXI acquisition files were selected by default.')
                    obj.TFOpt.TFBaseName = '\PXI_TF*';
                    obj.NoiseOpt.NoiseBaseName = '\PXI_noise*';%%%'\HP*'
            end
            ButtonName = questdlg('Do you want to show the results?', ...
                'ZarTES v1.0', ...
                'Yes', 'No', 'Yes');
            switch ButtonName
                case 'Yes'
                    obj.TFOpt.boolShow = 1;
                otherwise
                    obj.TFOpt.boolShow = 0;
            end
            %%
            %%%definimos variables necesarias.
            
            StrRange = {'P';'N'};
            StrRangeExt = {'Positive Ibias Range';'Negative Ibias Range'};
            fig = nan(1,2);
            model = 1;
            
            for k1 = 1:2
                if isempty(eval(['obj.IVset' StrRange{k1} '.ibias']))
                    continue;
                end
                IVset = eval(['obj.IVset' StrRange{k1}]);
                IVsetPath = IVset(1).IVsetPath;
                if k1 == 1
                    indt = find(IVsetPath == filesep);
                    IVsetPath = IVsetPath(1:indt(end-1));
                    str = dir([IVsetPath '*mK']);
                else
                    ind = find(IVsetPath == filesep);
                    IVsetPath = [IVsetPath(1:ind(end-1)) 'Negative Bias' filesep];
                    str = dir([IVsetPath '*mK']);
                end
                k = 1;
                dirs = {[]};
                for jjj = 1:length(str)
                    if str(jjj).isdir
                        if isempty(strfind(str(jjj).name,'('))
                            dirs{k} = [IVsetPath str(jjj).name]; %#ok<*PROP>
                            k = k+1;
                        end
                    end
                end
                h_i = 1;
                h = nan(1,50);
                g = nan(1,50);
                
                H = multiwaitbar(2,[0 0],{'Folder(s)','File(s)'});
                H.figure.Name = 'Z(w) Analysis';
                for i = 1:length(dirs)
                    %%%buscamos los ficheros a analizar en cada directorio.
                    D = [dirs{i} obj.TFOpt.TFBaseName];
                    filesZ = ListInBiasOrder(D);
                    if isempty(filesZ)
                        continue;
                    end
                    
                    D = [dirs{i} obj.NoiseOpt.NoiseBaseName];                    
                    filesNoise = ListInBiasOrder(D);
                    
                    indSep = find(dirs{i} == filesep);
                    Path = dirs{i}(indSep(end)+1:end);
                    Tbath = sscanf(Path,'%dmK\');
                    %%%hacemos loop en cada fichero a analizar.
                    k = 1;
                    ImZmin = nan(1,length(filesZ));
                    jj = 1;
                    for j1 = 1:length(filesZ)
                        NameStr = filesZ{j1};
                        NameStr(NameStr == '_') = ' ';
                        if ishandle(H.figure)
                            multiwaitbar(2,[i/length(dirs) j1/length(filesZ)],{Path,NameStr},H);
                        else
                            H = multiwaitbar(2,[i/length(dirs) j1/length(filesZ)],{Path,NameStr});
                            H.figure.Name = 'ZarTES v1.0';
                        end
                        thefile = strcat(dirs{i},'\',filesZ{j1});
                        
                        [param, ztes, fZ, ERP, CI, aux1, StrModel, p0] = obj.FitZ(thefile);                                                                                                
                        
                        if param.rp > 1 || param.rp < 0
                            continue;
                        end
                        paramList = fieldnames(param);
                        for pm = 1:length(paramList)
                            eval(['obj.P' StrRange{k1} '(i).p(jj).' paramList{pm} ' = param.' paramList{pm} ';']);
                        end
                        eval(['obj.P' StrRange{k1} '(i).CI{jj} = CI;']);
                        eval(['obj.P' StrRange{k1} '(i).residuo(jj) = aux1;']);
                        eval(['obj.P' StrRange{k1} '(i).fileZ(jj) = {[dirs{i} filesep filesZ{j1}]};']);
                        eval(['obj.P' StrRange{k1} '(i).ElecThermModel(jj) = {StrModel};']);                              
                        eval(['obj.P' StrRange{k1} '(i).ztes{jj} = ztes;']);
                        eval(['obj.P' StrRange{k1} '(i).fZ{jj} = fZ;']);
                        eval(['obj.P' StrRange{k1} '(i).ERP{jj} = ERP;']);
                        %%%%%%%%%%%%%%%%%%%%%%Pintamos Gráficas
                        
                        if obj.TFOpt.boolShow
                            if jj == 1
                                fig(i) = figure('Name',Path);
                                ax = axes;
                            end
                            ind = 1:3:length(ztes);
                            
                            h(h_i) = plot(ax,1e3*ztes(ind),'.','color',[0 0.447 0.741],...
                                'markerfacecolor',[0 0.447 0.741],'markersize',15,'ButtonDownFcn',{@ChangeGoodOptP},'Tag',[dirs{i} filesep filesZ{jj}]);
                            grid(ax,'on');
                            hold(ax,'on');%%% Paso marker de 'o' a '.'
                            set(ax,'linewidth',2,'fontsize',12,'fontweight','bold');
                            xlabel(ax,'Re(mZ)','fontsize',12,'fontweight','bold');
                            ylabel(ax,'Im(mZ)','fontsize',12,'fontweight','bold');%title('Ztes with fits (red)');
                            ImZmin(jj) = min(imag(1e3*ztes));
                            ylim(ax,[min(-15,min(ImZmin)-1) 1])                            
                            g(h_i) = plot(ax,1e3*fZ(:,1),1e3*fZ(:,2),'r','linewidth',2,...
                                'ButtonDownFcn',{@ChangeGoodOptP},'Tag',[dirs{i} filesep filesZ{jj} ':fit']);hold(ax,'on');                            
                            set([h(h_i) g(h_i)],'UserData',[h(h_i) g(h_i)]);
                        end                                                
                        if k == 1 || jj == length(filesZ)
                            aux_str = strcat(num2str(round(param.rp*100)),'% R_n'); %#ok<NASGU>
                        end
                        k = k+1;
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        %%%Analizamos el ruido
                        if ~isempty(filesNoise)
                            if i == 1 && j1 == 1
                                H1 = multiwaitbar(2,[0 0],{Path,NameStr});
                                H1.figure.Name = 'Noise Analysis';
                            end
                            NameStr = filesNoise{j1};
                            NameStr(NameStr == '_') = ' ';
                            if ishandle(H1.figure)
                                multiwaitbar(2,[i/length(dirs) j1/length(filesNoise)],{Path,NameStr},H1);
                            else
                                H1 = multiwaitbar(2,[i/length(dirs) j1/length(filesNoise)],{Path,NameStr});
                                H1.figure.Name = 'Noise Analysis';
                            end
                            FileName = [dirs{i} filesep filesNoise{j1}];
                            [RES, SimRes, M, Mph, fNoise, SigNoise] = obj.fitNoise(FileName, param);  
                            
%                             f_DS = fNoise(1:3:end);
%                             
%                             f_DS = logspace(log10(fNoise(1)),log10(fNoise(end)),321)';
%                             SigNoise_DS =spline(fNoise,SigNoise,f_DS);
                            
                            eval(['obj.P' StrRange{k1} '(i).p(jj).ExRes = RES;']);
                            eval(['obj.P' StrRange{k1} '(i).p(jj).ThRes = SimRes;']);
                            eval(['obj.P' StrRange{k1} '(i).fileNoise(jj) = {FileName};']);
                            eval(['obj.P' StrRange{k1} '(i).NoiseModel(jj) = {obj.NoiseOpt.NoiseModel};']);
                            eval(['obj.P' StrRange{k1} '(i).fNoise{jj} = fNoise;']);
                            eval(['obj.P' StrRange{k1} '(i).SigNoise{jj} = SigNoise;']);
                            eval(['obj.P' StrRange{k1} '(i).p(jj).M = M;']);
                            eval(['obj.P' StrRange{k1} '(i).p(jj).Mph = Mph;']);
                                             
                        end
                        h_i = h_i+1;
                        jj = jj+1;
                    end
                    eval(['obj.P' StrRange{k1} '(i).Tbath = Tbath*1e-3;;']);
                    
                end
                eval(['dat.P = obj.P' StrRange{k1} ';']);
                
                try                    
                    if ishandle(H.figure)
                        delete(H.figure)
                        clear('H')
                    end
                    if ishandle(H1.figure)
                        delete(H1.figure)
                        clear('H1')
                    end                                        
                catch
                end
                if obj.TFOpt.boolShow
                    dat.fig = fig;
                    set(fig,'UserData',dat);
                    pause(0.2)
                    waitfor(helpdlg('After closing this message, check the validity of the curves and fittings','ZarTES v1.0'));
                    Data = get(fig(1),'UserData'); %#ok<NASGU>
                    eval(['obj.P' StrRange{k1} ' = Data.P;']);
                end                                
                % Capar los datos de forma que no puedan existir valores porl
                % encima de 1 y por debajo de 0
                % Además tendríamos que hacer un sort para que se pinten en
                % orden ascendente
                eval(['a = cell2mat(obj.P' StrRange{k1} '(k1).CI)'';']);
                eval(['[rp,rpjj] =sort([obj.P' StrRange{k1} '(k1).p.rp]);']);
                if ~isempty(rp)
                    
                    switch model
                        case 1
                            StrModelPar = {'Zinf';'Z0';'taueff'};          % 3 parameters
                        case 2
                            StrModelPar = {'Zinf';'Z0';'taueff';'ca0';'tauA'};
                        case 3
                            StrModelPar = {'Zinf';'Z0';'taueff';'tau1';'tau2';'d1';'d2'};
                    end
                    figParam(k1) = figure; %#ok<AGROW>
                    as = nan(1,length(StrModelPar));
                    for i = 1:length(StrModelPar)
                        as(i) = subplot(1,length(StrModelPar),i);
                        eval(['errorbar(as(i),rp,[obj.P' StrRange{k1} '(k1).p(rpjj).' StrModelPar{i} '],'...
                            'a(rpjj,1),''LineStyle'',''-.'',''Marker'',''.'',''MarkerEdgeColor'',[1 0 0]);'])
                        xlabel(as(i),'R_{TES}/R_n','fontsize',12,'fontweight','bold');
                        ylabel(as(i),StrModelPar{i},'fontsize',12,'fontweight','bold');
                        grid(as(i),'on');
                        hold(as(i),'on');
                    end
                    set(as,'linewidth',2,'fontsize',12,'fontweight','bold');
                    figParam(k1).Name = ['Thermal Model Parameters Evolution: ' StrRangeExt{k1}]; %#ok<AGROW>                    
                end
                
            end
        end        
        
        function [param, ztes, fZ, ERP, CI, aux1, StrModel, p0] = FitZ(obj,FileName)
            
            indSep = find(FileName == filesep);
            Path = FileName(1:indSep(end));            
            Name = FileName(find(FileName == filesep, 1, 'last' )+1:end);
            Tbath = sscanf(FileName(indSep(end-1)+1:indSep(end)),'%dmK\');
            Ib = str2double(Name(find(Name == '_', 1, 'last')+1:strfind(Name,'uA.txt')-1))*1e-6;
            % Buscamos si es Ibias positivos o negativos
            if ~isempty(strfind(Path,'Negative Bias'))
                [~,Tind] = min(abs([obj.IVsetN.Tbath]*1e3-Tbath));
                IV = obj.IVsetN(Tind);
                CondStr = 'N';
            else
                [~,Tind] = min(abs([obj.IVsetP.Tbath]*1e3-Tbath));
                IV = obj.IVsetP(Tind);
                CondStr = 'P';                        
            end
            % Primero valoramos que este en la lista            
            filesZ = ListInBiasOrder([Path obj.TFOpt.TFBaseName])';
            SearchFiles = strfind(filesZ,Name);
            for i = 1:length(filesZ)
                if ~isempty(SearchFiles{i})
                    IndFile = i;
                    break;
                end
            end
            fS = obj.TFS.f;            
            try
                eval(['[~,Tind] = find(abs([obj.P' CondStr '.Tbath]*1e3-Tbath)==0);']);
                eval(['ztes = obj.P' CondStr '(Tind).ztes{IndFile};'])
                if isempty(ztes)
                    error;
                end
            catch
                data = importdata(FileName);
                tf = data(:,2)+1i*data(:,3);
                Rth = obj.circuit.Rsh+obj.circuit.Rpar+2*pi*obj.circuit.L*data(:,1)*1i;
                ztes = (obj.TFS.tf./tf-1).*Rth;
            end
            
            Zinf = real(ztes(end));
            Z0 = real(ztes(1));
            [~,indfS] = min(imag(ztes));
            tau0 = 1/(2*pi*fS(indfS));
            opts = optimset('Display','off');
            switch obj.TFOpt.ElecThermModel
                case 'One Single Thermal Block'
                    p0 = [Zinf Z0 tau0];          % 3 parameters
                    StrModel = 'One Single Thermal Block';
                case 'Two Thermal Blocks (Specify which)'
                    ca0 = 1e-1;
                    tauA = 1e-6;
                    p0 = [Zinf Z0 tau0 ca0 tauA];%%%p0 for 2 block model.  % 5 parameters
                    StrModel = 'Two Thermal Blocks (Specify which)'; 
                case 'Three Thermal Blocks (Specify which)'
                    tau1 = 1e-5;
                    tau2 = 1e-5;
                    d1 = 0.8;
                    d2 = 0.1;
                    p0 = [Zinf Z0 tau0 tau1 tau2 d1 d2];%%%p0 for 3 block model.   % 7 parameters
                    StrModel = 'Three Thermal Blocks (Specify which)'; 
            end
            
            [p,aux1,aux2,aux3,out,lambda,jacob] = lsqcurvefit(@fitZ,p0,fS,...
                [real(ztes) imag(ztes)],[],[],opts);%#ok<ASGLU> %%%uncomment for real parameters.
            MSE = (aux2'*aux2)/(length(fS)-length(p)); %#ok<NASGU>
            ci = nlparci(p,aux2,'jacobian',jacob);
            CI = ci(:,1)'-p;
            CI = abs(CI).*sign(p);
            p_CI = [p; CI];
            param = GetModelParameters(p_CI,IV,Ib,obj);
            fZ = fitZ(p,fS);            
            ERP = sum(abs(abs(ztes-fZ(:,1)+1i*fZ(:,2))./abs(ztes)))/length(ztes);
        end                
        
        function [RES, SimRes, M, Mph, fNoise, SigNoise] = fitNoise(obj,FileName, param)
            indSep = find(FileName == filesep);
            Path = FileName(1:indSep(end));
            Name = FileName(find(FileName == filesep, 1, 'last' )+1:end);    
            Tbath = sscanf(FileName(indSep(end-1)+1:indSep(end)),'%dmK\');
            Ib = str2double(Name(find(Name == '_', 1, 'last')+1:strfind(Name,'uA.txt')-1))*1e-6;
            % Buscamos si es Ibias positivos o negativos
            if ~isempty(strfind(Path,'Negative Bias'))
                [~,Tind] = min(abs([obj.IVsetN.Tbath]*1e3-Tbath));
                IV = obj.IVsetN(Tind);
                CondStr = 'N';
            else
                [~,Tind] = min(abs([obj.IVsetP.Tbath]*1e3-Tbath));
                IV = obj.IVsetP(Tind);
                CondStr = 'P';                        
            end                        
            
            [noisedata, file] = loadnoise(0,Path,Name);%#ok<ASGLU> %%%quito '.txt'
            fNoise = noisedata{1}(:,1);
            SigNoise = V2I(noisedata{1}(:,2)*1e12,obj.circuit);
            OP = setTESOPfromIb(Ib,IV,param);
            SimulatedNoise = noisesim(obj.NoiseOpt.NoiseModel,obj.TES,OP,obj.circuit);
            SimRes = SimulatedNoise.Res;
            f = logspace(0,6,1000);
            sIaux = ppval(spline(f,SimulatedNoise.sI),noisedata{1}(:,1));
            NEP = sqrt(V2I(noisedata{1}(:,2),obj.circuit).^2-SimulatedNoise.squid.^2)./sIaux;
            NEP = NEP(~isnan(NEP));%%%Los ruidos con la PXI tienen el ultimo bin en NAN.            
            RES = 2.35/sqrt(trapz(noisedata{1}(1:size(NEP,1),1),1./medfilt1(real(NEP),20).^2))/2/1.609e-19; 
            %                 RES = 2.35/sqrt(trapz(noisedata{1}(1:end-1,1),1./medfilt1(real(NEP),20).^2))/2/1.609e-19; %#ok<NASGU>
            %%%Excess noise trials.
            %%%Johnson Excess
            findx = find(noisedata{1}(:,1) > obj.JohnsonExcess(1) & noisedata{1}(:,1) < obj.JohnsonExcess(1));
            xdata = noisedata{1}(findx,1);
            %ydata=sqrt(V2I(noisedata{1}(findx,2),circuit.Rf).^2-noiseIrwin.squid.^2);
            ydata = medfilt1(real(NEP(findx))*1e18,20);
            %size(ydata)
            if sum(ydata == Inf) %%%1Z1_23A @70mK 1er punto da error.
                M = 0;
            else
                M = lsqcurvefit(@(x,xdata) fitnoise(x,xdata,obj.TES,OP,obj.circuit),0,xdata,ydata,[],[],optimset('Display','off'));
            end
            %%%phonon Excess
            findx = find(noisedata{1}(:,1) > obj.PhononExcess(1) & noisedata{1}(:,1) < obj.PhononExcess(2));
            ydata = median(real(NEP(findx))*1e18);
            if sum(ydata == inf)
                Mph = 0;
            else
                ymod = median(ppval(spline(f,SimulatedNoise.NEP*1e18),noisedata{1}(findx,1)));
                Mph = sqrt(ydata/ymod-1);
            end
        end        
        
        function plotABCT(obj)
            
            warning off
            
            colors{1} = [0 0.4470 0.7410];
            colors{2} = [1 0.5 0.05];
            
            MS = 10;
            LW1 = 1;
            if ~isempty(obj.TES.sides)
                gammas = [2 0.729]*1e3; %valores de gama para Mo y Au
                rhoAs = [0.107 0.0983]; %valores de Rho/A para Mo y Au
                %sides = [200 150 100]*1e-6 %lados de los TES
                sides = obj.TES.sides;%sides = 100e-6;
                hMo = 55e-9; hAu = 340e-9; %hAu = 1.5e-6;
                %CN = (gammas.*rhoAs)*([hMo ;hAu]*sides.^2).*TES.Tc; %%%Calculo directo
                CN = (gammas.*rhoAs).*([hMo hAu]*sides.^2).*obj.TES.Tc; %%%calculo de cada contribucion por separado.
                CN = sum(CN);
                rpaux = 0.1:0.01:0.9;
            end
            YLabels = {'C(fJ/K)';'\tau_{eff}(\mus)';'\alpha_i';'\beta_i'};
            DataStr = {'rp(indC),C(indC)';'[P(i).p(jj).rp],[P(i).p(jj).taueff]*1e6';...
                'rp(indai),ai(indai)';'[P(i).p(jj).rp],[P(i).p(jj).bi]'};
            DataStr_CI = {'C_CI(indC)';'[P(i).p(jj).taueff_CI]*1e6';...
                'ai_CI(indai)';'[P(i).p(jj).bi_CI]'};
            
            PlotStr = {'plot';'semilogy';'plot';'semilogy'};
            
            
            StrRange = {'P';'N'};
            for k = 1:2
                if isempty(eval(['obj.P' StrRange{k} '.Tbath']))
                    continue;
                end
                P = eval(['obj.P' StrRange{k} ';']);
                if ~exist('fig','var')
                    fig.hObject = figure('Visible','off');
                end
                if ~isfield(fig,'subplots')
                    h = nan(4,1);
                    for i = 1:4
                        h(i) = subplot(2,2,i,'Visible','off');
                    end
                else
                    h = fig.subplots;
                end
                %global hc ht ha hb hl
                for i = 1:length(P)
                    if mod(i,2)
                        MarkerStr(i) = {'.-'};
                    else
                        MarkerStr(i) = {'.-.'};
                    end
                    TbathStr = [num2str(P(i).Tbath*1e3) 'mK-']; %mK
                    signo = sign(sscanf(char(regexp(P(i).fileZ{1},'-?\d+.?\d+uA','match')),'%fuA')*1e-6);
                    if signo == 1
                        NameStr = [TbathStr 'PosIbias'];
                    else
                        NameStr = [TbathStr 'NegIbias'];
                    end
                    %     shc = subplot(2,2,1);
                    [rp,jj] = sort([P(i).p.rp]);
                    
                    C = abs([P(i).p(jj).C])*1e15;
                    C_CI = abs([P(i).p(jj).C_CI])*1e15;
                    %%%Filtrado para visualización
                    mC = nanmedian(C);
                    %     indC = find(C < 3*mC & C > 0.3*mC);
                    indC = 1:length(C);
                    
                    ai = abs([P(i).p(jj).ai]);
                    ai_CI = abs([P(i).p(jj).ai_CI]);
                    %%%Filtrado para visualización
                    mai = nanmedian(ai);
                    %     indai = find(ai < 3*mai & ai > 0.3*mai);
                    indai = 1:length(ai);
                    
                    for j = 1:4
                                                                        
                        eval(['h_ax(' num2str(i) ',' num2str(j) ') = ' PlotStr{j} '(h(' num2str(j) '),' DataStr{j} ...
                            ',''' MarkerStr{i} ''',''color'',colors{k},''linewidth'',LW1,''markersize'',MS,''DisplayName'',''' NameStr ''''...
                            ',''ButtonDownFcn'',{@Identify_Origin},''UserData'',[{P;i;obj.circuit}]);']);
                        eval(['grid(h(' num2str(j) '),''on'');']);
                        eval(['hold(h(' num2str(j) '),''on'');']);
                        eval(['xlabel(h(' num2str(j) '),''R_{TES}/R_n'',''fontsize'',11,''fontweight'',''bold'');']);
                        eval(['ylabel(h(' num2str(j) '),''' YLabels{j} ''',''fontsize'',11,''fontweight'',''bold'');']);
                        eval(['er(k,i,j) = errorbar(h(' num2str(j) '),' DataStr{j} ',' DataStr_CI{j} ');']);
                        eval(['set(h(' num2str(j) '),''fontsize'',11,''fontweight'',''bold'');']);
                        eval(['axis(h(' num2str(j) '),''tight'');']);
                        
                    end
                    %     brush on;
                    %     linkprop(h_ax(i,:),'brushdata');
                    
                    %brush off;
                    linkaxes(h,'x');
                end
                
                if ~isfield(fig,'subplots')
                    %
                    semilogy(h(4),0.1:0.01:0.9,1./(0.1:0.01:0.9)-1,'r','linewidth',2,'DisplayName','Beta^{teo}');
                    if ~isempty(obj.TES.sides)
                        plot(h(1),rpaux,CN*1e15*ones(1,length(rpaux)),'-.','color','r','linewidth',2,'DisplayName','{C_{LB}}^{teo}')
                        plot(h(1),rpaux,2.43*CN*1e15*ones(1,length(rpaux)),'-.','color','k','linewidth',2,'DisplayName','{C_{UB}}^{teo}')
                    end
                end
                fig.subplots = h;                
                xlim([0.15 0.9])
            end
            fig.hObject.Visible = 'on';
            set(h,'Visible','on','ButtonDownFcn',{@GraphicErrors},'UserData',er,'fontsize',12,'linewidth',2,'fontweight','bold')
        end        
        
        function PlotNoiseTbathRp(obj,Tbath,Rn)
            if exist('Tbath','var')
                if ischar(Tbath) % Transformar en valor numerico '50.0mK'
                    Tbath = str2double(Tbath(1:end-2))*1e-3;
                end
                if exist('Rn','var')
                    if any(Rn <= 0) || any(Rn > 1)
                        warndlg('Rn out of range, Rn must be among 0-1 values!','ZarTES v1.0');
                        return;
                    end
                    boolcomponents = 1;
                    StrCond = {'P';'N'};
                    StrCond_Label = {'Positive_Ibias';'Negative_Ibias'};
                    for iP = 1:2
                        fig = figure('Name',StrCond_Label{iP});
                        
                        eval(['ind_Tbath = find([obj.P' StrCond{iP} '.Tbath]'' == Tbath);']);
                        eval(['files' StrCond{iP} ' = [obj.P' StrCond{iP} '(ind_Tbath).fileNoise]'';';]);
                        eval(['files' StrCond{iP} ' = files' StrCond{iP} '(end:-1:1);']);
                        eval(['N = length(files' StrCond{iP} ');']);                        
                        
                        for i = 1:N
                            eval(['noise{i} = importdata(files' StrCond{iP} '{i});']);                                                                                    
                            eval(['FileName = files' StrCond{iP} '{i};']);
                            FileName = FileName(find(FileName == filesep,1,'last')+1:end);
                            Ib = sscanf(FileName,strcat(obj.NoiseOpt.NoiseBaseName(2:end-1),'_%fuA.txt'))*1e-6; %%%HP_noise para ZTES18.!!!
                            eval(['OP = setTESOPfromIb(Ib,obj.IVset' StrCond{iP} '(ind_Tbath),obj.P' StrCond{iP} '(ind_Tbath).p,obj);']);
                            [ncols,nrows] = SmartSplit(N); %#ok<ASGLU>
                            hs = subplot(ceil(N/ncols),ncols,i);
                            hold(hs,'on');
                            grid(hs,'on');
                            if obj.NoiseOpt.Mjo == 1
                                M = OP.M;
                            else
                                M = 0;
                            end
                            auxnoise = noisesim('irwin',obj.TES,OP,obj.circuit,M);
                            f = logspace(0,6,1000);
                            si0 = auxnoise;%debug,para N = 1 ver la SI.
                            
                            switch obj.NoiseOpt.tipo
                                case 'current'
                                    
                                    loglog(hs,noise{i}(:,1),V2I(noise{i}(:,2)*1e12,obj.circuit),'.-r'); %%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
                                    loglog(hs,noise{i}(:,1),medfilt1(V2I(noise{i}(:,2)*1e12,obj.circuit),20),'.-k'); %%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
                                    
                                    if obj.NoiseOpt.Mph == 0
                                        totnoise = sqrt(auxnoise.sum.^2+auxnoise.squidarray.^2);
                                    else
                                        Mexph = OP.Mph;
                                        totnoise = sqrt((auxnoise.ph*(1+Mexph^2)).^2+auxnoise.jo.^2+auxnoise.sh.^2+auxnoise.squidarray.^2);
                                    end
                                    
                                    if ~boolcomponents
                                        loglog(hs,f,totnoise*1e12,'b');
                                        h = findobj(hs,'color','b');
                                    else
                                        loglog(hs,f,auxnoise.jo*1e12,f,auxnoise.ph*1e12,f,auxnoise.sh*1e12,f,totnoise*1e12);
                                        legend(hs,'experimental','exp\_filtered','jhonson','phonon','shunt','total');
                                        legend(hs,'off');
                                        h = findobj(hs,'displayname','total');
                                    end
                                    ylabel(hs,'pA/Hz^{0.5}','fontsize',12,'fontweight','bold')
                                    
                                case 'nep'
                                    
                                    sIaux = ppval(spline(f,auxnoise.sI),noise{i}(:,1));
                                    NEP = real(sqrt((V2I(noise{i}(:,2),obj.circuit).^2-auxnoise.squid.^2))./sIaux);
                                    loglog(noise{i}(:,1),(NEP*1e18),'.-r'),hold on,grid on,
                                    loglog(noise{i}(:,1),medfilt1(NEP*1e18,20),'.-k'),hold on,grid on,
                                    if obj.NoiseOpt.Mph == 0
                                        totNEP = auxnoise.NEP;
                                    else
                                        totNEP = sqrt(auxnoise.max.^2+auxnoise.jo.^2+auxnoise.sh.^2)./auxnoise.sI;%%%Ojo, estamos asumiendo Mph tal que F = 1, no tiene porqué.
                                    end
                                    if ~boolcomponents
                                        loglog(hs,f,totNEP*1e18,'b');hold on;grid on;
                                        h = findobj(hs,'color','b');
                                    else
                                        loglog(hs,f,auxnoise.jo*1e18./auxnoise.sI,f,auxnoise.ph*1e18./auxnoise.sI,f,auxnoise.sh*1e18./auxnoise.sI,f,(totNEP*1e18));
                                        legend(hs,'experimental','exp\_filtered','jhonson','phonon','shunt','total');
                                        legend(hs,'off');
                                        h = findobj(hs,'displayname','total');
                                    end
                                    ylabel(hs,'aW/Hz^{0.5}','fontsize',12,'fontweight','bold')
                            end
                            xlabel(hs,'\nu (Hz)','fontsize',12,'fontweight','bold')
                            axis(hs,[1e1 1e5 2 1e3])%% axis([1e1 1e5 1 1e4])
                            
                            %h = get(gca,'children')
                            set(h(1),'linewidth',3);
                            set(hs,'fontsize',11,'fontweight','bold');
                            set(hs,'linewidth',2)
                            set(hs,'XMinorGrid','off','YMinorGrid','off','GridLineStyle','-')
                            set(hs,'xtick',[10 100 1000 1e4 1e5],'xticklabel',{'10' '10^2' '10^3' '10^4' '10^5'})
                            set(hs,'XScale','log','YScale','log')
                            title(hs,strcat(num2str(round(OP.r0*100)),'%Rn'),'fontsize',12);
                            %         OP.Z0,OP.Zinf
                            %debug
                            if abs(OP.Z0-OP.Zinf) < 1.5e-3
                                set(get(findobj(hs,'type','axes'),'title'),'color','r');
                            end
                            
                            n = get(fig,'number');
                            fi = strcat('-f',num2str(n));
                            mkdir('figs');
                            name = strcat('figs\Noise',num2str(Tbath*1e3),'mK_',StrCond_Label{iP});
                            print(fi,name,'-dpng','-r0');
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                            
                            %%%%Pruebas sobre la cotribución de cada frecuencia a la
                            %%%%Resolucion.
                            if strcmpi(obj.NoiseOpt,'nep') && 0
                                figure
                                %RESJ = sqrt(2*log(2)./trapz(f,1./medfilt1(totNEP,1).^2));%%%x = noisedata{1}(:,1);
                                RESJ = sqrt(2*log(2)./trapz(f,1./totNEP.^2));
                                disp(num2str(RESJ));
                                %semilogx(f(1:end-1),((RESJ./totNEP(1:end-1)).^2/(2*log(2)).*diff(f))),hold on
                                semilogx(hs,f(1:end-1),sqrt((2*log(2)./cumsum((1./totNEP(1:end-1).^2).*diff(f))))/1.609e-19),hold on
                                fx = noise{i}(:,1);
                                RESJ2 = sqrt(2*log(2)./trapz(fx,1./NEP.^2));
                                disp(num2str(RESJ2));
                                %semilogx(fx(1:end-1),((RESJ2./NEP(1:end-1)).^2/(2*log(2)).*diff(fx)),'r')
                                semilogx(hs,fx(1:end-1),sqrt((2*log(2)./cumsum(1./NEP(1:end-1).^2.*diff(fx))))/1.609e-19,'r')
                                %semilogx(fx(1:end-1),((RESJ2./medfilt1(NEP(1:end-1),20)).^2/(2*log(2)).*diff(fx)),'k')
                            end
                            
                        end
                    end
                    
                end
            end            
        end
        
        function PlotTFTbathRp(obj,Tbath,Rn)
            if exist('Tbath','var')
                if ischar(Tbath) % Transformar en valor numerico '50.0mK'
                    Tbath = str2double(Tbath(1:end-2))*1e-3;
                end
                if exist('Rn','var')
                    if any(Rn <= 0) || any(Rn > 1)
                        warndlg('Rn out of range, Rn must be among 0-1 values!','ZarTES v1.0');
                        return;
                    end
                    boolcomponents = 1;
                    StrCond = {'P';'N'};
                    StrCond_Label = {'Positive_Ibias';'Negative_Ibias'};
                    for iP = 1:2
                        fig = figure('Name',StrCond_Label{iP});                        
                        eval(['ind_Tbath = find([obj.P' StrCond{iP} '.Tbath]'' == Tbath);']);
                        eval(['files' StrCond{iP} ' = [obj.P' StrCond{iP} '(ind_Tbath).fileZ]'';';]);
                        eval(['files' StrCond{iP} ' = files' StrCond{iP} '(end:-1:1);']);
                        eval(['N = length(files' StrCond{iP} ');']);                                                
                        for i = 1:N
                            eval(['TF{i} = importdata(files' StrCond{iP} '{i});']);
                            eval(['FileName = files' StrCond{iP} '{i};']);
                            FileName = FileName(find(FileName == filesep,1,'last')+1:end);                            
                            if ~isempty(strfind(FileName,'TF_PXI_'))
                                Ib = sscanf(FileName,'TF_PXI_%fuA.txt')*1e-6;
                            else
                                Ib = sscanf(FileName,'TF_%fuA.txt')*1e-6;
                            end                                
                            
                            eval(['OP = setTESOPfromIb(Ib,obj.IVset' StrCond{iP} '(ind_Tbath),obj.P' StrCond{iP} '(ind_Tbath).p,obj);']);
                            [ncols,nrows] = SmartSplit(N); %#ok<ASGLU>
                            hs = subplot(ceil(N/ncols),ncols,i);
                            hold(hs,'on');
                            grid(hs,'on');
                            ztes = eval(['obj.P' StrCond{iP} '(ind_Tbath).ztes{N-i+1};']);
                            fZ = eval(['obj.P' StrCond{iP} '(ind_Tbath).fZ{N-i+1};']);
                            
                            plot(hs,1e3*ztes,'.','color',[0 0.447 0.741],...
                                'markerfacecolor',[0 0.447 0.741],'markersize',15);
                            
                            set(hs,'linewidth',2,'fontsize',12,'fontweight','bold');
                            xlabel(hs,'Re(mZ)','fontsize',12,'fontweight','bold');
                            ylabel(hs,'Im(mZ)','fontsize',12,'fontweight','bold');%title('Ztes with fits (red)');
                            ImZmin = min(imag(1e3*ztes));
                            ylim(hs,[min(-15,min(ImZmin)-1) 1])                            
                            plot(hs,1e3*fZ(:,1),1e3*fZ(:,2),'r','linewidth',2);
                            title(hs,strcat(num2str(round(OP.r0*100)),'%Rn'),'fontsize',12);
                            if abs(OP.Z0-OP.Zinf) < 1.5e-3
                                set(get(findobj(hs,'type','axes'),'title'),'color','r');
                            end
                            
                            n = get(fig,'number');
                            fi = strcat('-f',num2str(n));
                            mkdir('figs');
                            name = strcat('figs\TF',num2str(Tbath*1e3),'mK_',StrCond_Label{iP});
                            print(fi,name,'-dpng','-r0');
                        end
                        
                    end
                end
            end
            
            
        end
        
        function GraphsReport(obj)
            % Pequeño menú para seleccionar lo que se quiere pintar
                                 
            %% Pintar curvas IV
            if obj.Report.IV_Curves
                figIV.hObject = figure('Visible','off');
                for i = 1:4
                    h(i) = subplot(2,2,i);
                end
                Data2DrawStr(1,:) = {'ibias*1e6';'vout'};
                Data2DrawStr_Units(1,:) = {'Ibias(\muA)';'Vout(V)'};
                Data2DrawStr(2,:) = {'vtes*1e6';'ptes*1e12'};
                Data2DrawStr_Units(2,:) = {'V_{TES}(\muV)';'Ptes(pW)'};
                Data2DrawStr(3,:) = {'vtes*1e6';'ites*1e6'};
                Data2DrawStr_Units(3,:) = {'V_{TES}(\muV)';'Ites(\muA)'};
                Data2DrawStr(4,:) = {'rtes';'ptes*1e12'};
                Data2DrawStr_Units(4,:) = {'R_{TES}/R_n';'Ptes(pW)'};
                
                IVset = [obj.IVsetP obj.IVsetN];
                for i = 1:length(IVset)
                    if IVset(i).good
                        for j = 1:4
                            eval(['plot(h(j),IVset(i).' Data2DrawStr{j,1} ', IVset(i).' Data2DrawStr{j,2} ', ''.--'','...
                                '''ButtonDownFcn'',{@ChangeGoodOpt},''DisplayName'',num2str(IVset(i).Tbath),''Tag'',IVset(i).file);']);
                            grid(h(j),'on');
                            hold(h(j),'on');
                            xlabel(h(j),Data2DrawStr_Units(j,1),'fontweight','bold');
                            ylabel(h(j),Data2DrawStr_Units(j,2),'fontweight','bold');
                        end
                    else  % No se pinta o se pinta de otro color
                        
                    end
                end
                set(h,'fontsize',12,'linewidth',2,'fontweight','bold')
                axis(h,'tight');
                figIV.hObject.Visible = 'on';
            end
            
            %% Pintar NKGT set
            if obj.Report.NKGTset
                clear fig;
                MS = 10; %#ok<NASGU>
                LS = 1; %#ok<NASGU>
                color{1} = [0 0.447 0.741];
                color{2} = [1 0 0]; %#ok<NASGU>
                StrField = {'n';'Tc';'K';'G'};
                StrMultiplier = {'1';'1';'1e-3';'1'}; %#ok<NASGU>
                StrLabel = {'n';'Tc(K)';'K(nW/K^n)';'G(pW/K)'};
                StrRange = {'P';'N'};
                StrIbias = {'Positive';'Negative'};
                for k = 1:2
                    if isempty(eval(['obj.Gset' StrRange{k} '.n']))
                        continue;
                    end
                    if ~exist('fig','var')
                        fig.hObject = figure;
                    end
                    Gset = eval(['obj.Gset' StrRange{k}]);
                    
                    TES_OP_y = find([Gset.Tc] == obj.TES.Tc,1,'last');
                    if isfield(fig,'subplots')
                        h1 = fig.subplots;
                    end
                    for j = 1:length(StrField)
                        if ~isfield(fig,'subplots')
                            h1(j) = subplot(2,2,j);
                        end
                        eval(['plot(h1(j),[Gset.rp],[Gset.' StrField{j} '],''.-'','...
                            '''color'',color{k},''linewidth'',LS,''markersize'',MS,''DisplayName'',''' StrIbias{k} ''');']);
                        hold(h1(j),'on');
                        grid(h1(j),'on');
                        
                        try
                            eval(['plot(h1(j),Gset(TES_OP_y).rp,Gset(TES_OP_y).' StrField{j} ',''.-'','...
                                '''color'',''g'',''linewidth'',LS,''markersize'',MS*1.5,''DisplayName'',''Operation Point'');']);
                        catch
                        end
                        xlim(h1(j),[0.15 0.9]);
                        xlabel(h1(j),'R_{TES}/R_n','fontsize',11,'fontweight','bold');
                        ylabel(h1(j),StrLabel{j},'fontsize',11,'fontweight','bold');
                        set(h1(j),'linewidth',2,'fontsize',11,'fontweight','bold')
                    end
                    
                    fig.subplots = h1;
                end
                fig.hObject.Visible = 'on';
            end
            
            if obj.Report.ABCTset
                obj.plotABCT;
            end
            
            if obj.Report.FitPTset
                StrRange = {'P';'N'};
                for k = 1:2
                    if isempty(eval(['obj.IVset' StrRange{k} '.ibias']))
                        continue;
                    end
                    IVTESset = eval(['obj.IVset' StrRange{k}]);
                    fig = figure('Name','FitP vs. Tset');
                    ax = subplot(1,1,k); hold(ax,'on');
                    for jj = 1:length(perc)
                        Paux = [];
                        Iaux = [];
                        Tbath = [];
                        kj = 1;
                        for i = 1:length(IVTESset)
                            if IVTESset(i).good                                
                                ind = find(IVTESset(i).rtes > 0.1 & IVTESset(i).rtes < 0.8);%%%algunas IVs fallan.
                                if isempty(ind)
                                    continue;
                                end
                                Paux(kj) = ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ptes(ind)),perc(jj)); %#ok<AGROW>
                                Iaux(kj) = ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ites(ind)),perc(jj));%#ok<AGROW> %%%
                                Tbath(kj) = IVTESset(i).Tbath; %#ok<AGROW>
                                kj = kj+1;
                            else
                                Paux(kj) = nan;
                                Iaux(kj) = nan;
                                Tbath(kj) = nan;
                            end
                        end
                        Paux(isnan(Paux)) = [];
                        Iaux(isnan(Iaux)) = [];
                        Tbath(isnan(Tbath)) = [];                                            
                        plot(ax,Tbath,Paux*1e12,'bo','markerfacecolor','b'),hold(ax,'on');
                        
                        switch model
                            case 1
                                X0 = [-500 3 1];
                                XDATA = Tbath;
                                LB = [-Inf 2 0 ];%%%Uncomment for model1
                            case 2
                                X0 = [-6500 3.03 13 1.9e4];
                                XDATA = [Tbath;Iaux*1e6];
                                LB = [-1e5 2 0 0];
                            case 3
                                auxtbath = min(Tbath):1e-4:max(Tbath);
                                auxptes = spline(Tbath,Paux,auxtbath);
                                gbaux = abs(diff(auxptes)./diff(auxtbath));
                                opts = optimset('Display','off');
                                fit2 = lsqcurvefit(@(x,tbath)x(1)+x(2)*tbath,[3 2], log(auxtbath(2:end)),log(gbaux),[],opts); %#ok<NASGU>                                                              
                                plot(ax,log(auxtbath(2:end)),log(gbaux),'.-')
                        end
                        if model ~= 3
                            opts = optimset('Display','off');
                            [fit,resnorm,residual,exitflag,output,lambda,jacob] = lsqcurvefit(@fitP,X0,XDATA,Paux*1e12,LB,[],opts); %#ok<ASGLU>
                            plot(ax,Tbath,fitP(fit,XDATA),'-r','linewidth',1)                                                        
                        end
                    end
                    xlabel(ax,'T_{bath}(K)','fontsize',11,'fontweight','bold')
                    ylabel(ax,'P_{TES}(pW)','fontsize',11,'fontweight','bold')
                    set(ax,'fontsize',12,'linewidth',2,'fontweight','bold')
                end
            end
            
            if obj.Report.FitZset
                TESDATA.PlotTFTbathRp(0.05,0.15:0.05:0.85);
            end
            if obj.Report.NoiseSet 
                TESDATA.PlotNoiseTbathRp(0.05,0.15:0.05:0.85);
            end
            
        end        
        
        function PlotTESData(obj,param,Rn,Tbath)            
            if ~ischar(param)
                warndlg('param must be string','ZarTES v1.0');
                return;
            else
                YLabels = {'C(fJ/K)';'\tau_{eff}(\mus)';'\alpha_i';'\beta_i'};
                colors{1} = [0 0.4470 0.7410];
                colors{2} = [1 0.5 0.05];
                if nargin == 3
                    valP = nan;
                    valN = nan;
                    % Selecion de Rn y parametro a buscar en funcion de Tbath
                    [valP,TbathP,RnsP] = obj.PP.GetParamVsTbath(param,Rn); % Rn must be 0-1 value
                    [valN,TbathN,RnsN] = obj.PN.GetParamVsTbath(param,Rn); % Rn must be 0-1 value
                    
                    if strcmp(param,'ai')||strcmp(param,'ai_CI')||strcmp(param,'C')||strcmp(param,'C_CI')
                        valP = abs(valP);
                        valN = abs(valN);
                        if strcmp(param,'ai')||strcmp(param,'ai_CI')
                            Ylabel = '\alpha_i';
                        end
                        if strcmp(param,'C')||strcmp(param,'C_CI')
                            Ylabel = 'C(fJ/K)';
                        end
                    elseif strcmp(param,'taueff')||strcmp(param,'taueff_CI')
                        valP = valP*1e6;
                        valN = valN*1e6;
                        Ylabel = '\tau_{eff}(\mus)';
                    elseif strcmp(param,'bi')||strcmp(param,'bi_CI')
                        Ylabel = '\beta_i';
                    else
                        Ylabel = param;
                    end
                    fig = figure('Visible','on');
                    ax = axes(fig);                    
                    hold(ax,'on');
                    for i = 1:size(TbathP,1)
                        if size(valP,2) == 1
                            h = plot(ax,TbathP(i,:),valP','LineStyle','-.','Marker','o','DisplayName',['Rn: ' num2str(median(RnsP,1)) ' - Positive Ibias']); %,'MarkerFaceColor',colors{1},'MarkerEdgeColor',colors{1}
                        else
                            h = plot(ax,TbathP(i,:),valP(i,:),'LineStyle','-.','Marker','o','DisplayName',['Rn: ' num2str(median(RnsP(i,:))) ' - Positive Ibias']); %,'MarkerFaceColor',colors{1},'MarkerEdgeColor',colors{1}
                        end
                        h.MarkerFaceColor = h.Color;
                    end
                    for i = 1:size(TbathN,1)
                        if size(valN,2) == 1
                            h = plot(ax,TbathN(i,:),valN','LineStyle','-.','Marker','^','DisplayName',['Rn: ' num2str(median(RnsN,1)) ' - Negative Ibias']);
                        else
                            h = plot(ax,TbathN(i,:),valN(i,:),'LineStyle','-.','Marker','^','DisplayName',['Rn: ' num2str(median(RnsN(i,:))) ' - Negative Ibias']);
                        end
                        h.MarkerFaceColor = h.Color;
                    end
                    xlabel(ax,'T_{bath} (mK)');
                    ylabel(ax,Ylabel);
                    set(ax,'FontSize',11,'FontWeight','bold');                    
                    
                elseif nargin == 4              
                    valP = nan;
                    valN = nan;
                    % Selecion de Tbath y parametro a buscar en funcion de Rn
                    [valP,rpP,TbathP] = obj.PP.GetParamVsRn(param,Tbath); % Tbath = '50.0mK' o Tbath = 0.05;
                    [valN,rpN,TbathN] = obj.PN.GetParamVsRn(param,Tbath);
                    
                    if strcmp(param,'ai')||strcmp(param,'ai_CI')||strcmp(param,'C')||strcmp(param,'C_CI')
                        valP = abs(valP);
                        valN = abs(valN);
                        if strcmp(param,'ai')||strcmp(param,'ai_CI')
                            Ylabel = '\alpha_i';
                        end
                        if strcmp(param,'C')||strcmp(param,'C_CI')
                            Ylabel = 'C(fJ/K)';
                        end
                    elseif strcmp(param,'taueff')||strcmp(param,'taueff_CI')
                        valP = valP*1e6;
                        valN = valN*1e6;
                        Ylabel = '\tau_{eff}(\mus)';
                    elseif strcmp(param,'bi')||strcmp(param,'bi_CI')
                        Ylabel = '\beta_i';
                    else
                        Ylabel = param;
                    end
                
                                  
                    fig = figure('Visible','on');
                    ax = axes(fig);                    
                    hold(ax,'on');
                    plot(ax,rpP,valP,'DisplayName',['T_{bath}: ' num2str(TbathP) ' mK - Positive Ibias']);
                    plot(ax,rpN,valN,'DisplayName',['T_{bath}: ' num2str(TbathN) ' mK - Negative Ibias']);
                    xlabel(ax,'RTES/Rn');
                    ylabel(ax,Ylabel);
                    set(ax,'FontSize',11,'FontWeight','bold');   
                end
                
            end
        end
        
        function TFNoiseViever(obj)
            TF_Noise_Viewer(obj);
        end
        
        function Save(obj)             %#ok<MANU>
            uisave('obj');
        end
    
    end
end

