function GraphicErrors_NKGT(src,evnt)
% Auxiliary function to handle right-click mouse options of NKGT representation
% Last update: 18/11/2018

StrIbias = {'Positive';'Negative'};

cmenu = uicontextmenu('Visible','on');
c0 = uimenu(cmenu,'Label','Show only');
for i = 1:length(StrIbias)
    c0_1(i) = uimenu(c0,'Label',StrIbias{i},'Callback',{@Handle_Errors});
end
c0_1(i+1) = uimenu(c0,'Label','All','Callback',{@Handle_Errors});

Data = src.UserData;
he = findobj('Type','ErrorBar','Visible','on');
if ~isempty(he)
    StrLabel = 'Deactivate error bars';
else
    StrLabel = 'Activate error bars';
end


c1 = uimenu(cmenu,'Label',StrLabel,'Callback',{@Handle_Errors},'UserData',Data);
c3 = uimenu(cmenu,'Label','Hide Negative Ibias Data','Callback',...
    {@Handle_Errors},'UserData',Data);
c4 = uimenu(cmenu,'Label','Show Negative Ibias Data','Callback',...
    {@Handle_Errors},'UserData',Data);

c5 = uimenu(cmenu,'Label','Export Graphic Data','Callback',{@ExportGraph},'UserData',src);

set(src,'uicontextmenu',cmenu);

function Handle_Errors(src,evnt)

str = get(src,'Label');
if (~isempty(strfind(str,'Positive')))||(~isempty(strfind(str,'Negative')))
    TempStr = str;
else
    TempStr = '';
end
Data = src.UserData;

% Positive Ibias
h = findobj('Type','Line');
jp = [];
jn = [];
for i = 1:length(h)
    Tag = [h(i).DisplayName];
    if ~isempty(strfind(Tag,'Positive'))
        jp = [jp i] ;
    end
    if ~isempty(strfind(Tag,'Negative'))
        jn = [jn i] ;
    end
    
end
hp = h(jp);
hn = h(jn);

% Positive Ibias Error bars
he = findobj('Type','ErrorBar');
jpe = [];
jne = [];
for i = 1:length(he)
    Tag = [he(i).DisplayName];
    if ~isempty(strfind(Tag,'Positive'))
        jpe = [jpe i] ;
    end
    if ~isempty(strfind(Tag,'Negative'))
        jne = [jne i] ;
    end
end
hpe = he(jpe);
hne = he(jne);

switch str
    
    case 'Deactivate error bars'
        set([hpe; hne],'Visible','off');
        
        
    case 'Activate error bars'
        for i = 1:length(hn)
            if strcmp(hn(i).Visible,'on')
                set(hne(i),'Visible','on');
            end
        end
        for i = 1:length(hp)
            if strcmp(hp(i).Visible,'on')
                set(hpe(i),'Visible','on');
            end
        end

        
    case 'Hide Negative Ibias Data'
        
        set([hn; hne],'Visible','off');
        
        
    case 'Show Negative Ibias Data'
        
        set(hn,'Visible','on');
        for i = 1:length(hpe)
            if strcmp(hpe(i).Visible,'on')
                set(hne,'Visible','on');
            end
        end
        
    otherwise
        h = [findobj('Type','Line'); findobj('Type','ErrorBar')];
        set(h,'Visible','off');
        set([hp; hn],'Visible','on');
end

function ExportGraph(src,evnt)


h_axes = src.UserData;
[FileName, PathName] = uiputfile('.txt', 'Select a file name for storing data');
if isempty(FileName)
    return;
end
file = strcat([PathName FileName]);
fid = fopen(file,'a+');
hl = findobj(h_axes,'Type','Line','Visible','on');
LabelStr = [];
data = [];
for i = 1:length(hl)
    LabelStr = [LabelStr 'X_' hl(i).DisplayName '\t' 'Y_' hl(i).DisplayName '\t'];
    data = [data hl(i).XData'];    
    data = [data hl(i).YData'];
end
he = findobj(h_axes,'Type','ErrorBar','Visible','on');
for i = 1:length(he)
    LabelStr = [LabelStr 'X_Errorbar' he(i).DisplayName '\t' 'Y_Errorbar' he(i).DisplayName '\t' ...
        'Y_PosDelta' he(i).DisplayName '\t' 'Y_NegDelta' he(i).DisplayName '\t'];
    data = [data he(i).XData'];    
    data = [data he(i).YData'];
    data = [data he(i).YPositiveDelta'];    
    data = [data he(i).YNegativeDelta'];
end
fprintf(fid,[LabelStr '\n']);
save(file,'data','-ascii','-tabs','-append');
fclose(fid);

