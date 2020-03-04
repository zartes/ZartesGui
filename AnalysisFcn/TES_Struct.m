classdef TES_Struct
    % Class Struct for TES data
    %   This class contains all subclasses for TES analysis
    
    properties
        circuit;
        TFS;
        TFN;
        NoiseS;
        NoiseN;
        IVsetP;
        IVsetN;
        PvTModel;
        GsetP;
        GsetN;
        IC;
        FieldScan;
        ElectrThermalModel;
        TFOpt;
        NoiseOpt;
        PP;
        PN;
        TESParamP;
        TESParamN;
        TESThermalP;
        TESThermalN;
        TESDim;
        JohnsonExcess = [2e2 4.5e4];
        PhononExcess = [1e2 1e3];
        rtesLB = 0.05;
        rtesUB = 0.9;
        ptesThrs = 0.001;
        PvsV_Thrs = 5;  % Mirar mejor qué sentido tiene este valor
        PvsR_Thrs = 3;  % Mirar mejor qué sentido tiene este valor                
        
        Kb = 1.38e-23;
        Report;
    end
    
    properties (Access = private)
        version = 'ZarTES v2.2';
    end
    
    methods
        
        function obj = Constructor(obj)
            % Function to generate the class with default values
            
            obj.circuit = TES_Circuit;
            obj.circuit = obj.circuit.Constructor;
            obj.TFS = TES_TFS;
            obj.TFN = TES_TFS;
            obj.NoiseS = TES_BasalNoises;
            obj.NoiseN = TES_BasalNoises;
            obj.IVsetP = TES_IVCurveSet;
            obj.IVsetP = obj.IVsetP.Constructor;
            obj.IVsetN = TES_IVCurveSet;
            obj.IVsetN = obj.IVsetN.Constructor(1);
            obj.PvTModel = TES_PvTModel;
            obj.PvTModel = obj.PvTModel.Constructor;
            obj.GsetP = TES_Gset;
            obj.GsetN = TES_Gset;
            obj.IC = TES_IC;
            obj.IC = obj.IC.Constructor;
            obj.FieldScan = TES_FieldScan;
            obj.FieldScan = obj.FieldScan.Constructor;
            obj.ElectrThermalModel = TES_ElectrThermModel;
            obj.ElectrThermalModel = obj.ElectrThermalModel.Constructor;
            obj.TFOpt = TES_TF_Opt;
            obj.NoiseOpt = TES_Noise;
            obj.PP = TES_P;
            obj.PP = obj.PP.Constructor;
            obj.PN = TES_P;
            obj.PN = obj.PN.Constructor;
            obj.TESParamP = TES_Param;
            obj.TESParamP = obj.TESParamP.Constructor;
            obj.TESParamN = TES_Param;
            obj.TESParamN = obj.TESParamN.Constructor;
            obj.TESThermalP = TES_ThermalParam;
            obj.TESThermalP = obj.TESThermalP.Constructor;
            obj.TESThermalN = TES_ThermalParam;
            obj.TESThermalN = obj.TESThermalN.Constructor;
            obj.TESDim = TES_Dimensions;
            obj.TESDim = obj.TESDim.Constructor;
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
                waitfor(helpdlg('Before closing this message, please check the IV curves',obj.version));
                eval(['obj.IVset' StrRange{j} ' = get(figIV.hObject,''UserData'');']);                
            end
            ax = findobj(figIV.hObject,'Type','Axes');
            set(ax,'ButtonDownFcn',{@GraphicErrors})
            
            waitfor(msgbox('IV Curves Visually Checked!','ZarTES'));
        end        
        
        function obj = fitPvsTset(obj,perc,fig)
            % Function for fitting P-Tbath curves at Rn values.
            %
            % If perc range is empty, then it is computed automatically
            % according to the Ptes-rtes curves.
                        
            if isempty(fig)
                fig = figure('Name','fitP vs. Tset');
                
            end
            StrRange = {'P';'N'};
            StrTitle = {'Positive Ibias';'Negative Ibias'};
            for k = 1:2 % Positive and Negative Ibias ranges
                
                obj.PvTModel = obj.PvTModel.BuildPTbModel;
                
                if ~exist('ButtonName','var')
                    str = {'Ptes vs Vtes'; 'Ptes vs Rtes';'Minimum I-V curve transition'; 'Range %Rn'};
                    [s,OK] = listdlg('PromptString','Fitting based on?',...
                        'SelectionMode','single',...
                        'ListString',str);
                    if OK
                        ButtonName = str{s};
                    else
                        return;
                    end
