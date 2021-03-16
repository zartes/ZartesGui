classdef TES_PvTModel
    % Class TF for TES data
    %   This class contains options for Z(W) analysis
    
    properties              
        Models = {'G0nT_fit_direct';'KnT_fit_direct';'KnP0_direct';'KnP0Ic0_direct';'ABT_fit_direct';'Kn_direct'}; % One Single Thermal Block, Two Thermal Blocks
        Selected_Models = 1;
        
        Function = [];
        Description = [];
        X0 = [];%%%initial values
        LB = [];%%%lower bounds
        UB = [];%%%upper bounds
        rtesLB = 0.05;
        rtesUB = 0.9;
        ptesThrs = 0.001;
        PvsV_Thrs = 5;  % Mirar mejor qué sentido tiene este valor
        PvsR_Thrs = 3;  % Mirar mejor qué sentido tiene este valor  
                
    end
    
    methods
        
        function obj = Constructor(obj)
            switch obj.Models{obj.Selected_Models}
                case obj.Models{1}
                    obj.Function = @(p,T)(p(1)*(p(3).^p(2)-T.^p(2))./(p(2).*p(3).^(p(2)-1)));
                    obj.Description = 'p(1)=G0 p(2)=n p(3)=T_fit';          % 3 parameters
                    obj.X0 = [100 3 0.1];
                    obj.LB = [0 2 0];%%%lower bounds
                    obj.UB = [];
                case obj.Models{2}
                    obj.Function = @(p,T)(p(1)*(p(3).^p(2)-T.^p(2)));
                    obj.Description = 'p(1)=K p(2)=n p(3)=T_fit';
                    obj.X0 = [50 3 0.1];
                    obj.LB = [0 2 0];%%%lower bounds
                    obj.UB = [];
                case obj.Models{3}
                    obj.Function = @(p,T)(p(1)*T.^p(2)+p(3));
                    obj.Description = 'p(1)=-K p(2)=n p(3)=P0=k*T_fit^n';
                    obj.X0 = [-50 3 1];
                    obj.LB = [-Inf 2 0];%%%lower bounds
                    obj.UB = [];
                case obj.Models{4}
                    obj.Function = @(p,T)(p(1)*T(1,:).^p(2)+p(3)*(1-T(2,:)/p(4)).^(2*p(2)/3));
                    obj.Description = 'p(1)=-K, p(2)=n, p(3)=P0=K*T_fit^n, p(4)=Ic0';
                    obj.X0 = [-6500 3.03 13 1.9e4];
                    obj.LB = [-1e5 2 0 0];
                    obj.UB = [];
                case obj.Models{5}
                    obj.Function = @(p,T)(p(1)*(p(3)^2-T.^2)+p(2)*(p(3)^4-T.^4));
                    obj.Description = 'p(1)=A, p(2)=B, p(3)=T_fit';
                    obj.X0 = [1 1 0.1];
                    obj.LB = [0 0 0];
                    obj.UB = [];
                case obj.Models{6}
                    obj.Function = @(p,T,T_fit)(p(1)*(T_fit.^p(2)-T.^p(2))./(p(2).*T_fit.^(p(2)-1)));
                    obj.Description = 'p(1)=K p(2)=n';      
                    obj.X0 = [50 3];
                    obj.LB = [0 2];%%%lower bounds
                    obj.UB = [];
            end
        end
        
        function obj = View(obj)
            % Function to check visually the class values
            
            h = figure('Visible','off','Tag','TES_PvTModel');
            waitfor(Conf_Setup(h,[],obj));
            TF_Opt = guidata(h);
            if ~isempty(TF_Opt)
                obj = obj.Update(TF_Opt);
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
        
        function obj = BuildPTbModel(obj)
            
            switch obj.Models{obj.Selected_Models}
                case obj.Models{1}
                    obj.Function = @(p,T)(p(1)*(p(3).^p(2)-T.^p(2))./(p(2).*p(3).^(p(2)-1)));
                    obj.Description = 'p(1)=G0 p(2)=n p(3)=T_fit';          % 3 parameters
                    obj.X0 = [100 3 0.1];
                    obj.LB = [0 2 0];%%%lower bounds
                    obj.UB = [];
                case obj.Models{2}
                    obj.Function = @(p,T)(p(1)*(p(3).^p(2)-T.^p(2)));
                    obj.Description = 'p(1)=K p(2)=n p(3)=T_fit';
                    obj.X0 = [50 3 0.1];
                    obj.LB = [0 2 0];%%%lower bounds
                    obj.UB = [];
                case obj.Models{3}
                    obj.Function = @(p,T)(p(1)*T.^p(2)+p(3));
                    obj.Description = 'p(1)=-K p(2)=n p(3)=P0=k*T_fit^n';
                    obj.X0 = [-50 3 1];
                    obj.LB = [-Inf 2 0];%%%lower bounds
                    obj.UB = [];
                case obj.Models{4}
                    obj.Function = @(p,T)(p(1)*T(1,:).^p(2)+p(3)*(1-T(2,:)/p(4)).^(2*p(2)/3));
                    obj.Description = 'p(1)=-K, p(2)=n, p(3)=P0=K*T_fit^n, p(4)=Ic0';
                    obj.X0 = [-6500 3.03 13 1.9e4];
                    obj.LB = [-1e5 2 0 0];
                    obj.UB = [];
                case obj.Models{5}
                    obj.Function = @(p,T)(p(1)*(p(3)^2-T.^2)+p(2)*(p(3)^4-T.^4));
                    obj.Description = 'p(1)=A, p(2)=B, p(3)=T_fit';
                    obj.X0 = [1 1 0.1];
                    obj.LB = [0 0 0];
                    obj.UB = [];
                case obj.Models{6}
                    obj.Function = @(p,T,T_fit)(p(1)*(T_fit.^p(2)-T.^p(2))./(p(2).*T_fit.^(p(2)-1)));
                    obj.Description = 'p(1)=K p(2)=n';
                    obj.X0 = [50 3];
                    obj.LB = [0 2];%%%lower bounds
                    obj.UB = [];
            end                                    
        end
        
        function [obj, Gset] = FittingOption(obj,IVset,fig)
            obj = obj.BuildPTbModel;
            Gset = [];
            Gset = TES_Gset;
            Gset = Gset.Constructor;
                    
            perc = [];
            if ~IVset.Filled
                return;
            end
            
            str = {'Ptes vs Vtes'; 'Ptes vs Rtes';'Minimum I-V curve transition'; 'Range %Rn'};
            [s,OK] = listdlg('PromptString','Fitting based on?',...
                'SelectionMode','single',...
                'ListString',str);
            if OK
                ButtonName = str{s};
            else
                return;
            end
            
                        
            switch ButtonName
                
                case 'Range %Rn'
                    if ~exist('fig','var')
                        fig = figure;
                    else
                        figure(fig);
                    end
                    if strcmp(IVset(1).range,'PosIbias')
                        k = 1;
                    else
                        k = 2;
                    end                    
                    if isempty(perc)
                        j = 1;
                        for i = 1:size(IVset,2)
                            if IVset(i).good
                                
                                diffptes = abs(diff(IVset(i).ptes));
                                x = IVset(i).rtes;
                                indx = find(IVset(i).rtes > obj.rtesLB);
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
                        name = '%Rn range to fit P vs. Tbath data (Suggested values)';
                        numlines = [1 70];
                        defaultanswer = {[num2str(minrange) ':0.01:' num2str(maxrange)]};
                        answer = inputdlg(prompt,name,numlines,defaultanswer);
                        if ~isempty(answer)
                            eval('perc = eval(answer{1});');
                            if ~isnumeric(perc)
                                warndlg('Invalid %Rn values',IVset.version);
                                return;
                            end
                        else
                            warndlg('Invalid %Rn values',IVset.version);
                            return;
                        end
                    else
                        perc = perc{k};
                    end
                    
                    ax = subplot(1,2,k,'Visible','off');
                    title(ax,IVset(1).range);
                    hold(ax,'on');
                    grid(ax,'on');
                                                            
                    c = distinguishable_colors(length(perc));
                    wb = waitbar(0,'Please wait...');
                    for jj = 1:length(perc)
                        Paux = [];
                        Iaux = [];
                        Tbath = [];
                        kj = 1;
                        clear SetIbias;
                        SetIbias{1} = [];
                        for i = 1:length(IVset)
                            if IVset(i).good
                                ind = find(IVset(i).rtes > obj.rtesLB & IVset(i).rtes < obj.rtesUB & IVset(i).ptes > 0);%%%algunas IVs fallan.
                                if isempty(ind)
                                    continue;
                                end
                                clear rtes ptes ites
                                rtes = IVset(i).rtes(ind);
                                ptes = IVset(i).ptes(ind);
                                ites = IVset(i).ites(ind);
                                [rtes,IA,~] = unique(rtes,'stable');
                                ptes = ptes(IA);
                                ites = ites(IA);
                                Paux{jj}(kj) = ppval(spline(rtes,ptes),perc(jj)); %#ok<AGROW>
                                Iaux{jj}(kj) = ppval(spline(rtes,ites),perc(jj));%#ok<AGROW> %%%
                                Tbath{jj}(kj) = IVset(i).Tbath; %#ok<AGROW>
                                kj = kj+1;
                                SetIbias = [SetIbias; {IVset(i).file}];
                            else
                                Paux{jj}(kj) = nan;
                                Iaux{jj}(kj) = nan;
                                Tbath{jj}(kj) = nan;
                            end
                        end
                        Paux{jj}(isnan(Paux{jj})) = [];
                        Iaux{jj}(isnan(Iaux{jj})) = [];
                        Tbath{jj}(isnan(Tbath{jj})) = [];
                        
                        
                        XDATA = Tbath{jj};
                        if strcmp(obj.Models{obj.Selected_Models},'KnP0Ic0_direct')
                            XDATA = [Tbath{jj};Iaux{jj}*1e6];
                        end
                        opts = optimset('Display','off');
                       
                        fitfun = @(x,y)obj.fitP(x,y);
                        [fit,~,aux2,~,~,~,auxJ] = lsqcurvefit(fitfun,obj.X0,XDATA,Paux{jj}*1e12,...
                            obj.LB,obj.UB,opts);                        
                        ci = nlparci(fit,aux2,'jacobian',auxJ); %%%confidence intervals.
                        
                        CI = diff(ci');
                        fit_CI = [fit; CI];
                        Gaux(jj) = obj.GetGfromFit(fit_CI');%#ok<AGROW,
                        ERP = sum(abs(abs(Paux{jj}*1e12-obj.fitP(fit,XDATA))./abs(Paux{jj}*1e12)))/length(Paux{jj}*1e12);
                        R2 = goodnessOfFit(obj.fitP(fit,XDATA)', Paux{jj}'*1e12,'NRMSE');
                        
                        Gset(jj).rp = perc(jj);
                        Gset(jj).model = obj.Description;
                        Gset(jj).n = Gaux(jj).n;
                        Gset(jj).n_CI = Gaux(jj).n_CI;
                        Gset(jj).K = Gaux(jj).K*1e-12;
                        Gset(jj).K_CI = Gaux(jj).K_CI*1e-12;
                        Gset(jj).T_fit = Gaux(jj).T_fit;
                        Gset(jj).T_fit_CI = Gaux(jj).T_fit_CI;
                        Gset(jj).G = Gaux(jj).G*1e-12;
                        Gset(jj).G_CI = Gaux(jj).G_CI*1e-12;
                        Gset(jj).G100 = Gaux(jj).G100*1e-12;
                        Gset(jj).ERP = ERP;
                        Gset(jj).R2 = R2;
                        Gset(jj).Tbath = Tbath{jj};
                        Gset(jj).Paux = Paux{jj}*1e12;
                        Gset(jj).Paux_fit = obj.fitP(fit,XDATA);
                        Gset(jj).opt = ButtonName;
                        
                        if obj.Selected_Models == 1
                            
                            DefaultModel = TES_PvTModel;
                            DefaultModel.Selected_Models = 2;
                            DefaultModel = DefaultModel.BuildPTbModel;
                            XDATA = Tbath{jj};
                            opts = optimset('Display','off');
                            fitfun = @(x,y)DefaultModel.fitP(x,y);
                            [fit2,~,aux2,~,~,~,auxJ] = lsqcurvefit(fitfun,DefaultModel.X0,XDATA,Paux{jj}*1e12,...
                                DefaultModel.LB,DefaultModel.UB,opts);
                            ci = nlparci(fit2,aux2,'jacobian',auxJ); %%%confidence intervals.
                            
                            CI = diff(ci');
                            fit_CI = [fit2; CI];
                            Gaux2(jj) = DefaultModel.GetGfromFit(fit_CI');%#ok<AGROW,
                            
                            Gset(jj).K = Gaux2(jj).K*1e-12;
                            Gset(jj).K_CI = Gaux2(jj).K_CI*1e-12;
                        end
                        
                        plot(ax,Tbath{jj},obj.fitP(fit,XDATA),'LineStyle','-','Color',c(jj,:),...
                            'LineWidth',1,'DisplayName',IVset(i).file,...
                            'ButtonDownFcn',{@Identify_Origin_PT},'UserData',{k;jj;i;obj},'Visible','off');
                        plot(ax,Tbath{jj},Paux{jj}*1e12,'Marker','o','MarkerFaceColor',c(jj,:),...
                            'MarkerEdgeColor',c(jj,:),'DisplayName',['Rn(%): ' num2str(perc(jj))],...
                            'ButtonDownFcn',{@Identify_Origin_PT},'UserData',SetIbias,'LineStyle','none','Visible','off')
                      
                        if ishandle(wb)
                            waitbar(jj/length(perc),wb,['Fit P vs. T in progress: ' IVset(1).range]);
                        end
                    end
                    if ishandle(wb)
                        delete(wb);
                    end
                    xlabel(ax,'T_{bath}(K)','FontSize',12,'FontWeight','bold')
                    ylabel(ax,'P_{TES}(pW)','FontSize',12,'FontWeight','bold')
                    set(ax,'FontSize',12,'LineWidth',2,'FontWeight','bold',...
                        'Box','on','FontUnits','Normalized');                    
                    
                    haxes = findobj('Type','Axes');
                    hline = findobj('Type','Line');
                    set([haxes;hline],'Visible','on');

                otherwise
                                        
                    if ~exist('fig','var')
                        fig = figure;
                    else
                        figure(fig);
                    end
                    if strcmp(IVset(1).range,'PosIbias')
                        k = 1;
                    else
                        k = 2;
                    end
                    if k == 1
                        axInd = [1 3];
                    else
                        axInd = [2 4];
                    end
                    ax(axInd(1),1) = subplot(2,2,axInd(1),'Visible','off');
                    ax(axInd(2),2) = subplot(2,2,axInd(2),'Visible','off');
                    
                    title(ax(axInd(1),1),IVset(1).range);
                    hold(ax(axInd(1),1),'on');
                    hold(ax(axInd(2),2),'on');      
                    grid(ax(axInd(1),1),'on');
                    grid(ax(axInd(2),2),'on');    
                    
                    
                    c = distinguishable_colors(length(IVset));
                    kj = 1;
                    clear SetIbias;
                    SetIbias{1} = [];
                    
                    for i = 1:length(IVset)
                        if ~IVset(i).good
                            continue;
                        end
                        SetIbias = [SetIbias; {IVset(i).file}];
                        fileName = IVset(i).file;
                        fileName(strfind(fileName,'_')) = '';
                        
                        dptes = diff(IVset(i).ptes*1e12);
                        dvtes = diff(IVset(i).vtes*1e6);
                        drtes = diff(IVset(i).rtes);
                        
                        switch ButtonName
                            case 'Ptes vs Vtes'
                                
                                indP = find(abs(dptes./dvtes) < obj.PvsV_Thrs, 1 );
                                if isempty(indP)
                                    continue;
                                end
                                if IVset(i).rtes(indP) > 1 || IVset(i).rtes(indP) < 0
                                    continue;
                                else
                                    perc(i) = IVset(i).rtes(indP);
                                end
                                plot(ax(axInd(1),1),IVset(i).vtes*1e6,IVset(i).ptes*1e12,'.-','Color',c(i,:),'Visible','off','DisplayName',fileName);
                                plot(ax(axInd(1),1),IVset(i).vtes(indP)*1e6,IVset(i).ptes(indP)*1e12,'Marker','o','MarkerEdgeColor','b','Visible',...
                                    'off','DisplayName',['%Rn: ' num2str(perc(i))]);
                                xlabel(ax(axInd(1),1),'V_{TES}(\muV)','FontWeight','bold');
                                ylabel(ax(axInd(1),1),'Ptes(pW)','FontWeight','bold');
                            case 'Ptes vs Rtes'
                                
                                indP = find(abs(dptes./drtes) < obj.PvsR_Thrs, 1 );
                                if isempty(indP)
                                    continue;
                                end
                                if IVset(i).rtes(indP) > 1 || IVset(i).rtes(indP) < 0
                                    continue;
                                else
                                    perc(i) = IVset(i).rtes(indP);
                                end
                                plot(ax(axInd(1),1),IVset(i).rtes,IVset(i).ptes*1e12,'.-','Color',c(i,:),'Visible','off','DisplayName',fileName);
                                plot(ax(axInd(1),1),IVset(i).rtes(indP),IVset(i).ptes(indP)*1e12,'Marker','o','MarkerEdgeColor','b','Visible',...
                                    'off','DisplayName',['%Rn: ' num2str(perc(i))]);
                                xlabel(ax(axInd(1),1),'R_{TES}/R_n','FontWeight','bold');
                                ylabel(ax(axInd(1),1),'Ptes(pW)','FontWeight','bold');
                                
                            case 'Minimum I-V curve transition'
                                                               
                                [~,i3] = min(diff(IVset(i).vout)./diff(IVset(i).ibias));
                                [~, indP] = min(abs(IVset(i).vout(1:i3)));
                                if isempty(indP)
                                    continue;
                                end
                                if IVset(i).rtes(indP) > 1 || IVset(i).rtes(indP) < 0
                                    continue;
                                else
                                    perc(i) = IVset(i).rtes(indP);
                                end
                                plot(ax(axInd(1),1),IVset(i).ibias*1e6,IVset(i).vout,'.-','Color',c(i,:),'Visible','off','DisplayName',fileName);
                                plot(ax(axInd(1),1),IVset(i).ibias(indP)*1e6,IVset(i).vout(indP),'Marker','o','MarkerEdgeColor','b','Visible',...
                                    'off','DisplayName',['%Rn: ' num2str(perc(i))]);
                                xlabel(ax(axInd(1),1),'I_{bias}(\muA)','FontWeight','bold');
                                ylabel(ax(axInd(1),1),'Vout(V)','FontWeight','bold');
                                
                            otherwise
                                return;
                        end
                        
                        
                        ind = find(IVset(i).rtes > obj.rtesLB & IVset(i).rtes < obj.rtesUB);%%%algunas IVs fallan.
                        if isempty(ind)
                            continue;
                        end                                                                                                
                        
                        Paux(kj) = ppval(spline(IVset(i).rtes(ind),IVset(i).ptes(ind)),perc(i)); %#ok<AGROW>
                        Iaux(kj) = ppval(spline(IVset(i).rtes(ind),IVset(i).ites(ind)),perc(i));
                        Tbath(kj) = IVset(i).Tbath; %#ok<AGROW>
                        kj = kj+1;
                                                                                                
                    end
                    
                    XDATA = Tbath;
                    if strcmp(obj.Models{obj.Selected_Models},'KnP0Ic0_direct')
                        XDATA = [Tbath;Iaux*1e6];
                    end
                    opts = optimset('Display','off');
                    
                    fitfun = @(x,y)obj.fitP(x,y);
                    [fit,~,aux2,~,~,~,auxJ] = lsqcurvefit(fitfun,obj.X0,XDATA,Paux*1e12,obj.LB,obj.UB,opts);
                    ci = nlparci(fit,aux2,'jacobian',auxJ); %%%confidence intervals.
                    
                    CI = diff(ci');
                    fit_CI = [fit; CI];
                    Gaux = obj.GetGfromFit(fit_CI');
                    ERP = sum(abs(abs(Paux*1e12-obj.fitP(fit,XDATA))./abs(Paux*1e12)))/length(Paux*1e12);
                    R2 = goodnessOfFit(obj.fitP(fit,XDATA)', Paux'*1e12,'NRMSE');
                    
                    Gset.rp = perc;
                    Gset.model = obj.Description;
                    Gset.n = Gaux.n;
                    Gset.n_CI = Gaux.n_CI;
                    Gset.K = Gaux.K*1e-12;
                    Gset.K_CI = Gaux.K_CI*1e-12;
                    Gset.T_fit = Gaux.T_fit;
                    Gset.T_fit_CI = Gaux.T_fit_CI;
                    Gset.G = Gaux.G*1e-12;
                    Gset.G_CI = Gaux.G_CI*1e-12;
                    Gset.G100 = Gaux.G100*1e-12;
                    Gset.ERP = ERP;
                    Gset.R2 = R2;
                    Gset.Tbath = Tbath;
                    Gset.Paux = Paux*1e12;
                    Gset.Paux_fit = obj.fitP(fit,XDATA);
                    Gset.opt = ButtonName;
                    
                    
                    plot(ax(axInd(2),2),Tbath,obj.fitP(fit,XDATA),'LineStyle','-',...
                        'Color',c(1,:),'LineWidth',2,'DisplayName',' ',...
                        'ButtonDownFcn',{@Identify_Origin_PT},'UserData',{k;1;i;obj},'Visible','off');
                    
                    plot(ax(axInd(2),2),Tbath,Paux*1e12,'Marker','o',...
                        'MarkerFaceColor',c(1,:),'MarkerEdgeColor',c(1,:),...
                        'DisplayName',['Rn(%): ' num2str(mean(perc)) '+-' num2str(std(perc))],...
                        'ButtonDownFcn',{@Identify_Origin_PT},'UserData',SetIbias,'LineStyle','none','Visible','off')
                    xlabel(ax(axInd(2),2),'T_{bath}(K)','FontSize',12,'FontWeight','bold')
                    ylabel(ax(axInd(2),2),'P_{TES}(pW)','FontSize',12,'FontWeight','bold')
                    
                    set([ax(axInd(1),1) ax(axInd(2),2)],'FontSize',12,'LineWidth',2,'FontWeight','bold','Box','on','FontUnits','Normalized');
                    axis([ax(axInd(1),1) ax(axInd(2),2)],'tight');
                    
                    haxes = findobj('Type','Axes');
                    hline = findobj('Type','Line');
                    set([haxes;hline],'Visible','on');
                    
            end
                
        end                        
        
        
        function P = fitP(obj,p,T,T_fit)
            % Function to fit P(Tbath) data.
            
            
            switch obj.Models{obj.Selected_Models}
                case obj.Models{6}
                    f = obj.Function;
                    P = f(p,T,T_fit);
                otherwise
                    P = obj.Function(p,T);
            end
        end
        
        function param = GetGfromFit(obj,fit)
            % Function to get thermal parameters from fitting
            
            switch obj.Models{obj.Selected_Models}
                case obj.Models{1}
                    param.n = fit(2,1);
                    param.n_CI = fit(2,2);
                    param.T_fit = fit(3,1);
                    param.T_fit_CI = fit(3,2);
                    param.G = fit(1,1);
                    param.G_CI = fit(1,2);
                    param.K = param.G/(param.n*param.T_fit.^(param.n-1));
                    param.K_CI = sqrt( ((param.T_fit^(1 - param.n)/param.n)*param.G_CI)^2 + ...
                        ((-(param.G*(param.n - 1))/(param.T_fit^param.n*param.n))*param.T_fit_CI)^2 + ...
                        ((- (param.G*param.T_fit^(1 - param.n))/param.n^2 - (param.G*param.T_fit^(1 - param.n)*log(param.T_fit))/param.n)*param.n_CI)^2); % To be computed
                    
                    param.G0 = param.G;
                    param.G100 = param.n*param.K*0.1^(param.n-1);
%                     if isfield(model,'ci')
%                         param.Errn = model.ci(2,2)-model.ci(2,1);
%                         param.ErrG = model.ci(1,2)-model.ci(1,1);
%                         param.ErrT_fit = model.ci(3,2)-model.ci(3,1);
%                     end
                case obj.Models{2}
                    param.n = fit(2,1);
                    param.n_CI = fit(2,2);
                    param.K = fit(1);
                    param.K_CI = fit(1,2);
                    param.T_fit = fit(3,1);
                    param.T_fit_CI = fit(3,2);
                    param.G = param.n*param.K*param.T_fit^(param.n-1);
                    param.G_CI = sqrt( ((param.K*param.T_fit^(param.n - 1) + param.K*param.T_fit^(param.n - 1)*param.n*log(param.T_fit))*param.n_CI)^2 ...
                        + ((param.n*param.T_fit^(param.n - 1))*param.K_CI)^2 ...
                        + ((param.n*param.K*param.T_fit^(param.n - 2)*(param.n - 1))*param.T_fit_CI)^2 );
                    param.G0 = param.G;
                    param.G100 = param.n*param.K*0.1^(param.n-1);
%                     if isfield(model,'ci')
%                         param.Errn = model.ci(2,2)-model.ci(2,1);
%                         param.ErrK = model.ci(1,2)-model.ci(1,1);
%                         param.ErrT_fit = model.ci(3,2)-model.ci(3,1);
%                     end
                    
                case obj.Models{3}
                    param.n = fit(2,1);
                    param.n_CI = fit(2,2);
                    param.K = -fit(1,1);
                    param.K_CI = abs(fit(1,2));
                    param.P0 = fit(3,1);
                    param.P0_CI = fit(3,2);
                    
                    param.T_fit = (param.P0/param.K)^(1/param.n);
                    param.T_fit_CI = sqrt( (((param.P0*(-param.P0/param.K)^(1/param.n - 1))/(param.K^2*param.n))*param.K_CI)^2 ...
                        + ((-(log(-param.P0/param.K)*(-param.P0/param.K)^(1/param.n))/param.n^2)*param.n_CI)^2 ...
                        + ((-(-param.P0/param.K)^(1/param.n - 1)/(param.K*param.n))*param.P0_CI)^2);
                    
                    param.G = param.n*param.K*param.T_fit^(param.n-1);
                    param.G_CI = sqrt( ((param.K*param.T_fit^(param.n - 1) + param.K*param.T_fit^(param.n - 1)*param.n*log(param.T_fit))*param.n_CI)^2 ...
                        + ((param.n*param.T_fit^(param.n - 1))*param.K_CI)^2 ...
                        + ((param.n*param.K*param.T_fit^(param.n - 2)*(param.n - 1))*param.T_fit_CI)^2 );
                    
                    param.G0 = param.G;
                    param.G100 = param.n*param.K*0.1^(param.n-1);
%                     if isfield(model,'ci')
%                         param.Errn = model.ci(2,2)-model.ci(2,1);
%                         param.ErrK = model.ci(1,2)-model.ci(1,1);
%                     end
%                     
                case obj.Models{4}
                    param.n = fit(2,1);
                    param.n_CI = fit(2,2);
                    param.K = -fit(1,1);
                    param.K_CI = fit(1,2);
                    param.P0 = fit(3,1);
                    param.P0_CI = fit(3,2);
                    
                    param.T_fit = (param.P0/param.K)^(1/param.n);
                    param.T_fit_CI = sqrt( (((param.P0*(-param.P0/param.K)^(1/param.n - 1))/(param.K^2*param.n))*param.K_CI)^2 ...
                        + ((-(log(-param.P0/param.K)*(-param.P0/param.K)^(1/param.n))/param.n^2)*param.n_CI)^2 ...
                        + ((-(-param.P0/param.K)^(1/param.n - 1)/(param.K*param.n))*param.P0_CI)^2);
                    
                    param.Ic = fit(4,1);
                    param.Ic_CI = fit(4,2);
                    %param.Pnoise=fit(5);%%%efecto de posible fuente extra de ruido.
                    param.G = param.n*param.K*param.T_fit^(param.n-1);
                    param.G_CI = sqrt( ((param.K*param.T_fit^(param.n - 1) + param.K*param.T_fit^(param.n - 1)*param.n*log(param.T_fit))*param.n_CI)^2 ...
                        + ((param.n*param.T_fit^(param.n - 1))*param.K_CI)^2 ...
                        + ((param.n*param.K*param.T_fit^(param.n - 2)*(param.n - 1))*param.T_fit_CI)^2 );
                    
                    param.G0 = param.G;
                    param.G100 = param.n*param.K*0.1^(param.n-1);
                    
                case obj.Models{5}
                    param.A = fit(1,1);
                    param.A_CI = fit(1,2);
                    param.B = fit(2,1);
                    param.B_CI = fit(2,2);
                    param.T_fit = fit(3,1);
                    param.T_fit_CI = fit(3,2);
                    param.G = 2*param.T_fit.*(param.A+2*param.B*param.T_fit.^2);
                    param.G_CI = sqrt( ((12*param.B*param.T_fit^2 + 2*param.A)*param.T_fit_CI)^2 + ...
                        ((2*param.T_fit)*param.A_CI)^2 + ...
                        ((4*param.T_fit^3)*param.B_CI)^2 );  %To be computed
                    param.G0 = param.G;
                    param.G_100 = 2*0.1.*(param.A+2*param.B*0.1.^2);
                    
                case obj.Models{6}                    
                    param.n = fit(2,1);
                    param.n_CI = fit(2,2);
                    param.K = fit(1,1);
                    param.K_CI = fit(1,2);
                    param.T_fit = obj.TESP.T_fit;
                    param.T_fit_CI = 0;
                    param.G = param.n*param.K*param.T_fit^(param.n-1);
                    param.G_CI = sqrt( ((param.K*param.T_fit^(param.n - 1) + param.K*param.T_fit^(param.n - 1)*param.n*log(param.T_fit))*param.n_CI)^2 ...
                        + ((param.n*param.T_fit^(param.n - 1))*param.K_CI)^2 ...
                        + ((param.n*param.K*param.T_fit^(param.n - 2)*(param.n - 1))*param.T_fit_CI)^2 );
                    param.G0 = param.G;
                    param.G100 = param.n*param.K*0.1^(param.n-1);
                    
            end
            
        end
        
        
    end
end