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

handles.VersionStr = 'ZarTES v2.1';
set(handles.Analyzer,'Name',handles.VersionStr);

handles.TES_ID = 0;
handles.NewTES = {[]};
handles.NewTES_DataPath = {[]};
% First TES_Analyzer Session is created by default


%% Generating the uimenus
IndMenu = 1;
MenuTES.Label{IndMenu} = {'TES Data'};
MenuTES.SubMenu{IndMenu} = {'Load TES';'TES Analysis';'Re-Analyze Loaded TES';'Save TES Data'};
MenuTES.SubMenu_1{IndMenu,1} = {[]};
MenuTES.SubMenu_1{IndMenu,2} = {'Set Data Path';'TES Device';'IV-Curves';'Superconductor State';'Normal State';'Z(w)-Noise Analysis';'Critical Currents';'Field Scan'};
% MenuTES.SubMenu_2{IndMenu,1} = {[]};
MenuTES.SubMenu_2{IndMenu,1} = {[]};
MenuTES.SubMenu_2{IndMenu,2} = {'TES Dimensions';'TES Parameters';'Circuit Values'};
% MenuTES.SubMenu_2{IndMenu,3} = {'Update Circuit Parameters (Slope IV-Curves)';'Import IV-Curves';'Check IV-Curves';'Fit P vs. T';'TES Thermal Parameters vs. %Rn';'TES Thermal Parameter Values';'Get G(T)'};
MenuTES.SubMenu_2{IndMenu,3} = {'Import IV-Curves';'Check IV-Curves';'Fit P vs. T';'TES Thermal Parameters vs. %Rn';'TES Thermal Parameter Values';'Get G(T)'};
MenuTES.SubMenu_2{IndMenu,4} = {'Load TF in Superconductor State (TFS)';'Check TFS';'Load Noise in Superconductor State';'Check Superconductor State Noise'};
MenuTES.SubMenu_2{IndMenu,5} = {'Load TF in Normal State (TFN)';'Check TFN';'Load Noise in Normal State';'Check Normal State Noise'};
MenuTES.SubMenu_2{IndMenu,6} = {'Z(w) Derived L';'Fit Z(w)-Noise to ElectroThermal Model'};
MenuTES.SubMenu_2{IndMenu,7} = {'Import Critical Currents'};
MenuTES.SubMenu_2{IndMenu,8} = {'Import Field Scan'};
MenuTES.SubMenu_1{IndMenu,3} = {[]};
MenuTES.Fcn{IndMenu} = {'TESData'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'Plot'};
MenuTES.SubMenu{IndMenu} = {'Plot NKGT Set';'Plot RTs Set';'Plot ABCT Set';...
    'Plot Z(w) vs %Rn';'Plot Noise vs %Rn';'Plot TES Data';'Plot IV-Z';'Plot Critical Currents';'Plot Field Scan'};
MenuTES.Fcn{IndMenu} = {'Plot'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'Macro'};
MenuTES.SubMenu{IndMenu} = {'Plot NKGT Sets';'Plot RTs Sets';'Plot ABCT Sets';'Plot TESs Data';'Plot IV-Zs';'Plots Critical Currents';'Plots Field Scan'};
MenuTES.Fcn{IndMenu} = {'MacroTES'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'Summary'};
MenuTES.SubMenu{IndMenu} = {'Z(w)-Noise Viewer';'Word Graphical Report'};
MenuTES.Fcn{IndMenu} = {'SummaryTES'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'Options'};
MenuTES.SubMenu{IndMenu} = {'P vs T Model Fitting Options';'Electro Thermal Model Fitting Options';'Report Options'};
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
StrLabel = {'Re-Analyze Loaded TES';'Save TES Data';'Plot';'Macro';'Summary';'TES Device';...
    'IV-Curves';'Fit P vs. T';'TES Thermal Parameters vs. %Rn';'TES Thermal Parameter Values';'Get G(T)';...
    'Superconductor State';'Normal State';'Critical Currents';'Field Scan';'Z(w)-Noise Analysis';'Options'};
