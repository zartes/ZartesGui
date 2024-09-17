function varargout = BFTempControl(varargin)
% BFTEMPCONTROL MATLAB code for BFTempControl.fig
%      BFTEMPCONTROL, by itself, creates a new BFTEMPCONTROL or raises the existing
%      singleton*.
%
%      H = BFTEMPCONTROL returns the handle to a new BFTEMPCONTROL or the handle to
%      the existing singleton*.
%
%      BFTEMPCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BFTEMPCONTROL.M with the given input arguments.
%
%      BFTEMPCONTROL('Property','Value',...) creates a new BFTEMPCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BFTempControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BFTempControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BFTempControl

% Last Modified by GUIDE v2.5 10-Mar-2022 09:14:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BFTempControl_OpeningFcn, ...
                   'gui_OutputFcn',  @BFTempControl_OutputFcn, ...
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


% --- Executes just before BFTempControl is made visible.
function BFTempControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BFTempControl (see VARARGIN)

% Choose default command line output for BFTempControl
handles.output = hObject;

position = get(handles.figure1,'Position');
set(handles.figure1,'Color',[0 120 180]/255,'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');

% handles.FileTemp = fopen('.\Temp\TM','w+');


% Green color - Active
handles.Active_Color = [120 170 50]/255;
% Gray color - Disable elements
handles.Disable_Color = [204 204 204]/255;

%% Conexión con el BlueFors
% DEVICE_IP = 'localhost';
% TIMEOUT = 10;

handles.BF = BlueFors;
handles.BF = handles.BF.Constructor;

set(handles.P,'String',num2str(handles.BF.P));
set(handles.I,'String',num2str(handles.BF.I));
set(handles.D,'String',num2str(handles.BF.D));
handles.PIDError = zeros(2,1);
handles.U = [0 0];
handles.E = [0 0 0];

handles.BF.SetMaxPower(1e-3);
set(handles.MaxPower,'String',num2str(handles.BF.ReadMaxPower*1e3));
T_MC = handles.BF.ReadTemp;
handles.MCTemp.String = num2str(T_MC);
handles.SetPt = handles.BF.ReadSetPoint;
set(handles.SetPoint,'String',num2str(handles.SetPt));
Period = 7;

% Poner limite de potencia max de 5mW
% En la potencia hay que poner un aviso de sobrepasar un 80% de potencia
% maxima.

%% Conexión con el Oxford
% try
%     e = actxserver('LabVIEW.Application');
%     vipath = 'C:\Users\Athena\Desktop\Software\2014_Oxford TES\IGHSUBS.LLB\IGHFrontPanel.vi';
%     handles.vi_IGHFrontPanel = invoke(e,'GetVIReference',vipath);
%     T_MC = handles.vi_IGHFrontPanel.GetControlValue('M/C');
%     handles.MCTemp.String = num2str(T_MC);
%     
%     Period = 5;
%     handles.timer = timer(...
%         'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
%         'Period', Period, ...                        % Initial period is 1 sec.
%         'TimerFcn', {@update_Temp_display},'UserData',handles,'Name','TEStimer');
%     start(handles.timer);
% catch
%     
% end
% url = 'http://192.168.2.121:5001/heater/update/heater_nr:4,';
% msg = webread(url)
PwrInit = handles.BF.ReadPower;
if PwrInit > handles.BF.ReadMaxPower
    PwrInit = 0;
    handles.BF.SetPower(0);
else
    % handles.BF.SetPower(PwrInit);
end
set(handles.PwrManual,'String',num2str(PwrInit));

controlby_Callback(handles.controlby,[],handles);
handles.Stop.UserData = 0;

handles.timer = timer(...
    'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
    'Period', Period, ...                        % Initial period is 1 sec.
    'TimerFcn', {@update_Temp_display},'UserData',handles,'Name','TEStimer');
start(handles.timer);

handles.AutoPwr = timer(...
    'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
    'Period', Period, ...                        % Initial period is 1 sec.
    'TimerFcn', {@auto_power},'UserData',{handles},'Name','TEStimer');
% Update handles structure

waitfor(warndlg('Temperature will be set in KELVIN!!! ','BFControler','modal'));
guidata(hObject, handles);

% UIWAIT makes BFTempControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BFTempControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
guidata(hObject,handles);

function update_Temp_display(src,evnt)

% Hay que añadir que guarde la lectura en un archivo 

