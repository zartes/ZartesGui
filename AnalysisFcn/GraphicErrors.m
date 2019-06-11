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
%         Tag2{j} = h(i).DisplayName(strfind(h(i).DisplayName,'mK')+3:end);
        j = j+1;
    end
end
cmenu = uicontextmenu('Visible','on');
if ~isempty(Tag)
TempStr = unique(Tag);
% IbiasStr = unique(Tag2);


c0 = uimenu(cmenu,'Label','Show');
for i = 1:length(TempStr)
    c0_1(i) = uimenu(c0,'Label',TempStr{i},'Callback',{@Handle_Errors});
end
c0_1(i+1) = uimenu(c0,'Label','All','Callback',{@Handle_Errors});
end

he = findobj(src,'Type','ErrorBar','-and','Visible','on');
Data = src.UserData;
% VarVisible = Data.er(1).Visible;

% if strcmp(VarVisible,'on')
if ~isempty(he)
    StrLabel = 'Deactivate error bars';
else
    StrLabel = 'Activate error bars';
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

c3 = uimenu(cmenu,'Label','Hide Negative Ibias Data','Callback',...
    {@Handle_Errors},'UserData',Data);
c4 = uimenu(cmenu,'Label','Show Negative Ibias Data','Callback',...
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
    
    case 'Deactivate error bars'
        try
            set([hpe; hne; hfe],'Visible','off');
        end
        
    case 'Activate error bars'
        
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