for i = 1:length(StrLabel)
    h = findobj(handles.Analyzer,'Label',StrLabel{i},'Tag','Analyzer');
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
% a_str = {'New Figure';'Open File';'Save Figure';'Link Plot';'Hide Plot Tools';'Show Plot Tools and Dock Figure'};
a_str = {'New Figure';'Open File';'Save Figure';'Link Plot'};
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
indAxes = findobj(handles.Analyzer,'Type','Axes');
delete(indAxes);
Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
% StrLabel = {'Plot NKGT Sets';'Plot ABCT Sets';'Plot TESs Data';'Plots Critical Currents';'Plots Field Scan'};
% if length(handles.Session) > 1
%     for i = 1:length(StrLabel)
%         h = findobj(handles.Analyzer,'Label',StrLabel{i},'Tag','Analyzer');
%         h.Enable = 'on';
%     end
% end
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
            h = findobj(handles.Analyzer,'Label',StrLabel{i},'Tag','Analyzer');
            %             for j = 1:length(h)
            %                 if strcmp(get(get(h(j),'Parent'),'Name'),'Analyzer')
            h.Enable = 'on';
            %                 end
            %             end
        end
        indAxes = findobj(handles.Analyzer,'Type','Axes','Tag','Analyzer');
        delete(indAxes);
        
        obj = TES_Analyzer_Session;
        Session = obj.LoadTES;
        if isa(Session,'TES_Analyzer_Session')
            % Comprobar si ya esta cargado
            if handles.TES_ID ~= 0
                for i = 1:length(handles.TES_ID)
                    if strcmp(Session.File,handles.Session{i}.File) && strcmp(Session.Path,handles.Session{i}.Path)
                        msgbox('Selected TES is already loaded',handles.VersionStr);
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
            
            guidata(src,handles);
            Enabling(Session,handles.TES_ID,handles.Analyzer);
            
            %             StrLabel = {'Macro';'Plot NKGT Sets';'Plot RTs Sets';'Plot ABCT Sets';'Plot TESs Data';'Plot Critical Currents';'Plot Field Scan'};
            if length(handles.Session) > 1
                %                 for i = 1:length(StrLabel)
                h = findobj(handles.Analyzer,'Label','Macro','Tag','Analyzer');
                h.Enable = 'on';
            end
            %             end
        end
        
    case 'Set Data Path'
        DataPath = uigetdir('', 'Pick a Data path named Z(w)-Ruido');
        if DataPath ~= 0
            DataPath = [DataPath filesep];
        else
            errordlg('Invalid Data path name!',handles.VersionStr,'modal');
            return;
        end
        
        h = findobj(handles.Analyzer,'Type','uimenu','Tag','Analyzer');
        for i = 1:length(h)
            h(i).Enable = 'off';
        end
        
        StrLabel = {'TES Data';'Load TES';'TES Analysis';'Set Data Path';'Critical Currents';'Import Critical Currents';'Field Scan';'Import Field Scan';...
            'Options';'P vs T Model Fitting Options';'Electro Thermal Model Fitting Options';'Report Options';'Help';'Guide';'About'};
        for i = 1:length(StrLabel)
            h = findobj(handles.Analyzer,'Label',StrLabel{i},'Tag','Analyzer');
            h.Enable = 'on';
        end
        indAxes = findobj(handles.Analyzer,'Type','Axes','Tag','Analyzer');
        delete(indAxes);
        
        Session = TES_Analyzer_Session;
        Session.File = [];
        Session.Path = DataPath;
        answer = inputdlg({'Insert a Nick name for the TES'},handles.VersionStr,[1 50],{' '});
        if isempty(answer)
            errordlg('Invalid Nick name!',handles.VersionStr,'modal');            
            return;
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
        [filename, pathname] = uigetfile({'sesion*';'circuit*'}, 'Pick a MATLAB file refering to circuit values',[Session.Path 'circuit.mat']);
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
            warndlg('Caution! Circuit parameters were not loaded, check it manually',handles.VersionStr);
        end
        guidata(src,handles);
        %         StrLabel = {'Macro';'Plot NKGT Sets';'Plot RTs Sets';'Plot ABCT Sets';'Plot TESs Data';'Plot Critical Currents';'Plot Field Scan'};
        if length(handles.Session) > 1
            %             for i = 1:length(StrLabel)
            h = findobj(handles.Analyzer,'Label','Macro','Tag','Analyzer');
            h.Enable = 'on';
            %             end
        end
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
        
    case 'Re-Analyze Loaded TES'
        str = cellstr(handles.Loaded_TES.String);
        [s1,~] = listdlg('PromptString','Select Loaded TES:',...
            'SelectionMode','multiple',...
            'ListString',str);
        if isempty(s1)
            return;
        end
        
        prompt = {'Enter the %Rn range (Initial:Step:Final):'};
        name = '%Rn range to fit P vs. Tbath data (suggested values)';
        numlines = [1 70];
        defaultanswer = {'0.2:0.01:0.7'};
        answer = inputdlg(prompt,name,numlines,defaultanswer);
        if ~isempty(answer)
            perc = eval(answer{1});
            if ~isnumeric(perc)
                warndlg('Invalid %Rn values',handles.VersionStr);
                return;
            end
        else
            warndlg('Invalid %Rn values',handles.VersionStr);
            return;
        end
        
        prompt = {'Enter the %Rn (0 < %Rn < 1) for TES thermal parameters'};
        name = 'TES Thermal Parameters';
        numlines = 1;
        defaultanswer = {'0.5'};
        answer = inputdlg(prompt,name,numlines,defaultanswer);
        if isempty(answer)
            warndlg('No %Rn value selected',handles.VersionStr);
            return;
        else
            X = str2double(answer{1});
            if isnan(X)
                warndlg('Invalid %Rn value',handles.VersionStr);
                return;
            end
        end
        
        opt.ElectrThermalModel = TES_ElectrThermModel;
        ButtonName = questdlg('Select Files Acquisition device', ...
            handles.VersionStr, ...
            'PXI', 'HP', 'HP');
        switch ButtonName
            case 'PXI'
                opt.ElectrThermalModel.Selected_TF_BaseName = 2;
                opt.ElectrThermalModel.Selected_NoiseBaseName = 2;
            case 'HP'
                opt.ElectrThermalModel.Selected_TF_BaseName = 1;
                opt.ElectrThermalModel.Selected_NoiseBaseName = 1;
                
            otherwise
                disp('PXI acquisition files were selected by default.')
                opt.ElectrThermalModel.Selected_TF_BaseName = 2;
                opt.ElectrThermalModel.Selected_NoiseBaseName = 2;                
        end
        
                
        prompt = {'Mimimum frequency value:','Maximum frequency value:'};
        dlg_title = 'Frequency limitation for Z(w)-Noise analysis';
        num_lines = [1 70];
        defaultans = {num2str(opt.ElectrThermalModel.Zw_LowFreq),num2str(opt.ElectrThermalModel.Zw_HighFreq)};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        
        if ~isempty(answer)
            minFreq = eval(answer{1});
            maxFreq = eval(answer{2});
            if ~isnumeric(minFreq)||~isnumeric(maxFreq)
                warndlg('Cancelled by user',handles.VersionStr);
                return;
            end
        else
            warndlg('Cancelled by user',handles.VersionStr);
            return;
        end
        opt.FreqRange = [minFreq maxFreq];
        opt.ElectrThermalModel.bool_Show = 0;
        
        for i = s1
            fig = handles.Analyzer;
            % Fit P vs T
            indAxes = findobj(fig,'Type','Axes');
            delete(indAxes);
            handles.Session{i}.TES = handles.Session{i}.TES.fitPvsTset(perc,fig);  %perc = 0.2:0.01:0.7; model = []; fig
            % Thermal parameters
            clear fig;
            fig.hObject = handles.Analyzer;
            indAxes = findobj(fig,'Type','Axes');
            delete(indAxes);            
            handles.Session{i}.TES = handles.Session{i}.TES.plotNKGTset(fig,X);
            % Fit Z(w)-Noise (HP by default)
            indAxes = findobj(fig,'Type','Axes');
            delete(indAxes);          
            
            handles.Session{i}.TES = handles.Session{i}.TES.FitZset(fig.hObject,opt);
            
        end        
        
        
    case 'TES Dimensions'
        handles.Session{handles.TES_ID}.TES.TESDim = handles.Session{handles.TES_ID}.TES.TESDim.EnterDimensions;
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
        
    case 'TES Parameters'
        handles.Session{handles.TES_ID}.TES.TESParamP.CheckValues('Positive Ibias');
        handles.Session{handles.TES_ID}.TES.TESParamN.CheckValues('Negative Ibias');
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
        
    case 'Circuit Values'
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.CheckCircuit;
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
    case 'Update Circuit Parameters (Slope IV-Curves)'
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes','Tag','Analyzer');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.IVcurveSlopesFromData(handles.Session{handles.TES_ID}.Path,fig);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.CheckCircuit;
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
    case 'Import IV-Curves'
        handles.Session{handles.TES_ID}.TES.IVsetP = TES_IVCurveSet;
        handles.Session{handles.TES_ID}.TES.IVsetP = handles.Session{handles.TES_ID}.TES.IVsetP.Constructor;
        handles.Session{handles.TES_ID}.TES.IVsetN = TES_IVCurveSet;
        handles.Session{handles.TES_ID}.TES.IVsetN = handles.Session{handles.TES_ID}.TES.IVsetN.Constructor(1);
        [IVsetP, TempLims, TESP] = handles.Session{handles.TES_ID}.TES.IVsetP.ImportFromFiles(handles.Session{handles.TES_ID}.TES,handles.Session{handles.TES_ID}.Path);
        if isempty(TempLims)
            return;
        end
        handles.Session{handles.TES_ID}.TES.circuit = handles.Session{handles.TES_ID}.TES.circuit.Update(TESP.circuit);
        handles.Session{handles.TES_ID}.TES.IVsetP = handles.Session{handles.TES_ID}.TES.IVsetP.Update(IVsetP);
        handles.Session{handles.TES_ID}.TES.TESParamP = handles.Session{handles.TES_ID}.TES.TESParamP.Update(TESP.TESParamP);
        
        handles.Session{handles.TES_ID}.TES.IVsetN(1).CorrectionMethod = handles.Session{handles.TES_ID}.TES.IVsetP(1).CorrectionMethod;
        [IVsetN, TempLims, TESN] = handles.Session{handles.TES_ID}.TES.IVsetN.ImportFromFiles(handles.Session{handles.TES_ID}.TES,handles.Session{handles.TES_ID}.TES.IVsetP(1).IVsetPath, TempLims);
        handles.Session{handles.TES_ID}.TES.circuit = handles.Session{handles.TES_ID}.TES.circuit.Update(TESN.circuit);
        handles.Session{handles.TES_ID}.TES.IVsetN = handles.Session{handles.TES_ID}.TES.IVsetN.Update(IVsetN);
        handles.Session{handles.TES_ID}.TES.TESParamN = handles.Session{handles.TES_ID}.TES.TESParamN.Update(TESN.TESParamN);
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        figure(fig.hObject);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.CheckIVCurvesVisually(fig);
        
