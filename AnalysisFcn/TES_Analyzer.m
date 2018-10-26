function varargout = TES_Analyzer(varargin)
% TES_ANALYZER MATLAB code for TES_Analyzer.fig
%      TES_ANALYZER, by itself, creates a new TES_ANALYZER or raises the existing
%      singleton*.
%
%      H = TES_ANALYZER returns the handle to a new TES_ANALYZER or the handle to
%      the existing singleton*.
%
%      TES_ANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TES_ANALYZER.M with the given input arguments.
%
%      TES_ANALYZER('Property','Value',...) creates a new TES_ANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TES_Analyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TES_Analyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TES_Analyzer

% Last Modified by GUIDE v2.5 26-Oct-2018 10:41:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TES_Analyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @TES_Analyzer_OutputFcn, ...
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


% --- Executes just before TES_Analyzer is made visible.
function TES_Analyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TES_Analyzer (see VARARGIN)

% Choose default command line output for TES_Analyzer
handles.output = hObject;

position = get(handles.TES_Analysis,'Position');
set(handles.TES_Analysis,'Color',[200 200 200]/255,'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');

handles.TES_ID = 0;

% First TES_Analyzer Session is created by default


%% Generating the uimenus
IndMenu = 1;
MenuTES.Label{IndMenu} = {'TES Data'};
MenuTES.SubMenu{IndMenu} = {'Load';'New TES Analysis';'Set TF in Superconductor State (TFS)';'Check TFS';'Save TES Data'};
MenuTES.Fcn{IndMenu} = {'TESData'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'TES device'};
MenuTES.SubMenu{IndMenu} = {'TES Dimensions';'Circuit Values';'TES Operating Point Parameters';'Change TES Operating Point'};
MenuTES.Fcn{IndMenu} = {'TES_Device'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'IV-Curves'};
MenuTES.SubMenu{IndMenu} = {'Import IV-Curves';'Check IV-Curves';...
    'Update Circuit Parameters (Slope IV-Curves)';'Fit P vs. T'};
MenuTES.Fcn{IndMenu} = {'IV_Curves'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'Z(w)-Noise'};
MenuTES.SubMenu{IndMenu} = {'Fit Z(w)-Noise to ElectroThermal Model'};
MenuTES.Fcn{IndMenu} = {'ZwNoise'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'View'};
MenuTES.SubMenu{IndMenu} = {'Plot NKGT Set';'Plot ABCT Set';...
    'Plot TF vs Tbath';'Plot Noise vs Tbath';'Plot TES Data'};
MenuTES.Fcn{IndMenu} = {'View'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'Options'};
MenuTES.SubMenu{IndMenu} = {'TF Options';'Noise Options'};
MenuTES.Fcn{IndMenu} = {'OptionsTES'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'Summary'};
MenuTES.SubMenu{IndMenu} = {'TF-Noise Viewer';'Word Graphical Report'};
MenuTES.Fcn{IndMenu} = {'SummaryTES'};
IndMenu = IndMenu +1;

MenuTES.Label{IndMenu} = {'Help'};
MenuTES.SubMenu{IndMenu} = {'Guide';'About'};
MenuTES.Fcn{IndMenu} = {'HelpTES'};
IndMenu = IndMenu +1;

