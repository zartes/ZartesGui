function GraphicErrors(src,evnt)
% Auxiliary function to handle right-click mouse options of ABCT representation
% Last update: 14/11/2018
fig = src.Parent;
h = findobj(fig,'Type','Line');
TempStr = [];
j = 1;
for i = 1:length(h)
    if ~isempty(strfind(h(i).DisplayName,'mK'))
        Tag{j} = h(i).DisplayName(1:strfind(h(i).DisplayName,'mK')+1);
        j = j+1;
    end
end
cmenu = uicontextmenu('Visible','on');
if ~isempty(Tag)
TempStr = unique(Tag);


c0 = uimenu(cmenu,'Label','Show');
for i = 1:length(TempStr)
    c0_1(i) = uimenu(c0,'Label',TempStr{i},'Callback',{@Handle_Errors});
end
c0_1(i+1) = uimenu(c0,'Label','All','Callback',{@Handle_Errors});
end

he = findobj(src,'Type','ErrorBar','-and','Visible','on');
Data = src.UserData;

if ~isempty(he)
    StrLabel = 'Hide error bars';
else
    StrLabel = 'Show error bars';
end


c1 = uimenu(cmenu,'Label',StrLabel,'Callback',{@Handle_Errors},'UserData',Data);

try
    VarVisible = Data.h_bad(1).Visible;
    if strcmp(VarVisible,'on')
        StrLabel = 'Hide Filtered Data';
    else
        StrLabel = 'Show Filtered Data';
    end
    c2 = uimenu(cmenu,'Label',StrLabel,'Callback',{@Handle_Errors},'UserData',Data);
catch
end

Tags = cellstr(char(h.DisplayName));
a = true;
i = 0;
while a && i < length(Tags)+1
    i = i+1;
    try
        if ~isempty(strfind(Tags{i},'Neg'))
            a = false;
        end
    catch
        break;
    end
end
if ~a % hay negativos
    if strcmp(h(i).Visible,'on')
        c3 = uimenu(cmenu,'Label','Hide Negative Ibias Data','Callback',...
            {@Handle_Errors},'UserData',Data);
    else
        c3 = uimenu(cmenu,'Label','Show Negative Ibias Data','Callback',...
            {@Handle_Errors},'UserData',Data);
    end
end

h1 = findobj(fig,'Type','Line','Visible','on');
if isempty(strfind([h1.DisplayName],'Fixed'))
    c3 = uimenu(cmenu,'Label','Show Data fixing C value','Callback',...
        {@Handle_Errors},'UserData',Data);
else
    c3 = uimenu(cmenu,'Label','Hide Data fixing C value','Callback',...
        {@Handle_Errors},'UserData',Data);
end

c41 = uimenu(cmenu,'Label','Change R^2 threshold','Callback',...
    {@Handle_Errors},'UserData',Data);

c5 = uimenu(cmenu,'Label','Export Graphic Data','Callback',{@ExportGraph},'UserData',src);
c6 = uimenu(cmenu,'Label','Save Graph','Callback',{@SaveGraph},'UserData',src);

c7 = uimenu(cmenu,'Label','Link all x axes','Callback',{@ManagingAxes},'UserData',src);
c8 = uimenu(cmenu,'Label','Change x axes limits','Callback',{@ManagingAxes},'UserData',src);
c9 = uimenu(cmenu,'Label','Change y axes limits','Callback',{@ManagingAxes},'UserData',src);

set(src,'uicontextmenu',cmenu);

function Handle_Errors(src,evnt)

hndl = guidata(src);
str = get(src,'Label');
if ~isempty(strfind(str,'mK'))
    TempStr = str;
else
    TempStr = '';
end
Data = src.UserData;

% Positive Ibias
h = findobj(hndl.Analyzer,'Type','Line');
jp = [];
jn = [];
jf = [];
jteo = [];
for i = 1:length(h)
    Tag = [h(i).DisplayName];    
    if ~isempty(strfind(Tag,[TempStr '-PosIbias']))
        jp = [jp i] ;
    end
    if ~isempty(strfind(Tag,[TempStr '-NegIbias']))
        jn = [jn i] ;
    end
    if ~isempty(strfind(Tag,'Filtered'))
        jf = [jf i] ;
    end
    if ~isempty(strfind(Tag,[TempStr 'teo']))
        jteo = [jteo i] ;
    end