%         [handles.Session{handles.TES_ID}.TES.TESP.mN, handles.Session{handles.TES_ID}.TES.TESP.mS] = handles.Session{handles.TES_ID}.TES.IVs_Slopes(handles.Session{handles.TES_ID}.TES.IVsetP);
%         [handles.Session{handles.TES_ID}.TES.TESN.mN, handles.Session{handles.TES_ID}.TES.TESN.mS] = handles.Session{handles.TES_ID}.TES.IVs_Slopes(handles.Session{handles.TES_ID}.TES.IVsetN);
%         [obj.TESN.mN, obj.TESN.mS] = obj.IVs_Slopes(IVsetN,fig);
                
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
    case 'Check IV-Curves'
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.CheckIVCurvesVisually(fig);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
    case 'Fit P vs. T'
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);        
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.fitPvsTset([],fig.hObject);
        
        waitfor(msgbox('Continue to Thermal parameters vs %Rn',handles.VersionStr)); %handles.VersionStr
%         fig = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);        
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.plotNKGTset(fig);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
        
    case 'TES Thermal Parameters vs. %Rn'
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.plotNKGTset(fig);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
    case 'TES Thermal Parameter Values'
        handles.Session{handles.TES_ID}.TES.TESThermalP.CheckValues('PosIbias');
        handles.Session{handles.TES_ID}.TES.TESThermalN.CheckValues('NegIbias');        
    case 'Get G(T)'
        handles.Session{handles.TES_ID}.TES.TESThermalP.G_calc;
        handles.Session{handles.TES_ID}.TES.TESThermalN.G_calc;
    case 'Load TF in Superconductor State (TFS)'
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.TFS = handles.Session{handles.TES_ID}.TES.TFS.TFfromFile(handles.Session{handles.TES_ID}.Path,handles.Analyzer);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
    case 'Check TFS'
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.TFS = handles.Session{handles.TES_ID}.TES.TFS.CheckTF(handles.Analyzer);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
        
    case 'Load Noise in Superconductor State'
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        [filename, pathname] = uigetfile({'*.txt'}, 'Pick a Noise file refering to normal state',[handles.Session{handles.TES_ID}.Path '*.txt']);
        if isequal(filename,0)            
            warndlg('No file selected',handles.VersionStr);
            return;
        end
        FileName = [pathname filename];
        if ~isa(handles.Session{handles.TES_ID}.TES.NoiseS,'TES_BasalNoises')
            handles.Session{handles.TES_ID}.TES.NoiseS = TES_BasalNoises;
            handles.Session{handles.TES_ID}.TES.NoiseS = handles.Session{handles.TES_ID}.TES.NoiseS.Constructor;
        end
        handles.Session{handles.TES_ID}.TES.NoiseS = handles.Session{handles.TES_ID}.TES.NoiseS.NoisefromFile(FileName,fig,handles.Session{handles.TES_ID}.TES);
        handles.Session{handles.TES_ID}.TES.NoiseS = handles.Session{handles.TES_ID}.TES.NoiseS.Plot(fig);
        
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
    case 'Check Superconductor State Noise'
        if handles.Session{handles.TES_ID}.TES.NoiseS.Filled
            fig = handles.Analyzer;
            indAxes = findobj(fig,'Type','Axes');
            delete(indAxes);
            handles.Session{handles.TES_ID}.TES.NoiseS = handles.Session{handles.TES_ID}.TES.NoiseS.Plot(fig);
        else
            waitfor(msgbox('No file previously loaded',handles.VersionStr));
        end
        
    case 'Load TF in Normal State (TFN)'
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        if ~isa(handles.Session{handles.TES_ID}.TES.TFN,'TES_TFN')
            handles.Session{handles.TES_ID}.TES.TFN = TES_TFS;
            handles.Session{handles.TES_ID}.TES.TFN = handles.Session{handles.TES_ID}.TES.TFN.Constructor;
        end
        handles.Session{handles.TES_ID}.TES.TFN = handles.Session{handles.TES_ID}.TES.TFN.TFfromFile(handles.Session{handles.TES_ID}.Path,handles.Analyzer);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
    case 'Check TFN'
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.TFN = handles.Session{handles.TES_ID}.TES.TFN.CheckTF(handles.Analyzer);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
    
    case 'Load Noise in Normal State'
        
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        [filename, pathname] = uigetfile({'*.txt'}, 'Pick a Noise file refering to normal state',[handles.Session{handles.TES_ID}.Path '*.txt']);
        if isequal(filename,0)            
            warndlg('No file selected',handles.VersionStr);
            return;
        end
        FileName = [pathname filename];
        if ~isa(handles.Session{handles.TES_ID}.TES.NoiseN,'TES_BasalNoises')
            handles.Session{handles.TES_ID}.TES.NoiseN = TES_BasalNoises;
            handles.Session{handles.TES_ID}.TES.NoiseN = handles.Session{handles.TES_ID}.TES.NoiseN.Constructor;
        end
        handles.Session{handles.TES_ID}.TES.NoiseN = handles.Session{handles.TES_ID}.TES.NoiseN.NoisefromFile(FileName,fig,handles.Session{handles.TES_ID}.TES);
        handles.Session{handles.TES_ID}.TES.NoiseN = handles.Session{handles.TES_ID}.TES.NoiseN.Plot(fig);
        
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
        
    case 'Check Normal State Noise'
        if handles.Session{handles.TES_ID}.TES.NoiseN.Filled
            fig = handles.Analyzer;
            indAxes = findobj(fig,'Type','Axes');
            delete(indAxes);
            handles.Session{handles.TES_ID}.TES.NoiseN = handles.Session{handles.TES_ID}.TES.NoiseN.Plot(fig);
        else
            waitfor(msgbox('No file previously loaded',handles.VersionStr));
        end
        
    case 'Z(w) Derived L'
    
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        L = handles.Session{handles.TES_ID}.TES.fitLcircuit;
        
        ax = axes(fig);
        semilogx(ax,handles.Session{handles.TES_ID}.TES.TFS.f,...
            imag(handles.Session{handles.TES_ID}.TES.TFS.tf./handles.Session{handles.TES_ID}.TES.TFN.tf),'DisplayName','Experimental Data')
        hold(ax,'on');
        grid(ax,'on');
        semilogx(ax,handles.Session{handles.TES_ID}.TES.TFS.f,...
            fitLfcn(L,handles.Session{handles.TES_ID}.TES.TFS.f,handles.Session{handles.TES_ID}.TES),'.-r','DisplayName','Fitting Data')        
        
        xlabel(ax,'Freq (Hz)','FontSize',12,'FontWeight','bold');
        ylabel(ax,'Imag(TFS/TFN)','FontSize',12,'FontWeight','bold');
        set(ax,'FontSize',12,'FontWeight','bold')
        ButtonName = questdlg(['Estimation of L: ' num2str(L) ', do you want to update L value to circuit?'], ...
            handles.VersionStr, ...
            'Yes', 'No', 'No');
        switch ButtonName
            case 'Yes'
                handles.Session{handles.TES_ID}.TES.circuit.L.Value = L;
                msgbox('Parameter L updated',handles.VersionStr)
        end % switch
        
        
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
    
    case 'Fit Z(w)-Noise to ElectroThermal Model'
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.FitZset;
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
        
    case 'Import Critical Currents'
        fig = handles.Analyzer;
        [handles.Session{handles.TES_ID}.TES.IC, Status]= handles.Session{handles.TES_ID}.TES.IC.ImportICs(handles.Session{handles.TES_ID}.Path,fig);        
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        if Status
            handles.Session{handles.TES_ID}.TES.PlotCriticalCurrent(fig);
        else
            handles.Session{handles.TES_ID}.TES.IC = handles.Session{handles.TES_ID}.TES.IC.Constructor;
        end
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
        
    case 'Import Field Scan'
        fig = handles.Analyzer;
        [handles.Session{handles.TES_ID}.TES.FieldScan, Status] = handles.Session{handles.TES_ID}.TES.FieldScan.ImportScan(handles.Session{handles.TES_ID}.Path,fig);
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        if Status
            handles.Session{handles.TES_ID}.TES.PlotFieldScan(fig);
        else
            handles.Session{handles.TES_ID}.TES.FieldScan.Constructor;
        end
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
        
    case 'Save TES Data'
        handles.Session{handles.TES_ID}.TES.Save([handles.Session{handles.TES_ID}.Path 'TES_' handles.Session{handles.TES_ID}.Tag]);
        Enabling(handles.Session{handles.TES_ID},handles.TES_ID,handles.Analyzer);
        