handles = src.UserData;
T_MC = handles.BF.ReadTemp;
if ~isnan(T_MC)
    handles.MCTemp.String = num2str(T_MC);
end
% drawnow;% fprintf(handles.FileTemp,'%f',T_MC);
 
function auto_power(src,evnt)
Data = src.UserData;
handles = guidata(Data{1}.figure1);

% Power = handles.BF.ReadPower;
if get(handles.Go2Temp,'BackgroundColor') == handles.Active_Color
    
    % handles.SetPt = handles.BF.ReadSetPoint;
    set(handles.SetPoint,'String',num2str(handles.SetPt));
    SetPoint_Callback(handles.SetPoint,[],handles);
%     handles.BF.SetTemp(handles.SetPt);
    % Se comprueba la temperatura de la mixing
%     frewind(handles.FileTemp);
%     T_MC = fgetl(handles.FileTemp);    
    
    T_MC = str2double(get(handles.MCTemp,'String'));
    while isnan(T_MC)
        T_MC = str2double(get(handles.MCTemp,'String'));            
    end
    
    dt = 7;
    handles.E(1) = handles.SetPt-T_MC;
    handles.U(1) = max(0,handles.U(2) + ...
        handles.BF.P*(handles.E(1)-handles.E(2)) + ...
        (handles.BF.P/handles.BF.I)*handles.E(1)*dt);
    
    handles.E(3) = handles.E(2);
    handles.E(2) = handles.E(1);
%     disp(handles.U);
    handles.U(2) = handles.U(1);      
    if handles.U(1) > handles.BF.ReadMaxPower
        disp('Power above recommended value, consider stop the controler!')
    end
    disp(handles.U(1));
    SetPower = min(handles.U(1),handles.BF.ReadMaxPower);   
    set(handles.PwrManual,'String',num2str(SetPower*1e3));
    if handles.U(1) >  5
        disp('Power above 5 mW');
    else
        handles.BF.SetPower(SetPower);
        disp(handles.E(1));
    end
    
    
%     Error = handles.PIDError;
%     
%     % La potencia de inicio se actualiza con la que tiene el heater al
%     % comienzo
% %     Power = handles.BF.ReadPower;
%     sumError = Power*handles.BF.I/handles.BF.P;
%     % calculo de la potencia a suministrar
%     Error = [handles.SetPt-T_MC; Error(1:end-1)];
%     handles.PIDError = Error;
%     sumError = sumError + Error(1);
%     
%     SetPower = min(max(handles.BF.P*(Error(1) +...
%         (1/handles.BF.I)*sumError +...
%         handles.BF.D*diff(Error([2 1]))),0),handles.BF.ReadMaxPower);
%     % De momento esta capado para no usar el heater
%     handles.BF.SetPower(SetPower);
%     [handles.BF.P handles.BF.I handles.BF.D]
end


guidata(handles.figure1,handles);

function SetPoint_Callback(hObject, eventdata, handles)
% hObject    handle to SetPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SetPoint as text
%        str2double(get(hObject,'String')) returns contents of SetPoint as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value < 0
        set(hObject,'String','0.085');
    end
else
    set(hObject,'String','0.085');
end
handles.SetPt = value;
handles.BF.SetTemp(handles.SetPt);
if value >= 0.06
    handles.P.String = 0.02;
    handles.BF.P = 0.02;
    handles.I.String = 100;
    handles.BF.I = 100;
    P_Callback(handles.P,[],handles)
else
    handles.BF.P = 0.01;
    handles.P.String = 0.01;
    handles.BF.I = 250;
    handles.I.String = 250;
    P_Callback(handles.P,[],handles)
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SetPoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Go2Temp,'BackgroundColor',handles.Disable_Color)
hObject.UserData = 1;
guidata(hObject,handles);


function MaxPower_Callback(hObject, eventdata, handles)
% hObject    handle to MaxPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxPower as text
%        str2double(get(hObject,'String')) returns contents of MaxPower as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','0');
    elseif value >= 5 % Limite de potencia máxima interna
         button = questdlg('Max Power beyond 5 mW. Are you sure to continue?','Warning','Yes','No','No');
        switch(button)
            case 'Yes'
            case 'No'
                set(handles.MaxPower,'String',num2str(handles.BF.ReadMaxPower*1e3));
                return;
        end
        
    end        
else
    set(hObject,'String','0');
end
handles.BF.SetMaxPower(value*1e-3); % milivatios
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function MaxPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function P_Callback(hObject, eventdata, handles)
% hObject    handle to P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of P as text
%        str2double(get(hObject,'String')) returns contents of P as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','0.01');   
    end        
