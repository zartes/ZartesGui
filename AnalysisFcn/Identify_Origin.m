function Identify_Origin(src,evnt)
if evnt.Button == 1
    hd = findobj('Type','Uimenu');
    set(hd,'Visible','off');
end

if evnt.Button == 3
    % evnt.IntersectionPoint
    % return;
    XData = src.XData;
    % YData = src.YData;
    x_click = evnt.IntersectionPoint(1);
    ind_U = find(XData >= x_click,1);
    U_error = abs(XData(ind_U)-x_click);
    ind_L = find(XData <= x_click, 1, 'last' );
    L_error = abs(XData(ind_L)-x_click);
    if U_error < L_error
        ind = ind_U;
    else
        ind = ind_L;
    end
    if isempty(ind)
        return;
    end
    
    Data = src.UserData;
    P = Data{1};
    N_meas = Data{2};
    Circuit = Data{3};
    % En la gráfica los datos están ordenados de menor a mayor
    [rp, jj] = sort([P(N_meas).p.rp]);
    % P(N_meas).p(ind)
    % rp(ind)
    ind_orig = jj(ind);
    
    hp = plot(src.Parent,evnt.IntersectionPoint(1),evnt.IntersectionPoint(2),'.',...
        'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[1 0 0],'markersize',15);
    % Esto sirve para Tau y beta
    % P(N_meas).p(ind_orig).bi
    
    % Identificar el subplot
    Parent = src.Parent;
    Ylabel = Parent.YLabel.String;
    
    % switch Ylabel
    %     case 'C(fJ/K)'
    %         C(indC)
    %     case '\tau_{eff}(\mus)'
    %         [P(i).p(jj).taueff]*1e6
    %     case '\alpha_i'
    %         ai(indai)
    %     case '\beta_i'
    % end
    
    FileStr = P(N_meas).fileZ{ind_orig};
    FileStrLabel = ['..' filesep FileStr(strfind(FileStr,'Z(w)-Ruido'):end)];
    
    % P(N_meas).fileZ(ind_orig)
    % P(N_meas).fileZ(ind_orig)
    data{1} = P(N_meas).ztes{ind_orig};
    data{2} = P(N_meas).fZ{ind_orig};
    data{3} = P(N_meas).fileNoise{ind_orig};
    data{4} = Circuit;
    
    TFParam = {['Tbath: ' num2str(P(N_meas).Tbath*1e3) 'mK'];...
        ['Residuo: ' num2str(P(N_meas).residuo(ind_orig))];...
        ['ERP: ' num2str(P(N_meas).ERP{ind_orig})];...
        ['rp: ' num2str(P(N_meas).p(ind_orig).rp)];['L0: ' num2str(P(N_meas).p(ind_orig).L0)];...
        ['alpha i: ' num2str(abs(P(N_meas).p(ind_orig).ai))];...
        ['beta i: ' num2str(P(N_meas).p(ind_orig).bi)];...
        ['tau0: ' num2str(P(N_meas).p(ind_orig).tau0)];...
        ['tau_eff: ' num2str(P(N_meas).p(ind_orig).taueff)];...
        ['C: ' num2str(abs(P(N_meas).p(ind_orig).C*1e15))];...
        ['Zinf: ' num2str(P(N_meas).p(ind_orig).Zinf)];...
        ['Z0: ' num2str(P(N_meas).p(ind_orig).Z0)]};
    
    NoiseParam = {['ExRes: ' num2str(P(N_meas).p(ind_orig).ExRes)];...
        ['ThRes: ' num2str(P(N_meas).p(ind_orig).ThRes)]; ['M: ' num2str(P(N_meas).p(ind_orig).M)];...
        ['Mph: ' num2str(P(N_meas).p(ind_orig).Mph)]};
    
    
    %% Añadir que se muestren todos los ruidos de la temperatura escogida
    
    cmenu = uicontextmenu('Visible','on');
    c1 = uimenu(cmenu,'Label',FileStrLabel);
    c2(1) = uimenu(c1,'Label','Z(w)-Noise Plots','Callback',...
        {@ProvMarksActions},'UserData',data);
    
    c2(2) = uimenu(c1,'Label','TF parameter analysis');
    for i = 1:length(TFParam)
        c3(i) = uimenu(c2(2),'Label',TFParam{i});
    end
    
    c2(3) = uimenu(c1,'Label','Noise parameter analysis');
    for i = 1:length(NoiseParam)
        c4(i) = uimenu(c2(3),'Label',NoiseParam{i});
    end
    
    %
    % c2(3) = uimenu(c1,'Label','Noise Plot','Callback',...
    %     {@ProvMarksActions},'UserData',data,'Separator','on');
    
    
    
    
    %         uimenu(cmenu,'Label','Change position mark','Callback',...
    %             {@ProvMarksActions},'UserData',src_change);
    %         uimenu(cmenu,'Label','Change description mark','Callback',...
    %             {@ProvMarksActions},'UserData',src_change);
    
    %% Add more options about provisional marks
    set(src,'uicontextmenu',cmenu);
    true = 1;
    while true
        pause(0.1);
        if ishandle(cmenu)            
            if strcmp(cmenu.Visible,'off')
                true = 0;
                delete(hp);
            end
        else
            true = 0;
        end
        pause(0.1);
    end    
end


function ProvMarksActions(src,evnt)

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
        wdir = Data{3}(1:inds);
        filesNoise = Data{3}(inds+1:end);
        [noise,file] = loadnoise(0,wdir,filesNoise);
%         fig = figure('Name',string(file));
        ax(2) = subplot(1,2,2);        
        loglog(ax(2),noise{1}(:,1),V2I(noise{1}(:,2)*1e12,Data{4}),'.-r'),%%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
        hold(ax(2),'on'),grid(ax(2),'on')
        loglog(ax(2),noise{1}(:,1),medfilt1(V2I(noise{1}(:,2)*1e12,Data{4}),20),'.-k'),hold(ax(2),'on'),grid(ax(2),'on')
        set(ax(2),'linewidth',2,'fontsize',12,'fontweight','bold');
        ylabel(ax(2),'pA/Hz^{0.5}','fontsize',12,'fontweight','bold')
        xlabel(ax(2),'\nu (Hz)','fontsize',12,'fontweight','bold')
        file{1}(file{1} == '_') = ' ';
        title(ax(2),file{1});
        fig.Visible = 'on';           
        
    otherwise
        
end    