end
guidata(src,handles);


function Plot(src,evnt)

handles = guidata(src);
switch src.Label
    case 'Plot NKGT Set'
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        rp = [handles.Session{handles.TES_ID}.TES.TESThermalP.Rn.Value handles.Session{handles.TES_ID}.TES.TESThermalN.Rn.Value];
        handles.Session{handles.TES_ID}.TES.plotNKGTset(fig,rp);
        
    case 'Plot RTs Set'
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.plotRTs(fig);
        
    case 'Plot ABCT Set'
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.plotABCT(fig);
    case 'Plot Z(w) vs %Rn'
%         fig.hObject = handles.Analyzer;
%         indAxes = findobj(fig.hObject,'Type','Axes');
%         delete(indAxes);
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
        handles.Session{handles.TES_ID}.TES.PlotTFTbathRp(Tbath,Rn);
        ButtonName = questdlg('Plot Real Z(w) and Imag Z(w) vs frequency?', ...
            handles.VersionStr, ...
            'Yes', 'No', 'No');
        switch ButtonName
            case 'Yes'
                handles.Session{handles.TES_ID}.TES.PlotTFReImagTbathRp(Tbath,Rn);
        end % switch
        
    case 'Plot Noise vs %Rn'
%         fig.hObject = handles.Analyzer;
%         indAxes = findobj(fig.hObject,'Type','Axes');
%         delete(indAxes);
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
        
    case 'Plot IV-Z'
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
        handles.Session{handles.TES_ID}.TES.CompareIV_Z(handles.Session{handles.TES_ID}.TES.IVsetP,handles.Session{handles.TES_ID}.TES.PP,Tbath,fig)
        handles.Session{handles.TES_ID}.TES.CompareIV_Z(handles.Session{handles.TES_ID}.TES.IVsetN,handles.Session{handles.TES_ID}.TES.PN,Tbath,fig)
        
    case 'Plot Critical Currents'
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.PlotCriticalCurrent(fig.hObject);
    case 'Plot Field Scan'
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.PlotFieldScan(fig.hObject);
end
guidata(src,handles);

function MacroTES(src,evnt)

