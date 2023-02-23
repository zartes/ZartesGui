function Identify_Origin(src,evnt)
% Auxiliary function to handle right-click mouse options of TF-Noise_Viewer
% Last update: 14/11/2018

if evnt.Button == 3
    
    Data = src.UserData;
    try
        P = Data{1};
    catch
        return;
    end
    N_meas = Data{2};
    P_Rango = Data{3};
    Circuit = Data{4};
    try
        param = Data{5};
        Action = Data{6};
    catch
        param = [];
    end
    
    % En la gráfica los datos están ordenados de menor a mayor
%     [XData, jj] = sort([P(N_meas).p.rp]);
    XData = [P(N_meas).p.rp];
    jj = 1:length(XData);
    x_click = evnt.IntersectionPoint(1);
    [val,ind] = min((abs(XData-x_click)));
    ind_orig = ind;
    hps = findobj(src.Parent.Parent,'Type','Axes');
    if isempty(param)
%         hps = findobj(src.Parent.Parent,'Type','Axes');
        StrParam = {'bi';'ai';'taueff*1e6';'C*1e15'};
        for i = 1:length(hps)
            hp(i) = plot(hps(i),XData(ind_orig),eval(['P(N_meas).p(jj(ind_orig)).' StrParam{i}]),'.',...
                'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[1 0 0],'markersize',15);
            set(get(get(hp(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        end
    else
        for i = 1:length(hps)
            if strcmp(param,'C')||strcmp(param,'C_CI')
                multStr = '1e15';
            elseif strcmp(param,'taueff')||strcmp(param,'taueff_CI')
                multStr = '1e6';
            else 
                multStr = '1';
            end
            hp(i) = plot(hps(i),XData(ind_orig),eval(['P(N_meas).p(jj(ind_orig)).' param '*' multStr]),'.',...
                'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[1 0 0],'markersize',15);
            set(get(get(hp(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        end
    end
    
    % Identificar el subplot
    Parent = src.Parent;
    Ylabel = Parent.YLabel.String;
    
    try
    FileStr = P(N_meas).fileZ{jj(ind_orig)};
    FileStrLabel = ['..\Z(w)-' FileStr(strfind(FileStr,'TF'):end)];
    data{1} = P(N_meas).ztes{jj(ind_orig)};
    data{2} = P(N_meas).fZ{jj(ind_orig)};
    data{3} = P(N_meas).fileNoise{jj(ind_orig)};
    data{4} = P(N_meas).fNoise{jj(ind_orig)};
    data{5} = P(N_meas).SigNoise{jj(ind_orig)};
    data{6} = Circuit;
        
    catch
        FileStrLabel = [];
        data = [];
        delete(hp);
        return;
    end
    param = fieldnames(P(N_meas).p);
    
    
    TFParam = {['Tbath: ' num2str(P(N_meas).Tbath*1e3) 'mK'];...
        ['Residuo: ' num2str(P(N_meas).residuo(jj(ind_orig)))];...        
        ['R2: ' num2str(P(N_meas).R2{jj(ind_orig)})]};
    for i = 1:length(param)-4
        TFParam = [TFParam; {[param{i} ': ' num2str(eval(['P(N_meas).p(jj(ind_orig)).' param{i}]))]}];
    end
    
    
    
    
    
    %% Añadir que se muestren todos los ruidos de la temperatura escogida
    
    cmenu = uicontextmenu('Visible','on');
    if ~isempty(data)
        c1 = uimenu(cmenu,'Label',FileStrLabel);
        c2(1) = uimenu(c1,'Label','Z(w)-Noise Plots','Callback',...
            {@ActionFcn},'UserData',data);
    end
    c2(2) = uimenu(c1,'Label','TF parameter analysis');
    for i = 1:length(TFParam)
        c3(i) = uimenu(c2(2),'Label',TFParam{i});
    end
    
    try
        NoiseParam = {['ExRes: ' num2str(P(N_meas).p(jj(ind_orig)).ExRes)];...
            ['ThRes: ' num2str(P(N_meas).p(jj(ind_orig)).ThRes)]; ['M: ' num2str(P(N_meas).p(jj(ind_orig)).M)];...
            ['Mph: ' num2str(P(N_meas).p(jj(ind_orig)).Mph)]};
        c2(3) = uimenu(c1,'Label','Noise parameter analysis');
        for i = 1:length(NoiseParam)
            c4(i) = uimenu(c2(3),'Label',NoiseParam{i});
        end
    catch
    end
    if ~isempty(data)
        if P(N_meas).Filtered{jj(ind_orig)} == 0
            c2(4) = uimenu(c1,'Label','Filter out','Callback',...
                {@ActionFcn},'UserData',{Data; jj(ind_orig); P_Rango});
        else
            c2(4) = uimenu(c1,'Label','Unfilter','Callback',...
                {@ActionFcn},'UserData',{Data; jj(ind_orig); P_Rango});
        end
    end
    
    c2(5) = uimenu(c1,'Label','Change color','Callback',...
        {@ActionFcn},'UserData',{Data; jj(ind_orig); P_Rango;evnt.Source.DisplayName});
    
    
    set(src,'uicontextmenu',cmenu);
    waitfor(cmenu,'Visible','off')
    delete(hp);
end


function ActionFcn(src,evnt)

File = src.Parent.Label;
Data = get(src,'UserData');
str = get(src,'Label');
inds = find(File == filesep, 1, 'last' );
wdir1 = File(1:inds);
filesZ = File(inds+1:end);
filesZ(filesZ == '_') = ' ';
switch str
    case 'Z(w)-Noise Plots'
        
        fig = figure('Name',['Z(w)-Noise Plots: ' wdir1],'Visible','off');
        ax(1) = subplot(1,2,1);
        plot(ax(1),1e3*Data{1},'.','color',[0 0.447 0.741],...
            'markerfacecolor',[0 0.447 0.741],'markersize',15);
        grid(ax(1),'on');
        hold(ax(1),'on');%%% Paso marker de 'o' a '.'
        set(ax(1),'linewidth',2,'fontsize',12,'fontweight','bold');
        xlabel(ax(1),'Re(mZ)','fontsize',12,'fontweight','bold');
        ylabel(ax(1),'Im(mZ)','fontsize',12,'fontweight','bold');%title('Ztes with fits (red)');
        title(ax(1),filesZ);
        plot(ax(1),1e3*Data{2}(:,1),1e3*Data{2}(:,2),'r','linewidth',2);
        
        inds = find(Data{3} == filesep, 1, 'last' );
        filesNoise = Data{3}(inds+1:end);
        file{1} = filesNoise;
        ax(2) = subplot(1,2,2);
        
        loglog(ax(2),Data{4}(:,1),Data{5}(:,1),'.-r'),%%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
        hold(ax(2),'on'),grid(ax(2),'on')
        loglog(ax(2),Data{4}(:,1),medfilt1(Data{5}(:,1),20),'.-k'),hold(ax(2),'on'),grid(ax(2),'on')
        set(ax(2),'linewidth',2,'fontsize',12,'fontweight','bold');
        ylabel(ax(2),'pA/Hz^{0.5}','fontsize',12,'fontweight','bold')
        xlabel(ax(2),'\nu (Hz)','fontsize',12,'fontweight','bold')
        file{1}(file{1} == '_') = ' ';
        title(ax(2),file{1});
        fig.Visible = 'on';
        
    case 'Filter out'
        handles = guidata(src.Parent.Parent.Parent);
        P = Data{1}{1};
        N_meas = Data{1}{2};
        ind_orig = Data{2};
        P(N_meas).Filtered{ind_orig} = 1;
        PRango = Data{3};
        if PRango == 1
            handles.Session{handles.TES_ID}.TES.PP(N_meas) = P(N_meas);
        else
            handles.Session{handles.TES_ID}.TES.PN(N_meas) = P(N_meas);
        end
        guidata(handles.Analyzer,handles);
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        if length(Data{1}) == 6
            Action = Data{1}{6};
            eval(['handles.Session{handles.TES_ID}.TES.' Action ';'])
        else
            handles.Session{handles.TES_ID}.TES.plotABCT(fig);
        end
        
        
    case 'Unfilter'
        handles = guidata(src.Parent.Parent.Parent);
        P = Data{1}{1};
        N_meas = Data{1}{2};
        ind_orig = Data{2};
        P(N_meas).Filtered{ind_orig} = 0;
        PRango = Data{3};
        if PRango == 1
            handles.Session{handles.TES_ID}.TES.PP(N_meas) = P(N_meas);
        else
            handles.Session{handles.TES_ID}.TES.PN(N_meas) = P(N_meas);
        end
        guidata(handles.Analyzer,handles);
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.plotABCT(fig);
        
    case 'Change color'
        c = uisetcolor;
        if ~isequal(c,0)
            hl = findobj('DisplayName',Data{4});            
            set(hl,'Color',c);
            try
                he = findobj('DisplayName',[Data{4} ' Error Bar']);
                set(he,'Color',c);            
            catch
            end
        end
        
        
    otherwise
        
end
