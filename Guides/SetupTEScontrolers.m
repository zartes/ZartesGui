function varargout = SetupTEScontrolers(varargin)
% SETUPTESCONTROLERS MATLAB code for SetupTEScontrolers.fig
%      SETUPTESCONTROLERS, by itself, creates a new SETUPTESCONTROLERS or raises the existing
%      singleton*.
%
%      H = SETUPTESCONTROLERS returns the handle to a new SETUPTESCONTROLERS or the handle to
%      the existing singleton*.
%
%      SETUPTESCONTROLERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETUPTESCONTROLERS.M with the given input arguments.
%
%      SETUPTESCONTROLERS('Property','Value',...) creates a new SETUPTESCONTROLERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SetupTEScontrolers_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SetupTEScontrolers_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SetupTEScontrolers

% Last Modified by GUIDE v2.5 25-Jul-2018 14:06:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SetupTEScontrolers_OpeningFcn, ...
    'gui_OutputFcn',  @SetupTEScontrolers_OutputFcn, ...
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


% --- Executes just before SetupTEScontrolers is made visible.
function SetupTEScontrolers_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SetupTEScontrolers (see VARARGIN)

% Choose default command line output for SetupTEScontrolers
handles.output = hObject;
position = get(handles.SetupTES,'Position');
set(handles.SetupTES,'Color',[0 120 180]/255,'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');

% Set correct paths (addition)
handles.CurrentPath = pwd;
handles.MainDir = handles.CurrentPath(1:find(handles.CurrentPath == filesep, 1, 'last' ));
handles.d = dir(handles.MainDir);
for i = 3:length(handles.d) % Los dos primeros son '.' y '..'
    if handles.d(i).isdir
        addpath([handles.MainDir handles.d(i).name])
    end
end

% Initialization of setting parameters
handles.TempFileDir = [];
handles.TempFileName = [];
handles.FieldFileDir = [];
handles.FieldFileName = [];



handles = Menu_Generation(handles);  % Here, the constructor is applied
% After Constructor, all the values have to be defined in the guide

% Electronic Magnicon
handles.SQ_Source.Value = handles.Squid.SourceCH;
a = cellstr(handles.SQ_Rf.String);
for i = 1:length(a)
    a{i} = strtrim(a{i});
end

IndexC = strfind(a, num2str(handles.Squid.Rf.Value));
handles.SQ_Rf.Value = find(not(cellfun('isempty', IndexC)),1);
% handles.SQ_Rf.Value = find(contains(a,num2str(handles.Squid.Rf.Value)) == 1,1);


handles.SQ_Pulse_Amp.String = num2str(handles.Squid.PulseAmp.Value);
IndexC = strfind(cellstr(handles.SQ_Pulse_Amp_Units.String), handles.Squid.PulseAmp.Units);
handles.SQ_Pulse_Amp_Units.Value = find(not(cellfun('isempty',IndexC)),1);
% handles.SQ_Pulse_Amp_Units.Value = find(contains(cellstr(handles.SQ_Pulse_Amp_Units.String),handles.Squid.PulseAmp.Units)==1,1);

handles.SQ_Pulse_DT.String = num2str(handles.Squid.PulseDT.Value);
IndexC = strfind(cellstr(handles.SQ_Pulse_DT_Units.String), handles.Squid.PulseDT.Units);
handles.SQ_Pulse_DT_Units.Value = find(not(cellfun('isempty',IndexC)),1);
% handles.SQ_Pulse_DT_Units.Value = find(contains(cellstr(handles.SQ_Pulse_DT_Units.String),handles.Squid.PulseDT.Units)==1,1);

handles.SQ_Pulse_Duration.String = num2str(handles.Squid.PulseDuration.Value);
IndexC = strfind(cellstr(handles.SQ_Pulse_Duration_Units.String), handles.Squid.PulseDuration.Units);
handles.SQ_Pulse_Duration_Units.Value = find(not(cellfun('isempty',IndexC)),1);
% handles.SQ_Pulse_Duration_Units.Value = find(contains(cellstr(handles.SQ_Pulse_Duration_Units.String),handles.Squid.PulseDuration.Units)==1,1);

% DSA



% PXI
handles.PXI.ConfStructs;
handles.PXI.WaveFormInfo;
handles.PXI.Options;


% Field Source

handles.CurSource_Vmax.String = num2str(handles.CurSour.Vmax.Value);
IndexC = strfind(cellstr(handles.CurSource_Vmax_Units.String), handles.CurSour.Vmax.Units);
handles.CurSource_Vmax_Units.Value = find(not(cellfun('isempty',IndexC)),1);
% handles.CurSource_Vmax_Units.Value = find(contains(cellstr(handles.CurSource_Vmax_Units.String),handles.CurSour.Vmax.Units)==1,1);



handles.EnableStr = {'off';'on'};
handles.DevStr = {'Multi';'Squid';'SpecAnal';'PXI';'CurSour'};
handles.DevStrOn = [1 1 1 1 1];

% Initialize connection of devices
for i = 1:size(handles.HndlStr,1)
    eval(['handles.' handles.HndlStr{i,1} ' = handles.Menu_' handles.HndlStr{i,1} '_sub(end).UserData;'])
    if eval(['handles.Devices.' handles.HndlStr{i,1} ' == 1;'])
        try
            eval(['handles.' handles.HndlStr{i,1} '= handles.' handles.HndlStr{i,1} '.Initialize;']);
            handles.DevStrOn(i) = 1;
        catch
            eval(['handles.Devices.' handles.HndlStr{i,1} ' = 0;'])
            handles.DevStrOn(i) = 0;
        end
    end
end
handles = Menu_Update(handles.DevStrOn,handles);

% Generation of log file
handles.LogName = ['Log_ZarTES ' datestr(now) '.txt'];
handles.LogName(strfind(handles.LogName,':')) = '-';
handles.LogFID = fopen(handles.LogName,'a+');
fprintf(handles.LogFID,['Session starts: ' datestr(now) '\n']);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SetupTEScontrolers wait for user response (see UIRESUME)
% uiwait(handles.SetupTES);