handles = guidata(src);
Markers = {'o';'x';'+';'*';'s';'d';'v';'^';'.';'<';'>';'p';'h'};
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
        Lines_old = [];
        j = 1;        
        for i = s
            SessionName = handles.Session{i}.Tag;
            SessionName(SessionName == '_') = ' ';
            rp = [handles.Session{i}.TES.TESThermalP.Rn.Value handles.Session{i}.TES.TESThermalN.Rn.Value];
            if isempty(rp)
                continue;
            end
            handles.Session{i}.TES.plotNKGTset(fig,rp);
            Lines = findobj(fig.hObject,'Type','Line');
            Lines = setdiff(Lines,Lines_old);
            for Ln = 1:length(Lines)
                if i == s(1)
                    Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                    Lines(Ln).UserData = i;
                    if ~strcmp(Lines(Ln).DisplayName,['Operating Point - ' SessionName])
                        Lines(Ln).Marker = Markers{j};
                        Lines(Ln).MarkerSize = 6;
                        %                         Lines(Ln).Color = colors(j,:);
                    end
                else
                    if ~isequal(Lines(Ln).UserData,i-1)
                        Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                        Lines(Ln).UserData = i;
                        if ~strcmp(Lines(Ln).DisplayName,['Operating Point - ' SessionName])
                            Lines(Ln).Marker = Markers{j};
                            Lines(Ln).MarkerSize = 6;
                            %                             Lines(Ln).Color = colors(j,:);
                        end
                        
                    end
                end
            end
            Lines_old = [Lines_old;Lines];
            j = j+1;
        end
        
    case 'Plot RTs Sets'
        str = cellstr(handles.Loaded_TES.String);
        [s,~] = listdlg('PromptString','Select Loaded TES:',...
            'SelectionMode','multiple',...
            'ListString',str);
        if isempty(s)
            return;
        end
        fig = handles.Analyzer;
        indAxes = findobj(fig,'Type','Axes');
        delete(indAxes);
        
        colors = distinguishable_colors(length(s));
        Lines_old = [];
        j = 1;
        for i = s
            SessionName = handles.Session{i}.Tag;
            SessionName(SessionName == '_') = ' ';
            handles.Session{i}.TES = handles.Session{i}.TES.plotRTs(fig);
            Lines = findobj(fig,'Type','Line');
            Lines = setdiff(Lines,Lines_old);
            for Ln = 1:length(Lines)
                if i == s(1)
                    Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                    US = Lines(Ln).UserData;
                    Lines(Ln).UserData = [US; i];
                    Lines(Ln).Marker = Markers{j};
                    Lines(Ln).MarkerSize = 6;
%                     Lines(Ln).Color = colors(j,:);
                else
                    US = Lines(Ln).UserData;
                    if length(US)<5
                        Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                        Lines(Ln).UserData = [US; i];
                        Lines(Ln).Marker = Markers{j};
                        Lines(Ln).MarkerSize = 6;
%                         Lines(Ln).Color = colors(j,:);
                    end
                end
            end
            Lines_old = [Lines_old;Lines];
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
        Lines_old = [];
        j = 1;
        for i = s
            SessionName = handles.Session{i}.Tag;
            SessionName(SessionName == '_') = ' ';
            handles.Session{i}.TES.plotABCT(fig);
            Lines = findobj(fig.hObject,'Type','Line');
            Lines = setdiff(Lines,Lines_old);
            for Ln = 1:length(Lines)
                if i == s(1)
                    Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                    US = Lines(Ln).UserData;
                    Lines(Ln).UserData = [US; i];
                    Lines(Ln).Marker = Markers{j};
                    Lines(Ln).MarkerSize = 6;
%                     Lines(Ln).Color = colors(j,:);
                else
                    US = Lines(Ln).UserData;
                    if length(US)<5
                        Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                        Lines(Ln).UserData = [US; i];
                        Lines(Ln).Marker = Markers{j};
                        Lines(Ln).MarkerSize = 6;
%                         Lines(Ln).Color = colors(j,:);
                    end
                end
            end
            Lines_old = [Lines_old;Lines];
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
        for k = 1:length(Axes)
            Axes(k).UserData = data{k};
        end
        
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
        pause(0.2)
        delete(indAxes);
        
        
        str = fieldnames(handles.Session{handles.TES_ID}.TES.PP(1).p);
        dummy = uimenu('Visible','off');
        waitfor(GraphicTESData(str,dummy));
        data = dummy.UserData;        
        
        Markers = {'o';'x';'+';'*';'s';'d';'v';'^';'.';'<';'>';'p';'h'};                
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
                    Tbath_ref = str2double(str(s))';
                    Rn = [];                   
                    
%                     handles.Session{handles.TES_ID}.TES.PlotTESData(data.param1,[],Tbath,handles.Analyzer);
                    