for i = 1:length(MenuTES.Label)
    handles.menu(i,1) = uimenu('Parent',handles.TES_Analysis,'Label',...
        MenuTES.Label{i}{1});
    for j = 1:length(MenuTES.SubMenu{i})
        eval(['handles.submenu(i,j) = uimenu(''Parent'',handles.menu(i),''Label'','...
            '''' MenuTES.SubMenu{i}{j} ''',''Callback'',{@' MenuTES.Fcn{i}{1} '});']);        
    end
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TES_Analyzer wait for user response (see UIRESUME)
% uiwait(handles.TES_Analysis);


% --- Outputs from this function are returned to the command line.
function varargout = TES_Analyzer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
set(handles.TES_Analysis,'Visible','on');

% --- Executes on selection change in Loaded_TES.
function Loaded_TES_Callback(hObject, eventdata, handles)
% hObject    handle to Loaded_TES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Loaded_TES contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Loaded_TES
handles.TES_ID = get(hObject,'Value');

% --- Executes during object creation, after setting all properties.
function Loaded_TES_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Loaded_TES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TESData(src,evnt)

handles = guidata(src);
switch src.Label
    case 'Load'
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
            handles.TES_ID = handles.TES_ID+1;
            Session.ID = handles.TES_ID;
            handles.Session{handles.TES_ID} = Session;            
            for i = 1:handles.TES_ID
                ListStr = {handles.Session{i}.Tag};
            end
            set(handles.LoadedStr,'Visible','on')
            set(handles.Loaded_TES,'String',char(ListStr),'Value',handles.TES_ID,'Visible','on');
        end
        
    case 'New TES Analysis'
        obj = TES_Analyzer_Session;
        
        DataPath = uigetdir('', 'Pick a Data path named Z(w)-Ruido');
        if DataPath ~= 0
            DataPath = [DataPath filesep];
        else
            errordlg('Invalid Data path name!','ZarTES v1.0','modal');
            return;
        end        
        % Creamos la superestructura del TES
        TESDATA = TES_Struct;
        TESDATA = TESDATA.Constructor;
        TESDATA.circuit = TESDATA.circuit.IVcurveSlopesFromData(DataPath);
        TESDATA.TFS = TESDATA.TFS.TFfromFile(DataPath);
        [TESDATA.IVsetP, TempLims] = TESDATA.IVsetP.ImportFromFiles(TESDATA,DataPath);
        TESDATA.IVsetN = TESDATA.IVsetN.ImportFromFiles(TESDATA,TESDATA.IVsetP(1).IVsetPath, TempLims);
        TESDATA = TESDATA.CheckIVCurvesVisually;
        
        TESDATA = TESDATA.fitPvsTset;
        TESDATA = TESDATA.plotNKGTset;
        TESDATA = TESDATA.EnterDimensions;
        TESDATA = TESDATA.FitZset;
        TESDATA.plotABCT;
        % Recopila las gráficas más importantes,
        TESDATA.PlotTFTbathRp;
        TESDATA.PlotNoiseTbathRp;
        TESDATA.GraphsReport;
        TESDATA.Save;
        
    case 'Set TF in Superconductor State (TFS)'     
        indAxes = findobj('Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.TFS = handles.Session{handles.TES_ID}.TES.TFS.TFfromFile(handles.Session{handles.TES_ID}.Path,handles.TES_Analysis);
    case 'Check TFS'
        indAxes = findobj('Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.TFS = handles.Session{handles.TES_ID}.TES.TFS.CheckTF(handles.TES_Analysis);
    case 'Save TES Data'
        handles.Session{handles.TES_ID}.TES.Save;
        
end
guidata(src,handles);

function TES_Device(src,evnt)

handles = guidata(src);
switch src.Label
    case 'TES Dimensions'
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.EnterDimensions;
    case 'Circuit Values'
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.CheckCircuit;
    case 'TES Operating Point Parameters'
        indAxes = findobj('Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.TES.CheckValues;
    case 'Change TES Operating Point'        
        fig.hObject = handles.TES_Analysis;
        indAxes = findobj('Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.plotNKGTset(fig);
        
end
guidata(src,handles);

function IV_Curves(src,evnt)

handles = guidata(src);
switch src.Label
    case 'Import IV-Curves'
        [handles.Session{handles.TES_ID}.TES.IVsetP, TempLims] = handles.Session{handles.TES_ID}.TES.IVsetP.ImportFromFiles(handles.Session{handles.TES_ID}.TES,handles.Session{handles.TES_ID}.Path);
        handles.Session{handles.TES_ID}.TES.IVsetN = handles.Session{handles.TES_ID}.TES.IVsetN.ImportFromFiles(handles.Session{handles.TES_ID}.TES,IVsetP(1).IVsetPath, TempLims);
    case 'Check IV-Curves'
        indAxes = findobj('Type','Axes');
        delete(indAxes);
        fig.hObject = handles.TES_Analysis;
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.CheckIVCurvesVisually(fig);        
    case 'Update Circuit Parameters (Slope IV-Curves)'
        indAxes = findobj('Type','Axes');
        delete(indAxes);
        obj = handles.Session{handles.TES_ID}.TES.circuit.IVcurveSlopesFromData(handles.Session{handles.TES_ID}.Path,handles.TES_Analysis);
        if isa(obj,'TES_Circuit')
            handles.Session{handles.TES_ID}.TES.circuit = obj;
        end
    case 'Fit P vs. T'
        indAxes = findobj('Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.fitPvsTset([],[],handles.TES_Analysis);
end
guidata(src,handles);

function ZwNoise(src,evnt)

handles = guidata(src);
switch src.Label    
    case 'Fit Z(w)-Noise to ElectroThermal Model'
        indAxes = findobj('Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES = handles.Session{handles.TES_ID}.TES.FitZset(handles.TES_Analysis);
end
guidata(src,handles);


function View(src,evnt)

handles = guidata(src);
switch src.Label
    case 'Plot NKGT Set'
        fig.hObject = handles.TES_Analysis;
        indAxes = findobj('Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.plotNKGTset(fig,1);
    case 'Plot ABCT Set'
        fig.hObject = handles.TES_Analysis;
        indAxes = findobj('Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.plotABCT(fig);
    case 'Plot TF vs Tbath'
        indAxes = findobj('Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.PlotTFTbathRp([]);
    case 'Plot Noise vs Tbath'
        indAxes = findobj('Type','Axes');
        delete(indAxes);
        handles.Session{handles.TES_ID}.TES.PlotNoiseTbathRp([]); 
        
    case 'Plot TES Data'
        indAxes = findobj('Type','Axes');
        delete(indAxes);
        str = fieldnames(handles.Session{handles.TES_ID}.TES.PP(1).p);
        [s,~] = listdlg('PromptString','Select a model parameter:',...
            'SelectionMode','single',...
            'ListString',str);
        if isempty(s)
            return;
        end
        param = str{s};
        ButtonName = questdlg('What''s next?', ...
            'ZarTES v1.0', ...
            [param ' vs. Tbath'], [param ' vs. Rn'], [param ' vs. Tbath']);
        switch ButtonName
            case [param ' vs. Tbath']
                prompt = {'Enter the Rn range:'};
                name = 'Rn range (0 < Rn < 1)';
                numlines = [1 70];
                defaultanswer = {'0.5:0.05:0.8'};
                answer = inputdlg(prompt,name,numlines,defaultanswer);
                Rn = eval(['[' answer{1} ']']);
                handles.Session{handles.TES_ID}.TES.PlotTESData(param,Rn,[],handles.TES_Analysis);
            case [param ' vs. Rn']
                str = cellstr(num2str(unique([[handles.Session{handles.TES_ID}.TES.PP.Tbath] ...
                    [handles.Session{handles.TES_ID}.TES.PN.Tbath]])'));
                [s,~] = listdlg('PromptString','Select a model parameter:',...
                    'SelectionMode','multiple',...
                    'ListString',str);
                if isempty(s)
                    return;
                end
                Tbath = str2double(str(s))';
                handles.Session{handles.TES_ID}.TES.PlotTESData(param,[],Tbath,handles.TES_Analysis);
        end % switch
        
end
guidata(src,handles);

function OptionsTES(src,evnt)

handles = guidata(src);
switch src.Label
    case 'TF Options'
%         handles.Session{handles.TES_ID}.TES.TFOpt = handles.Session{handles.TES_ID}.TES.TFOpt.View;
    case 'Noise Options'
%         handles.Session{handles.TES_ID}.TES.NoiseOpt = handles.Session{handles.TES_ID}.TES.NoiseOpt.View;
end
guidata(src,handles);

function SummaryTES(src,evnt)

handles = guidata(src);
switch src.Label
    case 'TF-Noise Viewer'
        handles.Session{handles.TES_ID}.TES.TFNoiseViever;
    case 'Word Graphical Report'  
        handles.Session{handles.TES_ID}.TES.GraphsReport;
        
end
guidata(src,handles);

function HelpTES(src,evnt)

handles = guidata(src);
switch src.Label
    case 'Guide'
        
    case 'About'
        
end
guidata(src,handles);
