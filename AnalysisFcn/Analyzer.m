function varargout = Analyzer(varargin)
% ANALYZER MATLAB code for Analyzer.fig
%      ANALYZER, by itself, creates a new ANALYZER or raises the existing
%      singleton*.
%
%      H = ANALYZER returns the handle to a new ANALYZER or the handle to
%      the existing singleton*.
%
%      ANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYZER.M with the given input arguments.
%
%      ANALYZER('Property','Value',...) creates a new ANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Analyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Analyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Analyzer

% Last Modified by GUIDE v2.5 07-Mar-2019 12:34:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Analyzer_OpeningFcn, ...
    'gui_OutputFcn',  @Analyzer_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Analyzer is made visible.
function Analyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Analyzer (see VARARGIN)

% Choose default command line output for Analyzer
handles.output = hObject;

% handles.Analyzer = handles.Analyzer(1);
position = get(handles.Analyzer,'Position');
set(handles.Analyzer,'Color',[200 200 200]/255,'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized','Toolbar','figure');

handles.TES_ID = 0;
handles.NewTES = {[]};
handles.NewTES_DataPath = {[]};
% First TES_Analyzer Session is created by default


%% Generating the uimenus
IndMenu = 1;
MenuTES.Label{IndMenu} = {'TES Data'};
MenuTES.SubMenu{IndMenu} = {'Load TES';'TES Analysis';'Save TES Data'};
MenuTES.SubMenu_1{IndMenu,1} = {[]};
MenuTES.SubMenu_1{IndMenu,2} = {'Set Data Path';'TES Device';'IV-Curves';'TF Superconductor';'Z(w)-Noise Analysis'};
% MenuTES.SubMenu_2{IndMenu,1} = {[]};
MenuTES.SubMenu_2{IndMenu,1} = {[]};
MenuTES.SubMenu_2{IndMenu,2} = {'TES Dimensions';'Circuit Values'};
MenuTES.SubMenu_2{IndMenu,3} = {'Update Circuit Parameters (Slope IV-Curves)';'Import IV-Curves';'Check IV-Curves';'Fit P vs. T';'TES Thermal Parameter Values';'TES Thermal Parameters vs. %Rn';'Get G(T)'};
MenuTES.SubMenu_2{IndMenu,4} = {'Load TF in Superconductor State (TFS)';'Check TFS'};
MenuTES.SubMenu_2{IndMenu,5} = {'Fit Z(w)-Noise to ElectroThermal Model'};
MenuTES.SubMenu_1{IndMenu,3} = {[]};
MenuTES.Fcn{IndMenu} = {'TESData'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'View'};
MenuTES.SubMenu{IndMenu} = {'Plot NKGT Set';'Plot ABCT Set';...
    'Plot Z(w) vs Rn';'Plot Noise vs Rn';'Plot TES Data'};
MenuTES.Fcn{IndMenu} = {'View'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'Macro'};
MenuTES.SubMenu{IndMenu} = {'Plot NKGT Sets';'Plot ABCT Sets';'Plot TESs Data'};
MenuTES.Fcn{IndMenu} = {'MacroTES'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'Summary'};
MenuTES.SubMenu{IndMenu} = {'Z(w)-Noise Viewer';'Word Graphical Report'};
MenuTES.Fcn{IndMenu} = {'SummaryTES'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'Options'};
MenuTES.SubMenu{IndMenu} = {'Z(w) Options';'Noise Options';'Report Options'};
MenuTES.Fcn{IndMenu} = {'OptionsTES'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'Help'};
MenuTES.SubMenu{IndMenu} = {'Guide';'About'};
MenuTES.Fcn{IndMenu} = {'HelpTES'};
IndMenu = IndMenu +1;


