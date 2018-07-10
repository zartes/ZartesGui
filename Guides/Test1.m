function varargout = Test1(varargin)
% TEST1 MATLAB code for Test1.fig
%      TEST1, by itself, creates a new TEST1 or raises the existing
%      singleton*.
%
%      H = TEST1 returns the handle to a new TEST1 or the handle to
%      the existing singleton*.
%
%      TEST1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST1.M with the given input arguments.
%
%      TEST1('Property','Value',...) creates a new TEST1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Test1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Test1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Test1

% Last Modified by GUIDE v2.5 03-Jul-2018 12:25:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Test1_OpeningFcn, ...
                   'gui_OutputFcn',  @Test1_OutputFcn, ...
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


% --- Executes just before Test1 is made visible.
function Test1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Test1 (see VARARGIN)

% Choose default command line output for Test1
handles.output = hObject;

position = get(handles.figure1,'Position');
set(handles.figure1,'Color',[0.95 0.95 0.95],'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');

% Initialization of setting parameters
handles.TempFileDir = [];
handles.TempFileName = [];
handles.FieldFileDir = [];
handles.FieldFileName = [];

% Initialization of classes 
handles.circuit = Circuit;
handles.HndlStr(:,1) = {'Multi';'Squid';'CurSour';'SpecAnal';'PXI'};
handles.HndlStr(:,2) = {'Multimeter';'ElectronicMagnicon';'CurrentSource';'SpectrumAnalyzer';'PXI_Acquisition_card'};

for i = 1:size(handles.HndlStr,1)
    eval(['handles.' handles.HndlStr{i,1} '=' handles.HndlStr{i,2} ';']);
    eval(['handles.' handles.HndlStr{i,1} '= handles.' handles.HndlStr{i,1} '.Constructor;']);    
    eval(['handles.Devices.' handles.HndlStr{i,1} ' = 0;']); % By default all are deactivated
end



handles.EnableStr = {'off';'on'};


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Test1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Test1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

set(handles.figure1,'Visible','on');
guidata(hObject,handles);

function ActivateStartButton(handles)
Value = (handles.IVs.Value||handles.ZN.Value||handles.Pulses.Value);
handles.Start.Enable = handles.EnableStr{Value+1};


% --- Executes on button press in IVs.
function IVs_Callback(hObject, eventdata, handles)
% hObject    handle to IVs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IVs
ActivateStartButton(handles);

% --- Executes on button press in ZN.
function ZN_Callback(hObject, eventdata, handles)
% hObject    handle to ZN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ZN
ActivateStartButton(handles)

% --- Executes on button press in Pulses.
function Pulses_Callback(hObject, eventdata, handles)
% hObject    handle to Pulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Pulses
ActivateStartButton(handles)


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

try
    if eventdata.Key == 'escape'
        delete(handles.figure1);
    elseif eventdata.Key == 'return'
        if strcmp(get(handles.save,'Enable'),'on')
            Start_Callback(handles.Start,eventdata,handles);
        end
    end
catch
end


% --- Executes on button press in TempBrowse.
function TempBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to TempBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[TempFileName, TempFileDir] = uigetfile({'*.stb','Example file (*.stb)'},...
    'Select file','tmp\T*.stb');

if ~isempty(TempFileName)&&~isequal(TempFileName,0)
    handles.TempFileDir = TempFileDir;
    handles.TempFileName = TempFileName;
    set(handles.TempFile,'String',[TempFileDir TempFileName],...
        'TooltipString',[TempFileDir TempFileName]);
else    
    set(handles.TempFile,'String','No file selected');
    return;
end
guidata(hObject,handles);


% --- Executes on button press in FieldBrowse.
function FieldBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to FieldBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FieldFileName, FieldFileDir] = uigetfile({'*.stb','Example file (*.stb)'},...
    'Select file','tmp\F*.stb');

if ~isempty(FieldFileName)&&~isequal(FieldFileName,0)
    handles.FieldFileDir = FieldFileDir;
    handles.FieldFileName = FieldFileName;
    set(handles.FieldFile,'String',[FieldFileDir FieldFileName],...
        'TooltipString',[FieldFileDir FieldFileName]);
else    
    set(handles.FieldFile,'String','No file selected');
    return;
end
guidata(hObject,handles);


% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% Check if Temperature of bath was set
if isempty(handles.TempFileName)
    ButtonName = questdlg('Set of T baths not provided, if continue current bath temp will be set. Do you want to continue?', ...
        'Setting parameters', ...
        'Yes', 'No', 'No');
    switch ButtonName
        case 'Yes'
            handles.TempFile.String = 'Current bath temp';
        otherwise
            uiwait(msgbox('Acquisition mode interrupted'));
            return;
    end
end

if isempty(handles.FieldFileName)
    ButtonName = questdlg('Set of values of Field B  not provided, if continue measurements will be set in absence of magnetic field. Do you want to continue?', ...
        'Setting parameters', ...
        'Yes', 'No', 'No');
    switch ButtonName
        case 'Yes'
            handles.FieldFile.String = 'Absence of magnetic field';
        otherwise
            uiwait(msgbox('Acquisition mode interrupted'));
            return;
    end
end

set([handles.IVs handles.ZN handles.Pulses...
    handles.TempBrowse handles.FieldBrowse handles.Start],'Enable','inactive');

Set.IVs.on = handles.IVs.Value; % Multimeter, Squid, and Opt (DC Current Source)
if Set.IVs.on
    DevStr = {'Multi';'Squid';'CurSour'};
    for i = 1:size(DevStr,1)
        eval(['handles.Devices.' DevStr{i} ' = 1;']);
    end
end

Set.ZN.on = handles.ZN.Value; % Multimeter, Squid, SpectrumAnalyzer, PXI and Opt (DC Current Source)
if Set.ZN.on
    DevStr = {'Multi';'Squid';'SpecAnal';'PXI';'CurSour'};
    for i = 1:size(DevStr,1)
        eval(['handles.Devices.' DevStr{i} ' = 1;']);
    end
end

Set.Pulses.on = handles.Pulses.Value; % Multimeter(pxi), Squid, PXI and Opt (DC Current Source)
if Set.Pulses.on
    DevStr = {'Multi';'Squid';'PXI';'CurSour'};
    for i = 1:size(DevStr,1)
        eval(['handles.Devices.' DevStr{i} ' = 1;']);
    end
end

% Initialize connection of devices

for i = 1:size(handles.HndlStr,1)
    if eval(['handles.Devices.' handles.HndlStr{i,1} ' == 1;'])
        eval(['handles.' handles.HndlStr{i,1} '= handles.' handles.HndlStr{i,1} '.Initialize;']); 
    end    
end

% Seleccionar los Ibvalues que se van a usar

% - Opcion 1: mediante archivo 
% - Opcion 2: con un guide
% - Opcion 3: desde una gráfica






waitfor(figure);
for i = 1:size(handles.HndlStr,1)
    if eval(['handles.Devices.' handles.HndlStr{i,1} ' == 1;'])
        eval(['handles.' handles.HndlStr{i,1} '.Destructor;']); 
    end    
end
set([handles.IVs handles.ZN handles.Pulses...
    handles.TempBrowse handles.FieldBrowse handles.Start],'Enable','on');