else
    set(hObject,'String','0.01'); % 1 microvatio
end
handles.BF.P = str2double(get(handles.P,'String'));
handles.BF.I = str2double(get(handles.I,'String'));
handles.BF.D = str2double(get(handles.D,'String'));
handles.BF.SetPID(handles.BF.P,handles.BF.I,handles.BF.D);

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function P_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function I_Callback(hObject, eventdata, handles)
% hObject    handle to I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of I as text
%        str2double(get(hObject,'String')) returns contents of I as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value < 0
        set(hObject,'String','2');   
    end        
else
    set(hObject,'String','2'); % 1 microvatio
end

handles.BF.P = str2double(get(handles.P,'String'));
handles.BF.I = str2double(get(handles.I,'String'));
handles.BF.D = str2double(get(handles.D,'String'));
handles.BF.SetPID(handles.BF.P,handles.BF.I,handles.BF.D);
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function I_CreateFcn(hObject, eventdata, handles)
% hObject    handle to I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function D_Callback(hObject, eventdata, handles)
% hObject    handle to D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D as text
%        str2double(get(hObject,'String')) returns contents of D as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value < 0
        set(hObject,'String','0.0005');   
    end        
else
    set(hObject,'String','0.0005'); % 1 microvatio
end

handles.BF.P = str2double(get(handles.P,'String'));
handles.BF.I = str2double(get(handles.I,'String'));
handles.BF.D = str2double(get(handles.D,'String'));
handles.BF.SetPID(handles.BF.P,handles.BF.I,handles.BF.D);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function D_CreateFcn(hObject, eventdata, handles)
% hObject    handle to D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Go2Temp.
function Go2Temp_Callback(hObject, eventdata, handles)
% hObject    handle to Go2Temp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Go2Temp,'BackgroundColor',handles.Active_Color);

PID_mode = handles.BF.ReadPIDStatus;
if PID_mode
    handles.BF.SetTempControl(0); %Manual
    handles.BF.SetPt = handles.SetPt;
    guidata(hObject,handles);

end

if strcmp(handles.AutoPwr.Running,'off')
    start(handles.AutoPwr);
end



guidata(hObject,handles);



% --- Executes on selection change in controlby.
function controlby_Callback(hObject, eventdata, handles)
% hObject    handle to controlby (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns controlby contents as cell array
%        contents{get(hObject,'Value')} returns selected item from controlby

switch get(hObject,'Value')
    case 1  % PID
        % Disable other case boxes
        set(handles.PwrManual,'Enable','off');
        % Enable self containers
        set([handles.P handles.I handles.D handles.Go2Temp handles.Stop],'Enable','on');
                
    case 2  % Manual
        % Disable other case boxes
        set(handles.PwrManual,'Enable','on');
        % Enable self containers
        set([handles.P handles.I handles.D handles.Go2Temp handles.Stop],'Enable','off');
        stop(handles.AutoPwr);
        Pwr = handles.BF.ReadPower*1e3;
        set(handles.PwrManual,'String',num2str(Pwr));
    case 3  % Others (could be IA-based)
        set([handles.P handles.I handles.D handles.PwrManual handles.Go2Temp handles.Stop],'Enable','off');
        stop(handles.AutoPwr);
    otherwise
end


% --- Executes during object creation, after setting all properties.
function controlby_CreateFcn(hObject, eventdata, handles)
% hObject    handle to controlby (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PwrManual_Callback(hObject, eventdata, handles)
% hObject    handle to PwrManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PwrManual as text
%        str2double(get(hObject,'String')) returns contents of PwrManual as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value < 0
        set(hObject,'String','0');   
    end        
    if value > 0.8*handles.BF.ReadMaxPower*1e3
        button = questdlg('Power up to 80% of max power. Are you sure to continue?','Warning','Yes','No','No');
        switch(button)
            case 'Yes'
            case 'No'
                set(handles.PwrManual,'String',num2str(handles.BF.ReadPower*1e3));
                return;
        end
    end
else
    set(hObject,'String','0'); % 1 microvatio
end
% value = str2double(get(hObject,'String'))*1e-3;

% De momento esta capado
% handles.BF.SetPower(value);

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function PwrManual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PwrManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

delete(hObject);

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    handles.BF.Heater.close;
delete(handles.AutoPwr);
delete(handles.timer);
catch
end

close(handles.figure1);