% MenuTES.SubMenu_1{IndMenu,size(MenuTES.SubMenu_1,2)} = [];
for i = 1:length(MenuTES.Label)
    handles.menu(i,1) = uimenu('Parent',handles.Analyzer,'Label',...
        MenuTES.Label{i}{1},'Tag','Analyzer');
    for j = 1:length(MenuTES.SubMenu{i})
        eval(['handles.submenu(i,j) = uimenu(''Parent'',handles.menu(i),''Label'','...
            '''' MenuTES.SubMenu{i}{j} ''',''Callback'',{@' MenuTES.Fcn{i}{1} '},''Tag'',''Analyzer'');']);
        try
            if ~isempty(MenuTES.SubMenu_1{i,j}{1})
                for n = 1:size(MenuTES.SubMenu_1{i,j},1)
                    eval(['handles.submenu_1(i,j,n) = uimenu(''Parent'',handles.submenu(i,j),''Label'','...
                        '''' MenuTES.SubMenu_1{i,j}{n} ''',''Callback'',{@' MenuTES.Fcn{i}{1} '},''Tag'',''Analyzer'');']);
                    %                     MenuTES.SubMenu_2{IndMenu,3}
                    if ~isempty(MenuTES.SubMenu_2{i,n}{1})
                        for k = 1:size(MenuTES.SubMenu_2{i,n},1)
                            eval(['handles.submenu_2(i,j,k) = uimenu(''Parent'',handles.submenu_1(i,j,n),''Label'','...
                                '''' MenuTES.SubMenu_2{i,n}{k} ''',''Callback'',{@' MenuTES.Fcn{i}{1} '},''Tag'',''Analyzer'');']);
                        end
                    end
                end
            end
        catch
        end
    end
end

% if handles.TES_ID == 0 then 'off'
StrEnable = {'on';'off'};
StrLabel = {'Save TES Data';'View';'Macro';'Summary';'TES Device';...
    'IV-Curves';'Fit P vs. T';'TES Thermal Parameter Values';'TES Thermal Parameters vs. %Rn';'Get G(T)';...
    'TF Superconductor';'Z(w)-Noise Analysis';'Options'};
for i = 1:length(StrLabel)
    h = findobj('Label',StrLabel{i},'Tag','Analyzer');
    h.Enable = StrEnable{~handles.TES_ID+1};
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Analyzer wait for user response (see UIRESUME)
% uiwait(handles.Analyzer);


% --- Outputs from this function are returned to the command line.
function varargout = Analyzer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
a_str = {'New Figure';'Open File';'Save Figure';'Link Plot';'Hide Plot Tools';'Show Plot Tools and Dock Figure'};
for i = 1:length(a_str)
    eval(['a = findall(handles.FigureToolBar,''ToolTipString'',''' a_str{i} ''');']);
    a.Visible = 'off';
end

set(handles.Analyzer,'Visible','on');


% --- Executes on selection change in Loaded_TES.
function Loaded_TES_Callback(hObject, eventdata, handles)
% hObject    handle to Loaded_TES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Loaded_TES contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Loaded_TES
handles.TES_ID = get(hObject,'Value');
indAxes = findobj('Type','Axes');
delete(indAxes);
Enabling(handles.Session{handles.TES_ID},handles.TES_ID);
StrLabel = {'Plot NKGT Sets';'Plot ABCT Sets';'Plot TESs Data'};
if length(handles.Session) > 1
    for i = 1:length(StrLabel)
        h = findobj('Label',StrLabel{i},'Tag','Analyzer');
        h.Enable = 'on';
    end
end
guidata(hObject,handles);




% --- Executes during object creation, after setting all properties.
function Loaded_TES_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Loaded_TES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TESData(src,evnt)

handles = guidata(src);
switch src.Label
    case 'Load TES'
        
        StrLabel = {'TES Data';'Help';'Guide';'About'};
        for i = 1:length(StrLabel)
            h = findobj('Label',StrLabel{i},'Tag','Analyzer');
            %             for j = 1:length(h)
            %                 if strcmp(get(get(h(j),'Parent'),'Name'),'Analyzer')
            h.Enable = 'on';
            %                 end
            %             end
        end
        indAxes = findobj('Type','Axes','Tag','Analyzer');
        delete(indAxes);
        
        obj = TES_Analyzer_Session;
        Session = obj.LoadTES;
        if isa(Session,'TES_Analyzer_Session')
            % Comprobar si ya esta cargado
            if handles.TES_ID ~= 0
                for i = 1:length(handles.TES_ID)
                    if strcmp(Session.File,handles.Session{i}.File) && strcmp(Session.Path,handles.Session{i}.Path)
                        msgbox('Selected TES is already loaded','ZarTES v1.0');
                        return;
                    end
                end
            end
            if isempty(handles.Loaded_TES.String)
                handles.TES_ID = handles.TES_ID+1;
            else
                handles.TES_ID = size(handles.Loaded_TES.String,1)+1;
            end
            
            Session.ID = handles.TES_ID;
            handles.Session{handles.TES_ID} = Session;
            for i = 1:handles.TES_ID
                ListStr(i) = {handles.Session{i}.Tag};
            end
            set(handles.LoadedStr,'Visible','on')
            set(handles.Loaded_TES,'String',char(ListStr),'Value',handles.TES_ID,'Visible','on');
                      
            
            Enabling(Session,handles.TES_ID);
            
            StrLabel = {'Macro';'Plot NKGT Sets';'Plot ABCT Sets';'Plot TESs Data'};
            if length(handles.Session) > 1
                for i = 1:length(StrLabel)
                    h = findobj('Label',StrLabel{i},'Tag','Analyzer');
                    h.Enable = 'on';
                end
            end
        end
        
    case 'Set Data Path'
        DataPath = uigetdir('', 'Pick a Data path named Z(w)-Ruido');
        if DataPath ~= 0
            DataPath = [DataPath filesep];
        else
            errordlg('Invalid Data path name!','ZarTES v1.0','modal');
            return;
        end
        
        h = findobj('Type','uimenu','Tag','Analyzer');
        for i = 1:length(h)
            h(i).Enable = 'off';
        end
        
        StrLabel = {'TES Data';'Load TES';'TES Analysis';'Set Data Path';...
            'Options';'Z(w) Options';'Noise Options';'Report Options';'Help';'Guide';'About'};
        for i = 1:length(StrLabel)
            h = findobj('Label',StrLabel{i},'Tag','Analyzer');
            h.Enable = 'on';
        end
        indAxes = findobj('Type','Axes','Tag','Analyzer');
        delete(indAxes);
        
        Session = TES_Analyzer_Session;
        Session.File = [];
        Session.Path = DataPath;
        answer = inputdlg({'Insert a Nick name for the TES'},'ZarTES v1.0',[1 50],{' '});
        if isempty(answer{1})
            answer{1} = filename;
        end
        Session.Tag = answer{1};
        if isempty(handles.Loaded_TES.String)
            handles.TES_ID = handles.TES_ID+1;
        else
            handles.TES_ID = size(handles.Loaded_TES.String,1)+1;
        end
        Session.ID = handles.TES_ID;
        handles.Session{handles.TES_ID} = Session;
        for i = 1:handles.TES_ID
            ListStr(i) = {handles.Session{i}.Tag};
        end
        set(handles.LoadedStr,'Visible','on')
        set(handles.Loaded_TES,'String',char(ListStr),'Value',handles.TES_ID,'Visible','on');
        
        handles.Session{handles.TES_ID}.TES = TES_Struct;
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.Constructor;
        
        % Searching for Circuir variable (inside session or in circuit)
        [filename, pathname] = uigetfile({'sesion*';'circuit*'}, 'Pick a MATLAB file refering to sesion or circuit values',[Session.Path 'sesion.mat']);
        if ~isequal(filename,0)
            switch filename
                case 'sesion.mat'
                    load([pathname filename],'circuit');
                case 'circuit.mat'
                    load([pathname filename],'circuit');
            end     
            handles.Session{handles.TES_ID}.TES.circuit = handles.Session{handles.TES_ID}.TES.circuit.Update(circuit);
            handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.CheckCircuit;            
        else
            warndlg('Caution! Circuit parameters were not loaded, check it manually','ZarTES v1.0');
        end
%             d = dir([DataPath 'sesion.mat']);
%         circuit = [];
%         if ~isempty(d)
%             load([DataPath 'sesion.mat'],'circuit');
%             if ~isempty(circuit)
%                 handles.Session{handles.TES_ID}.TES.circuit = handles.Session{handles.TES_ID}.TES.circuit.Update(circuit);
%             end
%         else
%             [filename, pathname] = uigetfile({'sesion.m';'circuit.m'}, 'Pick a MATLAB code file');
%             load([DataPath 'sesion.mat'],'circuit');
%             if ~isempty(circuit)
%                 handles.Session{handles.TES_ID}.TES.circuit = handles.Session{handles.TES_ID}.TES.circuit.Update(circuit);
%             end
%             d = dir([DataPath 'circuit.mat']);
%             load([DataPath 'circuit.mat'],'circuit');
%             if ~isempty(circuit)
%                 handles.Session{handles.TES_ID}.TES.circuit = handles.Session{handles.TES_ID}.TES.circuit.Update(circuit);
%             end
%             
%         end
        
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID);
        
    case 'TES Dimensions'
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.EnterDimensions;
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID);
    case 'Circuit Values'
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.CheckCircuit;
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID);
    case 'Update Circuit Parameters (Slope IV-Curves)'
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes','Tag','Analyzer');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.circuit = handles.Session{handles.TES_ID}.TES.circuit.IVcurveSlopesFromData(handles.Session{handles.TES_ID}.Path,fig);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.CheckCircuit;
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID);
    case 'Import IV-Curves'
        [handles.Session{handles.TES_ID}.TES.IVsetP, TempLims] = handles.Session{handles.TES_ID}.TES.IVsetP.ImportFromFiles(handles.Session{handles.TES_ID}.TES,handles.Session{handles.TES_ID}.Path);
        handles.Session{handles.TES_ID}.TES.IVsetN = handles.Session{handles.TES_ID}.TES.IVsetN.ImportFromFiles(handles.Session{handles.TES_ID}.TES,handles.Session{handles.TES_ID}.TES.IVsetP(1).IVsetPath, TempLims);
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.CheckIVCurvesVisually(fig);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID);
    case 'Check IV-Curves'
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.CheckIVCurvesVisually(fig);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID);
    case 'Fit P vs. T'
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);        
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.fitPvsTset([],[],fig);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID);
    case 'TES Thermal Parameter Values'
%         fig = handles.Analyzer;
%         indAxes = findobj(fig,'Type','Axes');
%         delete(indAxes);
        handles.Session{handles.TES_ID}.TES.TES.CheckValues;
    case 'TES Thermal Parameters vs. %Rn'
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.plotNKGTset(fig);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID);
    case 'Get G(T)'
        handles.Session{handles.TES_ID}.TES.TES.G_calc;
    case 'Load TF in Superconductor State (TFS)'
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.TFS = handles.Session{handles.TES_ID}.TES.TFS.TFfromFile(handles.Session{handles.TES_ID}.Path,handles.Analyzer);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID);
    case 'Check TFS'
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.TFS = handles.Session{handles.TES_ID}.TES.TFS.CheckTF(handles.Analyzer);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID);
    case 'Fit Z(w)-Noise to ElectroThermal Model'
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.FitZset;
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID);
    case 'Save TES Data'
        handles.Session{handles.TES_ID}.TES.Save([handles.Session{handles.TES_ID}.Path 'TES_' handles.Session{handles.TES_ID}.Tag]);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID);
        
end
guidata(src,handles);


function View(src,evnt)

handles = guidata(src);
switch src.Label
    case 'Plot NKGT Set'
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.plotNKGTset(fig,1);
    case 'Plot ABCT Set'
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.plotABCT(fig);
    case 'Plot Z(w) vs Rn'
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        str = cellstr(num2str(unique([[handles.Session{handles.TES_ID}.TES.PP.Tbath] ...
            [handles.Session{handles.TES_ID}.TES.PN.Tbath]])'));
        [s,~] = listdlg('PromptString','Select Tbath value/s:',...
            'SelectionMode','multiple',...
            'ListString',str);
        if isempty(s)
            return;
        end
        Tbath = str2double(str(s))';
        prompt = {'Enter the Rn range:'};
        name = 'Rn range (0 < Rn < 1)';
        numlines = [1 70];
        defaultanswer = {'0.5:0.05:0.8'};
        answer = inputdlg(prompt,name,numlines,defaultanswer);
        Rn = eval(['[' answer{1} ']']);
        handles.Session{handles.TES_ID}.TES.PlotTFTbathRp(Tbath,Rn);
    case 'Plot Noise vs Rn'
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        str = cellstr(num2str(unique([[handles.Session{handles.TES_ID}.TES.PP.Tbath] ...
            [handles.Session{handles.TES_ID}.TES.PN.Tbath]])'));
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
        handles.Session{handles.TES_ID}.TES.PlotNoiseTbathRp(Tbath,Rn);
        
    case 'Plot TES Data'
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        str = fieldnames(handles.Session{handles.TES_ID}.TES.PP(1).p);
        
        dummy = uimenu('Visible','off');
        waitfor(GraphicTESData(str,dummy));
        data = dummy.UserData;
        
        if ~isempty(data)
            
            switch data.case
                case 1 % vs. Rn
                    str = cellstr(num2str(unique([[handles.Session{handles.TES_ID}.TES.PP.Tbath] ...
                        [handles.Session{handles.TES_ID}.TES.PN.Tbath]])'));
                    [s,~] = listdlg('PromptString','Select Tbath value/s:',...
                        'SelectionMode','multiple',...
                        'ListString',str);
                    if isempty(s)
                        return;
                    end
                    Tbath = str2double(str(s))';
                    handles.Session{handles.TES_ID}.TES.PlotTESData(data.param1,[],Tbath,handles.Analyzer);
                case 2 % vs. Tbath
                    prompt = {'Enter the %Rn range:'};
                    name = '%Rn range (0 < %Rn < 1)';
                    numlines = [1 70];
                    defaultanswer = {'0.5:0.05:0.8'};
                    answer = inputdlg(prompt,name,numlines,defaultanswer);
                    Rn = eval(['[' answer{1} ']']);
                    handles.Session{handles.TES_ID}.TES.PlotTESData(data.param1,Rn,[],handles.Analyzer);
                case 3 % Param1 vs. Param2
                    param = data.param1;
                    param2 = data.param2;
                    params = char([{param};{param2}]);
                    handles.Session{handles.TES_ID}.TES.PlotTESData(params,[],[],handles.Analyzer);
            end
        else
            return;
        end
end
guidata(src,handles);

function MacroTES(src,evnt)

handles = guidata(src);
switch src.Label
    case 'Plot NKGT Sets'
        str = cellstr(handles.Loaded_TES.String);
        [s,~] = listdlg('PromptString','Select Loaded TES:',...
            'SelectionMode','multiple',...
            'ListString',str);
        if isempty(s)
            return;
        end
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        
        colors = distinguishable_colors(length(s));
        j = 1;
        for i = s
            handles.Session{i}.TES.plotNKGTset(fig,1);
            Lines = findobj('Type','Line');
            for Ln = 1:length(Lines)
                if i == s(1)
                    Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' handles.Session{i}.Tag];
                    Lines(Ln).UserData = i;
                    if ~strcmp(Lines(Ln).DisplayName,['Operating Point - ' handles.Session{i}.Tag])
                        Lines(Ln).Color = colors(j,:);
                    end
                else
                    if ~isequal(Lines(Ln).UserData,i-1)
                        Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' handles.Session{i}.Tag];
                        Lines(Ln).UserData = i;
                        if ~strcmp(Lines(Ln).DisplayName,['Operating Point - ' handles.Session{i}.Tag])
                            Lines(Ln).Color = colors(j,:);
                        end
                        
                    end
                end
            end
            j = j+1;
        end
        
        
    case 'Plot ABCT Sets'
        str = cellstr(handles.Loaded_TES.String);
        [s,~] = listdlg('PromptString','Select Loaded TES:',...
            'SelectionMode','multiple',...
            'ListString',str);
        if isempty(s)
            return;
        end
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        
        er(1:4) = {[]};
        h_bad(1:4) = {[]};
        erbad(1:4) = {[]};
        
        colors = distinguishable_colors(length(s));
        j = 1;
        for i = s
            handles.Session{i}.TES.plotABCT(fig);
            Lines = findobj(fig.hObject,'Type','Line');
            for Ln = 1:length(Lines)
                if i == s(1)
                    Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' handles.Session{i}.Tag];
                    US = Lines(Ln).UserData;
                    Lines(Ln).UserData = [US; i];
                    Lines(Ln).Color = colors(j,:);
                else
                    US = Lines(Ln).UserData;
                    if length(US)<5
                        Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' handles.Session{i}.Tag];
                        Lines(Ln).UserData = [US; i];
                        Lines(Ln).Color = colors(j,:);
                    end
                end
            end
            j = j+1;
            Axes = findobj(fig.hObject,'Type','Axes');
            for k = 1:length(Axes)
                USData{k} = Axes(k).UserData;
                try
                    er{k} = [er{k} USData{k}.er];
                    h_bad{k} = [h_bad{k} USData{k}.h_bad];
                    erbad{k} = [erbad{k} USData{k}.erbad];
                    
                    data{k}.er = er{k};
                    data{k}.h_bad = h_bad{k};
                    data{k}.erbad = erbad{k};
                    Axes(k).UserData = data{k};
                catch
                end
            end
        end
%         for k = 1:length(Axes)
%             Axes(k).UserData = data{k};
%         end
        
    case 'Plot TESs Data'
        str = cellstr(handles.Loaded_TES.String);
        [s1,~] = listdlg('PromptString','Select Loaded TES:',...
            'SelectionMode','multiple',...
            'ListString',str);
        if isempty(s1)
            return;
        end
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        
        str = fieldnames(handles.Session{handles.TES_ID}.TES.PP(1).p);
        dummy = uimenu('Visible','off');
        waitfor(GraphicTESData(str,dummy));
        data = dummy.UserData;
        
        if ~isempty(data)
            
            switch data.case
                case 1 % vs. Rn
                    
                    TbathNums = [];
                    for i = s1
                        TbathNums = [TbathNums [handles.Session{i}.TES.PP.Tbath] ...
                            [handles.Session{i}.TES.PN.Tbath]];
                    end
                    
                    str = cellstr(num2str(unique(TbathNums)'));
                    [s,~] = listdlg('PromptString','Select Tbath value/s:',...
                        'SelectionMode','multiple',...
                        'ListString',str);
                    if isempty(s)
                        return;
                    end
                    Tbath = str2double(str(s))';
                    Rn = [];                   
                    
                    handles.Session{handles.TES_ID}.TES.PlotTESData(data.param1,[],Tbath,handles.Analyzer);
                    
                    colors = distinguishable_colors(length(s1));
                    j = 1;
                    for i = s1
                        handles.Session{i}.TES.PlotTESData(data.param1,Rn,Tbath,handles.Analyzer);
                        Lines = findobj(fig.hObject,'Type','Line');
                        for Ln = 1:length(Lines)
                            if i == s1(1)
                                Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' handles.Session{i}.Tag];
                                Lines(Ln).UserData = i;
                                Lines(Ln).Color = colors(j,:);
                            else
                                if ~isequal(Lines(Ln).UserData,i-1)
                                    Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' handles.Session{i}.Tag];
                                    Lines(Ln).UserData = i;
                                    Lines(Ln).Color = colors(j,:);
                                end
                            end
                        end
                        j = j+1;
                    end
                    
                case 2 % vs. Tbath
                    prompt = {'Enter the %Rn range:'};
                    name = '%Rn range (0 < %Rn < 1)';
                    numlines = [1 70];
                    defaultanswer = {'0.5:0.05:0.8'};
                    answer = inputdlg(prompt,name,numlines,defaultanswer);
                    Rn = eval(['[' answer{1} ']']);
                    Tbath = [];
                                                            
                    colors = distinguishable_colors(length(s1));
                    j = 1;
                    for i = s1
                        handles.Session{i}.TES.PlotTESData(data.param1,Rn,Tbath,handles.Analyzer);
                        Lines = findobj(fig.hObject,'Type','Line');
                        for Ln = 1:length(Lines)
                            if i == s1(1)
                                Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' handles.Session{i}.Tag];
                                Lines(Ln).UserData = i;
                                Lines(Ln).Color = colors(j,:);
                            else
                                if ~isequal(Lines(Ln).UserData,i-1)
                                    Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' handles.Session{i}.Tag];
                                    Lines(Ln).UserData = i;
                                    Lines(Ln).Color = colors(j,:);
                                end
                            end
                        end
                        j = j+1;
                    end                    
                    
                case 3 % Param1 vs. Param2
                    param = data.param1;
                    param2 = data.param2;
                    params = char([{param};{param2}]);
                    for i = s1
                        handles.Session{i}.TES.PlotTESData(params,[],[],handles.Analyzer);
                    end
            end
        else
            return;
        end
        
        
end
guidata(src,handles);

function OptionsTES(src,evnt)

handles = guidata(src);
switch src.Label
    case 'Z(w) Options'
        handles.Session{handles.TES_ID}.TES.TFOpt = handles.Session{handles.TES_ID}.TES.TFOpt.View;
    case 'Noise Options'
        handles.Session{handles.TES_ID}.TES.NoiseOpt = handles.Session{handles.TES_ID}.TES.NoiseOpt.View;
    case 'Report Options'
        handles.Session{handles.TES_ID}.TES.Report = handles.Session{handles.TES_ID}.TES.Report.View;
end
guidata(src,handles);

function SummaryTES(src,evnt)

handles = guidata(src);
switch src.Label
    case 'Z(w)-Noise Viewer'
        handles.Session{handles.TES_ID}.TES.TFNoiseViever;
    case 'Word Graphical Report'
        handles.Session{handles.TES_ID}.TES.GraphsReport;
        
end
guidata(src,handles);

function HelpTES(src,evnt)

handles = guidata(src);
switch src.Label
    case 'Guide'
        winopen('TES_Analyzer_UserGuide.pdf');
    case 'About'
        fig = figure('Visible','off','NumberTitle','off','Name','ZarTES v1.0','MenuBar','none','Units','Normalized');
        ax = axes;
        data = imread('ICMA-CSIC.jpg');
        image(data)
        ax.Visible = 'off';
        fig.Position = [0.35 0.35 0.3 0.22];
        fig.Visible = 'on';
end
guidata(src,handles);


function Enabling(Session,TES_ID)
StrEnable = {'on';'off'};
% Verificar si todos los campos están completos
% TES_Circuit (circuit)

StrLabel_On = {'TES Device';'TES Dimensions';'Circuit Values';...
    'IV-Curves';'Update Circuit Parameters (Slope IV-Curves)';'Import IV-Curves';'Save TES Data';'Options'};
for i = 1:length(StrLabel_On)
    h = findobj('Label',StrLabel_On{i},'Tag','Analyzer');
    h.Enable = StrEnable{(~TES_ID+1)};
end


%   Si hay algun campo vacío (Update from IV curves)
% TES_IVCurveSet (IVsetP o IVsetN)
%   Si están vacios (Import IV curves)
if Session.TES.IVsetP.Filled || Session.TES.IVsetN.Filled
    StrLabel_On = {'Check IV-Curves';'Fit P vs. T';...
        'TF Superconductor';'Load TF in Superconductor State (TFS)';'Check TFS'};
    for i = 1:length(StrLabel_On)
        h = findobj('Label',StrLabel_On{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)};
    end
else
    StrLabel_Off = {'Check IV-Curves';'Fit P vs. T';...
        'TF Superconductor';'Load TF in Superconductor State (TFS)';'Check TFS'};
    for i = 1:length(StrLabel_Off)
        h = findobj('Label',StrLabel_Off{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)+1};
    end
end


% TES_Gset (GsetP o GsetN)
%   Si están vacios (FitPset)
if Session.TES.GsetP.Filled || Session.TES.GsetN.Filled
    StrLabel_On = {'TES Thermal Parameter Values';'TES Thermal Parameters vs. %Rn';'Get G(T)';...
        'View';'Plot NKGT Set'};
    for i = 1:length(StrLabel_On)
        h = findobj('Label',StrLabel_On{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)};
    end
else
    StrLabel_Off = {'TES Thermal Parameter Values';'TES Thermal Parameters vs. %Rn';'Get G(T)';...
        'View';'Plot NKGT Set'};
    for i = 1:length(StrLabel_Off)
        h = findobj('Label',StrLabel_Off{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)+1};
    end
end


% TES_Param (TES)
%   Si están vacios (plotNKGT)
if Session.TES.TES.Filled && Session.TES.TFS.Filled
    StrLabel_On = {'Z(w)-Noise Analysis';'Fit Z(w)-Noise to ElectroThermal Model'};
    for i = 1:length(StrLabel_On)
        h = findobj('Label',StrLabel_On{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)};
    end
else
    StrLabel_Off = {'Z(w)-Noise Analysis';'Fit Z(w)-Noise to ElectroThermal Model'};
    for i = 1:length(StrLabel_Off)
        h = findobj('Label',StrLabel_Off{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)+1};
    end
end

% TES_P (PP o PN)
%   Si están vacios (FitZset)
if Session.TES.PP.Filled || Session.TES.PN.Filled
    StrLabel_On = {'View';'Plot ABCT Set';'Plot Z(w) vs Rn';'Plot Noise vs Rn';'Plot TES Data';...
        'Summary';'Z(w)-Noise Viewer';'Word Graphical Report'};
    for i = 1:length(StrLabel_On)
        h = findobj('Label',StrLabel_On{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)};
    end
else
    StrLabel_Off = {'View';'Plot ABCT Set';'Plot Z(w) vs Rn';'Plot Noise vs Rn';'Plot TES Data';...
        'Summary';'Z(w)-Noise Viewer';'Word Graphical Report'};
    for i = 1:length(StrLabel_Off)
        h = findobj('Label',StrLabel_Off{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)+1};
    end
end


% --- Executes when user attempts to close Analyzer.
function Analyzer_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to Analyzer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

if handles.TES_ID ~= 0
    ButtonName = questdlg('Do you want to save before exit?', ...
        'ZarTES v1.0', ...
        'Yes', 'No', 'Yes');
    switch ButtonName
        case 'Yes'
            handles.Session{handles.TES_ID}.TES.Save([handles.Session{handles.TES_ID}.Path 'TES_' handles.Session{handles.TES_ID}.Tag]);
        case 'No'
    end
end
% rmvpath([pwd filesep 'AnalysisFcn']);
delete(hObject);


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function Analyzer_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Analyzer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


switch eventdata.Source.SelectionType
    case 'alt' % Botón derecho
        cmenu = uicontextmenu('Visible','on');
        c6 = uimenu(cmenu,'Label','Save Graph','Callback',{@SaveGraph},'UserData',hObject);
        set(hObject,'uicontextmenu',cmenu);
    case 'normal' % Botón izquierdo
    case 'extend' % Pulsando Ruleta del raton
end
        
function SaveGraph(src,evnt)
ha = findobj(src.UserData.Parent,'Type','Axes');
fg = figure;
copyobj(ha,fg);
[file,path] = uiputfile('*.jpg','Save Graph name');
if ~isequal(file,0)
    print(fg,'-djpeg',[path filesep file]);
%     hgsave(fg,[path filesep file]);
end
% pause;