% --- Outputs from this function are returned to the command line.
function varargout = SetupTEScontrolers_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
set(handles.SetupTES,'Visible','on');

%%%%%%%%%%%%%%%%%%  SQUID FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in SQ_Pulse_Mode.
function SQ_Pulse_Mode_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of SQ_Pulse_Mode

if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
else
    if hObject.Value
        hObject.BackgroundColor = [120 170 50]/255;
        handles.SQ_Pulse_Mode_Str.String = 'Pulse Mode ON';
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        % Pulse Configuration Mode
        % Pulse On
        handles.Squid.PulseAmp.Value = str2double(handles.SQ_Pulse_Amp.String);
        contents = cellstr(get(handles.SQ_Pulse_Amp_Units,'String'));
        handles.Squid.PulseAmp.Units = contents{get(handles.SQ_Pulse_Amp_Units,'Value')};
        
        handles.Squid.PulseDT.Value = str2double(handles.SQ_Pulse_DT.String);
        contents = cellstr(get(handles.SQ_Pulse_DT_Units,'String'));
        handles.Squid.PulseDT.Units = contents{get(handles.SQ_Pulse_DT_Units,'Value')};
        
        handles.Squid.PulseDuration.Value = str2double(handles.SQ_Pulse_Duration.String);
        contents = cellstr(get(handles.SQ_Pulse_Duration_Units,'String'));
        handles.Squid.PulseDuration.Units = contents{get(handles.SQ_Pulse_Duration_Units,'Value')};
        
        handles.Squid.Cal_Pulse_ON;
        handles.Actions_Str.String = 'Electronic Magnicon: PULSE MODE ON';
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    else
        hObject.BackgroundColor = [240 240 240]/255;
        handles.SQ_Pulse_Mode_Str.String = 'Pulse Mode OFF';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        % Pulse Off
        handles.Squid.Cal_Pulse_OFF;
        handles.Actions_Str.String = 'Electronic Magnicon: PULSE MODE OFF';
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

% --- Executes on button press in SQ_TES2NormalState.
function SQ_TES2NormalState_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_TES2NormalState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of SQ_TES2NormalState
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
else
    if hObject.Value
        hObject.BackgroundColor = [120 170 50]/255;  % Green Color
        hObject.Enable = 'off';
        
        ButtonName = questdlg('What range of I bias?', ...
            'Current Sign Question', ...
            'Positive', 'Negative', 'Positive');
        switch ButtonName
            case 'Positive'
                Ibias_sign = 1;
            case 'Negative'
                Ibias_sign = -1;
            otherwise
                hObject.BackgroundColor = [240 240 240]/255;
                hObject.Value = 0;
                hObject.Enable = 'on';
                return;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        handles.Squid.TES2NormalState(Ibias_sign)
        handles.Actions_Str.String = ['Electronic Magnicon: TES in Normal State (' ButtonName ' values)'];
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        pause(1);
        hObject.BackgroundColor = [240 240 240]/255;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end

% --- Executes on button press in SQ_Reset_Closed_Loop.
function SQ_Reset_Closed_Loop_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Reset_Closed_Loop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of SQ_Reset_Closed_Loop
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
else
    if hObject.Value
        hObject.BackgroundColor = [120 170 50]/255;  % Green Color
        hObject.Enable = 'off';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        handles.Squid.ResetClossedLoop;
        handles.Actions_Str.String = 'Electronic Magnicon: Closed Loop Reset';
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        pause(1);
        hObject.BackgroundColor = [240 240 240]/255;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end

% --- Executes on button press in SQ_Calibration.
function SQ_Calibration_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SQ_Calibration
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
else
    if hObject.Value
        hObject.BackgroundColor = [120 170 50]/255;  % Green Color
        hObject.Enable = 'off';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        handles.Squid = handles.Squid.Calibration;
        handles.SQ_Rf_real.String = num2str(handles.Squid.Rf.Value);
        handles.Actions_Str.String = 'Electronic Magnicon: RF Calibration done';
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        pause(1);
        hObject.BackgroundColor = [240 240 240]/255;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end


