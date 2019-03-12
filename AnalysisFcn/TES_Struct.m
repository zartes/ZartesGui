classdef TES_Struct
    % Class Struct for TES data
    %   This class contains all subclasses for TES analysis
    
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
            % Function to generate the class with default values
            
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
        
        function obj = CheckCircuit(obj)
            % Function to check visually the class values
            
            h = figure('Visible','off','Tag','TES_Struct');
            waitfor(Conf_Setup(h,[],obj));
            NewCircuit = guidata(h);
            if ~isempty(NewCircuit)
                obj.circuit = obj.circuit.Update(NewCircuit);
            end
        end
        
        function obj = CheckIVCurvesVisually(obj, figIV)
            % Function to check visually the I-V curves
            
            if ~exist('figIV','var')
                figIV = [];
            end
            StrRange = {'P';'N'};
            for j = 1:length(StrRange)
                eval(['figIV = obj.IVset' StrRange{j} '.plotIVs(figIV);']);
                
                % Revisar las curvas IV y seleccionar aquellas para eliminar del
                % analisis
                waitfor(helpdlg('Before closing this message, please check the IV curves','ZarTES v1.0'));
                eval(['obj.IVset' StrRange{j} ' = get(figIV.hObject,''UserData'');']);
            end
            
        end
        
        function obj = fitPvsTset(obj,perc,model,fig)
            % Function for fitting P-Tbath curves at Rn values.
            %
            % If Rn ranges is empty, the range is computed automatically
            % according to the Ptes-rtes curves.
            
            if isempty(perc)
                j = 1;
                for i = 1:size(obj.IVsetP,2)+size(obj.IVsetN,2)
                    try
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
                    if isempty(indx)
                        continue;
                    end
                    diffptes = diffptes(indx);
                    range = find(diffptes > nanmedian(diffptes)+0.001*max(diffptes));
                    minrange(i,1) = x(range(end));
                    maxrange(i,1) = x(range(end-1));
                    if i == size(obj.IVsetP,2)
                        j = 1;
                    else
                        j = j+1;
                    end
                    catch
                        minrange(i,1) = 10;
                        maxrange(i,1) = 0;
                    end
                end
                minrange = minrange(minrange < 0.5);
                maxrange = maxrange(maxrange > 0.5);
                minrange = ceil(max(minrange)*1e3)/1e3;
                maxrange = ceil(min(maxrange)*1e3)/1e3;
                warning off;
                
                prompt = {'Enter the %Rn range (Initial:Step:Final):'};
                name = '%Rn range to fit P vs. Tbath data (suggested values)';
                numlines = [1 70];
                defaultanswer = {[num2str(minrange) ':0.01:' num2str(maxrange)]};
                answer = inputdlg(prompt,name,numlines,defaultanswer);
                if ~isempty(answer)
                    perc = eval(answer{1});
                    if ~isnumeric(perc)
                        warndlg('Invalid %Rn values','ZarTES v1.0');
                        return;
                    end
                else
                    warndlg('Invalid %Rn values','ZarTES v1.0');
                    return;
                end
            end
            
            if isempty(model)
                model = 1;
            end
            if isempty(fig)
                fig = figure('Name','fitP vs. Tset');
            end
            StrRange = {'P';'N'};
            StrTitle = {'Positive Ibias';'Negative Ibias'};
            
            for k = 1:2                
                eval(['obj.Gset' StrRange{k} ' = [];']);
                eval(['obj.Gset' StrRange{k} ' = TES_Gset;']);
                eval(['obj.Gset' StrRange{k} ' = obj.Gset' StrRange{k} '.Constructor;']);
                if isempty(eval(['obj.IVset' StrRange{k} '.ibias']))
                    continue;
                end
                figure(fig);
                ax = subplot(1,2,k,'Visible','off'); 
                title(ax,StrTitle{k});
                hold(ax,'on');
                IVTESset = eval(['obj.IVset' StrRange{k}]);
                c = distinguishable_colors(length(perc));
                wb = waitbar(0,'Please wait...');
                for jj = 1:length(perc)
                    Paux = [];
                    Iaux = [];
                    Tbath = [];
                    kj = 1;
                    clear SetIbias;                    
                    SetIbias{1} = [];
                    for i = 1:length(IVTESset)
                        if IVTESset(i).good
                            ind = find(IVTESset(i).rtes > 0.05 & IVTESset(i).rtes < 0.9);%%%algunas IVs fallan.
                            if isempty(ind)
                                continue;
                            end
                            Paux(kj) = ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ptes(ind)),perc(jj)); %#ok<AGROW>
                            Iaux(kj) = ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ites(ind)),perc(jj));%#ok<AGROW> %%%
                            Tbath(kj) = IVTESset(i).Tbath; %#ok<AGROW>
                            kj = kj+1;
                            SetIbias = [SetIbias; {IVTESset(i).file}];
                        else
                            Paux(kj) = nan;
                            Iaux(kj) = nan;
                            Tbath(kj) = nan;
                        end
                    end
                    Paux(isnan(Paux)) = [];
                    Iaux(isnan(Iaux)) = [];
                    Tbath(isnan(Tbath)) = [];
                    
                    eval(['obj.Gset' StrRange{k} '(jj).rp = perc(jj);']);
                    eval(['obj.Gset' StrRange{k} '(jj).model = model;']);
                                       
                    
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
                            
                            plot(ax,log(auxtbath(2:end)),log(gbaux),'.-','Visible','off')
                    end
                    if model ~= 3
                        
                        opts = optimset('Display','off');
                        
                        [fit,resnorm,residual,exitflag,output,lambda,jacob] = lsqcurvefit(@obj.fitP,X0,XDATA,Paux*1e12,LB,[],opts); %#ok<ASGLU>                        
                        ci = nlparci(fit,residual','jacobian',jacob);
                        CI = (ci(:,2)-ci(:,1))';
                        fit_CI = [fit; CI];
                        Gaux(jj) = obj.GetGfromFit(fit_CI);%#ok<AGROW,NASGU> %%antes se pasaba fitaux.
                        ERP = sum(abs(abs(Paux*1e12-obj.fitP(fit,XDATA))./abs(Paux*1e12)))/length(Paux*1e12);
                        R = corr([obj.fitP(fit,XDATA)' Paux'*1e12]);
                        R2 = R(1,2)^2;
                        eval(['obj.Gset' StrRange{k} '(jj).n = Gaux(jj).n;']);
                        eval(['obj.Gset' StrRange{k} '(jj).n_CI = Gaux(jj).n_CI;']);
                        eval(['obj.Gset' StrRange{k} '(jj).K = Gaux(jj).K;']);
                        eval(['obj.Gset' StrRange{k} '(jj).K_CI = Gaux(jj).K_CI;']);
                        eval(['obj.Gset' StrRange{k} '(jj).Tc = Gaux(jj).Tc;']);
                        eval(['obj.Gset' StrRange{k} '(jj).Tc_CI = Gaux(jj).Tc_CI;']);
                        eval(['obj.Gset' StrRange{k} '(jj).G = Gaux(jj).G;']);
                        eval(['obj.Gset' StrRange{k} '(jj).G_CI = Gaux(jj).G_CI;']);
                        eval(['obj.Gset' StrRange{k} '(jj).ERP = ERP;']);
                        eval(['obj.Gset' StrRange{k} '(jj).R2 = R2;']);
                        plot(ax,Tbath,obj.fitP(fit,XDATA),'LineStyle','-','Color',c(jj,:),'linewidth',1,'DisplayName',IVTESset(i).file,...
                            'ButtonDownFcn',{@Identify_Origin_PT},'UserData',{k;jj;i;obj},'Visible','off');
                    end
                    plot(ax,Tbath,Paux*1e12,'Marker','o','MarkerFaceColor',c(jj,:),'MarkerEdgeColor',c(jj,:),'DisplayName',['Rn(%): ' num2str(perc(jj))],...
                            'ButtonDownFcn',{@Identify_Origin_PT},'UserData',SetIbias,'LineStyle','none','Visible','off')
                    if ishandle(wb)
                        waitbar(jj/length(perc),wb,['Fit P vs. T in progress: ' StrTitle{k}]);
                    end
                end
                xlabel(ax,'T_{bath}(K)','fontsize',11,'fontweight','bold')
                ylabel(ax,'P_{TES}(pW)','fontsize',11,'fontweight','bold')
                set(ax,'fontsize',12,'linewidth',2,'fontweight','bold')
                if ishandle(wb)
                    delete(wb);
                end
            end
            
            haxes = findobj('Type','Axes');           
            hline = findobj('Type','Line');
            set([haxes;hline],'Visible','on');
        end
        
        function P = fitP(obj,p,T)
            % Function to fit P(Tbath) data.
            
            [ii,~] = size(T);
            model = ii;
            if model == 1
                %%%p(1)=a=-K, p(2)=n, p(3)=P0=K*Tc^n
                P = p(1)*T.^p(2)+p(3);
            elseif model == 2
                %%%p(1)=-K, p(2)=n, p(3)=P0=K*Tc^n, p(4)=Ic0. p(5)=Pnoise
                P = p(1)*T(1,:).^p(2)+p(3)*(1-T(2,:)/p(4)).^(2*p(2)/3);%+p(5);
            elseif model > 2
                error('Wrong P(T) model?')
            end
        end
        
        function param = GetGfromFit(obj,p)
            % Function to get thermal parameters from fitting
            %             fit
            % Model 1  p(1)=a=-K, p(2)=n, p(3)=P0=K*Tc^n
            rp = p(1,:);
            rp_CI = p(2,:);
            
            param.n = rp(2);
            param.n_CI = rp_CI(2);
            
            param.K = -rp(1);
            param.K_CI = abs(rp_CI(1));
            
            param.Tc = (rp(3)/-rp(1))^(1/rp(2));                
            param.Tc_CI = sqrt( (((rp(3)*(-rp(3)/rp(1))^(1/rp(2) - 1))/(rp(1)^2*rp(2)))*rp_CI(1))^2 ...
                + ((-(log(-rp(3)/rp(1))*(-rp(3)/rp(1))^(1/rp(2)))/rp(2)^2)*rp_CI(2))^2 ...
                + ((-(-rp(3)/rp(1))^(1/rp(2) - 1)/(rp(1)*rp(2)))*rp_CI(3))^2);
            
            if length(p) > 3
                param.Ic = rp(4);%%%used in model2
                %param.Pnoise=fit(5);%%%efecto de posible fuente extra de ruido.
            end
            param.G = param.n*param.K*param.Tc^(param.n-1); 
            param.G_CI = sqrt( ((param.K*param.Tc^(param.n - 1) + param.K*param.Tc^(param.n - 1)*param.n*log(param.Tc))*param.n_CI)^2 ...
                + ((param.n*param.Tc^(param.n - 1))*param.K_CI)^2 ...
                + ((param.n*param.K*param.Tc^(param.n - 2)*(param.n - 1))*param.Tc_CI)^2 );
                    
%             param.tau0_CI = sqrt(((param.L0-1)*rp_CI(3))^2 + ((rp(3))*param.L0_CI)^2 );
        end
        
        function obj = plotNKGTset(obj,fig,opt)
            % Function to visualize n, K, G and T with respect to RTes/Rn
            %
            % This function allows determining the final thermal parameters
            
            MS = 5; %#ok<NASGU>
            LS = 1; %#ok<NASGU>
            color{1} = [0 0.447 0.741];
            color{2} = [1 0 0]; %#ok<NASGU>
            StrField = {'n';'Tc';'K';'G'};
            StrMultiplier = {'1';'1e3';'1e-12';'1e-12';}; %#ok<NASGU>
%             StrMultiplier = {'1';'1';'1e-3';'1'}; %#ok<NASGU>
            StrLabel = {'n';'Tc(mK)';'K(nW/K^n)';'G(pW/K)'};
            StrRange = {'P';'N'};
            StrIbias = {'Positive';'Negative'};
            Marker = {'o';'^'};
            LineStr = {'.-';':'};
            
            for k = 1:2
                if isempty(eval(['obj.Gset' StrRange{k} '.n']))
                    continue;
                end
                if nargin < 2
                    fig.hObject = figure;
                end
                Gset = eval(['obj.Gset' StrRange{k}]);
                try
                    TES_OP_y = find([Gset.Tc] == obj.TES.Tc*1e-3,1,'last');
                catch
                end
                if isfield(fig,'subplots')
                    h = fig.subplots;
                end
                for j = 1:length(StrField)
                    if ~isfield(fig,'subplots')
                        h(j) = subplot(2,2,j,'ButtonDownFcn',{@GraphicErrors_NKGT});
                        hold(h(j),'on');
                        grid(h(j),'on');
                    end
                    rp = [Gset.rp];
                    [~,ind] = sort(rp);
                    val = eval(['[Gset.' StrField{j} ']*' StrMultiplier{j} ';']);
                    try
                        val_CI = eval(['[Gset.' StrField{j} '_CI]*' StrMultiplier{j} ';']);
                        er(j) = errorbar(h(j),rp(ind),val(ind),val_CI(ind),'color',color{k},...
                            'Visible','off','DisplayName',[StrIbias{k} ' Error Bar'],'Clipping','on');
                    catch
                    end
                    eval(['plot(h(j),rp(ind),val(ind),''' LineStr{k} ''','...
                        '''color'',color{k},''MarkerFaceColor'',color{k},''linewidth'',LS,''markersize'',MS,''Marker'','...
                        '''' Marker{k} ''',''DisplayName'',''' StrIbias{k} ''');']);
                    xlim(h(j),[0.15 0.9]);
                    xlabel(h(j),'R_{TES}/R_n','fontsize',11,'fontweight','bold');
                    ylabel(h(j),StrLabel{j},'fontsize',11,'fontweight','bold');
                    set(h(j),'linewidth',2,'fontsize',11,'fontweight','bold')
                    
                    try
                        eval(['plot(h(j),Gset(TES_OP_y).rp,Gset(TES_OP_y).' StrField{j} ',''.-'','...
                            '''color'',''g'',''MarkerFaceColor'',''g'',''MarkerEdgeColor'',''g'',''linewidth'',LS,''Marker'',''hexagram'',''markersize'',2*MS,''DisplayName'',''Operation Point'');']);
                    catch
                    end
                end
                fig.subplots = h;
                try
                    data.er = er;
                    set(h,'ButtonDownFcn',{@GraphicErrors_NKGT},'UserData',data,'fontsize',12,'linewidth',2,'fontweight','bold')
                catch
                end
                set(h,'Visible','on');
            end
            if nargin < 2
                warndlg('TESDATA.fitPvsTset must be firstly applied.','ZarTES v1.0')
                fig = [];
            end
            if nargin < 3
                pause(0.2)
                waitfor(helpdlg('After closing this message, select a point for TES characterization','ZarTES v1.0'));
                figure(fig.hObject);
                
                % Seleccion mediante teclado de la Rn
                prompt = {'Enter the %Rn (0 < %Rn < 1) for TES thermal parameters'};
                name = 'TES Thermal Parameters';
                numlines = 1;
                defaultanswer = {'0.8'};
                answer = inputdlg(prompt,name,numlines,defaultanswer);
                if isempty(answer)
                    warndlg('No %Rn value selected','ZarTES v1.0');
                    return;
                else
                    X = str2double(answer{1});
                    if isnan(X)
                        warndlg('Invalid %Rn value','ZarTES v1.0');
                        return;
                    end
                end
                
                % Seleccion mediante raton sobre las gráficas
                %                 [X,~] = ginput(1);
                
                if X > max(rp)
                    X = max(rp);
                end
                ind_rp = find(rp >= X,1); %#ok<NASGU>
                
                IndxOP = findobj('DisplayName','Operation Point');
                delete(IndxOP);
                
                StrField = {'n';'Tc';'K';'G'};
                TESmult = {'1';'1e3';'1e-12';'1e-12';};
                for i = 1:length(StrField)
                    eval(['val = [obj.GsetP.' StrField{i} ']*' TESmult{i} ';']);
                    eval(['obj.TES.' StrField{i} ' = val(ind_rp);']);
                    
                    eval(['plot(h(i),obj.GsetP(ind_rp).rp,val(ind_rp),''.-'','...
                        '''color'',''g'',''MarkerFaceColor'',''g'',''MarkerEdgeColor'',''g'','...
                        '''linewidth'',LS,''Marker'',''hexagram'',''markersize'',2*MS,''DisplayName'',''Operating Point'');']);
                    axis(h(i),'tight')
                    
                    
                end
                uiwait(msgbox({['n: ' num2str(obj.TES.n)];['K: ' num2str(obj.TES.K)];...
                    ['Tc: ' num2str(obj.TES.Tc) 'mK'];['G: ' num2str(obj.TES.G)]},'TES Operating Point','modal'));
                obj.TES.Tc = obj.TES.Tc*1e-3; 
                
            end
        end
        
        function obj = EnterDimensions(obj)
            % Function to set TES dimensions
            %
            % If this data is available, then theoretical C value could
            % be analytically determined
            
            prompt = {'Enter length value:','Enter width value:'};
            name = 'Provide TES dimension';
            numlines = [1 50; 1 50];
            defaultanswer = {'25e-6','25e-6'};
            
            answer = inputdlg(prompt,name,numlines,defaultanswer);
            if ~isempty(answer)
                obj.TES.sides = sqrt(str2double(answer{1})*str2double(answer{2}));
            end
        end
        
        function obj = FitZset(obj,fig)
            % Function to fit Z(w) at different Tbaths according to the
            % selected electro-thermal model.
            %
            % Filtered data is generated when ai or C are found negatives,
            % and when ERP value (Error Relative Parameter) is greater than 0.8
            
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
            
            prompt = {'Mimimum frequency value:','Maximum frequency value:'};
            dlg_title = 'Frequency limitation for Z(w)-Noise analysis';
            num_lines = [1 70];
            defaultans = {'0','100000'};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
            
            if ~isempty(answer)
                minFreq = eval(answer{1});
                maxFreq = eval(answer{2});
                if ~isnumeric(minFreq)||~isnumeric(maxFreq)
                    warndlg('Cancelled by user','ZarTES v1.0');
                    return;
                end
            else
                warndlg('Cancelled by user','ZarTES v1.0');
                return;
            end
            FreqRange = [minFreq maxFreq];
            
            ButtonName = questdlg('Do you want to show the data and fits?', ...
                'ZarTES v1.0', ...
                'Yes', 'No', 'Yes');
            switch ButtonName
                case 'Yes'
                    obj.TFOpt.boolShow = 1;
                otherwise
                    obj.TFOpt.boolShow = 0;
            end
            
            StrRange = {'P';'N'};
            StrRangeExt = {'Positive Ibias Range';'Negative Ibias Range'};
            if nargin < 2
                fig = nan(1,2);
            end
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
                
                if isempty(dirs{1})
                    if k1 == 1
                        DataPath = uigetdir(IVsetPath, 'Pick a Z(w)-Ruido path containing Temperature named folders (Positive Bias)');
                    else
                        DataPath = uigetdir(IVsetPath, 'Pick a Z(w)-Ruido path containing Temperature named folders (Negative Bias)');
                    end
                    if DataPath ~= 0
                        DataPath = [DataPath filesep];
                    else
                        errordlg('Invalid Data path name!','ZarTES v1.0','modal');
                        return;
                    end
                    
                    if k1 == 1
%                         indt = find(DataPath == filesep);
%                         DataPath = DataPath(1:indt(end-1));
                        str = dir([DataPath '*mK']);
                    else
%                         ind = find(DataPath == filesep);
%                         DataPath = [DataPath(1:ind(end-1)) 'Negative Bias' filesep];
                        str = dir([DataPath '*mK']);
                    end
                    k = 1;
                    dirs = {[]};
                    for jjj = 1:length(str)
                        if str(jjj).isdir
                            if isempty(strfind(str(jjj).name,'('))
                                dirs{k} = [DataPath str(jjj).name]; %#ok<*PROP>
                                k = k+1;
                            end
                        end
                    end
                    if isempty(dirs{1})
                        errordlg('Invalid Data path name!','ZarTES v1.0','modal');
                        return;
                    end
                end
                
                h_i = 1;
                h = nan(1,50);
                g = nan(1,50);
                
                H = multiwaitbar(2,[0 0],{'Folder(s)','File(s)'});
                H.figure.Name = 'Z(w) Analysis';
                H1 = multiwaitbar(2,[0 0],{'Folder(s)','File(s)'});
                H1.figure.Name = 'Noise Analysis';
                eval(['obj.P' StrRange{k1} ' = TES_P;']);
                eval(['obj.P' StrRange{k1} ' = obj.P' StrRange{k1} '.Constructor;']);
                
                iOK = 1;
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
                    Tbath = sscanf(Path,'%dmK');
                    if isempty(Tbath)
                        continue;
                    end
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
                        
                        [param, ztes, fZ, ERP, R2, CI, aux1, StrModel, p0] = obj.FitZ(thefile,FreqRange);
                        
                        if param.rp > 1 || param.rp < 0
                            continue;
                        end
                        eval(['obj.P' StrRange{k1} '(iOK).Tbath = Tbath*1e-3;;']);
                        paramList = fieldnames(param);
                        for pm = 1:length(paramList)
                            eval(['obj.P' StrRange{k1} '(iOK).p(jj).' paramList{pm} ' = param.' paramList{pm} ';']);
                        end
                        eval(['obj.P' StrRange{k1} '(iOK).CI{jj} = CI;']);
                        eval(['obj.P' StrRange{k1} '(iOK).residuo(jj) = aux1;']);
                        eval(['obj.P' StrRange{k1} '(iOK).fileZ(jj) = {[dirs{i} filesep filesZ{j1}]};']);
                        eval(['obj.P' StrRange{k1} '(iOK).ElecThermModel(jj) = {StrModel};']);
                        eval(['obj.P' StrRange{k1} '(iOK).ztes{jj} = ztes;']);
                        eval(['obj.P' StrRange{k1} '(iOK).fZ{jj} = fZ;']);
                        eval(['obj.P' StrRange{k1} '(iOK).ERP{jj} = ERP;']);
                        eval(['obj.P' StrRange{k1} '(iOK).R2{jj} = R2;']);
                        
                        % Datos filtrados por valores negativos de C o
                        % alpha
                        if param.C < 0 || param.ai < 0
                            eval(['obj.P' StrRange{k1} '(iOK).Filtered{jj} = 1;']);
                        elseif ERP > 0.8
                            eval(['obj.P' StrRange{k1} '(iOK).Filtered{jj} = 1;']);
                        else
                            eval(['obj.P' StrRange{k1} '(iOK).Filtered{jj} = 0;']);
                        end
                        % Datos filtrados por valores con ERP (Error
                        % Relativo Promedio) mayores de 0.8
                        
                        %%%%%%%%%%%%%%%%%%%%%%Pintamos Gráficas
                        
                        if obj.TFOpt.boolShow
                            if jj == 1
                                if nargin < 2
                                    if k1 == 1
                                        fig(i) = figure('Name',[Path 'Positive Ibias Range']);
                                    else
                                        fig(i) = figure('Name',[Path 'Negative Ibias Range']);
                                    end
                                else
                                    figure(fig);
                                    indAxes = findobj(fig,'Type','Axes');
                                    delete(indAxes);
                                end
                                ax = axes;
                                grid(ax,'on');
                                hold(ax,'on');
                            end
                            ind = 1:3:length(ztes);
                            try
                            h(h_i) = plot(ax,1e3*ztes(ind),'.','color',[0 0.447 0.741],...
                                'markerfacecolor',[0 0.447 0.741],'markersize',15,'ButtonDownFcn',{@ChangeGoodOptP},'Tag',[dirs{i} filesep filesZ{jj}]);
                            %%% Paso marker de 'o' a '.'
                            set(ax,'linewidth',2,'fontsize',12,'fontweight','bold');
                            xlabel(ax,'Re(mZ)','fontsize',12,'fontweight','bold');
                            ylabel(ax,'Im(mZ)','fontsize',12,'fontweight','bold');%title('Ztes with fits (red)');
                            ImZmin(jj) = min(imag(1e3*ztes));
                            ylim(ax,[min(-15,min(ImZmin)-1) 1])
                            g(h_i) = plot(ax,1e3*fZ(:,1),1e3*fZ(:,2),'r','linewidth',2,...
                                'ButtonDownFcn',{@ChangeGoodOptP},'Tag',[dirs{i} filesep filesZ{jj} ':fit']);hold(ax,'on');
                            set([h(h_i) g(h_i)],'UserData',[h(h_i) g(h_i)]);
                            catch
                            end
                        end
                        if k == 1 || jj == length(filesZ)
                            aux_str = strcat(num2str(round(param.rp*100)),'% R_n'); %#ok<NASGU>
                        end
                        k = k+1;
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        %%%Analizamos el ruido
                        if ~isempty(filesNoise)
                            
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
                            
                            eval(['obj.P' StrRange{k1} '(iOK).p(jj).ExRes = RES;']);
                            eval(['obj.P' StrRange{k1} '(iOK).p(jj).ThRes = SimRes;']);
                            eval(['obj.P' StrRange{k1} '(iOK).fileNoise(jj) = {FileName};']);
                            eval(['obj.P' StrRange{k1} '(iOK).NoiseModel(jj) = {obj.NoiseOpt.NoiseModel};']);
                            eval(['obj.P' StrRange{k1} '(iOK).fNoise{jj} = fNoise;']);
                            eval(['obj.P' StrRange{k1} '(iOK).SigNoise{jj} = SigNoise;']);
                            eval(['obj.P' StrRange{k1} '(iOK).p(jj).M = M;']);
                            eval(['obj.P' StrRange{k1} '(iOK).p(jj).Mph = Mph;']);
                            
                        end
                        h_i = h_i+1;
                        jj = jj+1;                        
                        
                    end
                    
                    iOK = iOK+1; 
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
                
                try
                    eval(['a = cell2mat(obj.P' StrRange{k1} '(k1).CI'')'''';']);
                    eval(['[rp,rpjj] =sort([obj.P' StrRange{k1} '(k1).p.rp]);']);
                catch
                    rp = [];
                end
                if ~isempty(rp)
                    switch obj.TFOpt.ElecThermModel
                        case 'One Single Thermal Block'
                            StrModelPar = {'Zinf';'Z0';'taueff'};          % 3 parameters
                        case 'Two Thermal Blocks (Specify which)'
                            StrModelPar = {'Zinf';'Z0';'taueff';'ca0';'tauA'};
                        case 'Three Thermal Blocks (Specify which)'
                            StrModelPar = {'Zinf';'Z0';'taueff';'tau1';'tau2';'d1';'d2'};
                    end
                    figParam(k1) = figure; %#ok<AGROW>
                    as = nan(1,length(StrModelPar));
                    for i = 1:length(StrModelPar)
                        as(i) = subplot(1,length(StrModelPar),i);
                        if ~strcmp(StrModelPar{i},'taueff')
                            eval(['errorbar(as(i),rp,[obj.P' StrRange{k1} '(k1).p(rpjj).' StrModelPar{i} '],'...
                                'a(rpjj,i),''LineStyle'',''-.'',''Marker'',''.'',''MarkerEdgeColor'',[1 0 0]);'])
                        else
                            eval(['errorbar(as(i),rp,[obj.P' StrRange{k1} '(k1).p(rpjj).' StrModelPar{i} ']*1e6,'...
                                'a(rpjj,i)*1e6,''LineStyle'',''-.'',''Marker'',''.'',''MarkerEdgeColor'',[1 0 0]);'])
                        end
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
        
        function [param, ztes, fZ, ERP, R2, CI, aux1, StrModel, p0] = FitZ(obj,FileName,FreqRange)
            % Function to fit Z(w) according to the selected
            % electro-thermal model
            
            indSep = find(FileName == filesep);
            Path = FileName(1:indSep(end));
            Name = FileName(find(FileName == filesep, 1, 'last' )+1:end);
            Tbath = sscanf(FileName(indSep(end-1)+1:indSep(end)),'%dmK');
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
            fS = fS(fS >= FreqRange(1) & fS <= FreqRange(2));
            try
                eval(['[~,Tind] = find(abs([obj.P' CondStr '.Tbath]*1e3-Tbath)==0);']);
                eval(['ztes = obj.P' CondStr '(Tind).ztes{IndFile};'])
                if isempty(ztes)
                    error;
                end
            catch
                data = importdata(FileName);
                data = data(data(:,1) >= FreqRange(1) & data(:,1) <= FreqRange(2),:);
                tf = data(:,2)+1i*data(:,3);
                Rth = obj.circuit.Rsh+obj.circuit.Rpar+2*pi*obj.circuit.L*data(:,1)*1i;
                ztes = (obj.TFS.tf(obj.TFS.f >= FreqRange(1) & obj.TFS.f <= FreqRange(2))./tf-1).*Rth;
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
            [p,aux1,aux2,aux3,out,lambda,jacob] = lsqcurvefit(@obj.fitZ,p0,fS,...
                [real(ztes) imag(ztes)],[],[],opts);%#ok<ASGLU> %%%uncomment for real parameters.
            MSE = (aux2'*aux2)/(length(fS)-length(p)); %#ok<NASGU>
            ci = nlparci(p,aux2,'jacobian',jacob);
            CI = (ci(:,2)-ci(:,1))';
            p_CI = [p; CI];
            param = obj.GetModelParameters(p_CI,IV,Ib);
            fZ = obj.fitZ(p,fS);
            ERP = sum(abs(abs(ztes-fZ(:,1)+1i*fZ(:,2))./abs(ztes)))/length(ztes);
            R2 = abs((corr(fZ(:,1)+1i*fZ(:,2),ztes)).^2);
        end
        
        function fz = fitZ(obj,p,f)
            % Function to fit Z(w) according to the selected
            % electro-thermal model
            
            w = 2*pi*f;
            D = (1+(w.^2)*(p(3).^2));
            if length(p) == 3
                %%%p=[Zinf Z0 tau];
                rfz = p(1)-(p(1)-p(2))./D;%%%modelo de 1 bloque.
                imz = -(p(1)-p(2))*w*p(3)./D;%%% modelo de 1 bloque.
                imz = -abs(imz);
            elseif length(p) == 5
                fz = p(1)+(p(1)-p(2)).*(-1+1i*w*p(3).*(1-p(4)*1i*w*p(5)./(1+1i*w*p(5)))).^-1;%%%SRON
                rfz = real(fz);
                imz = -abs(imag(fz));
            elseif length(p) == 7
                %p=[Zinf Z0 tau_I tau_1 tau_2 d1 d2]. Maasilta IH.
                fz = p(1)+(p(2)-p(1)).*(1-p(6)-p(7)).*(1+1i*w*p(3)-p(6)./(1+1i*w*p(4))-p(7)./(1+1i*w*p(5))).^-1;
                rfz = real(fz);
                imz = -abs(imag(fz));
            end
            fz = [rfz imz];
        end
        
        function param = GetModelParameters(obj,p,IVmeasure,Ib)
            % Function to get the model parameters of the electro-thermal
            % model at an specific Ibias value.
            
            Rn = obj.circuit.Rn;
            T0 = obj.TES.Tc;
            G0 = obj.TES.G;
            [iaux,ii] = unique(IVmeasure.ibias,'stable');
            vaux = IVmeasure.vout(ii);
            [m,i3] = min(diff(vaux)./diff(iaux)); %#ok<ASGLU>
            
            %%%% Modificado por Juan %%%%%
            
            CompStr = {'>';'';'<'};
            if eval(['Ib' CompStr{median(sign(iaux))+2} 'iaux(1:i3)'])
                P = polyfit(iaux(i3+1:end),vaux(i3+1:end),1);
                Vout = polyval(P,Ib);
            else
                Vout = ppval(spline(iaux(1:i3),vaux(1:i3)),Ib);
            end
            IVaux.ibias = Ib;
            IVaux.vout = Vout;
            IVaux.Tbath = IVmeasure.Tbath;
            
            F = obj.circuit.invMin/(obj.circuit.invMf*obj.circuit.Rf);%36.51e-6;
            I0 = IVaux.vout*F;
            Vs = (IVaux.ibias-I0)*obj.circuit.Rsh;%(ibias*1e-6-ites)*Rsh;if Ib in uA.
            V0 = Vs-I0*obj.circuit.Rpar;
            
            P0 = V0.*I0;
            R0 = V0/I0;
            
            rp = p(1,:);
            rp_CI = p(2,:);
            rp(1,3) = abs(rp(3));
            if length(rp) == 3
                param.rp = R0/Rn;
                
                param.L0 = (rp(2)-rp(1))/(rp(2)+R0);
                param.L0_CI = sqrt((((rp(1)+R0)/((rp(2)+R0)^2))*rp_CI(2))^2 + ((-1/(R0 + rp(2)))*rp_CI(1))^2 );
                
                param.ai = param.L0*G0*T0/P0;
                param.ai_CI = (G0*T0/P0)*param.L0_CI;
                
                param.bi = (rp(1)/R0)-1;
                param.bi_CI = (1/R0)*rp_CI(1);
                
                param.taueff = rp(3);
                param.taueff_CI = rp_CI(3);
                
                param.tau0 = rp(3)*(param.L0-1);
                param.tau0_CI = sqrt(((param.L0-1)*rp_CI(3))^2 + ((rp(3))*param.L0_CI)^2 );
                
                param.C = param.tau0*G0;
                param.C_CI = G0*param.tau0_CI;
                
                param.Zinf = rp(1);
                param.Zinf_CI = rp_CI(1);
                
                param.Z0 = rp(2);
                param.Z0_CI = rp_CI(2);
                
            elseif(length(p) == 5)
                %derived parameters for 2 block model case A
                param.rp = R0/Rn;
                param.L0 = (rp(2)-rp(1))/(rp(2)+R0);
                param.ai = param.L0*G0*T0/P0;
                param.bi = (rp(1)/R0)-1;
                param.tau0 = rp(3)*(param.L0-1);
                param.taueff = rp(3);
                param.C = param.tau0*G0;
                param.Zinf = rp(1);
                param.Z0 = rp(2);
                param.CA = param.C*rp(4)/(1-rp(4));
                param.GA = param.CA/rp(5);
                param.tauA = rp(5);
                param.ca0 = rp(4);
            elseif(length(p) == 7)
                param = nan;
            end
        end
        
        function [RES, SimRes, M, Mph, fNoise, SigNoise] = fitNoise(obj,FileName, param)
            % Function for Noise analysis.
            
            indSep = find(FileName == filesep);
            Path = FileName(1:indSep(end));
            Name = FileName(find(FileName == filesep, 1, 'last' )+1:end);
            Tbath = sscanf(FileName(indSep(end-1)+1:indSep(end)),'%dmK');
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
            noisedata{1} = importdata(FileName);
            fNoise = noisedata{1}(:,1);
            SigNoise = obj.V2I(noisedata{1}(:,2)*1e12);
            OP = obj.setTESOPfromIb(Ib,IV,param);
            SimulatedNoise = obj.noisesim(OP);
            SimRes = SimulatedNoise.Res;
            f = logspace(0,6,1000);
            sIaux = ppval(spline(f,SimulatedNoise.sI),noisedata{1}(:,1));
            NEP = sqrt(obj.V2I(noisedata{1}(:,2)).^2-SimulatedNoise.squid.^2)./sIaux;
            NEP = NEP(~isnan(NEP));%%%Los ruidos con la PXI tienen el ultimo bin en NAN.
            RES = 2.35/sqrt(trapz(noisedata{1}(1:size(NEP,1),1),1./medfilt1(real(NEP),20).^2))/2/1.609e-19;
            
            %%%Excess noise trials.
            %%%Johnson Excess
            findx = find(noisedata{1}(:,1) > obj.JohnsonExcess(1) & noisedata{1}(:,1) < obj.JohnsonExcess(1));
            xdata = noisedata{1}(findx,1);
            ydata = medfilt1(real(NEP(findx))*1e18,20);
            if isempty(findx)||sum(ydata == Inf) %%%1Z1_23A @70mK 1er punto da error.
                M = 0;
            else
                M = (lsqcurvefit(@(x,xdata) obj.noisesim(OP,x,xdata),0,xdata,ydata,[],[],optimset('Display','off')))*1e18;
            end
            %%%phonon Excess
            findx = find(noisedata{1}(:,1) > obj.PhononExcess(1) & noisedata{1}(:,1) < obj.PhononExcess(2));
            ydata = median(real(NEP(findx))*1e18);
            if isempty(findx)||sum(ydata == inf)
                Mph = 0;
            else
                ymod = median(ppval(spline(f,SimulatedNoise.NEP*1e18),noisedata{1}(findx,1)));
                Mph = sqrt(ydata/ymod-1);
            end
        end
        
        function noise = noisesim(obj,OP,M,f)
            % Function for noise simulation.
            %
            % Simulacion de componentes de ruido.
            % de donde salen las distintas componentes de la fig13.24 de la pag.201 de
            % la tesis de maria? ahi estan dadas en pA/rhz.
            % Las ecs 2.31-2.33 de la tesis de Wouter dan nep(f) pero no tienen la
            % dependencia con la freq adecuada. Cuadra mÃ¡s con las ecuaciones 2.25-2.27
            % que de hecho son ruido en corriente.
            % La tesis de Maria hce referencia (p199) al capÃ­tulo de Irwin y Hilton
            % sobre TES en el libro Cryogenic Particle detection. Tanto en ese capÃ­tulo
            % como en el Ch1 de McCammon salen expresiones para las distintas
            % componentes de ruido.
            %
            %definimos unos valores razonables para los parÃ¡metros del sistema e
            %intentamos aplicar las expresiones de las distintas referencias.
            
            gamma = 0.5;
            Kb = 1.38e-23;
            C = OP.C;
            L = obj.circuit.L;
            G = obj.TES.G;
            alfa = OP.ai;
            bI = OP.bi;
            Rn = obj.circuit.Rn;
            Rs = obj.circuit.Rsh;
            Rpar = obj.circuit.Rpar;
            RL = Rs+Rpar;
            R0 = OP.R0;
            beta = (R0-Rs)/(R0+Rs);
            T0 = obj.TES.Tc;
            Ts = OP.Tbath;
            P0 = OP.P0;
            I0 = OP.I0;
            V0 = OP.V0;
            L0 = P0*alfa/(G*T0);
            n = obj.TES.n;
            
            if isfield(obj.circuit,'Nsquid')
                Nsquid = obj.circuit.Nsquid;
            else
                Nsquid = 3e-12;
            end
            if abs(OP.Z0-OP.Zinf) < 1.5e-3
                I0 = (Rs/RL)*OP.ibias;
            end
            tau = C/G;
            taueff = tau/(1+beta*L0);
            tauI = tau/(1-L0);
            tau_el = L/(RL+R0*(1+bI));
            
            if nargin < 3
                M = 0;
                f = logspace(0,6,1000);
            end
            
            switch obj.NoiseOpt.NoiseModel
                case 'wouter'
                    i_ph = sqrt(4*gamma*Kb*T0^2*G)*alfa*I0*R0./(G*T0*(R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));
                    i_jo = sqrt(4*Kb*T0*R0)*sqrt(1+4*pi^2*tau^2.*f.^2)./((R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));
                    i_sh = sqrt(4*Kb*Ts*Rs)*sqrt((1-L0)^2+4*pi^2*tau^2.*f.^2)./((R0+Rs)*(1+beta*L0)*sqrt(1+4*pi^2*taueff^2.*f.^2));%%%
                    noise.ph = i_ph;noise.jo = i_jo;noise.sh = i_sh;noise.sum = sqrt(i_ph.^2+i_jo.^2+i_sh.^2);
                case 'irwin'
                    sI = -(1/(I0*R0))*(L/(tau_el*R0*L0)+(1-RL/R0)-L*tau*(2*pi*f).^2/(L0*R0)+1i*(2*pi*f)*L*tau*(1/tauI+1/tau_el)/(R0*L0)).^-1;%funcion de transferencia.
                    
                    t = Ts/T0;
                    %%%calculo factor F. See McCammon p11.
                    %n = 3.1;
                    %F = t^(n+1)*(t^(n+2)+1)/2;%F de boyle y rogers. n =  exponente de la ley de P(T). El primer factor viene de la pag22 del cap de Irwin.
                    F = (t^(n+2)+1)/2;%%%specular limit
                    %F = t^(n+1)*(n+1)*(t^(2*n+3)-1)/((2*n+3)*(t^(n+1)-1));%F de Mather. La
                    %diferencia entre las dos fÃ³rmulas es menor del 1%.
                    %F = (n+1)*(t^(2*n+3)-1)/((2*n+3)*(t^(n+1)-1));%%%diffusive limit.
                    
                    stfn = 4*Kb*T0^2*G*abs(sI).^2*F;%Thermal Fluctuation Noise
                    ssh = 4*Kb*Ts*I0^2*RL*(L0-1)^2*(1+4*pi^2*f.^2*tau^2/(1-L0)^2).*abs(sI).^2/L0^2; %Load resistor Noise
                    %M = 1.8;
                    stes = 4*Kb*T0*I0^2*R0*(1+2*bI)*(1+4*pi^2*f.^2*tau^2).*abs(sI).^2/L0^2*(1+M^2);%%%Johnson noise at TES.
                    if ~isreal(sqrt(stes))
                        stes = zeros(1,length(f));
                    end
                    smax = 4*Kb*T0^2*G.*abs(sI).^2;
                    
                    sfaser = 0;%21/(2*pi^2)*((6.626e-34)^2/(1.602e-19)^2)*(10e-9)*P0/R0^2/(2.25e-8)/(1.38e-23*T0);%%%eq22 faser
                    sext = (18.5e-12*abs(sI)).^2;
                    
                    NEP_tfn = sqrt(stfn)./abs(sI);
                    NEP_ssh = sqrt(ssh)./abs(sI);
                    NEP_tes = sqrt(stes)./abs(sI);
                    Res_tfn = 2.35/sqrt(trapz(f,1./NEP_tfn.^2))/2/1.609e-19;
                    Res_ssh = 2.35/sqrt(trapz(f,1./NEP_ssh.^2))/2/1.609e-19;
                    Res_tes = 2.35/sqrt(trapz(f,1./NEP_tes.^2))/2/1.609e-19;
                    Res_tfn_tes = 2.35/sqrt(trapz(f,1./(NEP_tes.*NEP_tfn)))/2/1.609e-19;
                    Res_tfn_ssh = 2.35/sqrt(trapz(f,1./(NEP_ssh.*NEP_tfn)))/2/1.609e-19;
                    Res_ssh_tes = 2.35/sqrt(trapz(f,1./(NEP_tes.*NEP_ssh)))/2/1.609e-19;
                    
                    NEP = sqrt(stfn+ssh+stes)./abs(sI);
                    Res = 2.35/sqrt(trapz(f,1./NEP.^2))/2/1.609e-19;%resoluciÃ³n en eV. Tesis Wouter (2.37).
                    
                    %stes = stes*M^2;
                    i_ph = sqrt(stfn);
                    i_jo = sqrt(stes);
                    if ~isreal(i_jo)
                        i_jo = zeros(1,length(f));
                    end
                    i_sh = sqrt(ssh);
                    %G*5e-8
                    %(n*TES.K*Ts.^n)*5e-6
                    %i_temp = (n*TES.K*Ts.^n)*0e-6*abs(sI);%%%ruido en Tbath.(5e-4 = 200uK, 5e-5 = 20uK, 5e-6 = 2uK)
                    
                    noise.f = f;
                    noise.ph = i_ph;noise.jo = i_jo;noise.sh = i_sh;noise.sum = sqrt(stfn+stes+ssh);%noise.sum = i_ph+i_jo+i_sh;
                    noise.sI = abs(sI);noise.NEP = NEP;noise.max = sqrt(smax);noise.Res = Res;%noise.tbath = i_temp;
                    noise.Res_tfn = Res_tfn; noise.Res_ssh = Res_ssh; noise.Res_tes = Res_tes;
                    noise.Res_tfn_tes = Res_tfn_tes;noise.Res_tfn_ssh = Res_tfn_ssh;noise.Res_ssh_tes = Res_ssh_tes;
                    noise.squid = Nsquid;
                    noise.squidarray = Nsquid*ones(1,length(f));
                otherwise
                    warndlg('no valid model','ZarTES v1.0');
                    noise = [];
            end
        end
        
        function Ites = V2I(obj,vout)
            % Function to convert Vout values to Ites
            
            Ites = vout*obj.circuit.invMin/(obj.circuit.invMf*obj.circuit.Rf);
        end
        
        function OP  =  setTESOPfromIb(obj,Ib,IV,p)
            % Function to set the TES operating point from Ibias and IV curves and fitted
            % parameters p.
            
            [iaux,ii] = unique(IV.ibias,'stable');
            vaux = IV.vout(ii);
            [m,i3] = min(diff(vaux)./diff(iaux)); %#ok<ASGLU>
            
            %%%% Modificado por Juan %%%%%
            
            CompStr = {'>';'';'<'};
            if eval(['Ib' CompStr{median(sign(iaux))+2} 'iaux(1:i3)'])
                P = polyfit(iaux(i3+1:end),vaux(i3+1:end),1);
                OP.vout = polyval(P,Ib);
            else
                OP.vout = ppval(spline(iaux(1:i3),vaux(1:i3)),Ib);
            end
            
            %%%%%%%%%%%%%%%%
            
            OP.ibias = Ib;
            OP.Tbath = IV.Tbath;
            
            F = obj.circuit.invMin/(obj.circuit.invMf*obj.circuit.Rf);%36.51e-6;
            %F=36.52e-6;
            ites = OP.vout*F;
            Vs = (OP.ibias-ites)*obj.circuit.Rsh;%(ibias*1e-6-ites)*Rsh;if Ib in uA.
            vtes = Vs-ites*obj.circuit.Rpar;
            OP.P0 = vtes.*ites;
            OP.R0 = vtes./ites;
            OP.r0 = OP.R0/obj.circuit.Rn;
            OP.I0 = ites;
            OP.V0 = vtes;
            
            if length(p) > 1
                OP.ai = ppval(spline([p.rp],[p.ai]),OP.r0);
                OP.bi = ppval(spline([p.rp],[p.bi]),OP.r0);
                OP.C = ppval(spline([p.rp],[p.C]),OP.r0);
                OP.L0 = ppval(spline([p.rp],[p.L0]),OP.r0);
                OP.tau0 = ppval(spline([p.rp],[p.tau0]),OP.r0);
                OP.Z0 = ppval(spline([p.rp],[p.Z0]),OP.r0);
                OP.Zinf = ppval(spline([p.rp],[p.Zinf]),OP.r0);
                OP.M = ppval(spline([p.rp],real([p.M])),OP.r0);
                OP.Mph = ppval(spline([p.rp],real([p.Mph])),OP.r0);
                OP.G0 = OP.C./OP.tau0;
            else
                OP.ai = p.ai;
                OP.bi = p.bi;
                OP.C = p.C;
                OP.L0 = p.L0;
                OP.tau0 = p.tau0;
                OP.Z0 = p.Z0;
                OP.Zinf = p.Zinf;
                OP.G0 = OP.C./OP.tau0;
            end
        end
        
        function plotABCT(obj,fig)
            % Function to visualize the model parameters, alpha, beta, C
            % and Tbath.
            
            warning off;
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
            DataStr = {'rp(IndxGood),[P(i).p(jj(IndxGood)).C]*1e15';'rp(IndxGood),[P(i).p(jj(IndxGood)).taueff]*1e6';...
                'rp(IndxGood),[P(i).p(jj(IndxGood)).ai]';'rp(IndxGood),[P(i).p(jj(IndxGood)).bi]'};
            DataStr_CI = {'[P(i).p(jj(IndxGood)).C_CI]*1e15';'[P(i).p(jj(IndxGood)).taueff_CI]*1e6';...
                '[P(i).p(jj(IndxGood)).ai_CI]';'[P(i).p(jj(IndxGood)).bi_CI]'};
            
            DataStrBad = {'rp(IndxBad),[P(i).p(jj(IndxBad)).C]*1e15';'rp(IndxBad),[P(i).p(jj(IndxBad)).taueff]*1e6';...
                'rp(IndxBad),[P(i).p(jj(IndxBad)).ai]';'rp(IndxBad),[P(i).p(jj(IndxBad)).bi]'};
            DataStrBad_CI = {'[P(i).p(jj(IndxBad)).C_CI]*1e15';'[P(i).p(jj(IndxBad)).taueff_CI]*1e6';...
                '[P(i).p(jj(IndxBad)).ai_CI]';'[P(i).p(jj(IndxBad)).bi_CI]'};
            PlotStr = {'plot';'semilogy';'plot';'semilogy'};
            
            StrRange = {'P';'N'};
            ind = 1;
            for k = 1:2
                if isempty(eval(['obj.P' StrRange{k} '.Tbath']))
                    continue;
                end
                P = eval(['obj.P' StrRange{k} ';']);
                if nargin < 2
                    fig.hObject = figure('Visible','off');
                end
                if ~isfield(fig,'subplots')
                    h = nan(4,1);
                    for i = 1:4
                        h(i) = subplot(2,2,i,'Visible','off','ButtonDownFcn',{@Identify_Origin});
                    end
                else
                    h = fig.subplots;
                end
                for i = 1:length(P)
                    if mod(i,2)
                        MarkerStr(i) = {'.-'};
                    else
                        MarkerStr(i) = {'.-.'};
                    end
                    TbathStr = [num2str(P(i).Tbath*1e3) 'mK-']; %mK
                    if k == 1
                        NameStr = [TbathStr 'PosIbias'];
                    else
                        NameStr = [TbathStr 'NegIbias'];
                    end
                    try
                        [rp,jj] = sort([P(i).p.rp]);
                    catch
                        continue;
                    end
                    if isempty(P(i).Filtered{1})
                        P(i).Filtered(1:length(rp)) = {0};
                    end
                    IndxGood = find(cell2mat(P(i).Filtered(jj))== 0);
                    IndxBad = find(cell2mat(P(i).Filtered(jj))== 1);
                    
                    for j = 1:4
                        
                        eval(['grid(h(' num2str(j) '),''on'');']);
                        eval(['hold(h(' num2str(j) '),''on'');']);
                        try
                            eval(['er(ind) = errorbar(h(' num2str(j) '),' DataStr{j} ',' DataStr_CI{j} ',''color'',colors{k},''Visible'',''off'',''DisplayName'',''' NameStr ' Error Bar'',''Clipping'',''on'');']);
                        catch
                        end
                        try
                        eval(['h_ax(' num2str(i) ',' num2str(j) ') = ' PlotStr{j} '(h(' num2str(j) '),' DataStr{j} ...
                            ',''' MarkerStr{i} ''',''color'',colors{k},''linewidth'',LW1,''markersize'',MS,''DisplayName'',''' NameStr ''''...
                            ',''ButtonDownFcn'',{@Identify_Origin},''UserData'',[{P;i;k;obj.circuit}]);']);
                        eval(['set(h(' num2str(j) '),''fontsize'',11,''fontweight'',''bold'');']);
                        eval(['axis(h(' num2str(j) '),''tight'');']);
                        catch
                        end
                        try
                            eval(['erbad(ind) = errorbar(h(' num2str(j) '),' DataStrBad{j} ',' DataStrBad_CI{j} ',''Visible'',''off'',''color'',[1 1 1]*160/255,'...
                                '''linestyle'',''none'',''DisplayName'',''Filtered Error Bar'',''Clipping'',''on'');']);
                            eval(['h_bad(ind) = ' PlotStr{j} '(h(' num2str(j) '),' DataStrBad{j} ...
                                ',''' MarkerStr{i} ''',''color'',[1 1 1]*160/255,''markersize'',MS,''DisplayName'',''Filtered'''...
                                ',''ButtonDownFcn'',{@Identify_Origin},''UserData'',[{P;i;k;obj.circuit}],''Visible'',''off'',''linestyle'',''none'');']);                                                       
                        catch
                        end                        
                        
                        eval(['xlabel(h(' num2str(j) '),''R_{TES}/R_n'',''fontsize'',11,''fontweight'',''bold'');']);
                        eval(['ylabel(h(' num2str(j) '),''' YLabels{j} ''',''fontsize'',11,''fontweight'',''bold'');']);
                        ind = ind+1;
                    end
                end
                
                if ~isfield(fig,'subplots')
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
            
            try
                data.er = er;
                data.h_bad = h_bad;
                data.erbad = erbad;
                set(h,'ButtonDownFcn',{@GraphicErrors},'UserData',data,'fontsize',12,'linewidth',2,'fontweight','bold')
            catch
            end
            set(h,'Visible','on')
            
        end
        
        function fig = PlotNoiseTbathRp(obj,Tbath,Rn,fig)
            % Function to visualize noise representations with respect to
            % Rn values
            
            StrCond = {'P';'N'};
            StrCond_Label = {'Positive_Ibias';'Negative_Ibias'};
            IndFig = 1;
            for iP = 1:2
                if isempty(Tbath)
                    ind_TbathN = 1:length(eval(['[obj.P' StrCond{iP} '.Tbath]']));
                else
                    for i = 1:length(Tbath)
                        eval(['ind_TbathN(i) = find([obj.P' StrCond{iP} '.Tbath]'' == Tbath(i));']);
                    end
                end
                for ind_Tbath = ind_TbathN
                    
                    if ~isempty(Rn)
                        %                     Rn = sort(0.20:0.10:0.8,'descend');  % Example of using
                        eval(['Rp = [obj.P' StrCond{iP} '(ind_Tbath).p.rp];']);
                        
                        for i = 1:length(Rn)
                            [~,ind(i)] = min(abs(Rp-Rn(i)));
                        end
                        try
                            eval(['files' StrCond{iP} ' = [obj.P' StrCond{iP} '(ind_Tbath).fileNoise(ind)]'';';]);
                            eval(['N = length(files' StrCond{iP} ');']);
                        catch
                            return;
                        end
                    else
                        eval(['files' StrCond{iP} ' = [obj.P' StrCond{iP} '(ind_Tbath).fileNoise]'';';]);
                        eval(['N = length(files' StrCond{iP} ');']);
                        ind = N:-1:1;
                        eval(['files' StrCond{iP} ' = files' StrCond{iP} '(ind);']);
                    end
                    
                    if nargin < 4
                        fig(IndFig) = figure('Name',StrCond_Label{iP});
                    end
                    [ncols,~] = SmartSplit(N);
                    hs = nan(N,1);
                    j = 0;
                    for i = 1:N
                        hs(i) = subplot(ceil(N/ncols),ncols,i);
                        hold(hs(i),'on');
                        grid(hs(i),'on');
                        xlabel(hs(i),'\nu (Hz)');
                        if ~mod(j,ncols)
                            switch obj.NoiseOpt.tipo
                                case 'current'
                                    ylabel(hs(i),'pA/Hz^{0.5}');
                                case 'nep'
                                    ylabel(hs(i),'aW/Hz^{0.5}');
                            end
                            j = 0;
                        end
                        j = j+1;
                    end
                    set(hs,'LineWidth',2,'FontSize',11,'FontWeight','bold',...
                        'XMinorGrid','off','YMinorGrid','off','GridLineStyle','-',...
                        'xtick',[10 100 1000 1e4 1e5],'xticklabel',{'10' '10^2' '10^3' '10^4' '10^5'},...
                        'XScale','log','YScale','log');
                    
                    for i = 1:N
                        eval(['FileName = files' StrCond{iP} '{i};']);
                        FileName = FileName(find(FileName == filesep,1,'last')+1:end);
                        Ib = sscanf(FileName,strcat(obj.NoiseOpt.NoiseBaseName(2:end-1),'_%fuA.txt'))*1e-6; %%%HP_noise para ZTES18.!!!
                        eval(['OP = obj.setTESOPfromIb(Ib,obj.IVset' StrCond{iP} '(ind_Tbath),obj.P' StrCond{iP} '(ind_Tbath).p);']);
                        if obj.NoiseOpt.Mjo == 1
                            M = OP.M;
                        else
                            M = 0;
                        end
                        SigNoise = eval(['obj.P' StrCond{iP} '(ind_Tbath).SigNoise{ind(i)};']);
                        fNoise = eval(['obj.P' StrCond{iP} '(ind_Tbath).fNoise{ind(i)};']);
                        
                        f = logspace(0,6,1000);
                        auxnoise = obj.noisesim(OP,M,f);
                        
                        
                        switch obj.NoiseOpt.tipo
                            case 'current'
                                
                                loglog(hs(i),fNoise(:,1),SigNoise,'.-r'); %%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
                                loglog(hs(i),fNoise(:,1),medfilt1(SigNoise,20),'.-k'); %%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
                                
                                if obj.NoiseOpt.Mph == 0
                                    totnoise = sqrt(auxnoise.sum.^2+auxnoise.squidarray.^2);
                                else
                                    Mexph = OP.Mph;
                                    totnoise = sqrt((auxnoise.ph*(1+Mexph^2)).^2+auxnoise.jo.^2+auxnoise.sh.^2+auxnoise.squidarray.^2);
                                end
                                if ~obj.NoiseOpt.boolcomponents
                                    loglog(hs(i),f,totnoise*1e12,'b');
                                    h = findobj(hs(i),'color','b');
                                else
                                    loglog(hs(i),f,auxnoise.jo*1e12,f,auxnoise.ph*1e12,f,auxnoise.sh*1e12,f,totnoise*1e12);
                                    legend(hs(i),'experimental','exp\_filtered','jhonson','phonon','shunt','total');
                                    legend(hs(i),'off');
                                    h = findobj(hs,'displayname','total');
                                end
                            case 'nep'
                                sIaux = ppval(spline(f,auxnoise.sI),fNoise(:,1));
                                NEP = real(sqrt((SigNoise*1e-12).^2-auxnoise.squid.^2)./sIaux);
                                loglog(hs(i),fNoise(:,1),(NEP*1e18),'.-r'),hold on,grid on,
                                loglog(hs(i),fNoise(:,1),medfilt1(NEP*1e18,20),'.-k'),hold on,grid on,
                                if obj.NoiseOpt.Mph == 0
                                    totNEP = auxnoise.NEP;
                                else
                                    totNEP = sqrt(auxnoise.max.^2+auxnoise.jo.^2+auxnoise.sh.^2)./auxnoise.sI;%%%Ojo, estamos asumiendo Mph tal que F = 1, no tiene porqué.
                                end
                                if ~obj.NoiseOpt.boolcomponents
                                    loglog(hs(i),f,totNEP*1e18,'b');hold on;grid on;
                                    h = findobj(hs(i),'color','b');
                                else
                                    loglog(hs(i),f,auxnoise.jo*1e18./auxnoise.sI,f,auxnoise.ph*1e18./auxnoise.sI,f,auxnoise.sh*1e18./auxnoise.sI,f,(totNEP*1e18));
                                    legend(hs(i),'experimental','exp\_filtered','jhonson','phonon','shunt','total');
                                    legend(hs(i),'off');
                                    h = findobj(hs(i),'displayname','total');
                                end
                        end
                        axis(hs(i),[1e1 1e5 2 1e3])
                        title(hs(i),strcat(num2str(nearest(OP.r0*100),'%3.0f'),'%Rn'),'fontsize',12);
                        if abs(OP.Z0-OP.Zinf) < 1.5e-3
                            set(get(findobj(hs(i),'type','axes'),'title'),'color','r');
                        end
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        
                        %%%%Pruebas sobre la cotribución de cada frecuencia a la
                        %%%%Resolucion.
                        if strcmpi(obj.NoiseOpt,'nep')
                            RESJ = sqrt(2*log(2)./trapz(f,1./totNEP.^2));
                            disp(num2str(RESJ));
                            semilogx(hs(i),f(1:end-1),sqrt((2*log(2)./cumsum((1./totNEP(1:end-1).^2).*diff(f))))/1.609e-19),hold on
                            RESJ2 = sqrt(2*log(2)./trapz(fNoise(:,1),1./NEP.^2));
                            disp(num2str(RESJ2));
                            semilogx(hs(i),fNoise(1:end-1),sqrt((2*log(2)./cumsum(1./NEP(1:end-1).^2.*diff(fNoise(:,1)))))/1.609e-19,'r')
                        end
                        
                    end
                    if nargin < 3
                        n = get(fig(IndFig),'number');
                        fi = strcat('-f',num2str(n));
                        mkdir('figs');
                        name = strcat('figs\Noise',num2str(eval(['[obj.P' StrCond{iP} '(ind_Tbath).Tbath]'])*1e3),'mK_',StrCond_Label{iP});
                        print(fi,name,'-dpng','-r0');
                    end
                    IndFig = IndFig+1;
                end
            end
        end
        
        function fig = PlotTFTbathRp(obj,Tbath,Rn,fig)
            % Function to visualize Z(w) representations with respect to
            % Rn values
            
            StrCond = {'P';'N'};
            StrCond_Label = {'Positive_Ibias';'Negative_Ibias'};
            IndFig = 1;
            for iP = 1:2
                if isempty(Tbath)
                    ind_TbathN = 1:length(eval(['[obj.P' StrCond{iP} '.Tbath]']));
                else
                    for i = 1:length(Tbath)
                        try
                            eval(['ind_TbathN(i) = find([obj.P' StrCond{iP} '.Tbath]'' == Tbath(i));']);
                        catch
                            return;
                        end
                    end
                end
                for ind_Tbath = ind_TbathN
                    
                    if ~isempty(Rn)
                        eval(['Rp = [obj.P' StrCond{iP} '(ind_Tbath).p.rp];']);
                        
                        for i = 1:length(Rn)
                            [~,ind(i)] = min(abs(Rp-Rn(i)));
                        end
                        try
                            eval(['files' StrCond{iP} ' = [obj.P' StrCond{iP} '(ind_Tbath).fileZ(ind)]'';';]);
                            eval(['N = length(files' StrCond{iP} ');']);
                        catch
                            continue;
                        end
                    else
                        eval(['files' StrCond{iP} ' = [obj.P' StrCond{iP} '(ind_Tbath).fileZ]'';';]);
                        eval(['N = length(files' StrCond{iP} ');']);
                        ind = N:-1:1;
                        eval(['files' StrCond{iP} ' = files' StrCond{iP} '(ind);']);
                    end
                    if nargin < 4
                        fig(IndFig) = figure('Name',[StrCond_Label{iP} ' ' num2str(eval(['[obj.P' StrCond{iP} '(ind_Tbath).Tbath]'])*1e3) ' mK']);
                    end
                    [ncols,~] = SmartSplit(N);
                    hs = nan(N,1);
                    j = 0;
                    for i = 1:N
                        hs(i) = subplot(ceil(N/ncols),ncols,i);
                        hold(hs(i),'on');
                        grid(hs(i),'on');
                        xlabel(hs(i),'Re(mZ)');
                        if ~mod(j,ncols)
                            ylabel(hs(i),'Im(mZ)');
                            j = 0;
                        end
                        j = j+1;
                    end
                    set(hs,'LineWidth',2,'FontSize',11,'FontWeight','bold');
                    for i = 1:N
                        eval(['FileName = files' StrCond{iP} '{i};']);
                        FileName = FileName(find(FileName == filesep,1,'last')+1:end);
                        if ~isempty(strfind(upper(FileName),'TF_PXI_'))
                            Ib = sscanf(FileName,'TF_PXI_%fuA.txt')*1e-6;
                        else
                            Ib = sscanf(FileName,'TF_%fuA.txt')*1e-6;
                        end
                        eval(['OP = obj.setTESOPfromIb(Ib,obj.IVset' StrCond{iP} '(ind_Tbath),obj.P' StrCond{iP} '(ind_Tbath).p);']);
                        
                        ztes = eval(['obj.P' StrCond{iP} '(ind_Tbath).ztes{ind(i)};']);
                        fZ = eval(['obj.P' StrCond{iP} '(ind_Tbath).fZ{ind(i)};']);
                        
                        plot(hs(i),1e3*ztes,'.','color',[0 0.447 0.741],...
                            'markerfacecolor',[0 0.447 0.741],'markersize',15);
                        
                        ImZmin = min(imag(1e3*ztes));
                        ylim(hs(i),[min(-15,min(ImZmin)-1) 1])
                        plot(hs(i),1e3*fZ(:,1),1e3*fZ(:,2),'r','linewidth',2);
                        title(hs(i),strcat(num2str(nearest(OP.r0*100),'%3.0f'),'%Rn'),'fontsize',12);
                        if abs(OP.Z0-OP.Zinf) < 1.5e-3
                            set(get(findobj(hs(i),'type','axes'),'title'),'color','r');
                        end
                    end
                    if nargin < 3
                        n = get(fig(IndFig),'number');
                        fi = strcat('-f',num2str(n));
                        mkdir('figs');
                        name = strcat('figs\TF',num2str(eval(['[obj.P' StrCond{iP} '(ind_Tbath).Tbath]'])*1e3),'mK_',StrCond_Label{iP});
                        print(fi,name,'-dpng','-r0');
                    end
                    IndFig = IndFig+1;
                end
            end
        end
        
        function GraphsReport(obj)
            % Function to generate a word file report summarizing the most
            % important data and figures of the TES analysis.
            
            WordFileName = 'TestDoc.doc';
            CurDir = pwd;
            FileSpec = fullfile(CurDir,WordFileName);
            
            ActXWord = actxserver('Word.Application');
            ActXWord.Visible = false;
            trace(ActXWord.Visible);
            WordHandle = invoke(ActXWord.Documents,'Add');
            
            answer = inputdlg({'Insert Name of the TES or date'},'ZarTES v1.0',[1 50],{' '});
            if isempty(answer)
                return;
            end
            ActXWord.Selection.Font.Name = 'Arial';
            ActXWord.Selection.Font.Size = 15;
            ActXWord.Selection.BoldRun;
            ActXWord.Selection.TypeText(['Informe del TES: ' answer{1}]);
            ActXWord.Selection.TypeParagraph; %enter
            ActXWord.Selection.TypeParagraph;
            
            ActXWord.Selection.Font.Size = 11;
            ActXWord.Selection.LtrRun;
            ActXWord.Selection.TypeText('TES Circuit parameters:');
            ActXWord.Selection.TypeParagraph;
            
            CircProp = properties(obj.circuit);
            for i = 1:length(CircProp)
                CircProp{i} = [CircProp{i} ': ' num2str(eval(['obj.circuit.' CircProp{i}]))];
                ActXWord.Selection.TypeText(CircProp{i});
                ActXWord.Selection.TypeParagraph;
            end
            
            ActXWord.Selection.TypeParagraph; %enter
            ActXWord.Selection.TypeParagraph;
            ActXWord.Selection.TypeText('TES parameters:');
            ActXWord.Selection.TypeParagraph;
            
            TESProp = properties(obj.TES);
            for i = 1:length(TESProp)
                TESProp{i} = [TESProp{i} ': ' num2str(eval(['obj.TES.' TESProp{i}]))];
                ActXWord.Selection.TypeText(TESProp{i});
                ActXWord.Selection.TypeParagraph;
            end
            ActXWord.Selection.TypeParagraph; %enter
            ActXWord.Selection.TypeParagraph;
            
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
                
                
                TextString = 'IV Curves';
                ActXWord.Selection.TypeText(TextString);
                ActXWord.Selection.TypeParagraph; %enter
                
                print(figIV.hObject,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                close(figIV.hObject);
                clear figIV;
                ActXWord.Selection.TypeParagraph; %enter
                ActXWord.Selection.TypeParagraph;
            end
            
            if obj.Report.FitPTset
                StrRange = {'P';'N'};
                fig = figure('Name','FitP vs. Tset');
                for k = 1:2
                    if isempty(eval(['obj.IVset' StrRange{k} '.ibias']))
                        continue;
                    end
                    IVTESset = eval(['obj.IVset' StrRange{k}]);
                    ax = subplot(1,2,k); hold(ax,'on');
                    eval(['perc = [obj.Gset' StrRange{k} '.rp]'';'])
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
                        
                        switch eval(['obj.Gset' StrRange{k} '(jj).model'])
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
                        if eval(['obj.Gset' StrRange{k} '(jj).model']) ~= 3
                            opts = optimset('Display','off');
                            [fit,resnorm,residual,exitflag,output,lambda,jacob] = lsqcurvefit(@obj.fitP,X0,XDATA,Paux*1e12,LB,[],opts); %#ok<ASGLU>
                            plot(ax,Tbath,obj.fitP(fit,XDATA),'-r','linewidth',1)
                        end
                    end
                    xlabel(ax,'T_{bath}(K)','fontsize',11,'fontweight','bold')
                    ylabel(ax,'P_{TES}(pW)','fontsize',11,'fontweight','bold')
                    set(ax,'fontsize',12,'linewidth',2,'fontweight','bold')
                end
                print(fig,'-dmeta');
                close(fig);
                clear fig;
                ActXWord.Selection.TypeParagraph; %enter
                ActXWord.Selection.TypeParagraph;
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
                
                TextString = 'NKGT Figure';
                ActXWord.Selection.TypeText(TextString);
                ActXWord.Selection.TypeParagraph; %enter
                
                print(fig.hObject,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                ActXWord.Selection.TypeParagraph;
                close(fig.hObject);
                clear fig;
                ActXWord.Selection.TypeParagraph; %enter
                ActXWord.Selection.TypeParagraph;
            end
            
            if obj.Report.FitZset
                TextString = 'Z(w) Analysis';
                ActXWord.Selection.TypeText(TextString);
                ActXWord.Selection.TypeParagraph; %enter
                ActXWord.Selection.TypeParagraph;
                
                prompt = {'Enter the %Rn range:'};
                name = '%Rn range (0 < %Rn < 1)';
                numlines = [1 70];
                defaultanswer = {'0.5:0.05:0.8'};
                answer = inputdlg(prompt,name,numlines,defaultanswer);
                Rn = eval(['[' answer{1} ']']);
                
                fig = obj.PlotTFTbathRp([],Rn);
                try
                    Temps = num2str([obj.PP.Tbath]'*1e3);
                    for i = 1:length(Temps)
                        StrIni = ['Positive Ibias at ' Temps(i,:) ' mK ',];
                        StrIni(end) = [];
                        ActXWord.Selection.TypeText(StrIni)
                        ActXWord.Selection.TypeParagraph;
                        ActXWord.Selection.TypeParagraph;
                        print(fig(i),'-dmeta')
                        invoke(ActXWord.Selection,'Paste');
                        close(fig(i));
                        ActXWord.Selection.TypeParagraph;
                        ActXWord.Selection.TypeParagraph;
                    end
                catch
                end
                try
                    Temps = num2str([obj.PN.Tbath]'*1e3);
                    for j = 1:length(Temps)
                        StrIni = ['Negative Ibias at ' Temps(j,:) ' mK ',];
                        StrIni(end) = [];
                        ActXWord.Selection.TypeText(StrIni)
                        ActXWord.Selection.TypeParagraph;
                        ActXWord.Selection.TypeParagraph;
                        print(fig(i),'-dmeta')
                        invoke(ActXWord.Selection,'Paste');
                        close(fig(i));
                        ActXWord.Selection.TypeParagraph;
                        ActXWord.Selection.TypeParagraph;
                    end
                catch
                end
                clear fig;
            end
            
            if obj.Report.NoiseSet
                TextString = 'Noise Analysis';
                ActXWord.Selection.TypeText(TextString);
                ActXWord.Selection.TypeParagraph; %enter
                ActXWord.Selection.TypeParagraph;
                
                prompt = {'Enter the %Rn range:'};
                name = '%Rn range (0 < %Rn < 1)';
                numlines = [1 70];
                defaultanswer = {'0.5:0.05:0.8'};
                answer = inputdlg(prompt,name,numlines,defaultanswer);
                Rn = eval(['[' answer{1} ']']);
                
                fig = obj.PlotNoiseTbathRp([],Rn);
                try
                    Temps = num2str([obj.PP.Tbath]'*1e3);
                    for i = 1:length(Temps)
                        StrIni = ['Positive Ibias at ' Temps(i,:) ' mK ',];
                        StrIni(end) = [];
                        ActXWord.Selection.TypeText(StrIni)
                        ActXWord.Selection.TypeParagraph;
                        ActXWord.Selection.TypeParagraph;
                        print(fig(i),'-dmeta')
                        invoke(ActXWord.Selection,'Paste');
                        close(fig(i));
                        ActXWord.Selection.TypeParagraph;
                        ActXWord.Selection.TypeParagraph;
                    end
                    
                catch
                end
                try
                    Temps = num2str([obj.PN.Tbath]'*1e3);
                    for j = 1:length(Temps)
                        StrIni = ['Negative Ibias at ' Temps(j,:) ' mK ',];
                        StrIni(end) = [];
                        ActXWord.Selection.TypeText(StrIni)
                        ActXWord.Selection.TypeParagraph;
                        ActXWord.Selection.TypeParagraph;
                        print(fig(i),'-dmeta')
                        invoke(ActXWord.Selection,'Paste');
                        close(fig(i));
                        ActXWord.Selection.TypeParagraph;
                        ActXWord.Selection.TypeParagraph;
                    end
                    
                catch
                end
                clear fig;
            end
            
            if obj.Report.ABCTset
                fig.hObject = figure;
                obj.plotABCT(fig);
                
                TextString = 'ABCT Figure';
                ActXWord.Selection.TypeText(TextString);
                ActXWord.Selection.TypeParagraph; %enter
                ActXWord.Selection.TypeParagraph;
                
                print(fig.hObject,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                close(fig.hObject);
                clear fig;
                ActXWord.Selection.TypeParagraph;
                ActXWord.Selection.TypeParagraph;
                
                try
                    ActXWord.Selection.TypeText(['Fitting TF to: ' obj.PP(1).ElecThermModel{1}]);
                    ActXWord.Selection.TypeParagraph;
                    ActXWord.Selection.TypeParagraph;
                catch
                end
                
            end
            
            if ~exist(FileSpec,'file')
                % Save file as new:
                invoke(WordHandle,'SaveAs',FileSpec,1);
            else
                % Save existing file:
                invoke(WordHandle,'Save');
            end
            % Close the word window:
            invoke(WordHandle,'Close');
            % Quit MS Word
            invoke(ActXWord,'Quit');
            % Close Word and terminate ActiveX:
            delete(ActXWord);
        end
        
        function fig = PlotTESData(obj,param,Rn,Tbath,fig)
            % Function to visualize TES data: param vs Tbath, param vs Rn,
            % param1 vs param2
            
            if ~ischar(param)
                warndlg('param must be string','ZarTES v1.0');
                return;
            elseif size(param,1) == 1
                YLabels = {'C(fJ/K)';'\tau_{eff}(\mus)';'\alpha_i';'\beta_i'};
                colors{1} = [0 0.4470 0.7410];
                colors{2} = [1 0.5 0.05];
                if isempty(Tbath)
                    valP = nan;
                    valN = nan;
                    % Selecion de Rn y parametro a buscar en funcion de Tbath
                    [valP,TbathP,RnsP] = obj.PP.GetParamVsTbath(param,Rn); % Rn must be 0-1 value
                    [valN,TbathN,RnsN] = obj.PN.GetParamVsTbath(param,Rn); % Rn must be 0-1 value
                    
                    % Añadimos las barras de error
                    if isempty(strfind(param,'_CI'))
                        try
                            [valP_CI,TbathP,RnsP] = obj.PP.GetParamVsTbath([param '_CI'],Rn); % Rn must be 0-1 value
                            [valN_CI,TbathN,RnsN] = obj.PN.GetParamVsTbath([param '_CI'],Rn); % Rn must be 0-1 value
                        catch
                            
                        end
                    end
                    
                    StrRange = {'P';'N'};
                    StrCond = {'Positive';'Negative'};
                    StrMarker = {'o';'^'};
                    if nargin < 5
                        fig = figure('Visible','on');
                    end
                    if isempty(findobj('Type','Axes'))
                        figure(fig);
                        ax = axes;
                        hold(ax,'on');
                    else
                        ax = findobj('Type','Axes');
%                         if length(ax) > 1
%                             ax = axes;
%                             hold(ax,'on');
%                         end
                    end
                    for k = 1:2
                        
                        for i = 1:eval(['size(Tbath' StrRange{k} ',1)'])
                            if strcmp(param,'ai')||strcmp(param,'ai_CI')||strcmp(param,'C')||strcmp(param,'C_CI')
                                eval(['val' StrRange{k} '(i,:) = abs(val' StrRange{k} '(i,:));']);
                                if strcmp(param,'ai')||strcmp(param,'ai_CI')
                                    Ylabel = '\alpha_i';
                                end
                                if strcmp(param,'C')||strcmp(param,'C_CI')
                                    Ylabel = 'C(fJ/K)';
                                end
                            elseif strcmp(param,'taueff')||strcmp(param,'taueff_CI')
                                eval(['val' StrRange{k} '(i,:) = val' StrRange{k} '(i,:)*1e6;']);
                                Ylabel = '\tau_{eff}(\mus)';
                            elseif strcmp(param,'bi')||strcmp(param,'bi_CI')
                                Ylabel = '\beta_i';
                            else
                                Ylabel = param;
                            end
                        end
                        eval(['h = plot(ax,Tbath' StrRange{k} ',val' StrRange{k} ',''LineStyle'',''-.'',''Marker'',''' StrMarker{k} ''''...
                            ',''DisplayName'',''' StrCond{k} ' Ibias'');']);
                        try
                            eval(['e = errorbar(ax,Tbath' StrRange{k} ',val' StrRange{k} ',val' StrRange{k} '_CI,''LineStyle'',''-.'',''Marker'',''' StrMarker{k} ''''...
                                ',''DisplayName'',''' StrCond{k} ' Ibias'',''Visible'',''off'');']);
                        catch
                        end
                        for n = 1:length(h)
                            h(n).MarkerFaceColor = h(n).Color;
                        end
                    end
                    xlabel(ax,'T_{bath} (K)');
                    ylabel(ax,Ylabel);
                    set(ax,'FontSize',11,'FontWeight','bold');
                    grid(ax,'on');
                    set(ax,'ButtonDownFcn',{@GraphicErrors_NKGT});
                    
                elseif isempty(Rn)
                    valP = nan;
                    valN = nan;
                    % Selecion de Tbath y parametro a buscar en funcion de Rn
                    [valP,rpP,TbathP] = obj.PP.GetParamVsRn(param,Tbath); % Tbath = '50.0mK' o Tbath = 0.05;
                    [valN,rpN,TbathN] = obj.PN.GetParamVsRn(param,Tbath);
                    
                    if isempty(strfind(param,'_CI'))
                        try
                            [valP_CI,rpP,TbathP] = obj.PP.GetParamVsRn([param '_CI'],Tbath); % Tbath = '50.0mK' o Tbath = 0.05;
                            [valN_CI,rpN,TbathN] = obj.PN.GetParamVsRn([param '_CI'],Tbath);
                        catch
                        end
                    end
                    if nargin < 5
                        fig = figure('Visible','on');
                    end
                    if isempty(findobj('Type','Axes'))
                        figure(fig);
                        ax = axes;
                        hold(ax,'on');
                    else
                        ax = findobj('Type','Axes');
%                         if length(ax) > 1
%                             ax = axes;
%                             hold(ax,'on');
%                         end
                    end
                    StrRange = {'P';'N'};
                    StrCond = {'Positive';'Negative'};
                    for k = 1:2
                        for i = 1:eval(['length(Tbath' StrRange{k} ')'])
                            if strcmp(param,'ai')||strcmp(param,'ai_CI')||strcmp(param,'C')||strcmp(param,'C_CI')
                                eval(['val' StrRange{k} '{i} = abs(val' StrRange{k} '{i});']);
                                if strcmp(param,'ai')||strcmp(param,'ai_CI')
                                    Ylabel = '\alpha_i';
                                end
                                if strcmp(param,'C')||strcmp(param,'C_CI')
                                    Ylabel = 'C(fJ/K)';
                                end
                            elseif strcmp(param,'taueff')||strcmp(param,'taueff_CI')
                                eval(['val' StrRange{k} '{i} = val' StrRange{k} '{i}*1e6;']);
                                Ylabel = '\tau_{eff}(\mus)';
                            elseif strcmp(param,'bi')||strcmp(param,'bi_CI')
                                Ylabel = '\beta_i';
                            else
                                Ylabel = param;
                            end
                            
                            eval(['plot(ax,rp' StrRange{k} '{i},val' StrRange{k} '{i},''LineStyle'',''-.'',''Marker'',''o'''...
                                ',''DisplayName'',[''T_{bath}: '' num2str(Tbath' StrRange{k} '(i)*1e3) '' mK - ' StrCond{k} ' Ibias'']);']);
                            
                            try
                                eval(['errorbar(ax,rp' StrRange{k} '{i},val' StrRange{k} '{i},val' StrRange{k} '_CI{i},''LineStyle'',''-.'',''Marker'',''o'''...
                                    ',''DisplayName'',[''T_{bath}: '' num2str(Tbath' StrRange{k} '(i)*1e3) '' mK - ' StrCond{k} ' Ibias''],''Visible'',''off'');']);
                            catch
                            end
                        end
                    end
                    xlabel(ax,'R_{TES}/Rn');
                    ylabel(ax,Ylabel);
                    set(ax,'FontSize',11,'FontWeight','bold');
                    set(ax,'ButtonDownFcn',{@GraphicErrors_NKGT})
                end
                
            else % param1 vs param2 at same Tbath
                param1 = deblank(param(1,:));
                param2 = deblank(param(2,:));
                
                
                
                if (isempty(strfind(param1,'_CI')))&&(isempty(strfind(param2,'_CI')))
                    try
                        [valP1_CI,valP2_CI,TbathsP1,TbathsP2] = obj.PP.GetParamVsParam([param1 '_CI'],[param2 '_CI']);
                        [valN1_CI,valN2_CI,TbathsN1,TbathsN2] = obj.PN.GetParamVsParam([param1 '_CI'],[param2 '_CI']);
                    catch
                    end
                end
                [valP1,valP2,TbathsP1,TbathsP2] = obj.PP.GetParamVsParam(param1,param2);
                [valN1,valN2,TbathsN1,TbathsN2] = obj.PN.GetParamVsParam(param1,param2);
                if nargin < 5
                    fig = figure('Visible','on');
                end
                if isempty(findobj('Type','Axes'))
                    figure(fig);
                    ax = axes;
                    hold(ax,'on');
                else
                    ax = findobj('Type','Axes');
                    if length(ax) > 1
                        ax = axes;
                        hold(ax,'on');
                    end
                end
                StrRange = {'P';'N'};
                StrCond = {'Positive';'Negative'};
                for k = 1:2
                    for i = 1:eval(['length(Tbaths' StrRange{k} '1)'])
                        if strcmp(param1,'ai')||strcmp(param1,'ai_CI')||strcmp(param1,'C')||strcmp(param1,'C_CI')
                            eval(['val' StrRange{k} '1{i} = abs(val' StrRange{k} '1{i});']);
                            if strcmp(param1,'ai')||strcmp(param1,'ai_CI')
                                Xlabel = '\alpha_i';
                            end
                            if strcmp(param1,'C')||strcmp(param1,'C_CI')
                                Xlabel = 'C(fJ/K)';
                            end
                        elseif strcmp(param1,'taueff')||strcmp(param1,'taueff_CI')
                            eval(['val' StrRange{k} '1{i} = val' StrRange{k} '1{i}*1e6;']);
                            Xlabel = '\tau_{eff}(\mus)';
                        elseif strcmp(param1,'bi')||strcmp(param1,'bi_CI')
                            Xlabel = '\beta_i';
                        else
                            Xlabel = param1;
                        end
                        
                        if strcmp(param2,'ai')||strcmp(param2,'ai_CI')||strcmp(param2,'C')||strcmp(param2,'C_CI')
                            eval(['val' StrRange{k} '2{i} = abs(val' StrRange{k} '2{i});']);
                            if strcmp(param2,'ai')||strcmp(param2,'ai_CI')
                                Ylabel = '\alpha_i';
                            end
                            if strcmp(param2,'C')||strcmp(param2,'C_CI')
                                Ylabel = 'C(fJ/K)';
                            end
                        elseif strcmp(param2,'taueff')||strcmp(param2,'taueff_CI')
                            eval(['val' StrRange{k} '2{i} = val' StrRange{k} '2{i}*1e6;']);
                            Ylabel = '\tau_{eff}(\mus)';
                        elseif strcmp(param2,'bi')||strcmp(param2,'bi_CI')
                            Ylabel = '\beta_i';
                        else
                            Ylabel = param2;
                        end
                        eval(['plot(ax,val' StrRange{k} '2{i},val' StrRange{k} '1{i},''LineStyle'',''none'',''Marker'',''o'''...
                            ',''DisplayName'',[''T_{bath}: '' num2str(Tbaths' StrRange{k} '1(i)*1e3) '' mK - ' StrCond{k} ' Ibias'']);']);
                        try
                            eval(['errorbar(ax,val' StrRange{k} '2{i},val' StrRange{k} '1{i},val' StrRange{k} '1_CI{i}/2,val' StrRange{k} '1_CI{i}/2,val' StrRange{k} '2_CI{i}/2,val' StrRange{k} '2_CI{i}/2,''LineStyle'',''none'',''Marker'',''o'''...
                                ',''DisplayName'',[''T_{bath}: '' num2str(Tbaths' StrRange{k} '1(i)*1e3) '' mK - ' StrCond{k} ' Ibias''],''Visible'',''off'');']);
                        catch
                        end
                    end
                end
                xlabel(ax,Ylabel);
                ylabel(ax,Xlabel);
                set(ax,'FontSize',11,'FontWeight','bold');
                set(ax,'ButtonDownFcn',{@GraphicErrors_NKGT})
            end
        end
        
        function TFNoiseViever(obj)
            % Function that invokes TF_Noise_Viewer
            %
            % This graphical interface allows browsing across Z(w) and
            % Noise data results.
            
            TF_Noise_Viewer(obj);
        end
        
        function Save(obj,FileName)
            % Function to save TES data analysis
            
            uisave('obj',FileName);
        end
        
    end
end