%                     colors = distinguishable_colors(length(s1));
                    Lines_old = [];
                    j = 1;
                    for i = s1
                        TbathNums = unique([[handles.Session{i}.TES.PP.Tbath] ...
                            [handles.Session{i}.TES.PN.Tbath]]);
                        Tbath = intersect(TbathNums,Tbath_ref);
                        SessionName = handles.Session{i}.Tag;
                        SessionName(SessionName == '_') = ' ';
                        handles.Session{i}.TES.PlotTESData(data.param1,Rn,Tbath,handles.Analyzer);
                        Lines = findobj(fig.hObject,'Type','Line');
                        Lines = setdiff(Lines,Lines_old);
                        
                        jp = [];
                        jn = [];
                        for k = 1:length(Lines)
                            Tag = [Lines(k).DisplayName];
                            if ~isempty(strfind(Tag,'Positive'))
                                TbathP(k) = sscanf(Tag(strfind(Tag,':')+1:strfind(Tag,'mK')+1),'%d mK ');
                                jp = [jp k];
                            end
                            if ~isempty(strfind(Tag,'Negative'))
                                TbathN(k) = sscanf(Tag(strfind(Tag,':')+1:strfind(Tag,'mK')+1),'%d mK ');
                                jn = [jn k];
                            end
                        end
                        LinesP = Lines(jp);
                        [val,ind] = sort(TbathP(jp));
                        LinesP = LinesP(ind);
                        LinesN = Lines(jn);
                        [val,ind] = sort(TbathN(jn));
                        LinesN = LinesN(ind);
                        Lines = [LinesP;LinesN];
                                                
                        colors = distinguishable_colors(length(Lines));
                        
                        for Ln = 1:length(Lines)
                            if i == s1(1)
                                Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                                Lines(Ln).UserData = i;
                                Lines(Ln).Color = colors(Ln,:);
                                Lines(Ln).Marker = Markers{j};
                                Lines(Ln).MarkerSize = 6;
                            else
                                if ~isequal(Lines(Ln).UserData,i-1)
                                    Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                                    Lines(Ln).UserData = i;
                                    Lines(Ln).Color = colors(Ln,:);
                                    Lines(Ln).Marker = Markers{j};
                                    Lines(Ln).MarkerSize = 6;
                                end
                            end
                        end
                        Lines_old = [Lines_old;Lines];
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
                    
                    %                     colors = distinguishable_colors(length(s1));
                    Lines_old = [];
                    j = 1;
                    for i = s1
                        SessionName = handles.Session{i}.Tag;
                        SessionName(SessionName == '_') = ' ';
                        handles.Session{i}.TES.PlotTESData(data.param1,Rn,Tbath,handles.Analyzer);
                        Lines = findobj(fig.hObject,'Type','Line');
                        Lines = setdiff(Lines,Lines_old);
                        
                        jp = [];
                        jn = [];
                        for k = 1:length(Lines)
                            Tag = [Lines(k).DisplayName];
                            if ~isempty(strfind(Tag,'Positive'))
                                TbathP(k) = sscanf(Tag(strfind(Tag,':')+1:strfind(Tag,'mK')+1),'%d mK ');
                                jp = [jp k];
                            end
                            if ~isempty(strfind(Tag,'Negative'))
                                TbathN(k) = sscanf(Tag(strfind(Tag,':')+1:strfind(Tag,'mK')+1),'%d mK ');
                                jn = [jn k];
                            end
                        end
                        LinesP = Lines(jp);
                        [val,ind] = sort(TbathP(jp));
                        LinesP = LinesP(ind);
                        LinesN = Lines(jn);
                        [val,ind] = sort(TbathN(jn));
                        LinesN = LinesN(ind);
                        Lines = [LinesP;LinesN];
                                                
                        colors = distinguishable_colors(length(Lines));
                        
                        for Ln = 1:length(Lines)
                            if i == s1(1)
                                Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                                Lines(Ln).UserData = i;
                                Lines(Ln).Color = colors(Ln,:);
                                Lines(Ln).Marker = Markers{j};
                                Lines(Ln).MarkerSize = 6;
                            else
                                if ~isequal(Lines(Ln).UserData,i-1)
                                    Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                                    Lines(Ln).UserData = i;
                                    Lines(Ln).Color = colors(Ln,:);
                                    Lines(Ln).Marker = Markers{j};
                                    Lines(Ln).MarkerSize = 6;
                                end
                            end
                        end
                        Lines_old = [Lines_old;Lines];
                        j = j+1;
                    end                    
                    
                case 3 % Param1 vs. Param2
                    param = data.param1;
                    param2 = data.param2;
                    params = char([{param};{param2}]);
                    Lines_old = [];
                    j = 1;
                    for i = s1
                        SessionName = handles.Session{i}.Tag;
                        SessionName(SessionName == '_') = ' ';
                        handles.Session{i}.TES.PlotTESData(params,[],[],handles.Analyzer);
                        Lines = findobj(fig.hObject,'Type','Line');
                        Lines = setdiff(Lines,Lines_old);
                        
                        jp = [];
                        jn = [];
                        for k = 1:length(Lines)
                            Tag = [Lines(k).DisplayName];
                            if ~isempty(strfind(Tag,'Positive'))
                                TbathP(k) = sscanf(Tag(strfind(Tag,':')+1:strfind(Tag,'mK')+1),'%d mK ');
                                jp = [jp k];
                            end
                            if ~isempty(strfind(Tag,'Negative'))
                                TbathN(k) = sscanf(Tag(strfind(Tag,':')+1:strfind(Tag,'mK')+1),'%d mK ');
                                jn = [jn k];
                            end
                        end
                        LinesP = Lines(jp);
                        [val,ind] = sort(TbathP(jp));
                        LinesP = LinesP(ind);
                        LinesN = Lines(jn);
                        [val,ind] = sort(TbathN(jn));
                        LinesN = LinesN(ind);
                        Lines = [LinesP;LinesN];
                                                
                        colors = distinguishable_colors(length(Lines));
                        
                        for Ln = 1:length(Lines)
                            if i == s1(1)
                                Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                                Lines(Ln).UserData = i;
                                Lines(Ln).Color = colors(Ln,:);
                                Lines(Ln).Marker = Markers{j};
                                Lines(Ln).MarkerSize = 6;
                            else
                                if ~isequal(Lines(Ln).UserData,i-1)
                                    Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                                    Lines(Ln).UserData = i;
                                    Lines(Ln).Color = colors(Ln,:);
                                    Lines(Ln).Marker = Markers{j};
                                    Lines(Ln).MarkerSize = 6;
                                end
                            end
                        end
                        Lines_old = [Lines_old;Lines];
                        j = j+1;
                    end
            end
        else
            return;
        end
    case 'Plots Critical Currents'
        str = cellstr(handles.Loaded_TES.String);
        [s1,~] = listdlg('PromptString','Select Loaded TES:',...
            'SelectionMode','multiple',...
            'ListString',str);
        if isempty(s1)
            return;
        end
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        Lines_old = [];
        j = 1;
        for i = s1
            SessionName = handles.Session{i}.Tag;
            SessionName(SessionName == '_') = ' ';
            handles.Session{i}.TES.PlotCriticalCurrent(handles.Analyzer);
            Lines = findobj(fig.hObject,'Type','Line');
            Lines = setdiff(Lines,Lines_old);
            for Ln = 1:length(Lines)
                if i == s1(1)
                    Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                    Lines(Ln).UserData = i;
                    %                                 Lines(Ln).Color = colors(j,:);
                    Lines(Ln).Marker = Markers{j};
                    Lines(Ln).MarkerSize = 6;
                else
                    if ~isequal(Lines(Ln).UserData,i-1)
                        Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                        Lines(Ln).UserData = i;
                        %                                     Lines(Ln).Color = colors(j,:);
                        Lines(Ln).Marker = Markers{j};
                        Lines(Ln).MarkerSize = 6;
                    end
                end
            end
            Lines_old = [Lines_old;Lines];
            j = j+1;
        end
        
        
        
    case 'Plots Field Scan'
        str = cellstr(handles.Loaded_TES.String);
        [s1,~] = listdlg('PromptString','Select Loaded TES:',...
            'SelectionMode','multiple',...
            'ListString',str);
        if isempty(s1)
            return;
        end
        fig.hObject = handles.Analyzer;
        indAxes = findobj(fig.hObject,'Type','Axes');
        delete(indAxes);
        Lines_old = [];
        j = 1;
        for i = s1
            SessionName = handles.Session{i}.Tag;
            SessionName(SessionName == '_') = ' ';
            handles.Session{i}.TES.PlotFieldScan(handles.Analyzer);
            Lines = findobj(fig.hObject,'Type','Line');
            Lines = setdiff(Lines,Lines_old);
            for Ln = 1:length(Lines)
                if i == s1(1)
                    Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                    Lines(Ln).UserData = i;
                    %                                 Lines(Ln).Color = colors(j,:);
                    Lines(Ln).Marker = Markers{j};
                    Lines(Ln).MarkerSize = 6;
                else
                    if ~isequal(Lines(Ln).UserData,i-1)
                        Lines(Ln).DisplayName = [Lines(Ln).DisplayName ' - ' SessionName];
                        Lines(Ln).UserData = i;
                        %                                     Lines(Ln).Color = colors(j,:);
                        Lines(Ln).Marker = Markers{j};
                        Lines(Ln).MarkerSize = 6;
                    end
                end
            end
            Lines_old = [Lines_old;Lines];
            j = j+1;
        end