%                     ButtonName = questdlg('Fitting based on?', ...
%                         'Choose method for extracting %Rn values', ...
%                         'Ptes vs Vtes', 'Ptes vs Rtes','Range %Rn','Ptes vs Vtes');
                    switch ButtonName
                        case 'Ptes vs Vtes'
                            opt.RnFixed = 0;
                            opt.RnVariable = 1;
                        case 'Ptes vs Rtes'
                            opt.RnFixed = 0;
                            opt.RnVariable = 1;
                            
                        case 'Minimum I-V curve transition'
                            opt.RnFixed = 0;
                            opt.RnVariable = 1;
                        case 'Range %Rn'
                            
                        otherwise
                            return;
                    
                    end
                end
                switch ButtonName
                    
                    case 'Range %Rn'
                        opt.RnVariable = 0;
                        opt.RnFixed = 1;
                        clear perc;
                        perc = [];
                        if isempty(perc)
                            j = 1;
                            for i = 1:size(eval(['obj.IVset' StrRange{k}]),2)
                                if eval(['obj.IVset' StrRange{k} '(i).good'])
                                    
                                    diffptes = abs(diff(eval(['obj.IVset' StrRange{k} '(i).ptes'])));
                                    x = eval(['obj.IVset' StrRange{k} '(i).rtes;']);
                                    indx = find(eval(['obj.IVset' StrRange{k} '(i).rtes']) > obj.rtesLB);
                                    x = x(indx);
                                    if isempty(indx)
                                        continue;
                                    end
                                    indx(indx > size(diffptes,1)) = [];
                                    diffptes = diffptes(indx);
                                    range = find(diffptes > nanmedian(diffptes) + obj.ptesThrs*max(diffptes));
                                    try
                                        minrange(j,1) = x(range(end));
                                        maxrange(j,1) = x(range(end-1));
                                        j = j+1;
                                    end
                                end
                            end
                            minrange = minrange(minrange < 0.5);
                            maxrange = maxrange(maxrange > 0.5);
                            minrange = ceil(max(minrange)*1e3)/1e3;
                            maxrange = ceil(min(maxrange)*1e3)/1e3;
                            warning off;
                            if isempty(minrange)
                                minrange = 0.2;
                            end
                            
                            prompt = {'Enter the %Rn range (Initial:Step:Final):'};
                            name = '%Rn range to fit P vs. Tbath data (suggested values)';
                            numlines = [1 70];
                            defaultanswer = {[num2str(minrange) ':0.01:' num2str(maxrange)]};
                            answer = inputdlg(prompt,name,numlines,defaultanswer);
                            if ~isempty(answer)
                                eval(['perc' StrRange{k} ' = eval(answer{1});']);
                                if ~isnumeric(eval(['perc' StrRange{k} ]))
                                    warndlg('Invalid %Rn values',handles.version);
                                    return;
                                end
                            else
                                warndlg('Invalid %Rn values',handles.version);
                                return;
                            end
                        else
                            eval(['perc' StrRange{k} ' = perc{k};']);
                        end
                        
                        
                end % switch
                          
                eval(['obj.Gset' StrRange{k} ' = [];']);
                eval(['obj.Gset' StrRange{k} ' = TES_Gset;']);
                eval(['obj.Gset' StrRange{k} ' = obj.Gset' StrRange{k} '.Constructor;']);
                if isempty(eval(['obj.IVset' StrRange{k} '.ibias']))
                    continue;
                end
                
                if ~exist('opt','var')
                    return;
                end
                %%
                if opt.RnVariable
                    figure(fig);
                    if k == 1
                        axInd = [1 3];
                    else
                        axInd = [2 4];
                    end
                    ax(axInd(1),1) = subplot(2,2,axInd(1),'Visible','off');
                    ax(axInd(2),2) = subplot(2,2,axInd(2),'Visible','off');
                    title(ax(axInd(1),1),StrTitle{k});
                    hold(ax(axInd(1),1),'on');
                    hold(ax(axInd(2),2),'on');      
                    grid(ax(axInd(1),1),'on');
                    grid(ax(axInd(2),2),'on');    
                    
                    IVTESset = eval(['obj.IVset' StrRange{k}]);
                    c = distinguishable_colors(length(IVTESset));
                    kj = 1;
                    clear SetIbias;
                    SetIbias{1} = [];
                    perc = [];
                    for i = 1:length(IVTESset)
                        if ~IVTESset(i).good
                            continue;
                        end
                        
                        dptes = diff(IVTESset(i).ptes*1e12);
                        dvtes = diff(IVTESset(i).vtes*1e6);                        
                        drtes = diff(IVTESset(i).rtes);
                        switch ButtonName
                            case 'Ptes vs Vtes'
                                indP = find(abs(dptes./dvtes) < obj.PvsV_Thrs, 1 );
                            case 'Ptes vs Rtes'
                                indP = find(abs(dptes./drtes) < obj.PvsR_Thrs, 1 );
                            case 'Minimum I-V curve transition'
                                [~,i3] = min(diff(IVTESset(i).vout)./diff(IVTESset(i).ibias));
                                [val, indP] = min(abs(IVTESset(i).vout(1:i3)));                                
                        end
                        
                        
                        if isempty(indP)
                            continue;
                        end
                        if IVTESset(i).rtes(indP) > 1 || IVTESset(i).rtes(indP) < 0
                            continue;
                        else
                            perc(i) = IVTESset(i).rtes(indP);
                        end
                        
                        
                        ind = find(IVTESset(i).rtes > obj.rtesLB & IVTESset(i).rtes < obj.rtesUB);%%%algunas IVs fallan.
                        if isempty(ind)
                            continue;
                        end
                        Paux(kj) = ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ptes(ind)),perc(i)); %#ok<AGROW>
                        Iaux(kj) = ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ites(ind)),perc(i));
                        Tbath(kj) = IVTESset(i).Tbath; %#ok<AGROW>
                        kj = kj+1;
                        SetIbias = [SetIbias; {IVTESset(i).file}];
                        fileName = IVTESset(i).file;
                        fileName(strfind(fileName,'_')) = '';
                        switch ButtonName
                            case 'Ptes vs Vtes'
                                plot(ax(axInd(1),1),IVTESset(i).vtes*1e6,IVTESset(i).ptes*1e12,'.-','Color',c(i,:),'Visible','off','DisplayName',fileName);
                                plot(ax(axInd(1),1),IVTESset(i).vtes(indP)*1e6,IVTESset(i).ptes(indP)*1e12,'Marker','o','MarkerEdgeColor','b','Visible','off','DisplayName',['%Rn: ' num2str(perc(i))]);
                            case 'Ptes vs Rtes'
                                plot(ax(axInd(1),1),IVTESset(i).rtes,IVTESset(i).ptes*1e12,'.-','Color',c(i,:),'Visible','off','DisplayName',fileName);
                                plot(ax(axInd(1),1),IVTESset(i).rtes(indP),IVTESset(i).ptes(indP)*1e12,'Marker','o','MarkerEdgeColor','b','Visible','off','DisplayName',['%Rn: ' num2str(perc(i))]);
                            case 'Minimum I-V curve transition'
                                plot(ax(axInd(1),1),IVTESset(i).ibias,IVTESset(i).vout,'.-','Color',c(i,:),'Visible','off','DisplayName',fileName);
                                plot(ax(axInd(1),1),IVTESset(i).ibias(indP),IVTESset(i).vout(indP),'Marker','o','MarkerEdgeColor','b','Visible','off','DisplayName',['%Rn: ' num2str(perc(i))]);
                        end
                        
                    end
                    
                    XDATA = Tbath;
                    if strcmp(obj.PvTModel.Models{obj.PvTModel.Selected_Models},'KnP0Ic0_direct')
                        XDATA = [Tbath;Iaux*1e6];
                    end
                    opts = optimset('Display','off');
                    
                    fitfun = @(x,y)obj.PvTModel.fitP(x,y);
                    [fit,~,aux2,~,~,~,auxJ] = lsqcurvefit(fitfun,obj.PvTModel.X0,XDATA,Paux*1e12,obj.PvTModel.LB,obj.PvTModel.UB,opts);
                    ci = nlparci(fit,aux2,'jacobian',auxJ); %%%confidence intervals.
                    
                    CI = diff(ci');
                    fit_CI = [fit; CI];
                    Gaux = obj.PvTModel.GetGfromFit(fit_CI');
                    ERP = sum(abs(abs(Paux*1e12-obj.PvTModel.fitP(fit,XDATA))./abs(Paux*1e12)))/length(Paux*1e12);
                    R2 = goodnessOfFit(obj.PvTModel.fitP(fit,XDATA)', Paux'*1e12,'NRMSE');
%                     R = corrcoef([obj.fitP(fit,XDATA,model)' Paux'*1e12]);
%                     R2 = R(1,2)^2;
                    eval(['obj.Gset' StrRange{k} '.rp = perc;']);
                    eval(['obj.Gset' StrRange{k} '.model = obj.PvTModel.Description;']);
                    eval(['obj.Gset' StrRange{k} '.n = Gaux.n;']);
                    eval(['obj.Gset' StrRange{k} '.n_CI = Gaux.n_CI;']);
                    eval(['obj.Gset' StrRange{k} '.K = Gaux.K*1e-12;']);
                    eval(['obj.Gset' StrRange{k} '.K_CI = Gaux.K_CI*1e-12;']);
                    eval(['obj.Gset' StrRange{k} '.T_fit = Gaux.T_fit;']);
                    eval(['obj.Gset' StrRange{k} '.T_fit_CI = Gaux.T_fit_CI;']);
                    eval(['obj.Gset' StrRange{k} '.G = Gaux.G*1e-12;']);
                    eval(['obj.Gset' StrRange{k} '.G_CI = Gaux.G_CI*1e-12;']);
                    eval(['obj.Gset' StrRange{k} '.G100 = Gaux.G100*1e-12;']);
                    eval(['obj.Gset' StrRange{k} '.ERP = ERP;']);
                    eval(['obj.Gset' StrRange{k} '.R2 = R2;']);
                    eval(['obj.Gset' StrRange{k} '.Tbath = Tbath;']);
                    eval(['obj.Gset' StrRange{k} '.Paux = Paux*1e12;']);
                    eval(['obj.Gset' StrRange{k} '.Paux_fit = obj.PvTModel.fitP(fit,XDATA);']);
                    
                    
                    
                    plot(ax(axInd(2),2),Tbath,obj.PvTModel.fitP(fit,XDATA),'LineStyle','-','Color',c(1,:),'LineWidth',2,'DisplayName',' ',...
                        'ButtonDownFcn',{@Identify_Origin_PT},'UserData',{k;1;i;obj},'Visible','off');
                    
                    plot(ax(axInd(2),2),Tbath,Paux*1e12,'Marker','o','MarkerFaceColor',c(1,:),'MarkerEdgeColor',c(1,:),'DisplayName',['Rn(%): ' num2str(mean(perc)) '+-' num2str(std(perc))],...
                        'ButtonDownFcn',{@Identify_Origin_PT},'UserData',SetIbias,'LineStyle','none','Visible','off')
                    xlabel(ax(axInd(2),2),'T_{bath}(K)','FontSize',12,'FontWeight','bold')
                    ylabel(ax(axInd(2),2),'P_{TES}(pW)','FontSize',12,'FontWeight','bold')
                    xlabel(ax(axInd(1),1),'V_{TES}(\muV)','FontWeight','bold');
                    ylabel(ax(axInd(1),1),'Ptes(pW)','FontWeight','bold');
                    set([ax(axInd(1),1) ax(axInd(2),2)],'FontSize',12,'LineWidth',2,'FontWeight','bold','Box','on','FontUnits','Normalized');
                    axis([ax(axInd(1),1) ax(axInd(2),2)],'tight');
                    eval(['obj.TESThermal' StrRange{k} '.n.Value = obj.Gset' StrRange{k} '.n;']);
                    eval(['obj.TESThermal' StrRange{k} '.K.Value = obj.Gset' StrRange{k} '.K;']);
                    
                    for i = 1:length(eval(['obj.IVset' StrRange{k}]))
                        eval(['obj.IVset' StrRange{k} '(i).ttes = (obj.IVset' StrRange{k} '(i).ptes./'...
                            '[obj.TESThermal' StrRange{k} '.K.Value]+obj.IVset' StrRange{k} '(i).Tbath.^([obj.TESThermal' StrRange{k} '.n.Value])).^(1./[obj.TESThermal' StrRange{k} '.n.Value]);'])
                    end
                    eval(['obj.TESParam' StrRange{k} ' = obj.TESParam' StrRange{k} '.Tc_EstimationFromRTs(obj.IVset' StrRange{k} ');']);
                end
                %%
                
                if opt.RnFixed
                    figure(fig);
                    ax = subplot(1,2,k,'Visible','off');
                    title(ax,StrTitle{k});
                    hold(ax,'on');
                    grid(ax,'on');
                    IVTESset = eval(['obj.IVset' StrRange{k}]);
                    c = distinguishable_colors(length(eval(['perc' StrRange{k}])));
                    wb = waitbar(0,'Please wait...');
                    for jj = 1:length(eval(['perc' StrRange{k}]))
                        Paux = [];
                        Iaux = [];
                        Tbath = [];
                        kj = 1;
                        clear SetIbias;
                        SetIbias{1} = [];
                        for i = 1:length(IVTESset)
                            if IVTESset(i).good
                                ind = find(IVTESset(i).rtes > obj.rtesLB & IVTESset(i).rtes < obj.rtesUB & IVTESset(i).ptes > 0);%%%algunas IVs fallan.
                                if isempty(ind)
                                    continue;
                                end
                                Paux(kj) = ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ptes(ind)),eval(['perc' StrRange{k} '(jj)'])); %#ok<AGROW>
                                Iaux(kj) = ppval(spline(IVTESset(i).rtes(ind),IVTESset(i).ites(ind)),eval(['perc' StrRange{k} '(jj)']));%#ok<AGROW> %%%
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
                        
                        eval(['obj.Gset' StrRange{k} '(jj).rp = perc' StrRange{k} '(jj);']);
                        eval(['obj.Gset' StrRange{k} '(jj).model = obj.PvTModel.Description;']);
                        
                        XDATA = Tbath;
                        if strcmp(obj.PvTModel.Models{obj.PvTModel.Selected_Models},'KnP0Ic0_direct')
                            XDATA = [Tbath;Iaux*1e6];
                        end
                        opts = optimset('Display','off');
                        fitfun = @(x,y)obj.PvTModel.fitP(x,y);
                        [fit,~,aux2,~,~,~,auxJ] = lsqcurvefit(fitfun,obj.PvTModel.X0,XDATA,Paux*1e12,obj.PvTModel.LB,obj.PvTModel.UB,opts);
                        ci = nlparci(fit,aux2,'jacobian',auxJ); %%%confidence intervals.
                        
                        CI = diff(ci');
                        fit_CI = [fit; CI];
                        Gaux(jj) = obj.PvTModel.GetGfromFit(fit_CI');%#ok<AGROW,
                        ERP = sum(abs(abs(Paux*1e12-obj.PvTModel.fitP(fit,XDATA))./abs(Paux*1e12)))/length(Paux*1e12);
                        R2 = goodnessOfFit(obj.PvTModel.fitP(fit,XDATA)', Paux'*1e12,'NRMSE');
                        
                        eval(['obj.Gset' StrRange{k} '(jj).n = Gaux(jj).n;']);
                        eval(['obj.Gset' StrRange{k} '(jj).n_CI = Gaux(jj).n_CI;']);
                        eval(['obj.Gset' StrRange{k} '(jj).K = Gaux(jj).K*1e-12;']);
                        eval(['obj.Gset' StrRange{k} '(jj).K_CI = Gaux(jj).K_CI*1e-12;']);
                        eval(['obj.Gset' StrRange{k} '(jj).T_fit = Gaux(jj).T_fit;']);
                        eval(['obj.Gset' StrRange{k} '(jj).T_fit_CI = Gaux(jj).T_fit_CI;']);
                        eval(['obj.Gset' StrRange{k} '(jj).G = Gaux(jj).G*1e-12;']);
                        eval(['obj.Gset' StrRange{k} '(jj).G_CI = Gaux(jj).G_CI*1e-12;']);
                        eval(['obj.Gset' StrRange{k} '(jj).G100 = Gaux(jj).G100*1e-12;']);
                        eval(['obj.Gset' StrRange{k} '(jj).ERP = ERP;']);
                        eval(['obj.Gset' StrRange{k} '(jj).R2 = R2;']);
                        eval(['obj.Gset' StrRange{k} '(jj).Tbath = Tbath;']);
                        eval(['obj.Gset' StrRange{k} '(jj).Paux = Paux*1e12;']);
                        eval(['obj.Gset' StrRange{k} '(jj).Paux_fit = obj.PvTModel.fitP(fit,XDATA);']);
                        %                             eval(['obj.Gset' StrRange{k} '(jj).Paux_fit = obj.fitP(fit,XDATA,obj.TESP.T_fit,model);']);
                        
                        plot(ax,Tbath,obj.PvTModel.fitP(fit,XDATA),'LineStyle','-','Color',c(jj,:),'LineWidth',1,'DisplayName',IVTESset(i).file,...
                            'ButtonDownFcn',{@Identify_Origin_PT},'UserData',{k;jj;i;obj},'Visible','off');
                        
                        if obj.PvTModel.Selected_Models == 1
                            
                            DefaultModel = TES_PvTModel;
                            DefaultModel.Selected_Models = 2;
                            DefaultModel = DefaultModel.BuildPTbModel;
                            XDATA = Tbath;
                            opts = optimset('Display','off');
                            fitfun = @(x,y)DefaultModel.fitP(x,y);
                            [fit,~,aux2,~,~,~,auxJ] = lsqcurvefit(fitfun,DefaultModel.X0,XDATA,Paux*1e12,DefaultModel.LB,DefaultModel.UB,opts);
                            ci = nlparci(fit,aux2,'jacobian',auxJ); %%%confidence intervals.
                            
                            CI = diff(ci');
                            fit_CI = [fit; CI];
                            Gaux2(jj) = DefaultModel.GetGfromFit(fit_CI');%#ok<AGROW,
                            eval(['obj.Gset' StrRange{k} '(jj).K = Gaux2(jj).K*1e-12;']);
                            eval(['obj.Gset' StrRange{k} '(jj).K_CI = Gaux2(jj).K_CI*1e-12;']);
                        end
                        
                        
                        plot(ax,Tbath,Paux*1e12,'Marker','o','MarkerFaceColor',c(jj,:),'MarkerEdgeColor',c(jj,:),'DisplayName',['Rn(%): ' num2str(eval(['perc' StrRange{k} '(jj)']))],...
                            'ButtonDownFcn',{@Identify_Origin_PT},'UserData',SetIbias,'LineStyle','none','Visible','off')
                        if ishandle(wb)
                            waitbar(jj/length(eval(['perc' StrRange{k} ])),wb,['Fit P vs. T in progress: ' StrTitle{k}]);
                        end
                    end
                    if ishandle(wb)
                        delete(wb);
                    end
                    xlabel(ax,'T_{bath}(K)','FontSize',12,'FontWeight','bold')
                    ylabel(ax,'P_{TES}(pW)','FontSize',12,'FontWeight','bold')
                    set(ax,'FontSize',12,'LineWidth',2,'FontWeight','bold','Box','on','FontUnits','Normalized');
                    eval(['obj.TESParam' StrRange{k} ' = obj.TESParam' StrRange{k} '.Tc_EstimationFromRTs(obj.IVset' StrRange{k} ');']);
                end
                
%                 eval(['obj.TES' StrRange{k} ' = obj.TES' StrRange{k} '.Tc_EstimationFromRTs(obj.IVset' StrRange{k} ');']);
                
            end
            
            
            haxes = findobj('Type','Axes');           
            hline = findobj('Type','Line');
            set([haxes;hline],'Visible','on');
        end        
        
        function obj = plotRTs(obj,fig)
            % Function to show graphics of R vs T (reconstructed) according
            % to the Operation Point.
            
            if isempty(fig)
                fig = figure;
                ax = axes;
                hold(ax,'on');
                grid(ax,'on');
            else
                ax = findobj(fig,'Type','Axes');
                if isempty(ax)
                    ax = axes;
                end
                hold(ax,'on');
                grid(ax,'on');
            end
                
            StrRange = {'P';'N'};
            StrCond = {'Positive';'Negative'};
            for k = 1:2
                indIV = eval(['obj.TESParam' StrRange{k} '.IV_Tc.Value']);
                for i = 1:length(eval(['obj.IVset' StrRange{k} '']))
                    if eval(['obj.IVset' StrRange{k} '(i).good'])
                        TbathStr = num2str(eval(['obj.IVset' StrRange{k} '(i).Tbath'])*1e3);
                        eval(['plot(ax,obj.IVset' StrRange{k} '(i).ttes,obj.IVset' StrRange{k} '(i).Rtes*1e3,''DisplayName'',''Tbath: ' TbathStr ' mK - ' StrCond{k} ''');'])
                        if i == indIV
                            ind = eval(['find(obj.IVset' StrRange{k} '(i).ttes == obj.TESParam' StrRange{k} '.Tc_RT.Value);']);
                            TcStr = num2str(eval(['obj.TESParam' StrRange{k} '.Tc_RT.Value*1e3;']));
                            eval(['plot(ax,obj.IVset' StrRange{k} '(indIV).ttes(ind),obj.IVset' StrRange{k} '(indIV).Rtes(ind)*1e3,'...
                                '''DisplayName'',''Tc: ' TcStr ' mK - ' StrCond{k} ''',''Marker'',''hexagram'',''MarkerEdgeColor'',''r'',''MarkerFaceColor'',''g'');'])
                        end
                    end
                end
            end
            xlabel(ax,'T_{TES} (K)','FontSize',12,'FontWeight','bold');
            ylabel(ax,'R_{TES} (mOhm)','FontSize',12,'FontWeight','bold');
            set(ax,'FontSize',12,'FontWeight','bold','LineWidth',2,'Box','on','FontUnits','Normalized');
        end
        
        function obj = plotNKGTset(obj,fig,opt)
            % Function to visualize n, K, G and T with respect to RTes/Rn
            %
            % This function allows determining the final thermal
            % parameters, opt is the %Rn to estimate thermal parameters,
            % when empty user can determine the value manually
            
            MS = 5; %#ok<NASGU>
            LS = 1; %#ok<NASGU>
            color{1} = [0 0.447 0.741];
            color{2} = [1 0 0];
            StrField = {'n';'T_fit';'K';'G'};
            StrMultiplier = {'1';'1';'1e9';'1e12';};
            StrLabel = {'n';'T_{fit}(K)';'K(nW/K^n)';'G(pW/K)'};
            StrRange = {'P';'N'};
            StrIbias = {'Positive';'Negative'};
            StrIbiasSign = {'+';'-'};
            Marker = {'o';'^'};
            LineStr = {'.-';':'};
            
            if size([obj.GsetP.n],2) == 1
                for k = 1:2
                    eval(['obj.TESThermal' StrRange{k} '.n.Value = obj.Gset' StrRange{k} '.n;']);
                    eval(['obj.TESThermal' StrRange{k} '.n_CI.Value = obj.Gset' StrRange{k} '.n_CI;']);
                    eval(['obj.TESThermal' StrRange{k} '.K.Value = obj.Gset' StrRange{k} '.K;']);
                    eval(['obj.TESThermal' StrRange{k} '.K_CI.Value = obj.Gset' StrRange{k} '.K_CI;']);
                    eval(['obj.TESThermal' StrRange{k} '.T_fit.Value = obj.Gset' StrRange{k} '.T_fit;']);
                    eval(['obj.TESThermal' StrRange{k} '.T_fit_CI.Value = obj.Gset' StrRange{k} '.T_fit_CI;']);
                    eval(['obj.TESThermal' StrRange{k} '.G.Value = obj.Gset' StrRange{k} '.G;']);
                    eval(['obj.TESThermal' StrRange{k} '.G_CI.Value = obj.Gset' StrRange{k} '.G_CI;']);
                    eval(['obj.TESThermal' StrRange{k} '.G100.Value = obj.Gset' StrRange{k} '.G100;']);
                    eval(['obj.TESThermal' StrRange{k} '.Rn.Value = NaN;']);
                    %                     eval(['obj.TES' StrRange{k} '.rp = mean(obj.Gset' StrRange{k} '.rp);']);
                end
                obj.TESThermalP.CheckValues('PosIbias');
                obj.TESThermalN.CheckValues('NegIbias');
                return;
            else
                
                for k = 1:2
                    if isempty(eval(['obj.Gset' StrRange{k} '.n']))
                        continue;
                    end
                    if nargin < 2
                        fig.hObject = figure;
                    end
                    Gset = eval(['obj.Gset' StrRange{k}]);
                    
                    
                    try
                        %                     eval(['TES_OP_y = find([Gset.T_fit] == obj.TES' StrRange{k} '.T_fit*1e-3,1,''last'');']);
                        eval(['TES_OP_y = find([Gset.T_fit] == obj.TESThermal' StrRange{k} '.T_fit.Value,1,''last'');']);
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
                        eval(['rp' StrRange{k} ' = [Gset.rp];']);
                        eval(['[~,ind] = sort(rp' StrRange{k} ');'])
                        val = eval(['[Gset.' StrField{j} ']*' StrMultiplier{j} ';']);
                        try
                            val_CI = eval(['[Gset.' StrField{j} '_CI]*' StrMultiplier{j} ';']);
                            er(j) = errorbar(h(j),eval(['rp' StrRange{k} '(ind)']),val(ind),val_CI(ind),'Color',color{k},...
                                'Visible','off','DisplayName',[StrIbias{k} ' Error Bar'],'Clipping','on');
                            set(get(get(er(j),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                        catch
                        end
                        eval(['plot(h(j),rp' StrRange{k} '(ind),val(ind),''' LineStr{k} ''','...
                            '''Color'',''none'',''MarkerEdgeColor'',color{k},''MarkerFaceColor'',color{k},''LineWidth'',LS,''MarkerSize'',MS,''Marker'','...
                            '''' Marker{k} ''',''DisplayName'',''' StrIbias{k} ''');']);
                        xlim(h(j),[0.15 0.9]);
                        xlabel(h(j),'%R_n','FontSize',12,'FontWeight','bold');
                        ylabel(h(j),StrLabel{j},'FontSize',12,'FontWeight','bold');
                        set(h(j),'LineWidth',2,'FontSize',12,'FontWeight','bold','box','on')
                        
                        try
                            eval(['plot(h(j),Gset(TES_OP_y).rp,Gset(TES_OP_y).' StrField{j} '*' StrMultiplier{j} ',''.-'','...
                                '''Color'',''none'',''MarkerFaceColor'',''g'',''MarkerEdgeColor'',''g'',''LineWidth'',LS,''Marker'',''hexagram'',''MarkerSize'',2*MS,''DisplayName'',''Operation Point ' StrIbias{k} ' Ibias'');']);
                        catch
                        end
                    end
                    fig.subplots = h;
                    try
                        data.er = er;
                        set(h,'ButtonDownFcn',{@GraphicErrors_NKGT},'UserData',data,'FontSize',12,'LineWidth',2,'FontWeight','bold')
                    catch
                    end
                    set(h,'Visible','on');
%                     if k == 2
%                         return;
%                     end
                end
            end
            if nargin < 2
                warndlg('TESDATA.fitPvsTset must be firstly applied.',handles.version)
                fig = [];
            end
            
            StrField = {'n';'T_fit';'K';'G'};
            TESmult =  {'1';'1';'1e9';'1e12';};
            for k = 1:2
                IndxOP = findobj('DisplayName',['Operation Point ' StrIbias{k} ' Ibias']);
                delete(IndxOP);
                if nargin < 3
                    
                    pause(0.2)
                    waitfor(helpdlg('After closing this message, select a point for TES characterization',obj.version));
                    figure(fig.hObject);
                    
                    % Seleccion mediante teclado de la Rn
                    prompt = {'Enter the %Rn (0 < %Rn < 1) for TES thermal parameters'};
                    name = ['TES Thermal Parameters for ' StrIbias{k} ' Ibias'];
                    numlines = 1;
                    defaultanswer = {'0.8'};
                    answer = inputdlg(prompt,name,numlines,defaultanswer);
                    if isempty(answer)
                        warndlg('No %Rn value selected',handles.version);
                        return;
                    else
                        X = str2double(answer{1});
                        if isnan(X)
                            warndlg('Invalid %Rn value',handles.version);
                            return;
                        end
                    end
                    
                    % Seleccion mediante raton sobre las gráficas
                    %                 [X,~] = ginput(1);
                    
                    if eval(['X > max(rp' StrRange{k} ')'])
                        eval(['X = max(rp' StrRange{k} ');'])
                    end
                    eval(['X' StrRange{k} '= X;']);
                else
                    XP = opt(1);
                    XN = opt(2);
                end
                eval(['ind_rp = find(rp' StrRange{k} ' >= X' StrRange{k} ',1);']) %#ok<NASGU>
                                             
               
                for i = 1:length(StrField)
                    eval(['val = [obj.Gset' StrRange{k} '.' StrField{i} ']*' TESmult{i} ';']);
                    eval(['obj.TESThermal' StrRange{k} '.' StrField{i} '.Value = val(ind_rp);']);
                    eval(['val_CI = [obj.Gset' StrRange{k} '.' StrField{i} '_CI]*' TESmult{i} ';']);
                    eval(['obj.TESThermal' StrRange{k} '.' StrField{i} '_CI.Value = val_CI(ind_rp);']);
                    
                    eval(['plot(h(i),obj.Gset' StrRange{k} '(ind_rp).rp,val(ind_rp),''.-'','...
                        '''Color'',''none'',''MarkerFaceColor'',''g'',''MarkerEdgeColor'',''g'','...
                        '''LineWidth'',LS,''Marker'',''hexagram'',''MarkerSize'',2*MS,''DisplayName'',[''Operation Point ' StrIbias{k} ' Ibias'']);']);
                    axis(h(i),'tight') 
                    set(h(i),'FontUnits','Normalized');
                end
%                 eval(['obj.TESThermal' StrRange{k} '.T_fit = obj.TES' StrRange{k} '.T_fit;']);
                eval(['obj.TESThermal' StrRange{k} '.K.Value = obj.TESThermal' StrRange{k} '.K.Value*1e-9;']);
                eval(['obj.TESThermal' StrRange{k} '.K_CI.Value = obj.TESThermal' StrRange{k} '.K_CI.Value*1e-9;']);
                eval(['obj.TESThermal' StrRange{k} '.G.Value = obj.TESThermal' StrRange{k} '.G.Value*1e-12;']);
                eval(['obj.TESThermal' StrRange{k} '.G_CI.Value = obj.TESThermal' StrRange{k} '.G_CI.Value*1e-12;']);                
                eval(['obj.TESThermal' StrRange{k} '.G100.Value = obj.TESThermal' StrRange{k} '.G_calc(0.1);']);
                eval(['obj.TESThermal' StrRange{k} '.Rn.Value = X' StrRange{k} ';']);
                
                
                
%                     eval(['obj.TESThermal' StrRange{k} '.K.Value = obj.Gset' StrRange{k} '.K;']);
%                     eval(['obj.TESThermal' StrRange{k} '.K_CI.Value = obj.Gset' StrRange{k} '.K_CI;']);
%                     eval(['obj.TESThermal' StrRange{k} '.T_fit.Value = obj.Gset' StrRange{k} '.T_fit;']);
%                     eval(['obj.TESThermal' StrRange{k} '.T_fit_CI.Value = obj.Gset' StrRange{k} '.T_fit_CI;']);
%                     eval(['obj.TESThermal' StrRange{k} '.G.Value = obj.Gset' StrRange{k} '.G;']);
%                     eval(['obj.TESThermal' StrRange{k} '.G_CI.Value = obj.Gset' StrRange{k} '.G_CI;']);
%                     eval(['obj.TESThermal' StrRange{k} '.G100.Value = obj.Gset' StrRange{k} '.G100;']);
                
                if nargin < 3
                    uiwait(msgbox({['n: ' num2str(eval(['obj.TESThermal' StrRange{k} '.n.Value']))]; ['K: ' num2str(eval(['obj.TESThermal' StrRange{k} '.K.Value*1e9'])) ' nW/K^n'];... 
                        ['T_{fit}: ' num2str(eval(['obj.TESThermal' StrRange{k} '.T_fit.Value*1e3'])) ' mK'];['G: ' num2str(eval(['obj.TESThermal' StrRange{k} '.G.Value*1e12'])) ' pW/K']},'TES Operating Point','modal'));
                end
%                 eval(['obj.TES' StrRange{k} '.T_fit = obj.TES' StrRange{k} '.T_fit;']);
%                 eval(['obj.TES' StrRange{k} '.T_fit_CI = obj.TES' StrRange{k} '.T_fit_CI;']);
%                 eval(['obj.TESThermal' StrRange{k} '.G100 = obj.TESThermal' StrRange{k} '.G_calc(0.1);']);
%                 eval(['obj.TES' StrRange{k} '.rp = obj.Gset' StrRange{k} '(ind_rp).rp;']);
                
                for i = 1:length(eval(['obj.IVset' StrRange{k}]))
                    eval(['obj.IVset' StrRange{k} '(i).ttes = (obj.IVset' StrRange{k} '(i).ptes./[obj.TESThermal' StrRange{k} '.K.Value]'...
                        '+obj.IVset' StrRange{k} '(i).Tbath.^([obj.TESThermal' StrRange{k} '.n.Value])).^(1./[obj.TESThermal' StrRange{k} '.n.Value]);'])
                end
                eval(['obj.TESParam' StrRange{k} ' = obj.TESParam' StrRange{k} '.Tc_EstimationFromRTs(obj.IVset' StrRange{k} ');']);                
            end
            
        end
                        
        function obj = FitZset(obj,fig,opt)
            % Function to fit Z(w) at different Tbaths according to the
            % selected electro-thermal model.
            %
            % Filtered data is generated when ai or C are found negatives,
            % and when ERP value (Error Relative Parameter) is greater than 0.8
            if nargin < 2             
%                 TFBaseName = {'\TF*';'\PXI_TF*'};
%                 NoiseBaseName = {'\HP_noise*';'\PXI_noise*'};
                ButtonName = questdlg('Select Files Acquisition device', ...
                    obj.version, ...
                    'PXI', 'HP', 'Previously Selected','HP');
                switch ButtonName
                    case 'PXI'
                        obj.ElectrThermalModel.Selected_TF_BaseName = 2;
                        obj.ElectrThermalModel.Selected_NoiseBaseName = 2;
                                                
                        if (isempty(strfind(obj.TFS.file,'PXI_TF_')))&&(isempty(strfind(obj.TFS.file,'PXI_TFS')))
                            [Path, Name] = fileparts(obj.TFS.file);
                            warndlg('TFS must be a file named PXI_TF_* (PXI card)',obj.version);
                            obj.TFS = obj.TFS.importTF([Path filesep]);
                        end
                    case 'HP'
                        obj.ElectrThermalModel.Selected_TF_BaseName = 1;
                        obj.ElectrThermalModel.Selected_NoiseBaseName = 1;
                        if (isempty(strfind(obj.TFS.file,'\TF_')))&&(isempty(strfind(obj.TFS.file,'\TFS')))
                            [Path, Name] = fileparts(obj.TFS.file);
                            warndlg('TFS must be a file named TF_* (HP)',obj.version);
                            obj.TFS = obj.TFS.importTF([Path filesep]);
                        end
                    case 'Previously Selected'
                        
                    otherwise
                        disp('PXI acquisition files were selected by default.')
                        obj.ElectrThermalModel.Selected_TF_BaseName = 2;
                        obj.ElectrThermalModel.Selected_NoiseBaseName = 2;
                end
                
                prompt = {'Mimimum frequency value:','Maximum frequency value:'};
                dlg_title = 'Frequency limitation for Z(w)-Noise analysis';
                num_lines = [1 70];
                defaultans = {num2str(obj.ElectrThermalModel.Zw_LowFreq),num2str(obj.ElectrThermalModel.Zw_HighFreq)};
                answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                
                if ~isempty(answer)
                    minFreq = eval(answer{1});
                    maxFreq = eval(answer{2});
                    if ~isnumeric(minFreq)||~isnumeric(maxFreq)
                        warndlg('Cancelled by user',obj.version);
                        return;
                    end
                else
                    warndlg('Cancelled by user',obj.version);
                    return;
                end
                FreqRange = [minFreq maxFreq];
                
                ButtonName = questdlg('Do you want to show the data and fits?', ...
                    obj.version, ...
                    'Yes', 'No', 'Yes');
                switch ButtonName
                    case 'Yes'
                        obj.ElectrThermalModel.bool_Show = 1;
                    otherwise
                        obj.ElectrThermalModel.bool_Show = 0;
                end
            else
                % By default HP files are available
%                                
                % By default FreqRange [0 100000]
                FreqRange = opt.FreqRange; 
                
                % By default intermediate results are not shown
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
                    if ~exist(IVsetPath,'dir')
                        IVsetPath = [IVsetPath(1:ind(end-1)) 'Negative_Bias' filesep];
                    end
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
                        dirIndx = strfind(obj.PP(1).fileNoise{1},filesep);
                        obj.PP(1).fileNoise{1}(1:dirIndx(end-1))
                        DataPath = uigetdir(obj.PP(1).fileNoise{1}(1:dirIndx(end-1)), 'Pick a Z(w)-Ruido path containing Temperature named folders (Negative Bias)');
                    end
                    if DataPath ~= 0
                        DataPath = [DataPath filesep];
                    else
                        errordlg('Invalid Data path name!',handles.version,'modal');
                        return;
                    end
                    
                    str = dir([DataPath '*mK']);
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
                        errordlg('Invalid Data path name!',handles.version,'modal');
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
                
                
                iOK = 0;
                for i = 1:length(dirs)
                    
                    iOK = iOK+1;
                    eval(['obj.P' StrRange{k1} '(iOK) = TES_P;']);
                    eval(['obj.P' StrRange{k1} '(iOK) = obj.P' StrRange{k1} '(iOK).Constructor(obj.ElectrThermalModel);']);
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
                            H.figure.Name = 'ZarTES v2.0';
                        end
                        thefile = strcat(dirs{i},'\',filesZ{j1});
                        try
                            [param, ztes, fZ, fS, ERP, R2, CI, aux1, p0] = obj.ElectrThermalModel.FitZ(obj,thefile,FreqRange);
                        catch
                            continue;
                        end
                        eval(['obj.P' StrRange{k1} '(iOK).Tbath = Tbath*1e-3;;']);
                        if param.rp > obj.ElectrThermalModel.Zw_rpUB || param.rp < obj.ElectrThermalModel.Zw_rpLB
                            continue;
                        end
                        
                        paramList = fieldnames(param);
                        for pm = 1:length(paramList)
                            eval(['obj.P' StrRange{k1} '(iOK).p(jj).' paramList{pm} ' = param.' paramList{pm} ';']);
                        end
                        eval(['obj.P' StrRange{k1} '(iOK).CI{jj} = CI;']);
                        eval(['obj.P' StrRange{k1} '(iOK).residuo(jj) = aux1;']);
                        eval(['obj.P' StrRange{k1} '(iOK).fileZ(jj) = {[dirs{i} filesep filesZ{j1}]};']);
                        eval(['obj.P' StrRange{k1} '(iOK).ElecThermModel(jj) = obj.ElectrThermalModel.Zw_Models(obj.ElectrThermalModel.Selected_Zw_Models);']);
                        eval(['obj.P' StrRange{k1} '(iOK).ztes{jj} = ztes;']);
                        eval(['obj.P' StrRange{k1} '(iOK).fZ{jj} = fZ;']);
                        eval(['obj.P' StrRange{k1} '(iOK).fS{jj} = fS;']);
                        eval(['obj.P' StrRange{k1} '(iOK).ERP{jj} = ERP;']);
                        eval(['obj.P' StrRange{k1} '(iOK).R2{jj} = R2;']);
                        
                        % Datos filtrados por valores negativos de C o
                        % alpha
                        if param.C < 0 || param.ai < 0 || R2 < obj.ElectrThermalModel.Zw_R2Thrs
                            eval(['obj.P' StrRange{k1} '(iOK).Filtered{jj} = 1;']);
                        else
                            eval(['obj.P' StrRange{k1} '(iOK).Filtered{jj} = 0;']);
                        end
                        
                        %%%%%%%%%%%%%%%%%%%%%%Pintamos Gráficas
                        
                        if obj.ElectrThermalModel.bool_Show
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
                            h(h_i) = plot(ax,1e3*ztes(ind),'.','Color',[0 0.447 0.741],...
                                'markerfacecolor',[0 0.447 0.741],'MarkerSize',15,'ButtonDownFcn',{@ChangeGoodOptP},'Tag',[dirs{i} filesep filesZ{jj}]);
                            %%% Paso marker de 'o' a '.'
                            set(ax,'LineWidth',2,'FontSize',12,'FontWeight','bold','Box','on','FontUnits','Normalized');
                            xlabel(ax,'Re(mZ)','FontSize',12,'FontWeight','bold');
                            ylabel(ax,'Im(mZ)','FontSize',12,'FontWeight','bold');%title('Ztes with fits (red)');
                            ImZmin(jj) = min(imag(1e3*ztes));
                            ylim(ax,[min(-15,min(ImZmin)-1) 1])
                            g(h_i) = plot(ax,1e3*fZ(:,1),1e3*fZ(:,2),'r','LineWidth',2,...
                                'ButtonDownFcn',{@ChangeGoodOptP},'Tag',[dirs{i} filesep filesZ{jj} ':fit']);
                            hold(ax,'on');
                            grid(ax,'on');
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
                            [RES, SimRes, M, Mph, fNoise, SigNoise] = obj.ElectrThermalModel.fitNoise(obj,FileName, param);
                            
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
                if obj.ElectrThermalModel.bool_Show
                    try
                        dat.fig = fig;
                        set(fig,'UserData',dat);
                        pause(0.2)
                        waitfor(helpdlg('After closing this message, check the validity of the curves and fittings',handles.version));
                        Data = get(fig(1),'UserData'); %#ok<NASGU>
                        eval(['obj.P' StrRange{k1} ' = Data.P;']);
                    catch
                    end
                end
                % Capar los datos de forma que no puedan existir valores porl
                % encima de 1 y por debajo de 0
                % Además tendríamos que hacer un sort para que se pinten en
                % orden ascendente
                
                try
                    eval(['a = cell2mat(obj.P' StrRange{k1} '(iOK).CI'')'''';']);
                    eval(['[rp,rpjj] =sort([obj.P' StrRange{k1} '(iOK).p.rp]);']);
                catch
                    rp = [];
                end
                if ~isempty(rp)
                    StrModelPar = obj.ElectrThermalModel.StrModelPar;
                    figParam(k1) = figure; %#ok<AGROW>
                    as = nan(1,length(StrModelPar));
                    for i = 1:length(StrModelPar)
                        as(i) = subplot(1,length(StrModelPar),i);
                        if ~strcmp(StrModelPar{i},'taueff')
                            eval(['errorbar(as(i),rp,[obj.P' StrRange{k1} '(iOK).p(rpjj).' StrModelPar{i} '],'...
                                'a(rpjj,i),''LineStyle'',''-.'',''Marker'',''.'',''MarkerEdgeColor'',[1 0 0]);'])
                        else
                            eval(['errorbar(as(i),rp,[obj.P' StrRange{k1} '(iOK).p(rpjj).' StrModelPar{i} ']*1e6,'...
                                'a(rpjj,i)*1e6,''LineStyle'',''-.'',''Marker'',''.'',''MarkerEdgeColor'',[1 0 0]);'])
                        end
                        xlabel(as(i),'%R_n','FontSize',12,'FontWeight','bold');
                        ylabel(as(i),StrModelPar{i},'FontSize',12,'FontWeight','bold');
                        grid(as(i),'on');
                        hold(as(i),'on');
                    end
                    set(as,'LineWidth',2,'FontSize',12,'FontWeight','bold','Box','on','FontUnits','Normalized');
                    figParam(k1).Name = ['Thermal Model Parameters Evolution: ' StrRangeExt{k1}]; %#ok<AGROW>
                end
                
            end
        end
                        
        function Ites = V2I(obj,vout)
            % Function to convert Vout values to Ites            
            Ites = vout*obj.circuit.invMin.Value/(obj.circuit.invMf.Value*obj.circuit.Rf.Value);
        end
        
        function OP = setTESOPfromIb(obj,Ib,IV,p,CondStr)
            % Function to set the TES operating point from Ibias and IV curves and fitted
            % parameters p.
                                                
            [iaux, ii] = unique(IV.ibias,'stable');
            
            vaux = IV.vout(ii)+1000;
            raux = IV.rtes(ii);
            itaux = IV.ites(ii);
            vtaux = IV.vtes(ii);
            paux = IV.ptes(ii);
            if (isfield(IV, 'ttes'))
                taux = IV.ttes(ii);
            end
            [m, i3]=min(diff(vaux)./diff(iaux));
            %[m,i3]=min(diff(IV.vout)./diff(IV.ibias));%%%Calculamos el índice del salto de estado N->S.
            
            OP.vout = ppval(spline(iaux(1:i3),vaux(1:i3)),Ib)-1000;
            OP.ibias = Ib;
            OP.Tbath = IV.Tbath;            
            
            Rpar = eval(['obj.TESParam' CondStr '.Rpar.Value;']);
            Rn = eval(['obj.TESParam' CondStr '.Rn.Value;']);
            F = obj.circuit.invMin.Value/(obj.circuit.invMf.Value*obj.circuit.Rf.Value);%36.51e-6;
            ites = OP.vout*F;
            Vs = (OP.ibias-ites)*obj.circuit.Rsh.Value;%(ibias*1e-6-ites)*Rsh;if Ib in uA.
            vtes = Vs-ites*Rpar;
            OP.P0 = vtes.*ites;
            OP.R0 = vtes./ites;
            OP.r0 = OP.R0/Rn;
            OP.I0 = ites;
            OP.V0 = vtes;
            
            
            switch obj.ElectrThermalModel.Zw_Models{obj.ElectrThermalModel.Selected_Zw_Models}
                case obj.ElectrThermalModel.Zw_Models{1}
                    param = fieldnames(p);
                    if length(p) > 1                        
                        for i = 1:length(param)
                            if ~isempty(strfind(param{i},'_CI'))||~strcmp(param{i},'R0')
                                try  % añadiendo el P0 da error
                                eval(['OP.' param{i} ' = ppval(spline([p.rp],real([p.' param{i} '])),OP.r0);']);
                                catch
                                end
                            end
                        end
                    else
                        for i = 1:length(param)
                            if ~isempty(strfind(param{i},'_CI'))||~strcmp(param{i},'R0')
                                eval(['OP.' param{i} ' = p.' param{i} ';']);
                            end
                        end
                    end
                    OP.G0 = OP.C/OP.tau0;                                        
                    
                case obj.ElectrThermalModel.Zw_Models{2} % Revisar
                    param = fieldnames(p);
                    if length(p) > 1
                        for i = 1:length(param)
                            if (~isempty(strfind(param{i},'_CI')))||~strcmp(param{i},'R0')
                                try
                                    eval(['OP.' param{i} ' = ppval(spline([p.rp],real([p.' param{i} '])),OP.r0);']);
                                catch me
                                    disp(me.message);
                                end
                            end
                        end
                    else
                        for i = 1:length(param)
                            if ~isempty(strfind(param{i},'_CI'))||~strcmp(param{i},'R0')
                                eval(['OP.' param{i} ' = p.' param{i} ';']);
                            end
                        end
                    end
                    OP.G0 = OP.C/OP.tau0;
                    
                case obj.ElectrThermalModel.Zw_Models{3} % Revisar
                    param = fieldnames(p);
                    if length(p) > 1
                        for i = 1:length(param)
                            if (~isempty(strfind(param{i},'_CI')))||~strcmp(param{i},'R0')
                                try
                                    eval(['OP.' param{i} ' = ppval(spline([p.rp],real([p.' param{i} '])),OP.r0);']);
                                catch me
                                    disp(me.message);
                                end
                            end
                        end
                    else
                        for i = 1:length(param)
                            if ~isempty(strfind(param{i},'_CI'))||~strcmp(param{i},'R0')
                                eval(['OP.' param{i} ' = p.' param{i} ';']);
                            end
                        end
                    end
                    OP.G0 = OP.C/OP.tau0; 
                    
                case obj.ElectrThermalModel.Zw_Models{4} % Revisar
                    param = fieldnames(p);
                    if length(p) > 1
                        for i = 1:length(param)
                            if (~isempty(strfind(param{i},'_CI')))||~strcmp(param{i},'R0')
                                try
                                    eval(['OP.' param{i} ' = ppval(spline([p.rp],real([p.' param{i} '])),OP.r0);']);
                                catch me
                                    disp(me.message);
                                end
                            end
                        end
                    else
                        for i = 1:length(param)
                            if ~isempty(strfind(param{i},'_CI'))||~strcmp(param{i},'R0')
                                eval(['OP.' param{i} ' = p.' param{i} ';']);
                            end
                        end
                    end
                    OP.G0 = OP.C/OP.tau0;
                    
                otherwise % Poner opción de modelo no valido
%                     OP.ai = p.ai;
%                     OP.bi = p.bi;
%                     OP.C = p.C;
%                     OP.L0 = p.L0;
%                     OP.tau0 = p.tau0;
%                     OP.Z0 = p.Z0;
%                     OP.Zinf = p.Zinf;
%                     OP.G0 = OP.C./OP.tau0;
            end
        end
        
        function L = fitLcircuit(obj)
            % Function to compute circuit value L from positive bias
            % parameters
            opts = optimset('Display','off');
            L = lsqcurvefit(@(x,y)fitLfcn(x,y,obj),100e-9,obj.TFS.f,imag(obj.TFS.tf./obj.TFN.tf),[],[],opts);                        
        end
        
        function plotABCT(obj,fig,errorOpt)
            % Function to visualize the model parameters, alpha, beta, C
            % and Tbath.
            if nargin < 3
                errorOpt = 'off';
            end
            warning off;
            colors{1} = [0 0.4470 0.7410];
            colors{2} = [1 0.5 0.05];
            
            MS = 10;
            LW1 = 1;
            
            if ~isempty(obj.TESDim.sides.Value)

                gammas = [obj.TESDim.gammaMo.Value obj.TESDim.gammaAu.Value];
                rhoAs = [obj.TESDim.rhoMo.Value obj.TESDim.rhoAu.Value];                
                sides = obj.TESDim.sides.Value;
                hMo = obj.TESDim.hMo.Value;
                hAu = obj.TESDim.hAu.Value;
                
                rpaux = 0.1:0.01:0.9;
            end
            
            YLabels = {'C(fJ/K)';'\tau_{eff}(\mus)';'\alpha_i';'\beta_i'};
            DataStr = {'rp(IndxGood),[P(i).p(jj(IndxGood)).C]*1e15';...
                'rp(IndxGood),[P(i).p(jj(IndxGood)).taueff]*1e6';...
                'rp(IndxGood),[P(i).p(jj(IndxGood)).ai]';...
                'rp(IndxGood),[P(i).p(jj(IndxGood)).bi]'};
            DataStr_fixed = {'rp(IndxGood),[P(i).p(jj(IndxGood)).C_fixed]*1e15';...
                '[]';...
                'rp(IndxGood),[P(i).p(jj(IndxGood)).ai_fixed]';...
                '[]'};
            
            DataStr_CI = {'[P(i).p(jj(IndxGood)).C_CI]*1e15';'[P(i).p(jj(IndxGood)).taueff_CI]*1e6';...
                '[P(i).p(jj(IndxGood)).ai_CI]';'[P(i).p(jj(IndxGood)).bi_CI]'};
            
            DataStrBad = {'rp(IndxBad),[P(i).p(jj(IndxBad)).C]*1e15';'rp(IndxBad),[P(i).p(jj(IndxBad)).taueff]*1e6';...
                'rp(IndxBad),[P(i).p(jj(IndxBad)).ai]';'rp(IndxBad),[P(i).p(jj(IndxBad)).bi]'};
            DataStrBad_CI = {'[P(i).p(jj(IndxBad)).C_CI]*1e15';'[P(i).p(jj(IndxBad)).taueff_CI]*1e6';...
                '[P(i).p(jj(IndxBad)).ai_CI]';'[P(i).p(jj(IndxBad)).bi_CI]'};
            PlotStr = {'plot';'semilogy';'plot';'semilogy'};
            
            StrRange = {'P';'N'};
            ind = 1;
            
            colors = distinguishable_colors((length(obj.PP)+length(obj.PN)));
            ind_color = 1;
            for k = 1:2
                if isempty(all(eval(['obj.P' StrRange{k} '.Tbath'])))
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
                            eval(['er(ind) = errorbar(h(' num2str(j) '),'...
                                DataStr{j} ',' DataStr_CI{j} ',''Color'',[colors(ind_color,:)],''Visible'',''' errorOpt ''',''DisplayName'','''...
                                NameStr ' Error Bar'',''Clipping'',''on'');']);
                            set(get(get(er(ind),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                        catch
                            er = [];
                        end
                        try
                            eval(['h_ax(' num2str(i) ',' num2str(j) ') = ' PlotStr{j} '(h(' num2str(j) '),' DataStr{j} ...
                                ',''' MarkerStr{i} ''',''Color'',[colors(ind_color,:)],''LineWidth'',LW1,''MarkerSize'',MS,''DisplayName'',''' NameStr ''''...
                                ',''ButtonDownFcn'',{@Identify_Origin},''UserData'',[{P;i;k;obj.circuit}]);']);
                            eval(['set(h(' num2str(j) '),''FontSize'',12,''FontWeight'',''bold'',''Box'',''on'');']);
                            eval(['axis(h(' num2str(j) '),''tight'');']);
                        catch
                            eval('h_ax = [];');
                        end
                        
                        try
                            eval(['erbad(ind) = errorbar(h(' num2str(j) '),' DataStrBad{j} ',' DataStrBad_CI{j} ',''Visible'',''off'',''Color'',[1 1 1]*160/255,'...
                                '''linestyle'',''none'',''DisplayName'',''Filtered Error Bar'',''Clipping'',''on'');']);
                            set(get(get(erbad(ind),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                            eval(['h_bad(ind) = ' PlotStr{j} '(h(' num2str(j) '),' DataStrBad{j} ...
                                ',''' MarkerStr{i} ''',''Color'',[1 1 1]*160/255,''MarkerSize'',MS,''DisplayName'',''Filtered'''...
                                ',''ButtonDownFcn'',{@Identify_Origin},''UserData'',[{P;i;k;obj.circuit}],''Visible'',''off'',''linestyle'',''none'');']);                                                       
                            set(get(get(h_bad(ind),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                        catch
                            erbad = [];
                            h_bad = [];
                        end                        
                        
                        eval(['xlabel(h(' num2str(j) '),''%R_n'',''FontSize'',12,''FontWeight'',''bold'');']);
                        eval(['ylabel(h(' num2str(j) '),''' YLabels{j} ''',''FontSize'',12,''FontWeight'',''bold'');']);
                        ind = ind+1;
                    end
                    ind_color = ind_color+1;
                end
                
                if ~isfield(fig,'subplots')
                    teob = plot(h(4),0.1:0.01:0.9,1./(0.1:0.01:0.9)-1,'-.r','LineWidth',2,'DisplayName','Beta^{teo}');
                    set(get(get(teob,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                    set(h([2 4]),'YScale','log');
                    if ~isempty(obj.TESDim.sides.Value)
                        CN = sum((gammas.*rhoAs).*([hMo hAu].*sides(1)*sides(2)).*eval(['obj.TESThermal' StrRange{k} '.T_fit.Value'])); %%%calculo de cada contribucion por separado.                        
                        teo(1) = plot(h(1),rpaux,CN*1e15*ones(1,length(rpaux)),'-.r','LineWidth',1,'DisplayName','{C_{LB}}^{teo}');
                        set(get(get(teo(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                        teo(2) = plot(h(1),rpaux,2.43*CN*1e15*ones(1,length(rpaux)),'-.r','LineWidth',1,'DisplayName','{C_{UB}}^{teo}');
                        set(get(get(teo(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
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
                set(h,'ButtonDownFcn',{@GraphicErrors},'UserData',data,...
                    'FontSize',12,'LineWidth',2,'FontWeight','bold','Box','on','FontUnits','Normalized');
                set(h,'Visible','on')
            catch
            end
            
            
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
                    Tbath = eval(['[obj.P' StrCond{iP} '.Tbath]']);
                else
                    for i = 1:length(Tbath)
                        eval(['ind_TbathN(i) = find([obj.P' StrCond{iP} '.Tbath]'' == Tbath(i));']);
                    end                                                            
                end
                
                for ind_Tbath = ind_TbathN
                    try
                        [~,Tind] = min(abs(eval(['[obj.IVset' StrCond{iP} '.Tbath]'])-Tbath(ind_Tbath)));
                    catch
                        [~,Tind] = min(abs(eval(['[obj.IVset' StrCond{iP} '.Tbath]'])-Tbath));
                    end
                    IV = eval(['obj.IVset' StrCond{iP} '(Tind)']);
                    
                    if ~isempty(Rn)
                        %                     Rn = sort(0.20:0.10:0.8,'descend');  % Example of using
                        eval(['Rp = [obj.P' StrCond{iP} '(ind_Tbath).p.rp];']);
                        
                        for i = 1:length(Rn)
                            [~,ind(i)] = min(abs(Rp-Rn(i)));
                        end
                        ind = unique(ind,'stable');
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
                        fig(IndFig) = figure('Name',[StrCond_Label{iP} ' ' num2str(eval(['[obj.P' StrCond{iP} '(ind_Tbath).Tbath]'])*1e3) ' mK']);
                    end
%                     if nargin < 4
%                         
%                         fig(IndFig) = figure('Name',StrCond_Label{iP});
%                     end
                    [ncols,~] = SmartSplit(N);
                    hs = nan(N,1);
                    j = 0;
                    for i = 1:N
                        hs(i) = subplot(ceil(N/ncols),ncols,i);
                        hold(hs(i),'on');
                        grid(hs(i),'on');
                        xlabel(hs(i),'\nu (Hz)');
                        if ~mod(j,ncols)
                            switch obj.ElectrThermalModel.Selected_tipo
                                case 1 % current
                                    ylabel(hs(i),'pA/Hz^{0.5}');
                                case 2 % nep
                                    ylabel(hs(i),'aW/Hz^{0.5}');
                            end
                            j = 0;
                        end
                        j = j+1;
                    end
                    set(hs,'LineWidth',2,'FontSize',12,'FontWeight','bold','Box','on','FontUnits','Normalized',...
                        'XMinorGrid','off','YMinorGrid','off','GridLineStyle','-',...
                        'xtick',[10 100 1000 1e4 1e5],'xticklabel',{'10' '10^2' '10^3' '10^4' '10^5'},...
                        'XScale','log','YScale','log');
                                                            
                    for i = 1:N
                        eval(['FileName = files' StrCond{iP} '{i};']);
                        FileName = FileName(find(FileName == filesep,1,'last')+1:end);
                        if ~isempty(strfind(upper(FileName),'PXI_noise_'))
                            Ib = sscanf(FileName,'PXI_noise_%fuA.txt')*1e-6;
                        else
                            Ib = sscanf(FileName,'HP_noise_%fuA.txt')*1e-6;
                        end
%                         Ib = sscanf(FileName,strcat(NoiseBaseName(2:end-1),'_%fuA.txt'))*1e-6; %%%HP_noise para ZTES18.!!!
                        eval(['OP = obj.setTESOPfromIb(Ib,IV,obj.P' StrCond{iP} '(ind_Tbath).p,''' StrCond{iP} ''');']);
                        if obj.ElectrThermalModel.bool_Mjo == 1
                            M = OP.M;
                        else
                            M = 0;
                        end
                        SigNoise = eval(['obj.P' StrCond{iP} '(ind_Tbath).SigNoise{ind(i)};']);
                        fNoise = eval(['obj.P' StrCond{iP} '(ind_Tbath).fNoise{ind(i)};']);
                        
                        f = logspace(0,5,1000);
                        auxnoise = obj.ElectrThermalModel.noisesim(obj,OP,M,f,StrCond{iP});
                        
                        
                        switch obj.NoiseOpt.tipo
                            case 'current'
                                
                                loglog(hs(i),fNoise(:,1),SigNoise,'.-r','DisplayName','Experimental Noise'); %%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
                                loglog(hs(i),fNoise(:,1),medfilt1(SigNoise,obj.ElectrThermalModel.DataMedFilt),'.-k','DisplayName','Exp Filtered Noise'); %%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
                                
                                if obj.ElectrThermalModel.bool_Mph == 0
                                    totnoise = sqrt(auxnoise.sum.^2+auxnoise.squidarray.^2);
                                else
                                    Mexph = OP.Mph;
                                    totnoise = sqrt((auxnoise.ph.^2*(1+Mexph^2))+auxnoise.jo.^2+auxnoise.sh.^2+auxnoise.squidarray.^2);
                                end
                                if ~obj.ElectrThermalModel.bool_components
                                    loglog(hs(i),f,totnoise*1e12,'b','DisplayName','Total Simulation Noise');
                                    h = findobj(hs(i),'Color','b');
                                else
%                                     loglog(hs(i),f,auxnoise.jo*1e12,f,auxnoise.ph*1e12,f,auxnoise.sh*1e12,f,totnoise*1e12);
                                    loglog(hs(i),f,auxnoise.jo*1e12,'DisplayName','Johnson');
                                    loglog(hs(i),f,auxnoise.ph*1e12,'DisplayName','Phonon');
                                    loglog(hs(i),f,auxnoise.sh*1e12,'DisplayName','Shunt');
                                    loglog(hs(i),f,auxnoise.squidarray*1e12,'DisplayName','Squid');
                                    loglog(hs(i),f,totnoise*1e12,'DisplayName','Total');
%                                     legend(hs(i),'Experimental','Exp Filtered Noise','Johnson','Phonon','Shunt','Total');
%                                     legend(hs(i),'off');
%                                     h = findobj(hs,'displayname','total');
                                end
                            case 'nep'
                                sIaux = ppval(spline(f,auxnoise.sI),fNoise(:,1));
                                
                                NEP = real(sqrt((SigNoise*1e-12).^2-auxnoise.squid.^2)./sIaux);
                                loglog(hs(i),fNoise(:,1),(NEP*1e18),'.-r','DisplayName','Experimental Noise');hold(hs(i),'on'),grid(hs(i),'on'),
                                loglog(hs(i),fNoise(:,1),medfilt1(NEP*1e18,obj.ElectrThermalModel.DataMedFilt),'.-k','DisplayName','Exp Filtered Noise');hold(hs(i),'on'),grid(hs(i),'on'),
                                if obj.ElectrThermalModel.bool_Mph == 0
                                    totNEP = auxnoise.NEP;
                                else
                                    totNEP = sqrt(auxnoise.max.^2+auxnoise.jo.^2+auxnoise.sh.^2)./auxnoise.sI;%%%Ojo, estamos asumiendo Mph tal que F = 1, no tiene porqué.
                                end
                                if ~obj.ElectrThermalModel.bool_components
                                    loglog(hs(i),f,totNEP*1e18,'b','DisplayName','Total Simulation Noise');hold(hs(i),'on');grid(hs(i),'on');
                                    h = findobj(hs(i),'Color','b');
                                else
%                                     loglog(hs(i),f,auxnoise.jo*1e18./auxnoise.sI,f,auxnoise.ph*1e18./auxnoise.sI,f,auxnoise.sh*1e18./auxnoise.sI,f,(totNEP*1e18));
                                    loglog(hs(i),f,auxnoise.jo*1e18./auxnoise.sI,'DisplayName','Johnson');
                                    loglog(hs(i),f,auxnoise.ph*1e18./auxnoise.sI,'DisplayName','Phonon');
                                    loglog(hs(i),f,auxnoise.sh*1e18./auxnoise.sI,'DisplayName','Shunt');
                                    loglog(hs(i),f,auxnoise.squidarray*1e18./auxnoise.sI,'DisplayName','Squid');
                                    loglog(hs(i),f,totNEP*1e18,'DisplayName','Total');
%                                     legend(hs(i),'Experimental Noise','Exp Filtered Noise','Johnson','Phonon','Shunt','Total');
%                                     legend(hs(i),'off');
%                                     h = findobj(hs(i),'displayname','total');
                                end
                        end
                        axis(hs(i),[1e1 1e5 2 1e3])
                        title(hs(i),strcat(num2str(nearest(OP.r0*100),'%3.0f'),'%Rn'),'FontSize',12);
                        if abs(OP.Z0-OP.Zinf) < obj.ElectrThermalModel.Z0_Zinf_Thrs
                            set(get(findobj(hs(i),'type','axes'),'title'),'Color','r');
                        end
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        
                        %%%%Pruebas sobre la cotribución de cada frecuencia a la
                        %%%%Resolucion.
                        if obj.ElectrThermalModel.Selected_tipo == 2 % nep
%                         if strcmpi(obj.NoiseOpt,'nep')
                            RESJ = sqrt(2*log(2)./trapz(f,1./totNEP.^2));
                            disp(num2str(RESJ));
                            semilogx(hs(i),f(1:end-1),sqrt((2*log(2)./cumsum((1./totNEP(1:end-1).^2).*diff(f))))/1.609e-19);
                            hold(hs(i),'on');
                            grid(hs(i),'on');
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
                    Tbath = eval(['[obj.P' StrCond{iP} '.Tbath]']);
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
                    try
                        [~,Tind] = min(abs(eval(['[obj.IVset' StrCond{iP} '.Tbath]'])-Tbath(ind_Tbath)));
                    catch
                        [~,Tind] = min(abs(eval(['[obj.IVset' StrCond{iP} '.Tbath]'])-Tbath));
                    end
                    IV = eval(['obj.IVset' StrCond{iP} '(Tind)']);
                    if ~isempty(Rn)
                        eval(['Rp = [obj.P' StrCond{iP} '(ind_Tbath).p.rp];']);
                        
                        for i = 1:length(Rn)
                            [~,ind(i)] = min(abs(Rp-Rn(i)));
                        end
                        ind = unique(ind,'stable');
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
%                     try
%                         eval(['[~,Tind] = min(abs([obj.IVset' StrCond{iP} '.Tbath]-Tbath));'])
%                     catch
%                         Tind = ind_Tbath;
%                     end
%                     eval(['IV = obj.IVset' StrCond{iP} '(Tind);'])                    
                    
                    [ncols,~] = SmartSplit(N);
                    hs = nan(N,1);
                    j = 0;
                    for i = 1:N
                        hs(i) = subplot(ceil(N/ncols),ncols,i);
                        hold(hs(i),'on');
                        grid(hs(i),'on');
                        xlabel(hs(i),'Re(mZ)','FontSize',9);
                        if ~mod(j,ncols)
                            ylabel(hs(i),'Im(mZ)','FontSize',9);
                            j = 0;
                        end
                        j = j+1;
                    end
                    set(hs,'LineWidth',2,'FontSize',12,'FontWeight','bold','Box','on','FontUnits','Normalized');
                    
                    for i = 1:N
                        eval(['FileName = files' StrCond{iP} '{i};']);
                        FileName = FileName(find(FileName == filesep,1,'last')+1:end);
                        if ~isempty(strfind(upper(FileName),'PXI_TF'))
                            Ib = sscanf(FileName,'PXI_TF_%fuA.txt')*1e-6;
                        else
                            Ib = sscanf(FileName,'TF_%fuA.txt')*1e-6;
                        end
                        eval(['OP = obj.setTESOPfromIb(Ib,IV,obj.P' StrCond{iP} '(ind_Tbath).p,''' StrCond{iP} ''');']);
                        
                        ztes = eval(['obj.P' StrCond{iP} '(ind_Tbath).ztes{ind(i)};']);
                        fZ = eval(['obj.P' StrCond{iP} '(ind_Tbath).fZ{ind(i)};']);
                        
                        plot(hs(i),1e3*ztes,'.','Color',[0 0.447 0.741],...
                            'markerfacecolor',[0 0.447 0.741],'MarkerSize',15,'DisplayName','Experimental Data');
                        
                        ImZmin = min(imag(1e3*ztes));
                        ylim(hs(i),[min(-15,min(ImZmin)-1) 1])
                        plot(hs(i),1e3*fZ(:,1),1e3*fZ(:,2),'r','LineWidth',2,'DisplayName',eval(['obj.P' StrCond{iP} '(ind_Tbath).ElecThermModel{ind(i)}']));
                        title(hs(i),strcat(num2str(nearest(OP.r0*100),'%3.0f'),'%Rn'),'FontSize',12);
                        if abs(OP.Z0-OP.Zinf) < obj.ElectrThermalModel.Z0_Zinf_Thrs
                            set(get(findobj(hs(i),'type','axes'),'title'),'Color','r');
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
        
        function fig = PlotTFReImagTbathRp(obj,Tbath,Rn,fig)
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
                        ind = unique(ind,'stable');
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
                    try
                        eval(['[~,Tind] = min(abs([obj.IVset' StrCond{iP} '.Tbath]-Tbath));'])
                    catch
                        Tind = ind_Tbath;
                    end
                    eval(['IV = obj.IVset' StrCond{iP} '(Tind);'])    
                    [ncols,~] = SmartSplit(N);
                    hs = nan(N,1);
                    j = 0;
                    for i = 1:N
                        hs(i) = subplot(ceil(N/ncols),ncols,i);
                        hold(hs(i),'on');
                        grid(hs(i),'on');
                        xlabel(hs(i),'w (Hz)');
                        if ~mod(j,ncols)
                            ylabel(hs(i),'Re/Im(mZ)');
                            j = 0;
                        end
                        j = j+1;
                    end
                    set(hs,'LineWidth',2,'FontSize',12,'FontWeight','bold','Box','on','FontUnits','Normalized');
                    for i = 1:N
                        eval(['FileName = files' StrCond{iP} '{i};']);
                        FileName = FileName(find(FileName == filesep,1,'last')+1:end);
                        if ~isempty(strfind(upper(FileName),'PXI_TF'))
                            Ib = sscanf(FileName,'PXI_TF_%fuA.txt')*1e-6;
                        else
                            Ib = sscanf(FileName,'TF_%fuA.txt')*1e-6;
                        end
                        eval(['OP = obj.setTESOPfromIb(Ib,IV,obj.P' StrCond{iP} '(ind_Tbath).p,''' StrCond{iP} ''');']);
                        
                        ztes = eval(['obj.P' StrCond{iP} '(ind_Tbath).ztes{ind(i)};']);
                        fZ = eval(['obj.P' StrCond{iP} '(ind_Tbath).fZ{ind(i)};']);
                        fS = eval(['obj.P' StrCond{iP} '(ind_Tbath).fS{ind(i)};']);
                        
                        plot(hs(i),fS,real(1e3*ztes),'.','Color',[0 0 1],...
                            'markerfacecolor',[0 0.447 0.741],'MarkerSize',8,'DisplayName','Exp Re(Z(w))');
                        plot(hs(i),fS,imag(1e3*ztes),'.','Color',[1 0 0],...
                            'markerfacecolor',[0 0.447 0.741],'MarkerSize',8,'DisplayName','Exp Im(Z(w))');
                        
%                         ImZmin = min(imag(1e3*ztes));
%                         ylim(hs(i),[min(-15,min(ImZmin)-1) 1])
                        plot(hs(i),fS,1e3*fZ(:,1),'Color',[0 1 0],'LineStyle',':','LineWidth',2,'DisplayName','fit-Real(Z(w))');
                        plot(hs(i),fS,1e3*fZ(:,2),'Color',[0 0 0.1724],'LineStyle',':','LineWidth',2,'DisplayName','fit-Im(Z(w))');
                        title(hs(i),strcat(num2str(nearest(OP.r0*100),'%3.0f'),'%Rn'),'FontSize',12);
                        if abs(OP.Z0-OP.Zinf) < obj.ElectrThermalModel.Z0_Zinf_Thrs
                            set(get(findobj(hs(i),'type','axes'),'title'),'Color','r');
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
        
        function fig = PlotTESData(obj,param,Rn,Tbath,fig)
            % Function to visualize TES data: param vs Tbath, param vs Rn,
            % param1 vs param2
            %             if nargin == 5
            %                 delete([findobj(fig,'Type','Line'); findobj(fig,'Type','ErrorBar'); findobj(fig,'Type','Axes')]);
            %             end
            if ~ischar(param)
                warndlg('param must be string',handles.version);
                return;
            elseif size(param,1) == 1
                
                ActionStr = ['PlotTESData(''' param ''',[' num2str(Rn) '],[' num2str(Tbath) '],fig.hObject)'];
                YLabels = {'C(fJ/K)';'\tau_{eff}(\mus)';'\alpha_i';'\beta_i'};
                colors{1} = [0 0.4470 0.7410];
                colors{2} = [1 0.5 0.05];
                if isempty(Tbath)
                    valP = nan;
                    valN = nan;
                    % Selecion de Rn y parametro a buscar en funcion de Tbath
                    if ~strcmp(param,'ExRes')
                        [valP,TbathP,RnsP] = obj.PP.GetParamVsTbath(param,Rn); % Rn must be 0-1 value
                        [valN,TbathN,RnsN] = obj.PN.GetParamVsTbath(param,Rn); % Rn must be 0-1 value
                    else
                        [valP,TbathP,RnsP] = obj.PP.GetParamVsTbath(param,Rn); % Rn must be 0-1 value
                        [valPTh,TbathPTh,RnsP] = obj.PP.GetParamVsTbath(param,Rn); % Rn must be 0-1 value
                        
                        [valN,TbathN,RnsN] = obj.PN.GetParamVsTbath(param,Rn); % Rn must be 0-1 value
                        [valNTh,TbathNTh,RnsN] = obj.PN.GetParamVsTbath(param,Rn); % Rn must be 0-1 value
                    end
                    
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
                    ax = findobj(fig,'Type','Axes');
                    if isempty(ax)
                        figure(fig);
                        ax = axes;
                        hold(ax,'on');
                        grid(ax,'on');
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
                                    eval(['val' StrRange{k} '(i,:) = val' StrRange{k} '(i,:)*1e15;']);
                                    eval(['val' StrRange{k} '_CI(i,:) = val' StrRange{k} '_CI(i,:)*1e15;']);
                                end
                            elseif strcmp(param,'taueff')||strcmp(param,'taueff_CI')
                                eval(['val' StrRange{k} '(i,:) = val' StrRange{k} '(i,:)*1e6;']);
                                eval(['val' StrRange{k} '_CI(i,:) = val' StrRange{k} '_CI(i,:)*1e6;']);
                                Ylabel = '\tau_{eff}(\mus)';
                            elseif strcmp(param,'bi')||strcmp(param,'bi_CI')
                                Ylabel = '\beta_i';
                            elseif strcmp(param,'ExRes')
                                Ylabel = 'ExRes(eV)';
                            else
                                Ylabel = param;
                            end
                        end
                        
                        if ~strcmp(param,'ExRes')
                            eval(['h = plot(ax,Tbath' StrRange{k} ',val' StrRange{k} ',''LineStyle'',''-.'',''Marker'',''' StrMarker{k} ''''...
                                ',''DisplayName'',''' StrCond{k} ' Ibias'');']);
                            try
                                eval(['e = errorbar(ax,Tbath' StrRange{k} ',val' StrRange{k} ',val' StrRange{k} '_CI,''LineStyle'',''-.'',''Marker'',''' StrMarker{k} ''''...
                                    ',''DisplayName'',''' StrCond{k} ' Ibias'',''Visible'',''off'');']);
                                for ie = 1:length(e)
                                    set(get(get(e(ie),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                                    set(e(ie),'Color',h(ie).Color);
                                end
                            catch
                            end
                        else
                            eval(['h = plot(ax,Tbath' StrRange{k} ',val' StrRange{k} ',''LineStyle'',''-.'',''Marker'',''' StrMarker{k} ''''...
                                ',''DisplayName'',''ExRes ' StrCond{k} ' Ibias'');']);
                            %                             eval(['h = plot(ax,Tbath' StrRange{k} 'Th,val' StrRange{k} 'Th,''LineStyle'',''-'',''Marker'',''' StrMarker{k} ''''...
                            %                                 ',''DisplayName'',''ThRes ' StrCond{k} ' Ibias'',''Color'',h.Color);']);
                        end
                        for n = 1:length(h)
                            h(n).MarkerFaceColor = h(n).Color;
                        end
                    end
                    xlabel(ax,'T_{bath}(K)');
                    ylabel(ax,Ylabel);
                    set(ax,'FontSize',12,'FontWeight','bold','Box','on','FontUnits','Normalized');
                    grid(ax,'on');
                    set(ax,'ButtonDownFcn',{@GraphicErrors_NKGT});
                    
                elseif isempty(Rn)
                    valP = nan;
                    valN = nan;
                    % Selecion de Tbath y parametro a buscar en funcion de Rn
                    if ~strcmp(param,'ExRes')
                        [valP,rpP,TbathP] = obj.PP.GetParamVsRn(param,Tbath); % Tbath = '50.0mK' o Tbath = 0.05;
                        [valN,rpN,TbathN] = obj.PN.GetParamVsRn(param,Tbath);
                    else
                        [valP,rpP,TbathP] = obj.PP.GetParamVsRn(param,Tbath); % Tbath = '50.0mK' o Tbath = 0.05;
                        [valPTh,rpPTh,TbathP] = obj.PP.GetParamVsRn('ThRes',Tbath); % Tbath = '50.0mK' o Tbath = 0.05;
                        [valN,rpN,TbathN] = obj.PN.GetParamVsRn(param,Tbath);
                        [valNTh,rpNTh,TbathN] = obj.PN.GetParamVsRn('ThRes',Tbath);
                    end
                    
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
                    ax = findobj(fig,'Type','Axes');
                    if isempty(ax)
                        figure(fig);
                        ax = axes;
                        hold(ax,'on');
                        grid(ax,'on');
                    end
                    StrRange = {'P';'N'};
                    StrCond = {'Positive';'Negative'};
                    colors = distinguishable_colors(length(TbathP)+length(TbathN));
                    ind_color = 1;
                    for k = 1:2
                        for i = 1:eval(['length(Tbath' StrRange{k} ')'])
                            try
                                if strcmp(param,'ai')||strcmp(param,'ai_CI')||strcmp(param,'C')||strcmp(param,'C_CI')
                                    eval(['val' StrRange{k} '{i} = abs(val' StrRange{k} '{i});']);
                                    if strcmp(param,'ai')||strcmp(param,'ai_CI')
                                        Ylabel = '\alpha_i';
                                    end
                                    if strcmp(param,'C')||strcmp(param,'C_CI')
                                        Ylabel = 'C(fJ/K)';
                                        eval(['val' StrRange{k} '{i} = val' StrRange{k} '{i}*1e15;'])
                                        eval(['val' StrRange{k} '_CI{i} = val' StrRange{k} '_CI{i}*1e15;'])
                                    end
                                elseif strcmp(param,'taueff')||strcmp(param,'taueff_CI')
                                    eval(['val' StrRange{k} '{i} = val' StrRange{k} '{i}*1e6;']);
                                    eval(['val' StrRange{k} '{i}_CI = val' StrRange{k} '_CI{i}*1e6;']);
                                    Ylabel = '\tau_{eff}(\mus)';
                                elseif strcmp(param,'bi')||strcmp(param,'bi_CI')
                                    Ylabel = '\beta_i';
                                elseif strcmp(param,'ExRes')
                                    Ylabel = 'ExRes (eV)';
                                else
                                    Ylabel = param;
                                end
                                P = eval(['obj.P' StrRange{k}]);
                                if ~strcmp(param,'ExRes')
                                    try
                                        eval(['e = errorbar(ax,rp' StrRange{k} '{i},val' StrRange{k} '{i},val' StrRange{k} '_CI{i},''LineStyle'',''-.'',''Marker'',''o'''...
                                            ',''DisplayName'',[''T_{bath}: '' num2str(Tbath' StrRange{k} '(i)*1e3) '' mK - ' StrCond{k} ' Ibias''],''Visible'',''off'',''Clipping'',''off'');']);
                                        
                                        set(get(get(e,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                                        
                                    catch
                                        e.Color = colors(ind_color,:);
                                    end
                                    eval(['h = plot(ax,rp' StrRange{k} '{i},val' StrRange{k} '{i},''LineStyle'',''-.'',''Marker'',''o'',''Color'',e.Color',...
                                        ',''DisplayName'',[''T_{bath}: '' num2str(Tbath' StrRange{k} '(i)*1e3) '' mK - ' StrCond{k} ' Ibias''],''ButtonDownFcn'',{@Identify_Origin},''UserData'',[{P;i;k;obj.circuit;param;ActionStr}]);']);
                                    
                                    
                                else
                                    
                                    eval(['h = plot(ax,rp' StrRange{k} '{i},val' StrRange{k} '{i},''LineStyle'',''-.'',''Marker'',''o'''...
                                        ',''DisplayName'',[''ExRes T_{bath}: '' num2str(Tbath' StrRange{k} '(i)*1e3) '' mK - ' StrCond{k} ' Ibias''],''ButtonDownFcn'',{@Identify_Origin},''UserData'',[{P;i;k;obj.circuit;param;ActionStr}]);']);
                                    eval(['h = plot(ax,rp' StrRange{k} 'Th{i},val' StrRange{k} 'Th{i},''LineStyle'',''-'',''Color'',h.Color'...
                                        ',''DisplayName'',[''ThRes T_{bath}: '' num2str(Tbath' StrRange{k} '(i)*1e3) '' mK - ' StrCond{k} ' Ibias''],''ButtonDownFcn'',{@Identify_Origin},''UserData'',[{P;i;k;obj.circuit;param;ActionStr}]);']);
                                end
                            catch
                            end
                            ind_color = ind_color+1;
                        end
                    end
                    xlabel(ax,'%Rn');
                    ylabel(ax,Ylabel);
                    set(ax,'FontSize',12,'FontWeight','bold','LineWidth',2,'Box','on','FontUnits','Normalized');
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
                    grid(ax,'on');
                else
                    ax = findobj('Type','Axes');
                    if length(ax) > 1
                        ax = axes;
                        hold(ax,'on');
                        grid(ax,'on');
                    end
                end
                StrRange = {'P';'N'};
                StrCond = {'Positive';'Negative'};
                for k = 1:2
                    for i = 1:eval(['length(Tbaths' StrRange{k} '1)'])
                        if strcmp(param1,'ai')||strcmp(param1,'ai_CI')||strcmp(param1,'C')||strcmp(param1,'C_CI')
                            eval(['val' StrRange{k} '1{i} = abs(val' StrRange{k} '1{i});']);
                            if strcmp(param1,'ai')||strcmp(param1,'ai_CI')
                                Ylabel = '\alpha_i';
                            end
                            if strcmp(param1,'C')||strcmp(param1,'C_CI')
                                Ylabel = 'C(fJ/K)';
                                eval(['val' StrRange{k} '1{i} = val' StrRange{k} '1{i}*1e15;'])
                                eval(['val' StrRange{k} '1{i}_CI = val' StrRange{k} '1{i}_CI*1e15;']);
                            end
                        elseif strcmp(param1,'taueff')||strcmp(param1,'taueff_CI')
                            eval(['val' StrRange{k} '1{i} = val' StrRange{k} '1{i}*1e6;']);
                            eval(['val' StrRange{k} '1_CI{i} = val' StrRange{k} '1{i}_CI*1e6;']);
                            Ylabel = '\tau_{eff}(\mus)';
                        elseif strcmp(param1,'bi')||strcmp(param1,'bi_CI')
                            Ylabel = '\beta_i';
                        else
                            Ylabel = param1;
                        end
                        
                        if strcmp(param2,'ai')||strcmp(param2,'ai_CI')||strcmp(param2,'C')||strcmp(param2,'C_CI')
                            eval(['val' StrRange{k} '2{i} = abs(val' StrRange{k} '2{i});']);
                            if strcmp(param2,'ai')||strcmp(param2,'ai_CI')
                                Xlabel = '\alpha_i';
                            end
                            if strcmp(param2,'C')||strcmp(param2,'C_CI')
                                Xlabel = 'C(fJ/K)';
                                eval(['val' StrRange{k} '2{i} = val' StrRange{k} '2{i}*1e15;'])
                                eval(['val' StrRange{k} '2{i} = val' StrRange{k} '2_CI{i}*1e15;']);
                            end
                        elseif strcmp(param2,'taueff')||strcmp(param2,'taueff_CI')
                            eval(['val' StrRange{k} '2{i} = val' StrRange{k} '2{i}*1e6;']);
                            eval(['val' StrRange{k} '2{i} = val' StrRange{k} '2_CI{i}*1e6;']);
                            Xlabel = '\tau_{eff}(\mus)';
                        elseif strcmp(param2,'bi')||strcmp(param2,'bi_CI')
                            Xlabel = '\beta_i';
                        else
                            Xlabel = param2;
                        end
                        
                        try
                            eval(['e = errorbar(ax,val' StrRange{k} '2{i},val' StrRange{k} '1{i},val' StrRange{k} '1_CI{i}/2,val' StrRange{k} '1_CI{i}/2,val' StrRange{k} '2_CI{i}/2,val' StrRange{k} '2_CI{i}/2,''LineStyle'',''none'',''Marker'',''o'''...
                                ',''DisplayName'',[''T_{bath}: '' num2str(Tbaths' StrRange{k} '1(i)*1e3) '' mK - ' StrCond{k} ' Ibias''],''Visible'',''off'',''Clipping'',''on'');']);
                            set(get(get(e,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                        catch
                        end
                        eval(['h = plot(ax,val' StrRange{k} '2{i},val' StrRange{k} '1{i},''LineStyle'',''-.'',''Marker'',''o'''...
                            ',''DisplayName'',[''T_{bath}: '' num2str(Tbaths' StrRange{k} '1(i)*1e3) '' mK - ' StrCond{k} ' Ibias'',''Color'',e.Color]);']);
                        
                    end
                end
                xlabel(ax,Xlabel);
                ylabel(ax,Ylabel);
                set(ax,'FontSize',12,'FontWeight','bold','LineWidth',2,'Box','on','FontUnits','Normalized');
                set(ax,'ButtonDownFcn',{@GraphicErrors_NKGT})
            end
        end
        
        function fig = CompareIV_Z(obj,IVset,P,Tbath,fig)
            %%%Función para pintar conjuntamente parámetros deducidos de las IVs y de
            %%%las Z(w)a una Tbath pasada en milikelvin.
%             Tbath = [IVset.Tbath];
            if exist('fig','var')
                figure(fig.hObject);
            else
                fig.hObject = figure;
            end
            if ~isfield(fig,'subplot')
                h(1) = subplot(2,1,1);
%                 set(h(1),'FontUnits','Normalized');
                grid(h(1),'on');
                hold(h(1),'on');
                h(2) = subplot(2,1,2);
%                 set(h(2),'FontUnits','Normalized');
                grid(h(2),'on');
                hold(h(2),'on');
                fig.subplot = h;
            else
                h = fig.subplot;
            end
            
            
            for i = 1:length(Tbath)
                %Extraemos la IV y la P asociadas a la Tbath de interés.
                [m1,Tind] = min(abs([IVset.Tbath]-Tbath(i)));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
                IVstr = IVset(Tind);
                [m2,Tind] = min(abs([P.Tbath]-Tbath(i)));
                p = P(Tind).p;
                thr = 1;%%%umbral en 1mK de diferencia entre la Tbath pasada y la Tbath más cercana de los datos.
                if (m1 >= thr || m2 >= thr)
                    error('Tbath not in the measured data. \n Remember to pass Tbath as a number in mK');
                end
                
                xiv_min = 0.05;
                xiv = 0.5*([IVstr.rtes(1:end-1)]+[IVstr.rtes(2:end)]);
                indx1 = find(xiv > xiv_min);
                
                a_eff = diff(log(IVstr.Rtes))./diff(log([IVstr.ttes]));
                %a_eff=diff(log(medfilt1([IVstr.Rtes],200)))./diff(log(medfilt1([IVstr.ttes],200)));
                b_eff = diff(log(IVstr.Rtes))./diff(log([IVstr.ites]));
                invb_eff = diff(log(IVstr.ites))./diff(log([IVstr.Rtes]));
                
                xz = [p.rp];
                xz_min = 0.05;
                indx2 = find(xz > xz_min);
                
                Za_effAprox = [p.ai]./(1+[p.bi]);
                %ecY='ai./(1+bi)';%%alfa_eff_Aprox
                
                %Za_eff=[p.ai_fixed].*(2*[p.L0]+[p.bi])./(2+[p.bi])./[p.L0];
                Za_eff = [p.ai].*(2*[p.L0]+[p.bi])./(2+[p.bi])./[p.L0];
                %ecY='ai.*(2*L0+bi)./(2+bi)./L0';%%%alfa_eff1
                
                try
                    Zb_eff = ([p.bi]+2*[p.Lh])./(1-[p.Lh]);
                catch
                    Zb_eff = ([p.bi]+2*[p.L0])./(1-[p.L0]);
                end
                %ecY='(bi+2*L0)./(1-L0)';%%%beta_eff
                invZb_eff = 1./Zb_eff;
                %ecY='(1-L0)./(bi+2*L0)'; %%%inverse beta_eff
                
                %%%Un poco de filtrado
                indx11 = find(xiv > xiv_min & xiv <= 1); %%%(xiv<0.8 & a_eff>0.5)
                indx22 = find(xz > xz_min & xz <= 1); %%%(xz<0.8 & Za_eff>0.5)
                
                if strcmp(IVset(1).range,'PosIbias')
                    RngLabel = 'Positive Ibias';
                else
                    RngLabel = 'Negative Ibias';
                end
                %plot(xiv(indx1),a_eff(indx1),'.-',xz(indx2),Za_eff(indx2),'.-',xz(indx2),Za_effAprox(indx2),'.-','linewidth',2,'markersize',15);
                plot(h(1),xiv(indx11),medfilt1(real(a_eff(indx11)),15),'LineWidth',2,'MarkerSize',15,'LineStyle','-.','DisplayName',['IV - ' num2str(Tbath(i)*1e3,'%1.1f') ' mK - ' RngLabel]);
                plot(h(1),xz(indx22),Za_eff(indx22)*1e-2,'LineStyle','-.','LineWidth',2,'MarkerSize',15,...
                    'DisplayName',['Z - ' num2str(Tbath(i)*1e3,'%1.1f') ' mK']);
                
                xlim(h(1),[xiv_min 0.95]);
%                 ylim(h(1),[0 250]);
                
                %legend('IV','Z','Z_{aprox}')
%                 legend(h(1),'IV','Z');
                
                
                plot(h(2),xiv(indx1),b_eff(indx1),'LineStyle','-.','LineWidth',2,'MarkerSize',15,'DisplayName',['IV - ' num2str(Tbath(i)*1e3,'%1.1f') ' mK - ' RngLabel]);
                    plot(h(2),xz(indx2),Zb_eff(indx2),'LineStyle','-.','LineWidth',2,'MarkerSize',15,'DisplayName',['Z - ' num2str(Tbath(i)*1e3,'%1.1f') ' mK']);
                xlim(h(2),[xiv_min 0.95]);
%                 ylim(h(2),[-5 5]);
                
%                 legend(h(2),'IV','Z');
            end
            ylabel(h(1),'\alpha_{eff}','FontSize',12,'FontWeight','bold');
            xlabel(h(1),'R_{TES}/R_n','FontSize',12,'FontWeight','bold');
            set(h(1),'LineWidth',2,'FontSize',12,'FontWeight','bold','Box','on');
            ylabel(h(2),'\beta_{eff}','FontSize',12,'FontWeight','bold');
            xlabel(h(2),'R_{TES}/R_n','FontSize',12,'FontWeight','bold');
            set(h(2),'LineWidth',2,'FontSize',12,'FontWeight','bold','Box','on');
            pause(0.1)
%             set(h,'Box','on','FontUnits','Normalized');
            
        end
                
        function fig = PlotCriticalCurrent(obj,fig)
            % Function to plot Critical currents vs BField searching
            % optimum field across bath temperatures
            if obj.IC.Filled
                if ~exist('fig','var')
                    fig = figure;
                end
                ax = findobj(fig,'Type','Axes');
                if isempty(ax)
                    ax = axes;
                end
                try
                    d.Label = 'Field(uA) \t';
                    d.data(:,1) = obj.IC.B{1};
                    j = 2;
                    for i = 1:length(obj.IC.B)
                        try
                            h(i) = plot(ax,obj.IC.B{i},obj.IC.p{i},'DisplayName', [num2str(obj.IC.Tbath{i}*1e3,'%1.1f') 'mK Ibias Positive']);
                            hold(ax,'on');
                            grid(ax,'on');
                            d.data(:,j) = obj.IC.p{i};
                            d.Label = [d.Label num2str(obj.IC.Tbath{i}*1e3,'%1.1f') 'mK \t'];
                            %                         d.Tbath(:,j) = obj.IC.Tbath{i};
                            j = j+1;
                        end
                    end
                    for i = 1:length(obj.IC.B)
                        try
                            hn(i) = plot(ax,obj.IC.B{i},obj.IC.n{i},'DisplayName', [num2str(obj.IC.Tbath{i}*1e3,'%1.1f') 'mK Ibias Negative']);
                            hold(ax,'on');
                            grid(ax,'on');
                            d.data(:,j) = obj.IC.n{i};
                            d.Label = [d.Label num2str(obj.IC.Tbath{i}*1e3,'%1.1f') 'mK \t'];
                            %                         d.Tbath(:,j) = obj.IC.Tbath{i};
                            j = j+1;
                        end
                    end
                    xlabel(ax,'Field (\muA)','FontSize',12,'FontWeight','bold');
                    ylabel(ax,'Critical current (\muA)','FontSize',12,'FontWeight','bold');
                    set(ax,'LineWidth',2,'FontSize',12,'FontWeight','bold','Box','on','FontUnits','Normalized','ButtonDownFcn',{@ExportData},'UserData',d);
                catch
                    
                end
            else
                fig = [];
            end
        end
        
        function fig = PlotFieldScan(obj,fig)
            % Function to plot Vout vs BField searching optimum field
            if obj.FieldScan.Filled
                if ~exist('fig','var')
                    fig = figure;
                end
                ax = findobj(fig,'Type','Axes');
                if isempty(ax)
                    ax = axes;
                end
                try
                    d.Label = 'Field(uA) \t';
                    d.data(:,1) = obj.FieldScan.B{1};
                    j = 2;
                    for i = 1:length(obj.FieldScan.B)
                        try
                            h(i) = plot(ax,obj.FieldScan.B{i},obj.FieldScan.Vout{i});
                            hold(ax,'on');
                            grid(ax,'on');
                            d.Label = [d.Label num2str(obj.FieldScan.Tbath{i}*1e3,'%1.1f') 'mK \t'];
                            %                         d.Tbath(:,j) = obj.IC.Tbath{i};
                            j = j+1;
                        end
                        try
                            set(h(i),'DisplayName', [num2str(obj.FieldScan.Tbath{i}*1e3,'%1.1f') 'mK Ibias ' num2str(obj.FieldScan.Ibias{i}) 'uA']);
                        catch
                            set(h(i),'DisplayName', [num2str(obj.FieldScan.Tbath{i}*1e3,'%1.1f') 'mK']);
                        end
                    end
                    xlabel(ax,'I_{Field} (\muA)','FontSize',12,'FontWeight','bold');
                    ylabel(ax,'Vdc(V)','FontSize',12,'FontWeight','bold');
                    set(ax,'LineWidth',2,'FontSize',12,'FontWeight','bold','Box','on','FontUnits','Normalized','ButtonDownFcn',{@ExportData},'UserData',d);
                catch
                end
            else
                fig = [];
            end
        end
                
        function GraphsReport(obj,Session)
            % Function to generate a word file report summarizing the most
            % important data and figures of the TES analysis.
            
            WordFileName = 'Template.docx';
            CurDir = pwd;
            FileSpec = fullfile(CurDir,WordFileName);
            
            %%
            [ActXWord,WordHandle]=StartWord(FileSpec);
%             ActXWord = actxserver('Word.Application');
%             ActXWord.Visible = false;
%             trace(ActXWord.Visible);
%             WordHandle = invoke(ActXWord.Documents,'Add');
            
            answer = inputdlg({'Insert Report File Name'},obj.version,[1 50],{Session.NickName});
            if isempty(answer)
                return;
            end
            FileName = answer;
            Style='Título 1';
            WordText(ActXWord,['Informe análisis TES: ' Session.TES_Idn],Style,[0,1]);%no enter
            Style='Normal';
            try
                d = dir(obj.IVsetP(1).IVsetPath(1:end-4));
                WordText(ActXWord,['Fecha medidas: ' datestr(d(1).date,1)],Style,[0,1]);%no enter            
            catch
                WordText(ActXWord,'Fecha medidas: ',Style,[0,1]);%no enter  
            end
                                                            
            WordText(ActXWord,['TES con depósito (' num2str(obj.TESDim.SputteringID) ') con '...
                num2str(obj.TESDim.hMo.Value*1e9) '/' num2str(obj.TESDim.hAu.Value*1e9)...
                ' de espesores y ' num2str(obj.TESDim.sides.Value(1)*1e6) ' µm x '...
                num2str(obj.TESDim.sides.Value(2)*1e6) ' µm de área.'],Style,[0,1]);%no enter
            
            if obj.TESDim.Membrane_bool
                WordText(ActXWord,['Membrana ' num2str(obj.TESDim.Membrane_thick)*1e6...
                    ' µm grosor, ' num2str(obj.TESDim.Membrane_length)*1e6 'x' num2str(obj.TESDim.Membrane_width)*1e6...
                    ' µm de tamaño'],Style,[0,1]);%no enter
            else
                WordText(ActXWord,'No presenta membrana.',Style,[0,1]);%no enter
            end
            
            
            if obj.TESDim.Abs_bool
                WordText(ActXWord,['Absorbente de Au/Bi de ' num2str(obj.TESDim.Abs_hAu.Value*1e6)...
                    ' x ' num2str(obj.TESDim.Abs_hBi.Value*1e6) ' µm.'],Style,[0,1]);%no enter
            else                
                WordText(ActXWord,'No presenta absorbente.',Style,[0,1]);%no enter
            end
            
            WordText(ActXWord,['SQUID: ' Session.Squid_Idn ' chip 2x16 Polarizado: Ib = 10.727 µA, Vb = 957.05 µV, phi_b = 7.85 µA.'],...
                Style,[0,1]);%no enter            
            WordText(ActXWord,['delta_phi = 1/Mf = ' num2str(obj.circuit.invMf.Value) ' µA/phi0'],Style,[0,1]);%no enter            
            WordText(ActXWord,['1/Min = ' num2str(obj.circuit.invMin.Value) ' µA/phi0'],Style,[0,1]);%no enter
            
            try                
                WordText(ActXWord,['Carpeta de datos: ' obj.IVsetP(1).IVsetPath(1:end-4)],Style,[0,1]);%no enter
                ind = findstr(obj.IVsetP(1).IVsetPath,filesep); %#ok<FSTR>
                RunStr = obj.IVsetP(1).IVsetPath(ind(end-2)+1:ind(end-1)-1);
                WordText(ActXWord,['RUNs analizados: ' RunStr ],Style,[0,1]);
                WordText(ActXWord,['(Rama Positiva/Negativa; Campo óptimo = ' Session.BFieldCond ' µA).'],Style,[0,1]);%no enter
                WordText(ActXWord,['Comentario: ' Session.Comments],Style,[0,1]);
            catch
                WordText(ActXWord,'Carpeta de datos: ',Style,[0,1]);%no enter
                WordText(ActXWord,'RUNs analizados:      (Con/Sin Campo óptimo = X µA).',Style,[0,1]);%no enter
            end            
                                    
            Style='Título 2';
            TextString='TES Circuit Parameters';
            WordText(ActXWord,TextString,Style,[0,1]);%enter after text
            
            CircProp = properties(obj.circuit);
            clear DataCell;
            DataCell(1,1:3) = {'Parametros','Valores','Unidades'};
            for i = 1:6 
                DataCell(i,1:3) = {CircProp{i}, num2str(eval(['obj.circuit.' CircProp{i} '.Value'])),...
                    eval(['obj.circuit.' CircProp{i} '.Units'])};
            end
            [NoRows,NoCols]=size(DataCell);
            %create table with data from DataCell
            Style = 'Cita';
            WordText(ActXWord,'',Style,[0,1]);%enter after text
            WordCreateTable(ActXWord,NoRows,NoCols,DataCell,[1 1]);%enter before table
            
            Style = 'Título 2';
            WordText(ActXWord,'',Style,[0,1]);%enter after text
            TextString='TES Parameters';
            WordText(ActXWord,TextString,Style,[0,1]);%enter after text
            
            TESProp = properties(obj.TESParamP);
            clear DataCell;
            DataCell(1,1:4) = {'Parametros','Ibias Positivas','Ibias Negativas','Unidades'};
            for i = 1:length(TESProp)-1 
                DataCell(i+1,1:4) = {TESProp{i}, num2str(eval(['obj.TESParamP.' TESProp{i} '.Value'])),...
                    num2str(eval(['obj.TESParamN.' TESProp{i} '.Value'])), eval(['obj.TESParamN.' TESProp{i} '.Units'])};
            end
            [NoRows,NoCols]=size(DataCell);
            %create table with data from DataCell
            Style = 'Cita';
            WordText(ActXWord,'',Style,[0,1]);%enter after text
            WordCreateTable(ActXWord,NoRows,NoCols,DataCell,[1 1]);%enter before table
            
            Style = 'Título 2';
            WordText(ActXWord,'',Style,[0,1]);%enter after text
            TextString='TES Thermal Parameters';
            WordText(ActXWord,TextString,Style,[0,1]);%enter after text
            
            TESProp = properties(obj.TESThermalP);
            clear DataCell;
            DataCell(1,1:4) = {'Parametros','Ibias Positivas','Ibias Negativas','Unidades'};
            for i = 1:length(TESProp) 
                DataCell(i+1,1:4) = {TESProp{i}, num2str(eval(['obj.TESThermalP.' TESProp{i} '.Value'])),...
                    num2str(eval(['obj.TESThermalN.' TESProp{i} '.Value'])), eval(['obj.TESThermalN.' TESProp{i} '.Units'])};
            end
            DataCell{length(TESProp)+1,1} = '%Rn Selected';
            [NoRows,NoCols]=size(DataCell);
            %create table with data from DataCell
            Style = 'Cita';
            WordText(ActXWord,'',Style,[0,1]);%enter after text
            WordCreateTable(ActXWord,NoRows,NoCols,DataCell,[1 1]);%enter before table
            
            Style = 'normal';
            TextString = ['Parametros termicos (rama positiva) obtenidos considerando %Rn: ' num2str(obj.GsetP(1).rp)...
                ':' num2str(obj.GsetP(2).rp-obj.GsetP(1).rp) ':' num2str(obj.GsetP(end).rp)];            
            WordText(ActXWord,TextString,Style,[0,1]);%enter after text
            TextString = ['Parametros termicos (rama negativa) obtenidos considerando %Rn: ' num2str(obj.GsetN(1).rp)...
                ':' num2str(obj.GsetN(2).rp-obj.GsetN(1).rp) ':' num2str(obj.GsetN(end).rp)];            
            WordText(ActXWord,TextString,Style,[0,1]);%enter after text
            
            FigNum = 1;
            
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
                Data2DrawStr_Units(4,:) = {'%R_n';'Ptes(pW)'};
                
                IVset = [obj.IVsetP obj.IVsetN];
                for i = 1:length(IVset)
                    if IVset(i).good
                        for j = 1:4
                            eval(['plot(h(j),IVset(i).' Data2DrawStr{j,1} ', IVset(i).' Data2DrawStr{j,2} ', ''.--'','...
                                '''ButtonDownFcn'',{@ChangeGoodOpt},''DisplayName'',num2str(IVset(i).Tbath),''Tag'',IVset(i).file);']);
                            grid(h(j),'on');
                            hold(h(j),'on');
                            xlabel(h(j),Data2DrawStr_Units(j,1),'FontWeight','bold');
                            ylabel(h(j),Data2DrawStr_Units(j,2),'FontWeight','bold');                            
                        end
                    else  % No se pinta o se pinta de otro color
                        
                    end
                end
                set(h,'FontSize',12,'LineWidth',2,'FontWeight','bold','Box','on','FontUnits','Normalized')
                axis(h,'tight');
                xlim(h(4),[0 1]);
                figIV.hObject.Visible = 'on';
                set(figIV.hObject, 'Position', get(0, 'Screensize'));
                % Curvas I-V eliminadas del analisis
                % Positivas
                PTbath = [obj.IVsetP.Tbath]*1e3;
                TbathsP = num2str(PTbath([obj.IVsetP.good] == 0),'%.1f, ');
                NTbath = [obj.IVsetN.Tbath]*1e3;
                TbathsN = num2str(NTbath([obj.IVsetN.good] == 0),'%.1f, ');
                 
                
                
                Style = 'Título 2';
                TextString = 'IV Curves';                
                WordText(ActXWord,TextString,Style,[0,1]);                                
                
                Style = 'normal';
                WordText(ActXWord,['Método de corrección I-Vs: ' obj.IVsetP(1).CorrectionMethod],Style,[0,1]);%enter after text
                
                print(figIV.hObject,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                close(figIV.hObject);
                pause(0.3)
                clear figIV;
                ActXWord.Selection.TypeParagraph;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '. IVs con Ibias positiva y negativa.'];
                WordText(ActXWord,TextString,Style,[0,1]);
                FigNum = FigNum+1;
                
                Style = 'normal';
                WordText(ActXWord,['Curvas I-V Positivas eliminadas: ' TbathsP(1:end-1) ' mK' ],Style,[0,1]);%enter after text
                WordText(ActXWord,['Curvas I-V Negativas eliminadas: ' TbathsN(1:end-1) ' mK' ],Style,[0,1]);%enter after text
                
            end
            
            if obj.Report.FitPTset
                
%                 model = obj.BuildPTbModel('GTcdirect');
                StrRange = {'P';'N'};
                fig = figure('Name','FitP vs. Tset');
                for k = 1:2                    
                    Gset = eval(['obj.Gset' StrRange{k}]);                    
                    Npoints = length([Gset.n]);
                    c = distinguishable_colors(Npoints);
                    
                    if Npoints > 1
                        ax = subplot(1,2,k); 
                        hold(ax,'on');
                        grid(ax,'on');
                        for i = 1:Npoints
                            plot(ax,Gset(i).Tbath,Gset(i).Paux_fit,'LineStyle','-','Color',...
                                c(i,:),'LineWidth',1);
                            hold(ax,'on')
                            grid(ax,'on');
                            
                            plot(ax,Gset(i).Tbath,Gset(i).Paux,'Marker','o','MarkerFaceColor',...
                                c(i,:),'MarkerEdgeColor',c(i,:),'DisplayName',['Rn(%): ' num2str(Gset(i).rp)]);
                        end
                        xlabel(ax,'T_{bath}(K)','FontSize',12,'FontWeight','bold')
                        ylabel(ax,'P_{TES}(pW)','FontSize',12,'FontWeight','bold')
                        set(ax,'FontSize',12,'LineWidth',2,'FontWeight','bold','Box','on','FontUnits','Normalized')
                    else
                        if k == 1
                            axInd = [1 3];
                        else
                            axInd = [2 4];
                        end
                        ax(axInd(1),1) = subplot(2,2,axInd(1),'Visible','on');
                        ax(axInd(2),2) = subplot(2,2,axInd(2),'Visible','on');                        
                        hold(ax(axInd(1),1),'on');
                        hold(ax(axInd(2),2),'on');
                        grid(ax(axInd(1),1),'on');
                        grid(ax(axInd(2),2),'on');
                        Gset = eval(['obj.Gset' StrRange{k}]);
                        if isempty(eval(['obj.IVset' StrRange{k} '.ibias']))
                            continue;
                        end
                        IVTESset = eval(['obj.IVset' StrRange{k}]);
                        c = distinguishable_colors(length(IVTESset));
                        for i = 1:length(IVTESset)
                            if IVTESset(i).good
                                dptes = diff(IVTESset(i).ptes*1e12);
                                dvtes = diff(IVTESset(i).vtes*1e6);
                                indP = find(abs(dptes./dvtes) < obj.PvsV_Thrs, 1 );
                                plot(ax(axInd(1),1),IVTESset(i).vtes*1e6,IVTESset(i).ptes*1e12,'.-','Color',c(i,:),'Visible','on');
                                plot(ax(axInd(1),1),IVTESset(i).vtes(indP)*1e6,IVTESset(i).ptes(indP)*1e12,'r*','Visible','on');
                            end
                        end
                        plot(ax(axInd(2),2),Gset.Tbath,Gset.Paux_fit,'LineStyle','-','Color',c(1,:),'LineWidth',1);
                        plot(ax(axInd(2),2),Gset.Tbath,Gset.Paux,'Marker','o','MarkerFaceColor',c(1,:),'MarkerEdgeColor',c(1,:))
                        xlabel(ax(axInd(2),2),'T_{bath}(K)','FontSize',12,'FontWeight','bold')
                        ylabel(ax(axInd(2),2),'P_{TES}(pW)','FontSize',12,'FontWeight','bold')
                        xlabel(ax(axInd(1),1),'V_{TES}(\muV)','FontWeight','bold');
                        ylabel(ax(axInd(1),1),'Ptes(pW)','FontWeight','bold');
                        set(ax(axInd(1),1),'FontSize',12,'LineWidth',2,'FontWeight','bold','Box','on','FontUnits','Normalized')
                        axis(ax(axInd(1),1),'tight');
                    end
                end
                
                Style='Título 2';
                TextString = 'Fit P vs T';
                WordText(ActXWord,TextString,Style,[0,1]);
                set(fig, 'Position', get(0, 'Screensize'));
                print(fig,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                ActXWord.Selection.TypeParagraph;
                close(fig);
                pause(0.3)
                clear fig;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '. Ajustes PTES-Tbath a lo largo de la transición para ambas polaridades.'];
                WordText(ActXWord,TextString,Style,[0,1]);
                FigNum = FigNum+1;
            end
            
            %% Pintar NKGT set
            if obj.Report.NKGTset                
            
                if size([obj.GsetP.n],2) > 1
%                     clear fig;
                    MS = 2; %#ok<NASGU>
                    LS = 0.5; %#ok<NASGU>
                    color{1} = [0 0.447 0.741];
                    color{2} = [1 0 0];
                    
                    StrField = {'n';'T_fit';'K';'G'};
                    StrMultiplier = {'1';'1';'1e9';'1e12';};
                    StrLabel = {'n';'T_{fit}(K)';'K(nW/K^n)';'G(pW/K)'};
                    StrRange = {'P';'N'};
                    StrIbias = {'Positive';'Negative'};
                    Marker = {'o';'^'};
                    LineStr = {'.-';':'};
                    for k = 1:2
                        if isempty(eval(['obj.Gset' StrRange{k} '.n']))
                            continue;
                        end
                        if ~exist('fig','var')
                            fig.hObject = figure;
                        end
                        Gset = eval(['obj.Gset' StrRange{k}]);
                        
                        TES_OP_y = find([Gset.T_fit] == eval(['obj.TESThermal' StrRange{k} '.T_fit.Value']),1,'last');
                        
                        if isfield(fig,'subplots')
                            h = fig.subplots;
                        end
                        for j = 1:length(StrField)
                            if ~isfield(fig,'subplots')
                                h(j) = subplot(2,2,j);
                                hold(h(j),'on');
                                grid(h(j),'on');
                            end
                            rp = [Gset.rp];
                            [~,ind] = sort(rp);
                            val = eval(['[Gset.' StrField{j} ']*' StrMultiplier{j} ';']);
                            try
                                val_CI = eval(['[Gset.' StrField{j} '_CI]*' StrMultiplier{j} ';']);
                                er(j) = errorbar(h(j),rp(ind),val(ind),val_CI(ind),'Color',color{k},...
                                    'Visible','on','DisplayName',[StrIbias{k} ' Error Bar'],'Clipping','on');
                            catch
                            end
                            eval(['plot(h(j),rp(ind),val(ind),''' LineStr{k} ''','...
                                '''Color'',color{k},''MarkerFaceColor'',color{k},''LineWidth'',LS,''MarkerSize'',MS,''Marker'','...
                                '''' Marker{k} ''',''DisplayName'',''' StrIbias{k} ''');']);
                            xlim(h(j),[0.15 0.9]);
                            xlabel(h(j),'%R_n','FontSize',12,'FontWeight','bold');
                            ylabel(h(j),StrLabel{j},'FontSize',12,'FontWeight','bold');
                            
                            
                            try
                                eval(['plot(h(j),Gset(TES_OP_y).rp,Gset(TES_OP_y).' StrField{j} '*' StrMultiplier{j} ',''.-'','...
                                    '''Color'',''g'',''MarkerFaceColor'',''g'',''MarkerEdgeColor'',''g'','...
                                    '''LineWidth'',LS,''Marker'',''hexagram'',''MarkerSize'',2*MS,''DisplayName'',''Operation Point ' StrIbias{k} ' Ibias'');']);
                            catch
                            end
                            
                        end
                        set(h,'LineWidth',2,'FontSize',12,'FontWeight','bold','Box','on');
                        fig.subplots = h;
                    end
                    set(fig.subplots,'FontUnits','Normalized');
%                     legend(h(end),'show','Location','Northeast');
                    set(fig.hObject, 'Position', get(0, 'Screensize'));
                    fig.hObject.Visible = 'on'; 
                    
                    Style='Título 2';
                    TextString = 'NKGT Figure';                    
                    WordText(ActXWord,TextString,Style,[0,1]);
                    Style='normal';
                    WordText(ActXWord,'',Style,[0,1]);
                    print(fig.hObject,'-dmeta');
                    invoke(ActXWord.Selection,'Paste');
                    ActXWord.Selection.TypeParagraph;
                    close(fig.hObject);
                    pause(0.3)
                    clear fig;
                    Style='Cita';
                    TextString = ['Fig. ' num2str(FigNum) '. Resultado de los ajustes PTES-Tbath a lo largo de la transición para ambas polaridades.'];
                    WordText(ActXWord,TextString,Style,[0,1]);
                    FigNum = FigNum+1;
                end
            end
            
            if obj.Report.BVscan && obj.FieldScan.Filled
                Style='Título 2';
                TextString = 'Campo óptimo';
                WordText(ActXWord,TextString,Style,[0,1]);
                Style='normal';
                WordText(ActXWord,'',Style,[0,1]);
                fig = obj.PlotFieldScan;
                set(fig.Children,'FontUnits','Normalized');
                set(fig, 'Position', get(0, 'Screensize')); 
                print(fig,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                close(fig);
                pause(0.3)
                clear fig;
                ActXWord.Selection.TypeParagraph;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '. Barrido de Vout para la determinación del campo óptimo.'];
                WordText(ActXWord,TextString,Style,[0,1]);
                FigNum = FigNum+1;
            end
            
            if obj.Report.TF_Normal
                [obj.TFN, fig] = obj.TFN.PlotTF;
                Style='normal';
                WordText(ActXWord,'',Style,[0,1]);
                print(fig,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                ActXWord.Selection.TypeParagraph;
                close(fig);
                pause(0.3)
                clear fig;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '. Función de transferencia en estado Normal, archivo: ' obj.TFN.file.'];
                WordText(ActXWord,TextString,Style,[0,1]);
                FigNum = FigNum+1;
            end
            if obj.Report.TF_Super
                [obj.TFS, fig] = obj.TFS.PlotTF;
                Style='normal';
                WordText(ActXWord,'',Style,[0,1]);
                print(fig,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                ActXWord.Selection.TypeParagraph;
                close(fig);
                pause(0.3)
                clear fig;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '. Función de transferencia en estado Superconductor, archivo: ' obj.TFS.file.'];
                WordText(ActXWord,TextString,Style,[0,1]);
                FigNum = FigNum+1;
            end
            
            if obj.Report.FitZset
                
                Style='Título 2';
                TextString = 'Z(w) Analysis';                
                WordText(ActXWord,TextString,Style,[0,1]);  
                Style='normal';
                TextString = ['Fig. ' num2str(FigNum) '. Parámetros dinámicos calculados usando el modelo de ' obj.PP(1).ElecThermModel{1}];
                WordText(ActXWord,TextString,Style,[0,1]);
%                 Rn = [obj.PP(1).p.rp];
                clear fig;
                
                str = cellstr(num2str(unique([[obj.PP.Tbath] ...
                    [obj.PN.Tbath]])'));
                [s,~] = listdlg('PromptString','Select Tbath value/s:',...
                    'SelectionMode','multiple',...
                    'ListString',str);
                if isempty(s)
                    return;
                end
                Tbath = str2double(str(s))';
                prompt = {'Enter the %Rn range:'};
                name = '%Rn range (0 < %Rn < 1)';
                numlines = [1 70];
                defaultanswer = {'0.5:0.05:0.8'};
                answer = inputdlg(prompt,name,numlines,defaultanswer);
                Rn = eval(['[' answer{1} ']']);
%                 handles.Session{handles.TES_ID}.TES.PlotTFTbathRp(Tbath,Rn);
                
                
                fig = obj.PlotTFTbathRp(Tbath,Rn);
                try
                    FigSubNum = 1;    
                    Temps = num2str([obj.PP.Tbath]'*1e3);
                    for i = 1:length([obj.PP.Tbath])
                        Style = 'normal';
                        StrIni = ['Positive Ibias at ' Temps(i,:) ' mK ',];
                        StrIni(end) = [];
                        WordText(ActXWord,StrIni,Style,[0,1]);
                        Style='normal';
                        WordText(ActXWord,'',Style,[0,1]);
                        set(fig(i).Children,'FontUnits','Normalized');
                        set(fig(i), 'Position', get(0, 'Screensize'));
                        print(fig(i),'-dmeta')
                        invoke(ActXWord.Selection,'Paste');
                        close(fig(i));
                        pause(0.3)
                        ActXWord.Selection.TypeParagraph;
                        Style='Cita';
                        TextString = ['Fig. ' num2str(FigNum) '. Z(w) a ' Temps(i,:) ' mK.'];
                        WordText(ActXWord,TextString,Style,[0,1]);                        
                        FigSubNum = FigSubNum+1;                        
                    end
                    FigNum = FigNum+1;
%                     set(fig, 'Position', get(0, 'Screensize'));
                    close(fig)
                catch
                end
                try
                    FigSubNum = 1;    
                    Temps = num2str([obj.PN.Tbath]'*1e3);
                    for j = 1:length([obj.PN.Tbath])
                        i = i+1;
                        Style = 'normal';
                        StrIni = ['Negative Ibias at ' Temps(j,:) ' mK ',];
                        StrIni(end) = [];
                        WordText(ActXWord,StrIni,Style,[0,1]);
                        Style='normal';
                        WordText(ActXWord,'',Style,[0,1]);
                        set(fig(i).Children,'FontUnits','Normalized');
                        set(fig(i), 'Position', get(0, 'Screensize'));
                        print(fig(i),'-dmeta')
                        invoke(ActXWord.Selection,'Paste');
                        close(fig(i));
                        pause(0.3)
                        ActXWord.Selection.TypeParagraph;
                        Style='Cita';
                        TextString = ['Fig. ' num2str(FigNum) '.' num2str(FigSubNum) '. Z(w) a ' Temps(j,:) ' mK.'];
                        WordText(ActXWord,TextString,Style,[0,1]);
%                         ActXWord.Selection.TypeParagraph;
                        FigSubNum = FigSubNum+1;
                    end
                    FigNum = FigNum+1;
                catch
                end
                clear fig;
            end
            
            if obj.Report.Noise_Normal
                fig = figure;
                [obj.NoiseN, fig] = obj.NoiseN.Plot(fig,obj,'Normal'); 
                Style='normal';
                WordText(ActXWord,'',Style,[0,1]);
                set(fig.Children,'FontUnits','Normalized','Box','on');
                set(fig, 'Position', get(0, 'Screensize'));
                print(fig,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                ActXWord.Selection.TypeParagraph;
                close(fig);
                pause(0.3)
                clear fig;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '. Ruido en estado Normal, archivo: ' obj.NoiseN.fileNoise];
                WordText(ActXWord,TextString,Style,[0,1]);
                FigNum = FigNum+1;
            end
            if obj.Report.Noise_Super
                fig = figure;
                [obj.NoiseS, fig] = obj.NoiseS.Plot(fig,obj,'Superconductor');                
                Style='normal';
                WordText(ActXWord,'',Style,[0,1]);
                set(fig.Children,'FontUnits','Normalized');
                set(fig, 'Position', get(0, 'Screensize'));
                print(fig,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                ActXWord.Selection.TypeParagraph;
                close(fig);
                pause(0.3)
                clear fig;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '. Ruido en estado Superconductor, archivo: ' obj.NoiseS.fileNoise];
                WordText(ActXWord,TextString,Style,[0,1]);
                FigNum = FigNum+1;
            end
            
            if obj.Report.NoiseSet
                
                Style='Título 2';
                TextString = 'Noise Analysis';
                WordText(ActXWord,TextString,Style,[0,1]);
                Style='normal';
                TextString = ['Fig. ' num2str(FigNum) '. Parámetros dinámicos calculados usando el modelo de ' obj.PP(1).ElecThermModel{1}];
                WordText(ActXWord,TextString,Style,[0,1]);
                
                str = cellstr(num2str(unique([[obj.PP.Tbath] ...
                    [obj.PN.Tbath]])'));
                [s,~] = listdlg('PromptString','Select Tbath value/s:',...
                    'SelectionMode','multiple',...
                    'ListString',str);
                if isempty(s)
                    return;
                end
                Tbath = str2double(str(s))';
                prompt = {'Enter the %Rn range:'};
                name = '%Rn range (0 < %Rn < 1)';
                numlines = [1 70];
                defaultanswer = {'0.5:0.05:0.8'};
                answer = inputdlg(prompt,name,numlines,defaultanswer);
                Rn = eval(['[' answer{1} ']']);
%                 handles.Session{handles.TES_ID}.TES.PlotNoiseTbathRp(Tbath,Rn);
                
                fig = obj.PlotNoiseTbathRp(Tbath,Rn);
                try
                    FigSubNum = 1;                    
                    Temps = num2str([obj.PP.Tbath]'*1e3);
                    for i = 1:length([obj.PP.Tbath])
                        Style = 'normal';
                        StrIni = ['Positive Ibias at ' Temps(i,:) ' mK ',];
                        StrIni(end) = [];
                        WordText(ActXWord,StrIni,Style,[0,1]);
                        Style='normal';
                        WordText(ActXWord,'',Style,[0,1]);
                        set(fig(i).Children,'FontUnits','Normalized');
                        set(fig(i), 'Position', get(0, 'Screensize'));
                        print(fig(i),'-dmeta')
                        invoke(ActXWord.Selection,'Paste');
                        close(fig(i));
                        pause(0.3)
                        ActXWord.Selection.TypeParagraph;
                        Style='Cita';
                        TextString = ['Fig. ' num2str(FigNum) '.' num2str(FigSubNum) '. Ruido a ' Temps(i,:) ' mK.'];
                        WordText(ActXWord,TextString,Style,[0,1]);
%                         ActXWord.Selection.TypeParagraph;
                        FigSubNum = FigSubNum+1;
                    end
                    FigNum = FigNum+1;
                catch
                end
                try
                    FigSubNum = 1;
                    Temps = num2str([obj.PN.Tbath]'*1e3);
                    for j = 1:length([obj.PN.Tbath])
                        i = i+1;
                        Style = 'normal';
                        StrIni = ['Negative Ibias at ' Temps(j,:) ' mK ',];
                        StrIni(end) = [];
                        WordText(ActXWord,StrIni,Style,[0,1]);
                        Style='normal';
                        WordText(ActXWord,'',Style,[0,1]);
                        set(fig(i).Children,'FontUnits','Normalized');
                        set(fig(i), 'Position', get(0, 'Screensize'));
                        print(fig(i),'-dmeta')
                        invoke(ActXWord.Selection,'Paste');
                        close(fig(i));
                        pause(0.3)
                        ActXWord.Selection.TypeParagraph;
                        Style='Cita';
                        TextString = ['Fig. ' num2str(FigNum) '.' num2str(FigSubNum) '. Ruido a ' Temps(j,:) ' mK.'];
                        WordText(ActXWord,TextString,Style,[0,1]);
%                         ActXWord.Selection.TypeParagraph;
                        FigSubNum = FigSubNum+1;
                    end
                    FigNum = FigNum+1;
                    
                catch
                end
                clear fig;
            end
            
            if obj.Report.ABCTset
                fig.hObject = figure;
                obj.plotABCT(fig,'on');
                set(fig.hObject.Children,'FontUnits','Normalized');
                legend(fig.hObject.Children(1),'show','Location','Northeast');
                Style='Título 2';
                TextString = 'ABCT Figure';
                WordText(ActXWord,TextString,Style,[0,1]);
                Style='normal';
                WordText(ActXWord,'',Style,[0,1]);
                set(fig.hObject, 'Position', get(0, 'Screensize'));                
                print(fig.hObject,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                close(fig.hObject);
                pause(0.3)
                ActXWord.Selection.TypeParagraph;
                clear fig;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '. Parámetros dinámicos calculados usando el modelo de ' obj.PP(1).ElecThermModel{1}];
                WordText(ActXWord,TextString,Style,[0,1]);
%                 ActXWord.Selection.TypeParagraph;
                FigNum = FigNum+1;
                
                
%                 try                    
%                     WordText(ActXWord,['Fitting TF to: ' obj.PP(1).ElecThermModel{1}],Style,[0,1]);
%                 catch
%                 end
                
            end
            if obj.Report.RTs
                fig.hObject = figure;
                obj.plotRTs(fig);
                
                Style='Título 2';
                TextString = 'RTs Figure';
                WordText(ActXWord,TextString,Style,[0,1]);
                Style='normal';
                WordText(ActXWord,'',Style,[0,1]);
                set(fig.hObject.Children,'FontUnits','Normalized');
                set(fig.hObject, 'Position', get(0, 'Screensize'));                 
                print(fig.hObject,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                close(fig.hObject);
                pause(0.3)
                ActXWord.Selection.TypeParagraph;
                clear fig;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '. Reconstrucción de las R(T) a partir de los valores de n y K obtenidos de los ajustes.'];
                WordText(ActXWord,TextString,Style,[0,1]);
                FigNum = FigNum+1;                             
                
            end
            
            if obj.Report.RT_4points
                
            end
            
            % Añadir la representación de las Ic's y del BVscan
            if obj.Report.IV_Z
                FigSubNum = 1;
                Style='Título 2';
                TextString = 'Comparativa IV-Z';
                WordText(ActXWord,TextString,Style,[0,1]);
                Style='normal';
                WordText(ActXWord,'',Style,[0,1]);
                Tbath = unique([[obj.PP.Tbath] [obj.PN.Tbath]]);
                fig = obj.CompareIV_Z(obj.IVsetP,obj.PP,Tbath);
                legend(fig.hObject.Children(1),'show','Location','Northwest')
                pause(0.1)
                Style='Normal';
                TextString = 'Positive Ibias';
                WordText(ActXWord,TextString,Style,[0,1]);
                set(fig.hObject.Children,'FontUnits','Normalized');
                set(fig.hObject, 'Position', get(0, 'Screensize')); 
                pause(0.1)
                print(fig.hObject,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                close(fig.hObject);
                pause(0.3)
                ActXWord.Selection.TypeParagraph;
                clear fig;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '.' num2str(FigSubNum) '. Comparativa de IV-Z correspondiente a Ibias positivos'];
                WordText(ActXWord,TextString,Style,[0,1]);   
                FigSubNum = FigSubNum+1;
                                
                fig = obj.CompareIV_Z(obj.IVsetN,obj.PN,Tbath);
                legend(fig.hObject.Children(1),'show','Location','best')
                pause(0.1)
                Style='Normal';
                TextString = 'Negative Ibias';
                WordText(ActXWord,TextString,Style,[0,1]);
                Style='normal';
                WordText(ActXWord,'',Style,[0,1]);
                set(fig.hObject.Children,'FontUnits','Normalized');
                set(fig.hObject, 'Position', get(0, 'Screensize')); 
                pause(0.1)
                print(fig.hObject,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                close(fig.hObject);
                pause(0.3)
                clear fig;
                ActXWord.Selection.TypeParagraph;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '.' num2str(FigSubNum) '. Comparativa de IV-Z correspondiente a Ibias negativos'];
                WordText(ActXWord,TextString,Style,[0,1]);  
                FigNum = FigNum+1;
                
            end
            
            if obj.Report.ICs && obj.IC.Filled
                Style='Título 2';
                TextString = 'Corrientes Críticas';
                WordText(ActXWord,TextString,Style,[0,1]);
                Style='normal';
                WordText(ActXWord,'',Style,[0,1]);
                fig = obj.PlotCriticalCurrent;
                legend(fig.Children,'show','Location','Northeast');
                set(fig.Children,'FontUnits','Normalized');
                set(fig, 'Position', get(0, 'Screensize')); 
                print(fig,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                close(fig);
                pause(0.3)
                clear fig;
                ActXWord.Selection.TypeParagraph;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '. Corrientes críticas obtenidas a diferentes temperaturas del baño.'];
                WordText(ActXWord,TextString,Style,[0,1]);
                FigNum = FigNum+1;
                
            end
            
            if obj.Report.BaselineRes
                Style='Título 2';
                TextString = 'Baseline Resolution';
                WordText(ActXWord,TextString,Style,[0,1]);
                Style='normal';
                WordText(ActXWord,'',Style,[0,1]);
                fig = figure;
                Tbath = unique([[obj.PP.Tbath] [obj.PN.Tbath]]);
                obj.PlotTESData('ExRes',[],Tbath,fig);
                legend(fig.Children,'show','Location','Northeastoutside');
                set(fig.Children,'FontUnits','Normalized');
                set(fig, 'Position', get(0, 'Screensize')); 
                print(fig,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                close(fig);
                pause(0.3)
                clear fig;
                ActXWord.Selection.TypeParagraph;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '. Baseline resolution.'];
                WordText(ActXWord,TextString,Style,[0,1]);
                FigNum = FigNum+1;
            end            
            if obj.Report.Mph
                Style='Título 2';
                TextString = 'Phonon noise';
                WordText(ActXWord,TextString,Style,[0,1]);
                Style='normal';
                WordText(ActXWord,'',Style,[0,1]);
                fig = figure;
                Tbath = unique([[obj.PP.Tbath] [obj.PN.Tbath]]);
                obj.PlotTESData('Mph',[],Tbath,fig);
                legend(fig.Children,'show','Location','Northeastoutside');
                set(fig.Children,'FontUnits','Normalized');
                set(fig, 'Position', get(0, 'Screensize')); 
                print(fig,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                close(fig);
                pause(0.3)
                clear fig;
                ActXWord.Selection.TypeParagraph;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '. Phonon noise contribution.'];
                WordText(ActXWord,TextString,Style,[0,1]);
                FigNum = FigNum+1;
            end
            if obj.Report.M
                Style='Título 2';
                TextString = 'Johnson noise';
                WordText(ActXWord,TextString,Style,[0,1]);
                Style='normal';
                WordText(ActXWord,'',Style,[0,1]);
                fig = figure;
                Tbath = unique([[obj.PP.Tbath] [obj.PN.Tbath]]);
                obj.PlotTESData('M',[],Tbath,fig);
                legend(fig.Children,'show','Location','Northeastoutside');
                set(fig.Children,'FontUnits','Normalized');
                set(fig, 'Position', get(0, 'Screensize')); 
                print(fig,'-dmeta');
                invoke(ActXWord.Selection,'Paste');
                close(fig);
                pause(0.3)
                clear fig;
                ActXWord.Selection.TypeParagraph;
                Style='Cita';
                TextString = ['Fig. ' num2str(FigNum) '.  Johnson noise contribution.'];
                WordText(ActXWord,TextString,Style,[0,1]);
                FigNum = FigNum+1;
            end            
            
            
            
            % Falta añadir visualizar el Ruido y las funciones de
            % transferencia en estado normal y superconductor.
            FileSpec = [pwd filesep FileName{1} '.doc'];
            CloseWord(ActXWord,WordHandle,FileSpec);   
            
%             if ~exist(FileSpec,'file')
%                 % Save file as new:
%                 invoke(WordHandle,'SaveAs',FileSpec,1);
%             else
%                 % Save existing file:
%                 invoke(WordHandle,'Save');
%             end
%             % Close the word window:
%             invoke(WordHandle,'Close');
%             % Quit MS Word
%             invoke(ActXWord,'Quit');
%             % Close Word and terminate ActiveX:
%             delete(ActXWord);
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
function [actx_word,word_handle]=StartWord(word_file_p)
    % Start an ActiveX session with Word:
    actx_word = actxserver('Word.Application');
    actx_word.Visible = true;
    trace(actx_word.Visible);  
    if ~exist(word_file_p,'file')
        % Create new document:
        word_handle = invoke(actx_word.Documents,'Add');
    else
        % Open existing document:
        word_handle = invoke(actx_word.Documents,'Open',word_file_p);
    end           
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WordGoTo(actx_word_p,what_p,which_p,count_p,name_p,delete_p)
    %Selection.GoTo(What,Which,Count,Name)
    actx_word_p.Selection.GoTo(what_p,which_p,count_p,name_p);
    if(delete_p)
        actx_word_p.Selection.Delete;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WordCreateTOC(actx_word_p,upper_heading_p,lower_heading_p)
%      With ActiveDocument
%         .TablesOfContents.Add Range:=Selection.Range, RightAlignPageNumbers:= _
%             True, UseHeadingStyles:=True, UpperHeadingLevel:=1, _
%             LowerHeadingLevel:=3, IncludePageNumbers:=True, AddedStyles:="", _
%             UseHyperlinks:=True, HidePageNumbersInWeb:=True, UseOutlineLevels:= _
%             True
%         .TablesOfContents(1).TabLeader = wdTabLeaderDots
%         .TablesOfContents.Format = wdIndexIndent
%     End With
    actx_word_p.ActiveDocument.TablesOfContents.Add(actx_word_p.Selection.Range,1,...
        upper_heading_p,lower_heading_p);
    
    actx_word_p.Selection.TypeParagraph; %enter  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WordText(actx_word_p,text_p,style_p,enters_p,color_p)
	%VB Macro
	%Selection.TypeText Text:="Test!"
	%in Matlab
	%set(word.Selection,'Text','test');
	%this also works
	%word.Selection.TypeText('This is a test');    
    if(enters_p(1))
        actx_word_p.Selection.TypeParagraph; %enter
    end
	actx_word_p.Selection.Style = style_p;
    if(nargin == 5)%check to see if color_p is defined
        actx_word_p.Selection.Font.ColorIndex=color_p;     
    end
    
	actx_word_p.Selection.TypeText(text_p);
    actx_word_p.Selection.Font.ColorIndex='wdAuto';%set back to default color
    for k=1:enters_p(2)    
        actx_word_p.Selection.TypeParagraph; %enter
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WordSymbol(actx_word_p,symbol_int_p)
    % symbol_int_p holds an integer representing a symbol, 
    % the integer can be found in MSWord's insert->symbol window    
    % 176 = degree symbol
    actx_word_p.Selection.InsertSymbol(symbol_int_p);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WordCreateTable(actx_word_p,nr_rows_p,nr_cols_p,data_cell_p,enter_p) 
    %Add a table which auto fits cell's size to contents
    if(enter_p(1))
        actx_word_p.Selection.TypeParagraph; %enter
    end
    %create the table
    %Add = handle Add(handle, handle, int32, int32, Variant(Optional))
    actx_word_p.ActiveDocument.Tables.Add(actx_word_p.Selection.Range,nr_rows_p,nr_cols_p,1,1);
    %Hard-coded optionals                     
    %first 1 same as DefaultTableBehavior:=wdWord9TableBehavior
    %last  1 same as AutoFitBehavior:= wdAutoFitContent
     
    %write the data into the table
    for r=1:nr_rows_p
        for c=1:nr_cols_p
            %write data into current cell
            WordText(actx_word_p,data_cell_p{r,c},'Normal',[0,0]);
            
            if(r*c==nr_rows_p*nr_cols_p)
                %we are done, leave the table
                actx_word_p.Selection.MoveDown;
            else%move on to next cell 
                actx_word_p.Selection.MoveRight;
            end            
        end
    end
    if(enter_p(2))
        actx_word_p.Selection.TypeParagraph; %enter
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WordPageNumbers(actx_word_p,align_p)
    %make sure the window isn't split
    if (~strcmp(actx_word_p.ActiveWindow.View.SplitSpecial,'wdPaneNone')) 
        actx_word_p.Panes(2).Close;
    end
    %make sure we are in printview
    if (strcmp(actx_word_p.ActiveWindow.ActivePane.View.Type,'wdNormalView') | ...
        strcmp(actx_word_p.ActiveWindow.ActivePane.View.Type,'wdOutlineView'))
        actx_word_p.ActiveWindow.ActivePane.View.Type ='wdPrintView';
    end
    %view the headers-footers
    actx_word_p.ActiveWindow.ActivePane.View.SeekView='wdSeekCurrentPageHeader';
    if actx_word_p.Selection.HeaderFooter.IsHeader
        actx_word_p.ActiveWindow.ActivePane.View.SeekView='wdSeekCurrentPageFooter';
    else
        actx_word_p.ActiveWindow.ActivePane.View.SeekView='wdSeekCurrentPageHeader';
    end
    %now add the pagenumbers 0->don't display any pagenumber on first page
     actx_word_p.Selection.HeaderFooter.PageNumbers.Add(align_p,0);
     actx_word_p.ActiveWindow.ActivePane.View.SeekView='wdSeekMainDocument';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PrintMethods(actx_word_p,category_p)
    style='Heading 3';
    text=strcat(category_p,'-methods');
    WordText(actx_word_p,text,style,[1,1]);           
    
    style='Normal';    
    text=strcat('Methods called from Matlab as: ActXWord.',category_p,'.MethodName(xxx)');
    WordText(actx_word_p,text,style,[0,0]);           
    text='Ignore the first parameter "handle". ';
    WordText(actx_word_p,text,style,[1,3]);           
    
    MethodsStruct=eval(['invoke(actx_word_p.' category_p ')']);
    MethodsCell=struct2cell(MethodsStruct);
    NrOfFcns=length(MethodsCell);
    for i=1:NrOfFcns
        MethodString=MethodsCell{i};
        WordText(actx_word_p,MethodString,style,[0,1]);           
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FigureIntoWord(actx_word_p)
	% Capture current figure/model into clipboard:
	print -dmeta
	% Find end of document and make it the insertion point:
	end_of_doc = get(actx_word_p.activedocument.content,'end');
	set(actx_word_p.application.selection,'Start',end_of_doc);
	set(actx_word_p.application.selection,'End',end_of_doc);
	% Paste the contents of the Clipboard:
    %also works Paste(ActXWord.Selection)
	invoke(actx_word_p.Selection,'Paste');
    actx_word_p.Selection.TypeParagraph; %enter    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CloseWord(actx_word_p,word_handle_p,word_file_p)
    if ~exist(word_file_p,'file')
        % Save file as new:
        invoke(word_handle_p,'SaveAs',word_file_p,1);
    else
        % Save existing file:
        invoke(word_handle_p,'Save');
    end
    % Close the word window:
    invoke(word_handle_p,'Close');            
    % Quit MS Word
    invoke(actx_word_p,'Quit');            
    % Close Word and terminate ActiveX:
    delete(actx_word_p);            
end