end
hp = h(jp);
hn = h(jn);
hf = h(jf);
hteo = h(jteo);
for i = 1:length(hteo)
     set(get(get(hteo(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end
% Positive Ibias Error bars
he = findobj('Type','ErrorBar');
jpe = [];
jne = [];
jfe = [];
for i = 1:length(he)
    Tag = [he(i).DisplayName];
    if ~isempty(strfind(Tag,[TempStr '-PosIbias']))
        jpe = [jpe i] ;
    end
    if ~isempty(strfind(Tag,[TempStr '-NegIbias']))
        jne = [jne i] ;
    end
    if ~isempty(strfind(Tag,'Filtered'))
        jfe = [jfe i] ;
    end
end
hpe = he(jpe);
hne = he(jne);
hfe = he(jfe);


switch str
    case 'All'
        set([hp; hn],'Visible','on');
        set([hpe; hne; hf; hfe],'Visible','off');
        for i = 1:max([length(hp) length(hn)])
            try
                set(get(get(hp(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
            end
            try
                set(get(get(hn(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
            end            
        end
    
    case 'Hide error bars'
        try
            set([hpe; hne; hfe],'Visible','off');
        end
        
    case 'Show error bars'
        
        try
            if strcmp(hf(1).Visible,'on')
                set(hfe,'Visible','on');
            end
            for i = 1:max([length(hn) length(hp)])
                try
                    if strcmp(hn(i).Visible,'on')
                        set(hne(i),'Visible','on');
                    end
                end
                try
                    if strcmp(hp(i).Visible,'on')
                        set(hpe(i),'Visible','on');
                    end
                end
            end
        end


    case 'Hide Filtered Data'
        try
            set([hf; hfe],'Visible','off');
        end
        
    case 'Show Filtered Data'
        
        try
            set(hf,'Visible','on');
            if strcmp(hpe(1).Visible,'on')
                set(hfe,'Visible','on');
            end
        end
        
        
    case 'Hide Negative Ibias Data'
        
        set([hn; hne],'Visible','off');
        for i = 1:length(hn)
            set(get(get(hn(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        end
        
        
    case 'Show Negative Ibias Data'
        
        set(hn,'Visible','on');
        for i = 1:length(hpe)
            if strcmp(hpe(i).Visible,'on')
                set(hne,'Visible','on');
            end
        end
        for i = 1:length(hn)
            set(get(get(hn(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
        end
        
    case 'Show Data fixing C value'
        handles = guidata(src);
        
        h = findobj(handles.Analyzer,'Type','Line','Tag','Fixed');
        if isempty(h)
            
            gammas = [handles.Session{handles.TES_ID}.TES.TESDim.gammaMo handles.Session{handles.TES_ID}.TES.TESDim.gammaAu];
            rhoAs = [handles.Session{handles.TES_ID}.TES.TESDim.rhoMo handles.Session{handles.TES_ID}.TES.TESDim.rhoAu];
            h = flip(findobj(handles.Analyzer,'Type','Axes')); % C tau ai bi
            colors = distinguishable_colors((length(handles.Session{handles.TES_ID}.TES.PP)+length(handles.Session{handles.TES_ID}.TES.PN)));
            ind_color = 1;
            
            for i = 1:length(handles.Session{handles.TES_ID}.TES.PP)
                T0 = handles.Session{handles.TES_ID}.TES.TESP.T_fit;
                G0 = handles.Session{handles.TES_ID}.TES.TESP.G;
                TbathStr = [num2str(handles.Session{handles.TES_ID}.TES.PP(i).Tbath*1e3) 'mK-']; %mK
                NameStr = [TbathStr 'PosIbias-C-Fixed'];
                k = 1;
                P = handles.Session{handles.TES_ID}.TES.PP;
                
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
                
                param.rp = rp(IndxGood);
                param.C_fixed = ones(1,length(param.rp))*sum((gammas.*rhoAs).*...
                    ([handles.Session{handles.TES_ID}.TES.TESDim.hMo handles.Session{handles.TES_ID}.TES.TESDim.hAu].*...
                    handles.Session{handles.TES_ID}.TES.TESDim.sides(1)*handles.Session{handles.TES_ID}.TES.TESDim.sides(2)).*handles.Session{handles.TES_ID}.TES.TESP.T_fit);
                
                taueff = [handles.Session{handles.TES_ID}.TES.PP(i).p(jj(IndxGood)).taueff];
                P0 = [handles.Session{handles.TES_ID}.TES.PP(i).p(jj(IndxGood)).P0];
                tau0 = 2.43*param.C_fixed/G0;
                L0 = tau0./taueff + 1;
                param.ai_fixed = L0.*G0.*T0./P0;
                
                
                plot(h(1),param.rp,2.43*param.C_fixed*1e15,'MarkerFaceColor','none','MarkerEdgeColor',colors(ind_color,:),'Color',colors(ind_color,:),'LineWidth',2,'MarkerSize',10,'DisplayName',NameStr,...
                    'ButtonDownFcn',{@Identify_Origin},'UserData',[{P;i;k;handles.Session{handles.TES_ID}.TES.circuit}],'LineStyle',':','Tag','Fixed');
                plot(h(3),param.rp,param.ai_fixed,'MarkerFaceColor','none','MarkerEdgeColor',colors(ind_color,:),'Color',colors(ind_color,:),'LineWidth',2,'MarkerSize',10,'DisplayName',NameStr,...
                    'ButtonDownFcn',{@Identify_Origin},'UserData',[{P;i;k;handles.Session{handles.TES_ID}.TES.circuit}],'LineStyle',':','Tag','Fixed');
                ind_color = ind_color+1;
            end
            for i = 1:length(handles.Session{handles.TES_ID}.TES.PN)
                T0 = handles.Session{handles.TES_ID}.TES.TESN.T_fit;
                G0 = handles.Session{handles.TES_ID}.TES.TESN.G;
                k = 2;
                P = handles.Session{handles.TES_ID}.TES.PN;
                TbathStr = [num2str(handles.Session{handles.TES_ID}.TES.PN(i).Tbath*1e3) 'mK-']; %mK
                NameStr = [TbathStr 'NegIbias-C-Fixed'];
                
                try
                    [rp,jj] = sort([P(i).p.rp]);
                catch
                    continue;
                end
                if isempty(P(i).Filtered{1})
                    P(i).Filtered(1:length(rp)) = {0};
                end
                IndxGood = find(cell2mat(P(i).Filtered(jj))== 0);
                param.rp = rp(IndxGood);
                param.C_fixed = ones(1,length(param.rp))*sum((gammas.*rhoAs).*...
                    ([handles.Session{handles.TES_ID}.TES.TESDim.hMo handles.Session{handles.TES_ID}.TES.TESDim.hAu].*...
                    handles.Session{handles.TES_ID}.TES.TESDim.sides(1)*handles.Session{handles.TES_ID}.TES.TESDim.sides(2)).*handles.Session{handles.TES_ID}.TES.TESP.T_fit);
                
                taueff = [handles.Session{handles.TES_ID}.TES.PN(i).p(jj(IndxGood)).taueff];
                P0 = [handles.Session{handles.TES_ID}.TES.PN(i).p(jj(IndxGood)).P0];
                tau0 = 2.43*param.C_fixed/G0;
                L0 = tau0./taueff + 1;
                param.ai_fixed = L0.*G0.*T0./P0;
                
                plot(h(1),param.rp,2.43*param.C_fixed*1e15,'MarkerFaceColor','none','MarkerEdgeColor',[colors(ind_color,:)],'Color',[colors(ind_color,:)],'LineWidth',2,'MarkerSize',10,'DisplayName',NameStr,...
                    'ButtonDownFcn',{@Identify_Origin},'UserData',[{P;i;k;handles.Session{handles.TES_ID}.TES.circuit}],'LineStyle',':','Tag','Fixed');
                plot(h(3),param.rp,param.ai_fixed,'MarkerFaceColor','none','MarkerEdgeColor',[colors(ind_color,:)],'Color',[colors(ind_color,:)],'LineWidth',2,'MarkerSize',10,'DisplayName',NameStr,...
                    'ButtonDownFcn',{@Identify_Origin},'UserData',[{P;i;k;handles.Session{handles.TES_ID}.TES.circuit}],'LineStyle',':','Tag','Fixed');
                ind_color = ind_color+1;
            end
        else
            h = [findobj(hndl.Analyzer,'Type','Line'); findobj(hndl.Analyzer,'Type','ErrorBar')];
            set(h,'Visible','off');
            for i = 1:length(h)
                set(get(get(h(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            end
            ht = [hp; hn];
            for i = 1:length(ht)
                if strcmp(ht(i).Visible,'on')
                    a = findobj(handles.Analyzer,'DisplayName',[ht(i).DisplayName '_C_Fixed']);
                    if ~isempty(a)
                        a.Visible = 'on';
                    end 
                end
            end
            set([hp; hn],'Visible','on');
            for i = 1:max([length(hp) length(hn)])
                try
                    set(get(get(hp(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
                end
                try
                    set(get(get(hn(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
                end
                
            end
            %             set(h,'Visible','on');
            %             for i = 1:length(h)
            %                 set(get(get(h(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
%             end
        end
        
    case 'Hide Data fixing C value'
        handles = guidata(src);
        h = findobj(handles.Analyzer,'Type','Line','Visible','on','Tag','Fixed');
        set(h,'Visible','off');
        for i = 1:length(h)
            set(get(get(h(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        end
        
        
    case 'Change R^2 threshold'
        
        handles = guidata(src);
        prompt={'Enter the new value for R^2 threshold:'};
        name='Change R^2 threshold for filtering data';
        numlines=1;
        defaultanswer={num2str(handles.Session{handles.TES_ID}.TES.ElectrThermalModel.Zw_R2Thrs)};        
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        if isempty(answer)
            warndlg('No valid entry or cancel by user',handles.VersionStr);
            return;
        else
            Zw_R2Thrs = str2double(answer{1});
            if isnan(Zw_R2Thrs)
                warndlg('No valid entry or cancel by user',handles.VersionStr);
                return;
            end
        end
        for i = 1:length(handles.Session{handles.TES_ID}.TES.PP)
            for j = 1:length(handles.Session{handles.TES_ID}.TES.PP(i).R2)
                if handles.Session{handles.TES_ID}.TES.PP(i).R2{j} < Zw_R2Thrs || ...
                        handles.Session{handles.TES_ID}.TES.PP(i).p(j).C < 0 || handles.Session{handles.TES_ID}.TES.PP(i).p(j).ai < 0
                    handles.Session{handles.TES_ID}.TES.PP(i).Filtered{j} = 1;
                else
                    handles.Session{handles.TES_ID}.TES.PP(i).Filtered{j} = 0;
                end
            end
        end
        for i = 1:length(handles.Session{handles.TES_ID}.TES.PN)
            for j = 1:length(handles.Session{handles.TES_ID}.TES.PN(i).R2)
                if handles.Session{handles.TES_ID}.TES.PN(i).R2{j} < Zw_R2Thrs || ...
                        handles.Session{handles.TES_ID}.TES.PN(i).p(j).C < 0 || handles.Session{handles.TES_ID}.TES.PN(i).p(j).ai < 0
                    handles.Session{handles.TES_ID}.TES.PN(i).Filtered{j} = 1;
                else
                    handles.Session{handles.TES_ID}.TES.PN(i).Filtered{j} = 0;
                end
            end
        end
        handles.Session{handles.TES_ID}.TES.ElectrThermalModel.Zw_R2Thrs = Zw_R2Thrs;
        guidata(src,handles);
        
    otherwise
        h = [findobj(hndl.Analyzer,'Type','Line'); findobj(hndl.Analyzer,'Type','ErrorBar')];
        set(h,'Visible','off');
        for i = 1:length(h)
            set(get(get(h(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        end
        set([hp; hn],'Visible','on');
        for i = 1:max([length(hp) length(hn)])
            try
                set(get(get(hp(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
            end
            try
                set(get(get(hn(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
            end
                
        end
end

function ExportGraph(src,evnt)


h_axes = src.UserData;
[FileName, PathName] = uiputfile('.txt', 'Select a file name for storing data');
if isequal(FileName,0)||isempty(FileName)
    return;
end
file = strcat([PathName FileName]);
fid = fopen(file,'a+');
hl = findobj(h_axes,'Type','Line','Visible','on');
he = findobj(h_axes,'Type','ErrorBar','Visible','on');
LabelStr = [];

for i = 1:length(hl)
    Nmax(i) = size(hl(i).XData,2);
end
data = NaN(max(Nmax),2*length(Nmax));

iok = 1;
for i = 1:length(hl)
    LabelStr = [LabelStr 'X_' hl(i).DisplayName '\t' 'Y_' hl(i).DisplayName '\t'];
    data(1:Nmax(i),iok) = hl(i).XData';    
    data(1:Nmax(i),iok+1) = hl(i).YData';
    iok = iok +2;
end
if ~isempty(he)
    for i = 1:length(he)
        Nmaxe(i) = size(he(i).XData,2);
    end
    datae = NaN(max(Nmaxe),4*length(Nmaxe));
    
    iok = 1;
    for i = 1:length(he)
        LabelStr = [LabelStr 'X_Errorbar' he(i).DisplayName '\t' 'Y_Errorbar' he(i).DisplayName '\t' ...
            'Y_PosDelta' he(i).DisplayName '\t' 'Y_NegDelta' he(i).DisplayName '\t'];
        datae(1:Nmaxe(i),iok) = he(i).XData';
        datae(1:Nmaxe(i),iok+1) = he(i).YData';
        datae(1:Nmaxe(i),iok+2) = he(i).YPositiveDelta';
        datae(1:Nmaxe(i),iok+3) = he(i).YNegativeDelta';
        iok = iok +4;
    end
    data = [data datae];
end
fprintf(fid,[LabelStr '\n']);
save(file,'data','-ascii','-tabs','-append');
fclose(fid);

function SaveGraph(src,evnt)

ha = findobj(src.UserData.Parent,'Type','Axes','Visible','on');
fg = figure;
copyobj(ha,fg);
for i = 1:length(ha)
    hdl = findobj(ha(i),'Visible','off');
    delete(hdl);
end
[file,path] = uiputfile('*.jpg','Save Graph name');
if ~isequal(file,0)
    print(fg,'-djpeg',[path filesep file]);
end

function ManagingAxes(src,evnt)

ha = findobj(src.UserData.Parent,'Type','Axes');
switch src.Label
    case 'Link all x axes'
        linkaxes(ha,'x');
    case 'Change x axes limits'
        v = axis;
        prompt ={'Min X Limit';'Max X Limit'};
        name = 'X-axes limits';
        numlines = [1 50];
        defaultanswer = {num2str(v(1));num2str(v(2))};
        answer = inputdlg(prompt,name,numlines,defaultanswer);
        if ~isempty(answer)
            try
                axis([str2double(answer{1}) str2double(answer{2}) v(3) v(4)]);
            end
        end
    case 'Change y axes limits'
        v = axis;
        prompt ={'Min Y Limit';'Max Y Limit'};
        name = 'Y-axes limits';
        numlines = [1 50];
        defaultanswer = {num2str(v(3));num2str(v(4))};
        answer = inputdlg(prompt,name,numlines,defaultanswer);
        if ~isempty(answer)
            try
                axis([v(1) v(2) str2double(answer{1}) str2double(answer{2})]);
            end
        end
end