function SQ_Pulse_Amp_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SQ_Pulse_Amp as text
%        str2double(get(hObject,'String')) returns contents of SQ_Pulse_Amp as a double
Edit_Protect(hObject)
contents = cellstr(get(handles.SQ_Pulse_Amp_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: Pulse Amplitude '...
    handles.SQ_Pulse_Amp.String ' ' contents{get(handles.SQ_Pulse_Amp_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_Pulse_Amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SQ_Pulse_Amp_Units.
function SQ_Pulse_Amp_Units_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns SQ_Pulse_Amp_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SQ_Pulse_Amp_Units

PulseAmp = str2double(handles.SQ_Pulse_Amp.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        PulseAmp = PulseAmp/1e-06;
    case -1
        PulseAmp = PulseAmp/1e-03;
    case 0
        PulseAmp = PulseAmp/1;
    case 1
        PulseAmp = PulseAmp/1e03;
    case 2
        PulseAmp = PulseAmp/1e06;
end
handles.SQ_Pulse_Amp.String = num2str(PulseAmp);
hObject.UserData = NewValue;
contents = cellstr(get(handles.SQ_Pulse_Amp_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: Pulse Amplitude '...
    handles.SQ_Pulse_Amp.String ' ' contents{get(handles.SQ_Pulse_Amp_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_Pulse_Amp_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SQ_Pulse_DT_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_DT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of SQ_Pulse_DT as text
%        str2double(get(hObject,'String')) returns contents of SQ_Pulse_DT as a double
Edit_Protect(hObject)
contents = cellstr(get(handles.SQ_Pulse_DT_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: Pulse Range '...
    handles.SQ_Pulse_DT.String ' ' contents{get(handles.SQ_Pulse_DT_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_Pulse_DT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_DT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SQ_Pulse_DT_Units.
function SQ_Pulse_DT_Units_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_DT_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns SQ_Pulse_DT_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SQ_Pulse_DT_Units
PulseDT = str2double(handles.SQ_Pulse_DT.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        PulseDT = PulseDT/1e-06;
    case -1
        PulseDT = PulseDT/1e-03;
    case 0
        PulseDT = PulseDT/1;
    case 1
        PulseDT = PulseDT/1e03;
    case 2
        PulseDT = PulseDT/1e06;
end
handles.SQ_Pulse_DT.String = num2str(PulseDT);
hObject.UserData = NewValue;
contents = cellstr(get(handles.SQ_Pulse_DT_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: Pulse Range '...
    handles.SQ_Pulse_DT.String ' ' contents{get(handles.SQ_Pulse_DT_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_Pulse_DT_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_DT_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SQ_Pulse_Duration_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_Duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of SQ_Pulse_Duration as text
%        str2double(get(hObject,'String')) returns contents of SQ_Pulse_Duration as a double
Edit_Protect(hObject)
contents = cellstr(get(handles.SQ_Pulse_Duration_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: Pulse Duration '...
    handles.SQ_Pulse_Duration.String ' ' contents{get(handles.SQ_Pulse_Duration_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_Pulse_Duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_Duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SQ_Pulse_Duration_Units.
function SQ_Pulse_Duration_Units_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_Duration_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns SQ_Pulse_Duration_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SQ_Pulse_Duration_Units
PulseDur = str2double(handles.SQ_Pulse_Duration.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        PulseDur = PulseDur/1e-06;
    case -1
        PulseDur = PulseDur/1e-03;
    case 0
        PulseDur = PulseDur/1;
    case 1
        PulseDur = PulseDur/1e03;
    case 2
        PulseDur = PulseDur/1e06;
end
handles.SQ_Pulse_Duration.String = num2str(PulseDur);
hObject.UserData = NewValue;
contents = cellstr(get(handles.SQ_Pulse_Duration_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: Pulse Duration '...
    handles.SQ_Pulse_Duration.String ' ' contents{get(handles.SQ_Pulse_Duration_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_Pulse_Duration_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_Duration_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in SQ_Set_I.
function SQ_Set_I_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Set_I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of SQ_Set_I
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
else
    if hObject.Value
        hObject.BackgroundColor = [120 170 50]/255;  % Green Color
        hObject.Enable = 'off';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        % Change to uA to ensure the correct units
        handles.SQ_Ibias_Units.Value = 3;
        SQ_Ibias_Units_Callback(handles.SQ_Ibias_Units,[],handles);
        Ibvalue = str2double(handles.SQ_Ibias.String);
        
        handles.Squid.Set_Current_Value(Ibvalue)  % uA.
        handles.Actions_Str.String = ['Electronic Magnicon: I bias set to ' num2str(Ibvalue) ' uA'];
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        
        handles.SQ_Read_I.Value = 1;
        SQ_Read_I_Callback(handles.SQ_Read_I,[],handles);
        
        handles.Multi_Read.Value = 1;
        Multi_Read_Callback(handles.Multi_Read,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pause(1);
        hObject.BackgroundColor = [240 240 240]/255;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end

% --- Executes on button press in SQ_Read_I.
function SQ_Read_I_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Read_I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of SQ_Read_I
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
else
    if hObject.Value
        hObject.BackgroundColor = [120 170 50]/255;  % Green Color
        hObject.Enable = 'off';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        Ireal = handles.Squid.Read_Current_Value;
        handles.SQ_realIbias.String = num2str(Ireal.Value);
        handles.SQ_realIbias_Units.Value = 3; % uA
        handles.Actions_Str.String = ['Electronic Magnicon: Measured I bias ' num2str(Ireal.Value) ' uA'];
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        pause(1);
        hObject.BackgroundColor = [240 240 240]/255;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end


function SQ_Ibias_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Ibias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SQ_Ibias as text
%        str2double(get(hObject,'String')) returns contents of SQ_Ibias as a double
value = str2double(hObject.String);
if ~isempty(value)&&~isnan(value)    
else
    hObject.String = '40';
    handles.SQ_Ibias_Units.Value = 3;
end

contents = cellstr(get(handles.SQ_Ibias_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: I bias '...
    handles.SQ_Ibias.String ' ' contents{get(handles.SQ_Ibias_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_Ibias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Ibias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SQ_Ibias_Units.
function SQ_Ibias_Units_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Ibias_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns SQ_Ibias_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SQ_Ibias_Units
Ibias = str2double(handles.SQ_Ibias.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Ibias = Ibias/1e-06;
    case -1
        Ibias = Ibias/1e-03;
    case 0
        Ibias = Ibias/1;
    case 1
        Ibias = Ibias/1e03;
    case 2
        Ibias = Ibias/1e06;
end
handles.SQ_Ibias.String = num2str(Ibias);
hObject.UserData = NewValue;
contents = cellstr(get(handles.SQ_Ibias_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: I bias '...
    handles.SQ_Ibias.String ' ' contents{get(handles.SQ_Ibias_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_Ibias_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Ibias_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SQ_realIbias_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_realIbias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of SQ_realIbias as text
%        str2double(get(hObject,'String')) returns contents of SQ_realIbias as a double
Edit_Protect(hObject)
contents = cellstr(get(handles.SQ_realIbias_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: Measured I bias '...
    handles.SQ_realIbias.String ' ' contents{get(handles.SQ_realIbias_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_realIbias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_realIbias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SQ_realIbias_Units.
function SQ_realIbias_Units_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_realIbias_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns SQ_realIbias_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SQ_realIbias_Units
realIbias = str2double(handles.SQ_realIbias.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        realIbias = realIbias/1e-06;
    case -1
        realIbias = realIbias/1e-03;
    case 0
        realIbias = realIbias/1;
    case 1
        realIbias = realIbias/1e03;
    case 2
        realIbias = realIbias/1e06;
end
handles.SQ_realIbias.String = num2str(realIbias);
hObject.UserData = NewValue;
contents = cellstr(get(handles.SQ_realIbias_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: Measured I bias '...
    handles.SQ_realIbias.String ' ' contents{get(handles.SQ_realIbias_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_realIbias_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_realIbias_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SQ_Rf_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Rf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of SQ_Rf as text
%        str2double(get(hObject,'String')) returns contents of SQ_Rf as a double
% Edit_Protect(hObject)

% --- Executes during object creation, after setting all properties.
function SQ_Rf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Rf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
hObject.String = num2str([0 0.7 0.75 0.91 1 2.14 2.31 2.73 3.0 7.0 7.5 9.1 10 23.1 30 100]'*1e3);
hObject.Value = 5;

% --- Executes on selection change in SQ_Rf_Units.
function SQ_Rf_Units_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Rf_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns SQ_Rf_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SQ_Rf_Units
Rf = str2double(handles.SQ_Rf.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Rf = Rf/1e-06;
    case -1
        Rf = Rf/1e-03;
    case 0
        Rf = Rf/1;
    case 1
        Rf = Rf/1e03;
    case 2
        Rf = Rf/1e06;
end
handles.SQ_Rf.String = num2str(Rf);
hObject.UserData = NewValue;
contents = cellstr(get(handles.SQ_Rf_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: Rf '...
    handles.SQ_Rf.String ' ' contents{get(handles.Rf_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_Rf_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Rf_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SQ_Rf_real_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Rf_real (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of SQ_Rf_real as text
%        str2double(get(hObject,'String')) returns contents of SQ_Rf_real as a double

% --- Executes during object creation, after setting all properties.
function SQ_Rf_real_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Rf_real (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SQ_Rf_real_Units.
function SQ_Rf_real_Units_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Rf_real_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns SQ_Rf_real_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SQ_Rf_real_Units
Rf_real = str2double(handles.SQ_Rf_real.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Rf_real = Rf_real/1e-06;
    case -1
        Rf_real = Rf_real/1e-03;
    case 0
        Rf_real = Rf_real/1;
    case 1
        Rf_real = Rf_real/1e03;
    case 2
        Rf_real = Rf_real/1e06;
end
handles.SQ_Rf_real.String = num2str(Rf_real);
hObject.UserData = NewValue;
contents = cellstr(get(handles.SQ_Rf_real_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: Measured Rf '...
    handles.SQ_Rf_real.String ' ' contents{get(handles.SQ_Rf_real_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_Rf_real_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Rf_real_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%  FIELD SETUP FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in CurSource_OnOff.
function CurSource_OnOff_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_OnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of CurSource_OnOff
if isempty(handles.CurSour.ObjHandle)
    handles.Actions_Str.String = 'Current Source Connection for Field Setup is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
else
    if hObject.Value
        hObject.BackgroundColor = [120 170 50]/255;
        handles.CurSource_OnOff_Str.String = 'Source ON';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        handles.CurSour.CurrentSource_Start;        
        handles.Actions_Str.String = 'Current Source: Mode ON';
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    else
        hObject.BackgroundColor = [240 240 240]/255;
        handles.CurSource_OnOff_Str.String = 'Source OFF';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        handles.CurSour.CurrentSource_Stop;
        handles.Actions_Str.String = 'Current Source: Mode OFF';
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
end

% --- Executes on button press in CurSource_Set_I.
function CurSource_Set_I_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_Set_I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of CurSource_Set_I
if isempty(handles.CurSour.ObjHandle)
    handles.Actions_Str.String = 'Current Source Connection for Field Setup is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
else
    if hObject.Value
        hObject.BackgroundColor = [120 170 50]/255;  % Green Color
        hObject.Enable = 'off';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        handles.CurSource_I_Units.Value = 1;  % Data is given in Amp
        CurSource_I_Units_Callback(handles.CurSource_I_Units,[],handles);
        I.Value = str2double(handles.CurSource_I.String);
        I.Units = 'A';
        
        handles.CurSour = handles.CurSour.SetIntensity(I);
        handles.Actions_Str.String = ['Current Source: I value set to ' num2str(I.Value) ' A'];
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        pause(1);
        hObject.BackgroundColor = [240 240 240]/255;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end


function CurSource_I_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of CurSource_I as text
%        str2double(get(hObject,'String')) returns contents of CurSource_I as a double
value = str2double(get(hObject,'String'));
Units = handles.CurSource_I_Units.Value;

if ~isempty(value)&&~isnan(value)
    if value <= 0
        hObject.String = '1';
        handles.CurSource_I_Units.Value = 2;
        CurSource_I_Callback(hObject, [], handles)
    elseif ((value > 0.005)&&(Units == 1))||((value > 5)&&(Units == 2))||((value > 5000)&&(Units == 3))
        hObject.String = '1';
        handles.CurSource_I_Units.Value = 2;
        CurSource_I_Callback(hObject, [], handles)
    end
else
    hObject.String = '1';
    handles.CurSource_I_Units.Value = 2;
    CurSource_I_Callback(hObject, [], handles)
end
contents = cellstr(handles.CurSource_I_Units.String);
handles.Actions_Str.String = ['Current Source: ' num2str(handles.CurSource_I.String) ' ' contents{handles.CurSource_I_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function CurSource_I_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurSource_I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in CurSource_I_Units.
function CurSource_I_Units_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_I_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns CurSource_I_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CurSource_I_Units
I_value = str2double(handles.CurSource_I.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        I_value = I_value/1e-06;
    case -1
        I_value = I_value/1e-03;
    case 0
        I_value = I_value/1;
    case 1
        I_value = I_value/1e03;
    case 2
        I_value = I_value/1e06;
end
handles.CurSource_I.String = num2str(I_value);
hObject.UserData = NewValue;
contents = cellstr(handles.CurSource_I_Units.String);
handles.Actions_Str.String = ['Current Source: I value ' num2str(handles.CurSource_I.String) ' ' contents{handles.CurSource_I_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function CurSource_I_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurSource_I_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in CurSource_Cal.
function CurSource_Cal_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_Cal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of CurSource_Cal
if isempty(handles.CurSour.ObjHandle)
    handles.Actions_Str.String = 'Current Source Connection for Field Setup is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
else
    if hObject.Value
        hObject.BackgroundColor = [120 170 50]/255;  % Green Color
        hObject.Enable = 'off';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        handles.CurSource_Vmax_Units.Value = 1;
        CurSource_Vmax_Units_Callback(handles.CurSource_Vmax_Units,[],handles);
        handles.CurSour.Vmax.Value = str2double(handles.CurSource_Vmax.String);
        handles.CurSour.Vmax.Units = 'V';
        
        handles.CurSour.Calibration;
        handles.Actions_Str.String = ['Current Source: Vmax ' num2str(handles.CurSour.Vmax.Value) ' V'];
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        pause(1);
        hObject.BackgroundColor = [240 240 240]/255;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end


function CurSource_Vmax_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_Vmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of CurSource_Vmax as text
%        str2double(get(hObject,'String')) returns contents of CurSource_Vmax as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','50');
        handles.CurSource_Vmax_Units.Value = 1;
        CurSource_Vmax_Callback(hObject, [], handles)
    end
else
    set(hObject,'String','50');
    handles.CurSource_Vmax_Units.Value = 1;
    CurSource_Vmax_Callback(hObject, [], handles)
end
contents = cellstr(handles.CurSource_Vmax_Units.String);
handles.Actions_Str.String = ['Current Source: Vmax ' num2str(handles.CurSource_Vmax.String) ' ' contents{handles.CurSource_Vmax_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function CurSource_Vmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurSource_Vmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in CurSource_Vmax_Units.
function CurSource_Vmax_Units_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_Vmax_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns CurSource_Vmax_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CurSource_Vmax_Units
V_max = str2double(handles.CurSource_Vmax.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        V_max = V_max/1e-06;
    case -1
        V_max = V_max/1e-03;
    case 0
        V_max = V_max/1;
    case 1
        V_max = V_max/1e03;
    case 2
        V_max = V_max/1e06;
end
handles.CurSource_Vmax.String = num2str(V_max);
hObject.UserData = NewValue;
contents = cellstr(handles.CurSource_Vmax_Units.String);
handles.Actions_Str.String = ['Current Source: Vmax ' num2str(handles.CurSource_Vmax.String) ' ' contents{handles.CurSource_Vmax_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function CurSource_Vmax_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurSource_Vmax_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%  MULTIMETER FUNCTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in Multi_Read.
function Multi_Read_Callback(hObject, eventdata, handles)
% hObject    handle to Multi_Read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Multi_Read
if isempty(handles.Multi.ObjHandle)
    handles.Actions_Str.String = 'Multimeter Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
else
    if hObject.Value
        hObject.BackgroundColor = [120 170 50]/255;  % Green Color
        hObject.Enable = 'off';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        [handles.Multi, Vdc] = handles.Multi.Read;  % The output is in Volts.
        handles.Multi_Value.String = num2str(Vdc.Value);
        handles.Actions_Str.String = ['Multimeter: Voltage ' num2str(Vdc.Value) ' V']; 
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        pause(1);
        hObject.BackgroundColor = [240 240 240]/255;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end


function Multi_Value_Callback(hObject, eventdata, handles)
% hObject    handle to Multi_Value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of Multi_Value as text
%        str2double(get(hObject,'String')) returns contents of Multi_Value as a double

% --- Executes during object creation, after setting all properties.
function Multi_Value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Multi_Value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%  RESPONSE SYSTEM SETUP  %%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in DSA_OnOff.
function DSA_OnOff_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_OnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of DSA_OnOff
if isempty(handles.DSA.ObjHandle)
    handles.Actions_Str.String = 'Digital Signal Analyzer HP3562A Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
else
    if hObject.Value
        hObject.BackgroundColor = [120 170 50]/255;
        handles.DSA_OnOff_Str.String = 'Source ON';
        handles.DSA_Read.Enable = 'on';
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if handles.TF_Mode.Value
            handles.DSA = handles.DSA.TF_Configuration;
            handles.Actions_Str.String = 'Digital Signal Analyzer HP3562A: TF Mode ON';
            Actions_Str_Callback(handles.Actions_Str,[],handles);
        else
            handles.DSA = handles.DSA.Noise_Configuration;
            handles.Actions_Str.String = 'Digital Signal Analyzer HP3562A: Noise Mode ON';
            Actions_Str_Callback(handles.Actions_Str,[],handles);
        end
        handles.DSA.SourceOn;        
        handles.Actions_Str.String = [handles.Actions_Str.String '; Source Mode ON'];
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        hObject.BackgroundColor = [240 240 240]/255;
        handles.DSA_OnOff_Str.String = 'Source OFF';
        handles.DSA_Read.Enable = 'off';
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        handles.DSA.SourceOff;
        handles.Actions_Str.String = 'Digital Signal Analyzer HP3562A: Source Mode OFF';
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

% --- Executes on button press in DSA_Read.
function DSA_Read_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_Read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of DSA_Read
if hObject.Value
    hObject.BackgroundColor = [120 170 50]/255;  % Green Color
    hObject.Enable = 'off';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Action of the device (including line)
    if handles.DSA_On.Value        
        [handles.DSA, datos] = handles.DSA.Read;   % Ver qué hacemos con esta variable!!
    end
    if handles.PXI_On.Value
        if handles.TF_Mode.Value
            handles.PXI = handles.PXI.TF_Configuration;
        else
            handles.PXI = handles.PXI.Noise_Configuration;
        end
        [data, WfmI] = handles.PXI.Get_Wave_Form;  % Ver qué hacemos con estas variables!!
    end    
    handles.Actions_Str.String = 'Digital Signal Analyzer HP3562A:';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    pause(1);
    hObject.BackgroundColor = [240 240 240]/255;
    hObject.Value = 0;
    hObject.Enable = 'on';
end

% --- Executes on button press in DSA_On.
function DSA_On_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_On (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of DSA_On
if (hObject.Value||handles.PXI_On.Value)
    handles.DSA_Read.Enable = 'on';
else
    handles.DSA_Read.Enable = 'off';
end

% --- Executes on button press in PXI_On.
function PXI_On_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_On (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of PXI_On
if (hObject.Value||handles.DSA_On.Value)
    handles.DSA_Read.Enable = 'on';
else
    handles.DSA_Read.Enable = 'off';
end
if hObject.Value
    set([handles.PXI_Mode handles.PXI_Conf_Mode],'Enable','on');
else
    set([handles.PXI_Mode handles.PXI_Conf_Mode],'Enable','off');
end

% --- Executes on button press in PXI_Pulses_Read.
function PXI_Pulses_Read_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Pulses_Read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PXI_Pulses_Read
if hObject.Value
    hObject.BackgroundColor = [120 170 50]/255;  % Green Color
    hObject.Enable = 'off';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Action of the device (including line)
    
    warndlg('Change ''Pulses Configuration'' before READ (PXI) button.','ZarTES v1.0');
    handles.PXI.Pulses_Configuration;
    [data, WfmI] = handles.PXI.Get_Wave_Form;   % Decidir qué se hace con estas variables!!
    handles.Actions_Str.String = 'PXI Acquisition Card: Acquisition of pulse system response';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pause(1);
    hObject.BackgroundColor = [240 240 240]/255;
    hObject.Value = 0;
    hObject.Enable = 'on';
end

% --- Executes on button press in TF_Mode.
function TF_Mode_Callback(hObject, eventdata, handles)
% hObject    handle to TF_Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of TF_Mode
Ch_TF = handles.TF_Panel.Children;
Ch_Noise = handles.Noise_Panel.Children;
if hObject.Value
    set(Ch_TF,'Enable','on');
    set(Ch_Noise,'Enable','off');
    handles.PXI_Mode.Value = 1;
else
    set(Ch_TF,'Enable','off');
    set(Ch_Noise,'Enable','on');
    handles.PXI_Mode.Value = 2;
end

% --- Executes on button press in Noise_Mode.
function Noise_Mode_Callback(hObject, eventdata, handles)
% hObject    handle to Noise_Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Noise_Mode
Ch_TF = handles.TF_Panel.Children;
Ch_Noise = handles.Noise_Panel.Children;
if hObject.Value
    set(Ch_TF,'Enable','off');
    set(Ch_Noise,'Enable','on');
    handles.PXI_Mode.Value = 2;
else
    set(Ch_TF,'Enable','on');
    set(Ch_Noise,'Enable','off');
    handles.PXI_Mode.Value = 1;
end


function Sine_Amp_Callback(hObject, eventdata, handles)
% hObject    handle to Sine_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of Sine_Amp as text
%        str2double(get(hObject,'String')) returns contents of Sine_Amp as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','50');
        handles.Sine_Amp_Units.Value = 2;
        Sine_Amp_Callback(hObject, [], handles)
    end
else
    set(hObject,'String','50');
    handles.Sine_Amp_Units.Value = 2;
    Sine_Amp_Callback(hObject, [], handles)
end

contents1 = cellstr(handles.Sine_Amp_Units.String);
contents2 = cellstr(handles.Sine_Freq_Units.String);
handles.Actions_Str.String = ['Digital Signal Analyzer HP3562A: TF Mode Sine  Amp '...
    handles.Sine_Amp.String ' ' contents1{handles.Sine_Amp_Units.Value} ' Freq ' ...
    handles.Sine_Freq.String ' ' contents2{handles.Sine_Freq_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function Sine_Amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sine_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Sine_Amp_Units.
function Sine_Amp_Units_Callback(hObject, eventdata, handles)
% hObject    handle to Sine_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns Sine_Amp_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Sine_Amp_Units

Amp = str2double(handles.Sine_Amp.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Amp = Amp/1e-06;
    case -1
        Amp = Amp/1e-03;
    case 0
        Amp = Amp/1;
    case 1
        Amp = Amp/1e03;
    case 2
        Amp = Amp/1e06;
end
handles.Sine_Amp.String = num2str(Amp);
hObject.UserData = NewValue;
contents1 = cellstr(handles.Sine_Amp_Units.String);
contents2 = cellstr(handles.Sine_Freq_Units.String);
handles.Actions_Str.String = ['Digital Signal Analyzer HP3562A: TF Mode Sine  Amp '...
    handles.Sine_Amp.String ' ' contents1{handles.Sine_Amp_Units.Value} ' Freq ' ...
    handles.Sine_Freq.String ' ' contents2{handles.Sine_Freq_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function Sine_Amp_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sine_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Sine_Freq_Callback(hObject, eventdata, handles)
% hObject    handle to Sine_Freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of Sine_Freq as text
%        str2double(get(hObject,'String')) returns contents of Sine_Freq as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','1');
        handles.Sine_Freq_Units.Value = 1;
        Sine_Freq_Callback(hObject, [], handles)
    end
else
    set(hObject,'String','1');
    handles.Sine_Freq_Units.Value = 1;
    Sine_Freq_Callback(hObject, [], handles)
end
contents1 = cellstr(handles.Sine_Amp_Units.String);
contents2 = cellstr(handles.Sine_Freq_Units.String);
handles.Actions_Str.String = ['Digital Signal Analyzer HP3562A: TF Mode Sine  Amp '...
    handles.Sine_Amp.String ' ' contents1{handles.Sine_Amp_Units.Value} ' Freq ' ...
    handles.Sine_Freq.String ' ' contents2{handles.Sine_Freq_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function Sine_Freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sine_Freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Sine_Freq_Units.
function Sine_Freq_Units_Callback(hObject, eventdata, handles)
% hObject    handle to Sine_Freq_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns Sine_Freq_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Sine_Freq_Units

Freq = str2double(handles.Sine_Freq.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Freq = Freq/1e-06;
    case -1
        Freq = Freq/1e-03;
    case 0
        Freq = Freq/1;
    case 1
        Freq = Freq/1e03;
    case 2
        Freq = Freq/1e06;
end
handles.Sine_Freq.String = num2str(Freq);
hObject.UserData = NewValue;
contents1 = cellstr(handles.Sine_Amp_Units.String);
contents2 = cellstr(handles.Sine_Freq_Units.String);
handles.Actions_Str.String = ['Digital Signal Analyzer HP3562A: TF Mode Sine  Amp '...
    handles.Sine_Amp.String ' ' contents1{handles.Sine_Amp_Units.Value} ' Freq ' ...
    handles.Sine_Freq.String ' ' contents2{handles.Sine_Freq_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function Sine_Freq_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sine_Freq_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Noise_Amp_Callback(hObject, eventdata, handles)
% hObject    handle to Noise_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of Noise_Amp as text
%        str2double(get(hObject,'String')) returns contents of Noise_Amp as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','100');
        handles.Noise_Amp_Units.Value = 2;
        Noise_Amp_Callback(hObject, [], handles)
    end
else
    set(hObject,'String','100');
    handles.Noise_Amp_Units.Value = 2;
    Noise_Amp_Callback(hObject, [], handles)
end
contents = cellstr(handles.Noise_Amp_Units.String);
handles.Actions_Str.String = ['Digital Signal Analyzer HP3562A: Noise Mode  Amp '...
    handles.Noise_Amp.String ' ' contents{handles.Noise_Amp_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function Noise_Amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Noise_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Noise_Amp_Units.
function Noise_Amp_Units_Callback(hObject, eventdata, handles)
% hObject    handle to Noise_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns Noise_Amp_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Noise_Amp_Units

Amp = str2double(handles.Noise_Amp.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Amp = Amp/1e-06;
    case -1
        Amp = Amp/1e-03;
    case 0
        Amp = Amp/1;
    case 1
        Amp = Amp/1e03;
    case 2
        Amp = Amp/1e06;
end
handles.Noise_Amp.String = num2str(Amp);
hObject.UserData = NewValue;
contents = cellstr(handles.Noise_Amp_Units.String);
handles.Actions_Str.String = ['Digital Signal Analyzer HP3562A: Noise Mode  Amp '...
    handles.Noise_Amp.String ' ' contents{handles.Noise_Amp_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function Noise_Amp_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Noise_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Noise_Freq_Callback(hObject, eventdata, handles)
% hObject    handle to Noise_Freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of Noise_Freq as text
%        str2double(get(hObject,'String')) returns contents of Noise_Freq as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','10');
        handles.Noise_Freq_Units.Value = 1;
        Noise_Freq_Callback(hObject, [], handles)
    end
else
    set(hObject,'String','10');
    handles.Noise_Freq_Units.Value = 1;
    Noise_Freq_Callback(hObject, [], handles)
end

% --- Executes during object creation, after setting all properties.
function Noise_Freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Noise_Freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Noise_Freq_Units.
function Noise_Freq_Units_Callback(hObject, eventdata, handles)
% hObject    handle to Noise_Freq_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns Noise_Freq_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Noise_Freq_Units

Freq = str2double(handles.Noise_Freq.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Freq = Freq/1e-06;
    case -1
        Freq = Freq/1e-03;
    case 0
        Freq = Freq/1;
    case 1
        Freq = Freq/1e03;
    case 2
        Freq = Freq/1e06;
end
handles.Noise_Freq.String = num2str(Freq);
hObject.UserData = NewValue;

% --- Executes during object creation, after setting all properties.
function Noise_Freq_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Noise_Freq_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SQ_Source.
function SQ_Source_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns SQ_Source contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SQ_Source
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
else
    warndlg('Change this parameter consistently with the SQUID Device!','ZarTES v1.0');
    handles.Squid.SourceCH = hObject.Value;
    handles.Actions_Str.String = ['Electronic Magnicon: Channel Source ' num2str(handles.Squid.SourceCH)];
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function SQ_Source_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in DSA_TF_Conf.
function DSA_TF_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_TF_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

waitfor(Conf_Setup(hObject,handles.TF_Menu.Value,handles));
handles.Actions_Str.String = 'Digital Signal Analyzer: Configuration changes in TF Mode';
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes on button press in DSA_Noise_Conf.
function DSA_Noise_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_Noise_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

waitfor(Conf_Setup(hObject,handles.Noise_Menu.Value,handles));
handles.Actions_Str.String = 'Digital Signal Analyzer: Configuration changes in Noise Mode';
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes on selection change in TF_Menu.
function TF_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to TF_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns TF_Menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TF_Menu

% --- Executes during object creation, after setting all properties.
function TF_Menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TF_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Noise_Menu.
function Noise_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Noise_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns Noise_Menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Noise_Menu

% --- Executes during object creation, after setting all properties.
function Noise_Menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Noise_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in PXI_Conf_Mode.
function PXI_Conf_Mode_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Conf_Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
waitfor(Conf_Setup_PXI(hObject,handles.PXI_Mode.Value,handles));
handles.PXI.ConfStructs = hObject.UserData;
handles.Actions_Str.String = 'PXI Acquisition Card: Configuration changes';
Actions_Str_Callback(handles.Actions_Str,[],handles);

guidata(hObject,handles);

% --- Executes on selection change in PXI_Mode.
function PXI_Mode_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns PXI_Mode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PXI_Mode

% --- Executes during object creation, after setting all properties.
function PXI_Mode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PXI_Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in PXI_Pulses_Conf.
function PXI_Pulses_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Pulses_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function Actions_Str_Callback(hObject, eventdata, handles)

fprintf(handles.LogFID,[hObject.String '\n']);

% --- Executes during object deletion, before destroying properties.
function SetupTES_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to SetupTES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Cerrar el archivo log creado en los cambios de String de Actions_Str.
try
    fprintf(handles.LogFID,['Session ends: ' datestr(now) '\n']);
    fclose(handles.LogFID);
    buttonquest = questdlg('Do you want to erase Log File?','ZarTES v1.0','Yes','No','No');
    switch buttonquest
        case Yes
            delete(handles.LogName);
    end
catch
end
try
    for i = 1:length(handles.DevStrOn)
        if handles.DevStrOn(i)
            try
                eval(['handles.' handles.HndlStr{i,1} '.Destructor;']);
            catch
            end
        end
    end
catch
end
try
    for i = 3:length(handles.d) % Los dos primeros son '.' y '..'
        if handles.d(i).isdir
            rmpath([handles.MainDir handles.d(i).name])
        end
    end
catch
end



%%%%%%%%%%%%%%%%%%%%%% OTHER FUNCTIONALITIES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles = Menu_Generation(handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization of classes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.Circuit = Circuit;
handles.Circuit = handles.Circuit.Constructor;
handles.menu(1) = uimenu('Parent',handles.SetupTES,'Label',...
    'Circuit');
handles.Menu_Circuit = uimenu('Parent',handles.menu(1),'Label',...
    'Circuit Properties','Callback',{@Obj_Properties},'UserData',handles.Circuit);

handles.HndlStr(:,1) = {'Multi';'Squid';'CurSour';'DSA';'PXI'};
handles.HndlStr(:,2) = {'Multimeter';'ElectronicMagnicon';'CurrentSource';'SpectrumAnalyzer';'PXI_Acquisition_card'};

% Menu is generated here
handles.menu(2) = uimenu('Parent',handles.SetupTES,'Label',...
    'Devices');

for i = 1:size(handles.HndlStr,1)
    eval(['handles.' handles.HndlStr{i,1} '=' handles.HndlStr{i,2} ';']);
    eval(['handles.' handles.HndlStr{i,1} '= handles.' handles.HndlStr{i,1} '.Constructor;']);
    eval(['handles.Devices.' handles.HndlStr{i,1} ' = 1;']); % By default all are activated
    eval(['handles.Menu_' handles.HndlStr{i,1} ' = uimenu(''Parent'',handles.menu(2),''Label'','...
        '[''&' handles.HndlStr{i,2} ''']);']);
    eval(['Mthds = methods(handles.' handles.HndlStr{i,1} ');']);
    jj = 1;
    % The firts menu is the one uses for initialize the device
    % connection
    eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ')  = uimenu(''Parent'',handles.Menu_' handles.HndlStr{i,1} ',''Label'','...
        ''' Initialize '',''Callback'',{@Obj_Actions},''UserData'',handles.' handles.HndlStr{i,1} ',''Separator'',''on'');']);
    jj = jj + 1;
    for j = 1:size(Mthds,1) %#ok<USENS>
        if isempty(cell2mat(strfind({'Constructor';'Destructor';'Initialize';handles.HndlStr{i,2}},Mthds{j})))
            eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ')  = uimenu(''Parent'',handles.Menu_' handles.HndlStr{i,1} ',''Label'','...
                '''' Mthds{j} ''',''Callback'',{@Obj_Actions},''UserData'',handles.' handles.HndlStr{i,1} ',''Enable'',''off'');']);
            jj = jj + 1;
        end
    end
    eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ') = uimenu(''Parent'',handles.Menu_' handles.HndlStr{i,1} ',''Label'','...
        '''' handles.HndlStr{i,2} ' Properties'',''Callback'',{@Obj_Properties},''UserData'',handles.' handles.HndlStr{i,1} ',''Separator'',''on'');']);
        
end

function handles = Menu_Update(DevicesOn,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(DevicesOn)
    eval(['Mthds = methods(handles.' handles.HndlStr{i,1} ');']);
    jj = 2;
    for j = 1:size(Mthds,1) %#ok<USENS>
        if isempty(cell2mat(strfind({'Constructor';'Destructor';'Initialize';handles.HndlStr{i,2}},Mthds{j})))
            eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ').UserData = handles.' handles.HndlStr{i,1} ';']);
            if DevicesOn(i)
                eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ').Enable = ''on'';']);
            else
                eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ').Enable = ''off'';']);
            end
            jj = jj + 1;
        end
    end
    eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ').UserData = handles.' handles.HndlStr{i,1} ';']);
end

function Obj_Actions(src,evnt)
handles  = guidata(src);
if ~isempty(strfind(src.Label,'Initialize')) % Device are checked if they are initialize.  If so, they are not initialize again.
    Parent = evnt.Source.Parent.Label(2:end); % First character is reserved for &
    switch Parent
        case 'Multimeter'
            if ~isempty(handles.Multi.ObjHandle)
                return;
            else
                handles.Multi = handles.Multi.Initialize;
                handles.DevStrOn(1) = 1;
            end
        case 'ElectronicMagnicon'
            if ~isempty(handles.Squid.ObjHandle)
                return;
            else
                handles.Squid = handles.Squid.Initialize;
                handles.DevStrOn(2) = 1;
            end
        case 'SpectrumAnalyzer'
            if ~isempty(handles.DS.ObjHandle)
                return;
            else
                handles.DSA = handles.DSA.Initialize;
                handles.DevStrOn(3) = 1;
            end
        case 'PXI_Acquisition_card'
            if ~isempty(handles.PXI.ObjHandle)
                return;
            else
                handles.PXI = handles.PXI.Initialize;
                handles.DevStrOn(4) = 1;
            end
        case 'CurrentSource'
            if ~isempty(handles.CurSour.ObjHandle)
                return;
            else
                handles.CurSour = handles.CurSour.Initialize;
                handles.DevStrOn(5) = 1;
            end
            
        otherwise
    end
    handles = Menu_Update(handles.DevStrOn,handles);  % Sub_menus are now available.
else
    eval(['[a, b] = src.UserData.' src.Label]);
end


guidata(src,handles);

function Edit_Protect(hObject)
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','1');
    end
else
    set(hObject,'String','1');
end

% --- Executes on button press in Check_Plot.
function Check_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Check_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Check_Plot
if hObject.Value
    set([handles.Elect_Mag_Panel handles.Charac_Panel handles.Field_Panel handles.Actions_Panel],'Units','Character')
    Position_old = handles.SetupTES.Position;
    handles.SetupTES.UserData = Position_old;
        
    handles.SetupTES.Position = [Position_old(1) Position_old(2) 0.89 Position_old(4)];
    
    handles.Result_Axes.Units = 'Character';
    handles.Result_Axes.Position = [156 6 85 30]; % Char
    handles.Result_Axes.Visible = 'on';
    
    handles.Draw_Select.Units = 'Character';
    handles.Draw_Select.Position = [156 43 16 1.2]; % Char
    handles.Draw_Select.Visible = 'on';
        
else
    handles.Result_Axes.Visible = 'off';
    handles.Draw_Select.Visible = 'off';
    handles.SetupTES.Position = handles.SetupTES.UserData;
    
end
    

% --- Executes on selection change in Draw_Select.
function Draw_Select_Callback(hObject, eventdata, handles)
% hObject    handle to Draw_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Draw_Select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Draw_Select


% --- Executes during object creation, after setting all properties.
function Draw_Select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Draw_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
