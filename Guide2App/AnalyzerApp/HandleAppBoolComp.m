function HandleAppBoolComp(src,evnt)

allfigs = findall(0, 'Type', 'figure');
appHandle = findall(allfigs, 'Name', 'TF_Viewer');
if ~isempty(appHandle)
    hndl = appHandle(1).RunningAppInstance;
end

% try
%     delete
% catch
% end
cmenu = uicontextmenu(hndl.figure1,'Visible','on');
% delete(cmenu);
% cmenu = uicontextmenu(hndl.figure1,'Visible','on');
data = get(src,'UserData');


% cmenu = uicontextmenu('Visible','on');
c1 = uimenu(cmenu,'Label','Noise Components');
if data.ElectrThermalModel.bool_components
    c2 = uimenu(c1,'Label','Hide','Callback',...
        {@NoiseComp},'UserData',data);
else
    c2 = uimenu(c1,'Label','Show','Callback',...
        {@NoiseComp},'UserData',data);
end
c3 = uimenu(c1,'Label','Type');
c4(1) = uimenu(c3,'Label','Current','Callback',{@NoiseComp},'UserData',data);
c4(2) = uimenu(c3,'Label','NEP','Callback',{@NoiseComp},'UserData',data);
if strcmp(data.ElectrThermalModel.tipo{data.ElectrThermalModel.Selected_tipo},'current')
    set(c4(1),'Checked','on');
    set(c4(2),'Checked','off');
else
    set(c4(1),'Checked','off');
    set(c4(2),'Checked','on');
end
c5 = uimenu(cmenu,'Label','Export Graphic Data','Callback',{@ExportGraph},'UserData',src);

hndl.figure1.ContextMenu = cmenu;
% pause(0.001)
open(cmenu,cmenu.Position);
set(src,'uicontextmenu',cmenu,'Visible','on');
% set(src,'uicontextmenu',cmenu);
end

function NoiseComp(src,evnt)

data = get(src,'UserData');
handles = guidata(src.Parent.Parent);
switch src.Label
    case 'Hide'
        data.ElectrThermalModel.bool_components = 0;
    case 'Show'
        data.ElectrThermalModel.bool_components = 1;
    case 'Current'
        data.ElectrThermalModel.Selected_tipo = 1;
        src.Checked = 'on';
        src.Parent.Children(1).Checked = 'off';

    case 'NEP'
        data.ElectrThermalModel.Selected_tipo = 2;
        src.Checked = 'on';
        src.Parent.Children(2).Checked = 'off';
end
% handles.varargin{1} = data;
guidata(src.Parent.Parent, handles);

allfigs = findall(0, 'Type', 'figure');
appHandle = findall(allfigs, 'Name', 'TF_Viewer');
app = guidata(appHandle);
app.varargin{2} = data;
guidata(appHandle, app);

[data.ElectrThermalModel.bool_components data.ElectrThermalModel.Selected_tipo]

PlotTF_Noise(app,src);

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
end