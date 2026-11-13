function DisplayAppResults(src,event)
allfigs = findall(0, 'Type', 'figure');
appHandle = findall(allfigs, 'Name', 'TF_Viewer');
if ~isempty(appHandle)
    hndl = appHandle(1).RunningAppInstance;
end

cmenu = uicontextmenu(hndl.figure1,'Visible','on');

data = src.UserData;
ind_orig = data{2};
FileStrLabel = data{3};

param = fieldnames(data{1}.p);


TFParam = {['Tbath: ' num2str(data{1}.Tbath*1e3) 'mK'];...
    ['Residuo: ' num2str(data{1}.residuo(ind_orig))];...
    ['R2: ' num2str(data{1}.R2{ind_orig})]};
for i = 1:length(param)-5
    TFParam = [TFParam; {[param{i} ': ' num2str(eval(['data{1}.p(ind_orig).' param{i}]))]}];
end

NoiseParam = {['Noise Model: ' data{1}.NoiseModel{ind_orig}];...
    ['ExRes: ' num2str(data{1}.p(ind_orig).ExRes)];...
    ['ThRes: ' num2str(data{1}.p(ind_orig).ThRes)];
    ['M: ' num2str(data{1}.p(ind_orig).M)];...
    %     ['M_CI: ' num2str(data{1}.p(ind_orig).M_CI)];...
    ['Mph: ' num2str(data{1}.p(ind_orig).Mph)]};...
    %     ['Mph_CI: ' num2str(data{1}.p(ind_orig).Mph_CI)]};


%% Añadir que se muestren todos los ruidos de la temperatura escogida

% cmenu = uicontextmenu('Visible','on');
c1 = uimenu(cmenu,'Label',FileStrLabel);

c2(1) = uimenu(c1,'Label','TF parameter analysis');
for i = 1:length(TFParam)
    c3(i) = uimenu(c2(1),'Label',TFParam{i});
    if i > 2
        Str = TFParam{i}(1:strfind(TFParam{i},':')-1);
        c3_1(i) = uimenu(c3(i),'Label',[Str ' (Histogram)'],'Callback',{@HistFcn},'UserData',{data; ind_orig});
    end
end

c2(2) = uimenu(c1,'Label','Noise parameter analysis');
for i = 1:length(NoiseParam)
    c4(i) = uimenu(c2(2),'Label',NoiseParam{i});
end

c5 = uimenu(cmenu,'Label','Export Graphic Data','Callback',{@ExportGraph},'UserData',src);
% c6 = uimenu(cmenu,'Label','Save Graph','Callback',{@SaveGraph},'UserData',src);

hndl.figure1.ContextMenu = cmenu;
% pause(0.001)
open(cmenu,cmenu.Position);
set(src,'uicontextmenu',cmenu,'Visible','on');

% set(src,'uicontextmenu',cmenu);

end





function figure1_ButtonDownFcn(hObject,eventdata,handles)

a = dbstack;
if ~isempty([strfind(a(end).name,'Forward_Callback') strfind(a(end).name,'Rewind_Callback')])
    set([handles.Rewind handles.Forward],'UserData',1);
    guidata(hObject,handles);
end
end

function HistFcn(src,evnt)

Str = src.Label;
Str = Str(1:strfind(Str,'(')-2);
if strcmp(Str,'alpha i')
    Str = 'ai';
elseif strcmp(Str,'beta i')
    Str = 'bi';
elseif strcmp(Str,'tau_eff')
    Str = 'taueff';
end
data = src.UserData;
figure;
try
    hist(eval(['cell2mat(data{1}{1}.' Str ')']),20);
catch
    hist(eval(['[data{1}{1}.p.' Str ']']),20);
end
ylabel('Counts');
xlabel(Str);
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
