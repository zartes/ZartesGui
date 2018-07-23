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

% Last Modified by GUIDE v2.5 20-Jul-2018 13:30:56

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
position = get(handles.figure1,'Position');
set(handles.figure1,'Color',[0 150 220]/255,'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SetupTEScontrolers wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SetupTEScontrolers_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
set(handles.figure1,'Visible','on');

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in SQ_Pulse_Mode.
function SQ_Pulse_Mode_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SQ_Pulse_Mode

if hObject.Value    
    hObject.BackgroundColor = [120 170 50]/255;
    handles.SQ_Pulse_Mode_Str.String = 'Pulse Mode ON';
    % Pulse Configuration Mode
    % Pulse On
else
    hObject.BackgroundColor = [240 240 240]/255;
    handles.SQ_Pulse_Mode_Str.String = 'Pulse Mode OFF';
    % Pulse Off
end


% --- Executes on button press in SQ_TES2NormalState.
function SQ_TES2NormalState_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_TES2NormalState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SQ_TES2NormalState

if hObject.Value
    hObject.BackgroundColor = [120 170 50]/255;  % Green Color
    hObject.Enable = 'off';
    % Action of the device (including line)
    pause(1);
    hObject.BackgroundColor = [240 240 240]/255;
    hObject.Value = 0;
    hObject.Enable = 'on';
end        


% --- Executes on button press in SQ_Reset_Closed_Loop.
function SQ_Reset_Closed_Loop_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Reset_Closed_Loop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SQ_Reset_Closed_Loop

if hObject.Value
    hObject.BackgroundColor = [120 170 50]/255;  % Green Color
    hObject.Enable = 'off';
    % Action of the device (including line)
    pause(1);
    hObject.BackgroundColor = [240 240 240]/255;
    hObject.Value = 0;
    hObject.Enable = 'on';
end


% --- Executes on button press in SQ_Calibration.
function SQ_Calibration_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SQ_Calibration
if hObject.Value
    hObject.BackgroundColor = [120 170 50]/255;  % Green Color
    hObject.Enable = 'off';
    % Action of the device (including line)
    
    pause(1);
    hObject.BackgroundColor = [240 240 240]/255;
    hObject.Value = 0;
    hObject.Enable = 'on';
end


function SQ_Pulse_Amp_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Pulse_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SQ_Pulse_Amp as text
%        str2double(get(hObject,'String')) returns contents of SQ_Pulse_Amp as a double
Edit_Protect(hObject)

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
if hObject.Value
    hObject.BackgroundColor = [120 170 50]/255;  % Green Color
    hObject.Enable = 'off';
    % Action of the device (including line)
    pause(1);
    hObject.BackgroundColor = [240 240 240]/255;
    hObject.Value = 0;
    hObject.Enable = 'on';
end

% --- Executes on button press in SQ_Read_I.
function SQ_Read_I_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Read_I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SQ_Read_I
if hObject.Value
    hObject.BackgroundColor = [120 170 50]/255;  % Green Color
    hObject.Enable = 'off';
    % Action of the device (including line)
    pause(1);
    hObject.BackgroundColor = [240 240 240]/255;
    hObject.Value = 0;
    hObject.Enable = 'on';
end



function SQ_Ibias_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Ibias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SQ_Ibias as text
%        str2double(get(hObject,'String')) returns contents of SQ_Ibias as a double
Edit_Protect(hObject)

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


% --- Executes on button press in CurSource_OnOff.
function CurSource_OnOff_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_OnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CurSource_OnOff
if hObject.Value    
    hObject.BackgroundColor = [120 170 50]/255;
    handles.CurSource_OnOff_Str.String = 'Source ON';
    % Pulse Configuration Mode
    % Pulse On
else
    hObject.BackgroundColor = [240 240 240]/255;
    handles.CurSource_OnOff_Str.String = 'Source OFF';
    % Pulse Off
end


% --- Executes on button press in CurSource_Set_I.
function CurSource_Set_I_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_Set_I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CurSource_Set_I
if hObject.Value
    hObject.BackgroundColor = [120 170 50]/255;  % Green Color
    hObject.Enable = 'off';
    % Action of the device (including line)
    pause(1);
    hObject.BackgroundColor = [240 240 240]/255;
    hObject.Value = 0;
    hObject.Enable = 'on';
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
if hObject.Value
    hObject.BackgroundColor = [120 170 50]/255;  % Green Color
    hObject.Enable = 'off';
    % Action of the device (including line)
    pause(1);
    hObject.BackgroundColor = [240 240 240]/255;
    hObject.Value = 0;
    hObject.Enable = 'on';
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



function Edit_Protect(hObject)
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','1');
    end    
else
    set(hObject,'String','1');
end


% --- Executes on button press in DSA_Cal.
function DSA_Cal_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_Cal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DSA_Cal

if hObject.Value
    hObject.BackgroundColor = [120 170 50]/255;  % Green Color
    hObject.Enable = 'off';
    % Action of the device (including line)
    pause(1);
    hObject.BackgroundColor = [240 240 240]/255;
    hObject.Value = 0;
    hObject.Enable = 'on';
end


% --- Executes on button press in DSA_OnOff.
function DSA_OnOff_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_OnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DSA_OnOff
if hObject.Value    
    hObject.BackgroundColor = [120 170 50]/255;
    handles.DSA_OnOff_Str.String = 'Source ON';
    % Pulse Configuration Mode
    % Pulse On
else
    hObject.BackgroundColor = [240 240 240]/255;
    handles.DSA_OnOff_Str.String = 'Source OFF';
    % Pulse Off
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
    % Action of the device (including line)
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

% --- Executes on button press in PXI_Pulses_Read.
function PXI_Pulses_Read_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Pulses_Read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PXI_Pulses_Read
if hObject.Value
    hObject.BackgroundColor = [120 170 50]/255;  % Green Color
    hObject.Enable = 'off';
    % Action of the device (including line)
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


% --- Executes on button press in Noise_Mode.
function Noise_Mode_Callback(hObject, eventdata, handles)
% hObject    handle to Noise_Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Noise_Mode



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


% --- Executes on button press in Multi_Read.
function Multi_Read_Callback(hObject, eventdata, handles)
% hObject    handle to Multi_Read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Multi_Read

if hObject.Value
    hObject.BackgroundColor = [120 170 50]/255;  % Green Color
    hObject.Enable = 'off';
    % Action of the device (including line)
    pause(1);
    hObject.BackgroundColor = [240 240 240]/255;
    hObject.Value = 0;
    hObject.Enable = 'on';
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


% --- Executes on button press in DSA_TF_Conf.
function DSA_TF_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_TF_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in DSA_Noise_Conf.
function DSA_Noise_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_Noise_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