end
guidata(src,handles);

function OptionsTES(src,evnt)

handles = guidata(src);
switch src.Label
    case 'P vs T Model Fitting Options' 
        handles.Session{handles.TES_ID}.TES.PvTModel = handles.Session{handles.TES_ID}.TES.PvTModel.View;
        
    case 'Electro Thermal Model Fitting Options'
        handles.Session{handles.TES_ID}.TES.ElectrThermalModel = handles.Session{handles.TES_ID}.TES.ElectrThermalModel.View;
%         handles.Session{handles.TES_ID}.TES.TFOpt = handles.Session{handles.TES_ID}.TES.TFOpt.View;
%     case 'Noise Options'
%         handles.Session{handles.TES_ID}.TES.NoiseOpt = handles.Session{handles.TES_ID}.TES.NoiseOpt.View;
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
        fig = figure('Visible','off','NumberTitle','off','Name',handles.VersionStr,'MenuBar','none','Units','Normalized','Position',[0.35 0.35 0.3 0.22]);
%         
%         set(fig,'Units','Normalized','Position',[0.35 0.35 0.3 0.22]);
        d = dir('Analyzer.m');
%         figure(fig);
        
        axtext = subplot(2,3,1,'Visible','off');
        text(0,0.6,'Software developed by Juan Bolea for QMAD ICMA-CSIC.');
        text(0,0.3,['Last update: ' d.date]);
        text(0,0,['Current version: ' handles.VersionStr]);
        
        
        ax1 = subplot(2,3,4,'Visible','off');
        ax2 = subplot(2,3,5,'Visible','off');
        ax3 = subplot(2,3,6,'Visible','off');
        try
            axes(ax1);
            data = imread('gatete.png');
            image(data)
            ax1.Visible = 'off';
        end
        try
            axes(ax2);
            data = imread('Unizar.png');
            data(data == 0) = 255;
            image(data)
            ax2.Visible = 'off';
        end
        axes(ax3);
        data = imread('ICMA-CSIC.jpg');
        image(data)
        ax3.Visible = 'off';
        fig.Position = [0.35 0.35 0.3 0.22];
        fig.Visible = 'on';
end
guidata(src,handles);


function Enabling(Session,TES_ID,fig)
handles = guidata(fig);
StrEnable = {'on';'off'};
% Verificar si todos los campos están completos
% TES_Circuit (circuit)

% StrLabel_On = {'TES Device';'TES Dimensions';'Circuit Values';...
%     'IV-Curves';'Update Circuit Parameters (Slope IV-Curves)';'Import IV-Curves';...
%     'Critical Currents';'Import Critical Currents';'Field Scan';'Import Field Scan';'Save TES Data';'Options'};
StrLabel_On = {'TES Device';'TES Dimensions';'Circuit Values';...
    'IV-Curves';'Import IV-Curves';...
    'Critical Currents';'Import Critical Currents';'Field Scan';'Import Field Scan';'Save TES Data';'Options'};
for i = 1:length(StrLabel_On)
    h = findobj(fig,'Label',StrLabel_On{i},'Tag','Analyzer');
    h.Enable = StrEnable{(~TES_ID+1)};
end


%   Si hay algun campo vacío (Update from IV curves)
% TES_IVCurveSet (IVsetP o IVsetN)
%   Si están vacios (Import IV curves)
if Session.TES.IVsetP.Filled || Session.TES.IVsetN.Filled
    StrLabel_On = {'Check IV-Curves';'Fit P vs. T';...
        'Superconductor State';'Load TF in Superconductor State (TFS)';'Check TFS';'Load Noise in Superconductor State';'Check Superconductor State Noise';...
        'Normal State';'Load TF in Normal State (TFN)';'Check TFN';'Load Noise in Normal State';'Check Normal State Noise'};
    for i = 1:length(StrLabel_On)
        h = findobj(fig,'Label',StrLabel_On{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)};
    end
else
    StrLabel_Off = {'Check IV-Curves';'Fit P vs. T';...
        'Superconductor State';'Load TF in Superconductor State (TFS)';'Check TFS';'Load Noise in Superconductor State';'Check Superconductor State Noise';...
        'Normal State';'Load TF in Normal State (TFN)';'Check TFN';'Load Noise in Normal State';'Check Normal State Noise'};
    for i = 1:length(StrLabel_Off)
        h = findobj(fig,'Label',StrLabel_Off{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)+1};
    end
end


% TES_Gset (GsetP o GsetN)
%   Si están vacios (FitPset)
if Session.TES.GsetP.Filled || Session.TES.GsetN.Filled
    StrLabel_On = {'TES Thermal Parameters vs. %Rn';'TES Thermal Parameter Values';'Get G(T)';...
        'Plot';'Plot NKGT Set'};
    for i = 1:length(StrLabel_On)
        h = findobj(fig,'Label',StrLabel_On{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)};
    end
else
    StrLabel_Off = {'TES Thermal Parameters vs. %Rn';'TES Thermal Parameter Values';'Get G(T)';...
        'Plot';'Plot NKGT Set'};
    for i = 1:length(StrLabel_Off)
        h = findobj(fig,'Label',StrLabel_Off{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)+1};
    end
end
if (Session.TES.TESThermalP.Filled)||Session.TES.TESThermalN.Filled
    StrLabel_On = {'Plot';'Plot RTs Set'};
    for i = 1:length(StrLabel_On)
        h = findobj(fig,'Label',StrLabel_On{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)};
    end
else
    StrLabel_Off = {'Plot';'Plot RTs Set'};
    for i = 1:length(StrLabel_Off)
        h = findobj(fig,'Label',StrLabel_Off{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)+1};
    end
end
% TES_Param (TES)
%   Si están vacios (plotNKGT)
if (Session.TES.TESThermalP.Filled && Session.TES.TFS.Filled)
    StrLabel_On = {'Z(w)-Noise Analysis';'Fit Z(w)-Noise to ElectroThermal Model';'Re-Analyze Loaded TES'};
    for i = 1:length(StrLabel_On)
        h = findobj(fig,'Label',StrLabel_On{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)};
    end
else
    StrLabel_Off = {'Z(w)-Noise Analysis';'Fit Z(w)-Noise to ElectroThermal Model';'Re-Analyze Loaded TES'};
    for i = 1:length(StrLabel_Off)
        h = findobj(fig,'Label',StrLabel_Off{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)+1};
    end
end
try
    if Session.TES.TFS.Filled && Session.TES.TFN.Filled
        StrLabel_On = {'Z(w) Derived L'};
        for i = 1:length(StrLabel_On)
            h = findobj(fig,'Label',StrLabel_On{i},'Tag','Analyzer');
            h.Enable = StrEnable{(~TES_ID+1)};
        end
    else
        StrLabel_Off = {'Z(w) Derived L'};
        for i = 1:length(StrLabel_Off)
            h = findobj(fig,'Label',StrLabel_Off{i},'Tag','Analyzer');
            h.Enable = StrEnable{(~TES_ID+1)+1};
        end
    end
catch
    StrLabel_Off = {'Z(w) Derived L'};
    for i = 1:length(StrLabel_Off)
        h = findobj(fig,'Label',StrLabel_Off{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)+1};
    end
end
% TES_P (PP o PN)
%   Si están vacios (FitZset)
if any(Session.TES.PP.Filled) || any(Session.TES.PN.Filled)
    StrLabel_On = {'Plot ABCT Set';'Plot Z(w) vs %Rn';'Plot Noise vs %Rn';'Plot TES Data';'Plot IV-Z';...
        'Summary';'Z(w)-Noise Viewer';'Word Graphical Report'};
    for i = 1:length(StrLabel_On)
        h = findobj(fig,'Label',StrLabel_On{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)};
    end
else
    StrLabel_Off = {'Plot ABCT Set';'Plot Z(w) vs %Rn';'Plot Noise vs %Rn';'Plot TES Data';'Plot IV-Z';...
        'Summary';'Z(w)-Noise Viewer';'Word Graphical Report'};
    for i = 1:length(StrLabel_Off)
        h = findobj(fig,'Label',StrLabel_Off{i},'Tag','Analyzer');
        h.Enable = StrEnable{(~TES_ID+1)+1};
    end
end


try
    if Session.TES.IC.Filled
        StrLabel_On = {'Plot';'Plot Critical Currents'};
        for i = 1:length(StrLabel_On)
            h = findobj(fig,'Label',StrLabel_On{i},'Tag','Analyzer');
            h.Enable = StrEnable{(~TES_ID+1)};
        end
    else
        StrLabel_Off = {'Plot Critical Currents'};
        for i = 1:length(StrLabel_Off)
            h = findobj(fig,'Label',StrLabel_Off{i},'Tag','Analyzer');
            h.Enable = StrEnable{(~TES_ID+1)+1};
        end
    end
    
    if Session.TES.FieldScan.Filled
        StrLabel_On = {'Plot';'Plot Field Scan'};
        for i = 1:length(StrLabel_On)
            h = findobj(fig,'Label',StrLabel_On{i},'Tag','Analyzer');
            h.Enable = StrEnable{(~TES_ID+1)};
        end
    else
        StrLabel_Off = {'Plot Field Scan'};
        for i = 1:length(StrLabel_Off)
            h = findobj(fig,'Label',StrLabel_Off{i},'Tag','Analyzer');
            h.Enable = StrEnable{(~TES_ID+1)+1};
        end
    end
    
        
catch
end

if Session.TES.TESParamP.Filled||Session.TES.TESParamN.Filled
    StrLabel_On = {'TES Parameters'};
        for i = 1:length(StrLabel_On)
            h = findobj(fig,'Label',StrLabel_On{i},'Tag','Analyzer');
            h.Enable = StrEnable{(~TES_ID+1)};
        end
end


% Enabling menus in Macro mode.
Ok_Thermal = zeros(1,length(handles.Session));
Ok_PP = zeros(1,length(handles.Session));
Ok_IC = zeros(1,length(handles.Session));
Ok_FieldScan = zeros(1,length(handles.Session));
for i = 1:length(handles.Session)
    Ok_Thermal(1,i) = or(handles.Session{i}.TES.TESThermalP.Filled,handles.Session{i}.TES.TESThermalN.Filled);
    Ok_PP(1,i) = any([handles.Session{i}.TES.PP.Filled handles.Session{i}.TES.PN.Filled]);
    Ok_IC(1,i) = handles.Session{i}.TES.IC.Filled;
    Ok_FieldScan(1,i) = handles.Session{i}.TES.FieldScan.Filled;
end
StrLabel_On = {'Plot NKGT Sets';'Plot RTs Sets'};
for i = 1:length(StrLabel_On)
    h = findobj(fig,'Label',StrLabel_On{i},'Tag','Analyzer');
    if any(Ok_Thermal)
        h.Enable = 'on';
    else
        h.Enable = 'off';
    end
end

StrLabel_On = {'Plot ABCT Sets';'Plot TESs Data'};
for i = 1:length(StrLabel_On)
    h = findobj(fig,'Label',StrLabel_On{i},'Tag','Analyzer');
    if any(Ok_PP)
        h.Enable = 'on';
    else
        h.Enable = 'off';
    end
end

StrLabel_On = {'Plots Critical Currents'};
for i = 1:length(StrLabel_On)
    h = findobj(fig,'Label',StrLabel_On{i},'Tag','Analyzer');
    if any(Ok_IC)
        h.Enable = 'on';
    else
        h.Enable = 'off';
    end
end
StrLabel_On = {'Plots Field Scan'};
for i = 1:length(StrLabel_On)
    h = findobj(fig,'Label',StrLabel_On{i},'Tag','Analyzer');
    if any(Ok_FieldScan)
        h.Enable = 'on';
    else
        h.Enable = 'off';
    end
end



% --- Executes when user attempts to close Analyzer.
function Analyzer_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to Analyzer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
ButtonName = questdlg('Are you sure to close Analyzer?', ...
        handles.VersionStr, ...
        'Yes', 'No', 'Yes');
    switch ButtonName
        case 'No'
            return;
    end

if handles.TES_ID ~= 0
    ButtonName = questdlg('Do you want to save before exit?', ...
        handles.VersionStr, ...
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
        ha = findobj(hObject,'Type','Axes');
        if isempty(ha)
            set(hObject,'uicontextmenu',[]);
        else
            cmenu = uicontextmenu('Visible','on');
            c6 = uimenu(cmenu,'Label','Save Graph','Callback',{@SaveGraph},'UserData',hObject);
            set(hObject,'uicontextmenu',cmenu);        
        end
    case 'normal' % Botón izquierdo
    case 'extend' % Pulsando Ruleta del raton
end
        
function SaveGraph(src,evnt)
ha = findobj(src.UserData,'Type','Axes');
   
fg = figure;
copyobj(ha,fg);
[file,path] = uiputfile('*.jpg','Save Graph name');
if ~isequal(file,0)
    print(fg,'-djpeg',[path filesep file]);
%     hgsave(fg,[path filesep file]);
end
% pause;