function varargout = RT_Characterization(varargin)
% RT_CHARACTERIZATION MATLAB code for RT_Characterization.fig
%      RT_CHARACTERIZATION, by itself, creates a new RT_CHARACTERIZATION or raises the existing
%      singleton*.
%
%      H = RT_CHARACTERIZATION returns the handle to a new RT_CHARACTERIZATION or the handle to
%      the existing singleton*.
%
%      RT_CHARACTERIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RT_CHARACTERIZATION.M with the given input arguments.
%
%      RT_CHARACTERIZATION('Property','Value',...) creates a new RT_CHARACTERIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RT_Characterization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RT_Characterization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RT_Characterization

% Last Modified by GUIDE v2.5 08-Apr-2022 11:11:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RT_Characterization_OpeningFcn, ...
                   'gui_OutputFcn',  @RT_Characterization_OutputFcn, ...
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


% --- Executes just before RT_Characterization is made visible.
function RT_Characterization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RT_Characterization (see VARARGIN)

% Choose default command line output for RT_Characterization
handles.output = hObject;

position = get(handles.figure1,'Position');
set(handles.figure1,'Color',[0 120 180]/255,'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');
handles.AVSPath = [pwd filesep 'AVS47'];
addpath(handles.AVSPath);

warning off;
handles.avs_Device = AVS;
handles.avs_Device = handles.avs_Device.Constructor;
handles.avs_Device = handles.avs_Device.Initialize;

% Reservamos el handles para el AVSByPass
handles.AVSByPass = AVSByPass;


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
handles.U = [handles.BF.ReadPower 0];
handles.E = [0 0 0];



handles.BF.SetMaxPower(1e-3);
set(handles.MaxPower,'String',num2str(handles.BF.ReadMaxPower*1e3));
T_MC = handles.BF.ReadTemp;
handles.MCTemp.String = num2str(T_MC);
Period = 7;
handles.timer = timer(...
    'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
    'Period', Period, ...                        % Initial period is 1 sec.
    'TimerFcn', {@update_Temp_display},'UserData',handles,'Name','TEStimer1');
start(handles.timer);

handles.AutoPwr = timer(...
    'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
    'Period', Period, ...                        % Initial period is 1 sec.
    'TimerFcn', {@auto_power},'UserData',{handles},'Name','TEStimer');

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

handles.Stop.UserData = 0;

hOpenMenu = uimenu('Parent',handles.figure1,'Label',...
    'Open File','Callback',{@OpenFile});

handles.vi = [];

TipoCurva = {'Ascendente';'Descendente'};
Curva = TipoCurva{get(handles.Scan_Type,'Value')};

switch Curva
    case 'Ascendente'
        set(handles.ApplyPower,'String','Apply >>');
    case 'Descendente'
        set(handles.ApplyPower,'String','Apply <<');
    otherwise
        
end

if handles.H_Grid.Value
    H_Grid_Callback(handles.H_Grid,[],handles);    
end
if handles.H_Hold.Value
    H_Hold_Callback(handles.H_Hold,[],handles);    
end
Exc_List_Callback(handles.Exc_List,[],handles);
Range_List_Callback(handles.Range_List,[],handles);
Channel_List_Callback(handles.Channel_List,[],handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RT_Characterization wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RT_Characterization_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
guidata(hObject,handles);

function update_Temp_display(src,evnt)

handles = src.UserData;
T_MC = handles.BF.ReadTemp;
% T_MC = handles.vi_IGHFrontPanel.GetControlValue('M/C');
handles.MCTemp.String = num2str(T_MC);
% guidata(hObject,handles);
% 
% 
% T_MC = handles.vi_IGHFrontPanel.GetControlValue('M/C');
% handles.MCTemp.String = num2str(T_MC);

function auto_power(src,evnt)
Data = src.UserData;
handles = guidata(Data{1}.figure1);
TipoCurva = {'Ascendente';'Descendente'};
Curva = TipoCurva{get(handles.Scan_Type,'Value')};

if get(handles.Start,'BackgroundColor') == handles.Active_Color
    Power = handles.BF.ReadPower;
    PowerStep = str2double(handles.PowerStep.String)*1e-6;
    switch Curva
        case 'Ascendente'
            SetPower = Power + PowerStep;
        case 'Descendente'
            SetPower = max(Power - PowerStep,0);
        otherwise
            
    end
    handles.BF.SetPower(SetPower)
else
    TempRange = [str2double(get(handles.Temp1,'String')) str2double(get(handles.Temp2,'String'))];    
    switch Curva
        case 'Ascendente'
            SetPt = min(TempRange);
        case 'Descendente'
            SetPt = max(TempRange);
    end


    handles.SetPt = handles.BF.ReadSetPoint;
    handles.BF.SetTemp(SetPt);
    % Se comprueba la temperatura de la mixing
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
    handles.U(2) = handles.U(1);
    
    % Calculo de la potencia version derivadas
    % Potencia anterior u(t)
%     t = tic;
%     u_t1 = handles.BF.ReadPower;
%     for jj = 1:2
%         T_MC = handles.BF.ReadTemp;
%         if jj > 1
%             % Error anterior e(t)
%             e_t1 = handles.SetPt-T_MC;
%             % Tiempo (dt)
%             dt = toc(t);
%         else
%             % Error actual e(t+1)
%              
% %             e_t = handles.SetPt-T_MC;            
%         end
%     end
    
    
    
%     u_t = u_t1*dt + handles.BF.P*(e_t-e_t1) + ...
%         (handles.BF.P/handles.BF.I)*e_t*dt;
    %+ (handles.BF.P*handles.BF.D)*((e_t-e_t1)-(e_t1-e_t2));
    SetPower = handles.U(1);          
    handles.BF.SetPower(SetPower);
    
    
    
%     Error = handles.PIDError;
%     
%     % La potencia de inicio se actualiza con la que tiene el heater al
%     % comienzo
%     % Power = handles.BF.ReadPower;
%     sumError = Power*handles.BF.I/handles.BF.P;
%     % calculo de la potencia a suministrar
%     Error = [SetPt-T_MC; Error(1:end-1)];
%     handles.PIDError = Error;
%     sumError = sumError + Error(1);
% %     SetPower = min(max(SetupTES.BF.P*(Error(1) +...
% %         (1/SetupTES.BF.I)*sumError +...
% %         SetupTES.BF.D*diff(Error([2 1]))),0),MaxPower);
%     SetPower = min(max(abs(handles.BF.P*(Error(1) +...
%         (1/handles.BF.I)*sumError +...
%         handles.BF.D*diff(Error([2 1])))),0),handles.BF.ReadMaxPower);
% %     SetPower
    
end
% handles.BF.SetPower(SetPower);

guidata(handles.figure1,handles);

function OpenFile(src,evnt)

handles = guidata(src);
[filename, pathname] = uigetfile( ...
    {'*.dat'}, ...
    'Pick ASCII file/s', ...
    'MultiSelect', 'on');

if ~isequal(filename,0)
    if ischar(filename)
        datos = importdata([pathname filename]);                        
        handles.axes1.Visible = 'on';
        plot(handles.axes1,datos(:,1),datos(:,2),'DisplayName',filename);
        xlabel('T (K)')
        ylabel('R (Ohm)');
    else
        handles.H_Hold.Value = 1;        
        H_Hold_Callback(handles.H_Hold,[],handles);
        handles.axes1.Visible = 'on';
        for i = 1:length(filename)
            datos{i} = importdata([pathname filename{i}]);
            plot(handles.axes1,datos{i}(:,1),datos{i}(:,2),'DisplayName',filename{i});            
        end
        xlabel(handles.axes1,'T (K)')
        ylabel(handles.axes1,'R (Ohm)');
    end
end

%%%  Filtro de promedio a cada temperatura.
% T = unique(datos(:,2));
% for i = 1:length(indx)
% R(i) = mean(datos(datos(:,2) == T(i),1));
% end
%%%


% --- Executes on selection change in Exc_List.
function Exc_List_Callback(hObject, eventdata, handles)
% hObject    handle to Exc_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Exc_List contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Exc_List

Excitacion = get(handles.Exc_List,'Value')-1;
ExcitacionContent = get(handles.Exc_List,'String');
ExcitacionStr = ExcitacionContent{Excitacion+1};
handles.avs_Device = handles.avs_Device.ChangeExcitacion(Excitacion);
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function Exc_List_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Exc_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Range_List.
function Range_List_Callback(hObject, eventdata, handles)
% hObject    handle to Range_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Range_List contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Range_List
Rango = get(handles.Range_List,'Value')-1;
RangoContent = get(handles.Range_List,'String');
RangoStr = RangoContent{Rango+1};
handles.avs_Device = handles.avs_Device.ChangeRango(Rango);

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Range_List_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Range_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Channel_List.
function Channel_List_Callback(hObject, eventdata, handles)
% hObject    handle to Channel_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Channel_List contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Channel_List

Channel = get(handles.Channel_List,'Value')-1;
handles.avs_Device = handles.avs_Device.ChangeChannel(Channel);
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function Channel_List_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Channel_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Scan_Type.
function Scan_Type_Callback(hObject, eventdata, handles)
% hObject    handle to Scan_Type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Scan_Type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Scan_Type
TipoCurva = {'Ascendente';'Descendente'};
Curva = TipoCurva{get(handles.Scan_Type,'Value')};
switch Curva
    case 'Ascendente'
        handles.ApplyPower.String = 'Apply >>';
    case 'Descendente'
        handles.ApplyPower.String = 'Apply <<';
end

% --- Executes during object creation, after setting all properties.
function Scan_Type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scan_Type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Temp_Step_Callback(hObject, eventdata, handles)
% hObject    handle to Temp_Step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Temp_Step as text
%        str2double(get(hObject,'String')) returns contents of Temp_Step as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','0.001');
    end
else
    set(hObject,'String','0.001');
end

% --- Executes during object creation, after setting all properties.
function Temp_Step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Temp_Step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Temp1_Callback(hObject, eventdata, handles)
% hObject    handle to Temp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Temp1 as text
%        str2double(get(hObject,'String')) returns contents of Temp1 as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','0.085');
    end
else
    set(hObject,'String','0.085');
end

% --- Executes during object creation, after setting all properties.
function Temp1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Temp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Temp2_Callback(hObject, eventdata, handles)
% hObject    handle to Temp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Temp2 as text
%        str2double(get(hObject,'String')) returns contents of Temp2 as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','0.06');
    end
else
    set(hObject,'String','0.06');
end

% --- Executes during object creation, after setting all properties.
function Temp2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Temp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'BackgroundColor',handles.Active_Color);

set(handles.avs,'Value',1);
% [avs_Device] = InicializaRTs(Channel,Rango,Excitacion);

%% BlueFors

%% Oxford
% if isempty(handles.vi)  % solo se instancia para la primera vez
%     e = actxserver('LabVIEW.Application');
%     vipath = 'C:\Users\Athena\Desktop\Software\2014_Oxford TES\IGHSUBS.LLB\IGHFrontPanel.vi';
%     handles.vi.vi_IGHFrontPanel = invoke(e,'GetVIReference',vipath);
%     vipath3 = 'C:\Users\Athena\Desktop\Software\2014_Oxford TES\KELVPNLS.LLB\KelvPromptForT.vi';
%     handles.vi.vi_PromptForT = invoke(e,'GetVIReference',vipath3);
%     vipath5 = 'C:\Users\Athena\Desktop\Software\2014_Oxford TES\IGHSUBS.LLB\IGHChangeSettings.vi';
%     handles.vi.vi_IGHChangeSettings = invoke(e,'GetVIReference',vipath5);
% end




TipoCurva = {'Ascendente';'Descendente'};
Curva = TipoCurva{get(handles.Scan_Type,'Value')};
TempRange = [str2double(get(handles.Temp1,'String')) str2double(get(handles.Temp2,'String'))];
ToleranceError = str2double(get(handles.Temp_Step,'String'))*0.2/0.001;
set(handles.axes1,'Visible','on','LineWidth',2,'FontSize',12,'FontWeight','bold');
TempStep = str2double(get(handles.Temp_Step,'String'));
% load(['Ch' num2str(Channel) '.mat']);

if handles.autopower.Value
    try
        start(handles.AutoPwr);
    catch
    end
end
handles.SetPower = handles.BF.ReadPower;
guidata(hObject,handles);
[R, T, Rsig, Tsig, Pt, Dt] = MedidaRTs(handles.avs_Device,handles,Curva,TempRange,TempStep,ToleranceError,handles.axes1);

if handles.autopower.Value
    stop(handles.AutoPwr);
end
% handles.BF.SetPower(0);

% h = findobj('Type','Line');
% set(h,'Visible','off');

% plot(handles.axes1,T,R,'DisplayName',['Ch' num2str(Channel) '-' RangoStr '-' ExcitacionStr '-' Curva ],'Marker','*');
% errorbar(handles.axes1,T,R,Rsig)
% herrorbar(T,R,Tsig)
% xlabel(handles.axes1,'Temperature (K)','LineWidth',2,'FontSize',12,'FontWeight','bold');
% ylabel(handles.axes1,'Resistance (Ohm)','LineWidth',2,'FontSize',12,'FontWeight','bold');
hf = figure;
figure(hf);
ax=axes;
% ax = gca;
Channel = get(handles.Channel_List,'Value')-1;
Rango = get(handles.Range_List,'Value')-1;
RangoContent = get(handles.Range_List,'String');
RangoStr = RangoContent{Rango+1};
Excitacion = get(handles.Exc_List,'Value')-1;
ExcitacionContent = get(handles.Exc_List,'String');
ExcitacionStr = ExcitacionContent{Excitacion+1};
hold(ax,'on');
plot(ax,T,R,'DisplayName',['Ch' num2str(Channel) '-' RangoStr '-' ExcitacionStr '-' Curva ],'Marker','*');
% errorbar(ax,T,R,Rsig);
% herrorbar(T,R,Tsig);
xlabel(ax,'Temperature (K)','LineWidth',2,'FontSize',12,'FontWeight','bold');
ylabel(ax,'Resistance (Ohm)','LineWidth',2,'FontSize',12,'FontWeight','bold');

[filename, pathname] = uiputfile( ...
    {'*.dat', 'ascii (*.dat)'}, ...
    'Save as',[pwd filesep 'Ch' num2str(Channel) '.dat']);
if isequal(filename,0)
    waitfor(warndlg('No file name was selected!','ZarTES v1.0'));
    Button = questdlg('Discard data?','ZarTES v1.0','Yes','No','No');
    switch Button
        case 'No'
            [filename, pathname] = uiputfile( ...
                {'*.dat', 'ascii (*.dat)'}, ...
                'Save as',[pwd filesep 'Ch' num2str(Channel) '.dat']);
        case 'Yes'
            set(hObject,'BackgroundColor',handles.Disable_Color);
            guidata(hObject,handles);
            return;
    end
end
data = [T' R' Tsig' Rsig' Pt' Dt'];
try
    save([pathname filename],'data','-ascii');
catch
    return;
end


hgsave(hf,[pathname filename(1:end-4) '.fig']);

set(hObject,'BackgroundColor',handles.Disable_Color);
guidata(hObject,handles);


% --- Executes on button press in H_Grid.
function H_Grid_Callback(hObject, eventdata, handles)
% hObject    handle to H_Grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of H_Grid
if hObject.Value
    grid(handles.axes1,'on');
else
    grid(handles.axes1,'off');
end
   
guidata(hObject,handles);

% --- Executes on button press in H_Hold.
function H_Hold_Callback(hObject, eventdata, handles)
% hObject    handle to H_Hold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of H_Hold
if hObject.Value
    hold(handles.axes1,'on');
else
    hold(handles.axes1,'off');
end
   
guidata(hObject,handles);


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
% cmenu = uicontextmenu('Visible','on');
% uimenu(cmenu,'Label','Export Graphic Data','Callback',{@ExportGraph},'UserData',hObject);
% set(hObject,'uicontextmenu',cmenu);
% 
% 
% function ExportGraph(src,evnt)
% 
% 
% h_axes = src.UserData;
% [FileName, PathName] = uiputfile('.txt', 'Select a file name for storing data');
% if isequal(FileName,0)||isempty(FileName)
%     return;
% end
% file = strcat([PathName FileName]);
% fid = fopen(file,'a+');
% hl = findobj(h_axes,'Type','Line','Visible','on');
% LabelStr = [];
% data = [];
% for i = 1:length(hl)
%     LabelStr = [LabelStr 'X_' hl(i).DisplayName '\t' 'Y_' hl(i).DisplayName '\t'];
%     data1 = []
%     data = [data hl(i).XData'];    
%     data = [data hl(i).YData'];
% end
% he = findobj(h_axes,'Type','ErrorBar','Visible','on');
% for i = 1:length(he)
%     LabelStr = [LabelStr 'X_Errorbar' he(i).DisplayName '\t' 'Y_Errorbar' he(i).DisplayName '\t' ...
%         'Y_PosDelta' he(i).DisplayName '\t' 'Y_NegDelta' he(i).DisplayName '\t'];
%     data = [data he(i).XData'];    
%     data = [data he(i).YData'];
%     data = [data he(i).YPositiveDelta'];    
%     data = [data he(i).YNegativeDelta'];
% end
% fprintf(fid,[LabelStr '\n']);
% save(file,'data','-ascii','-tabs','-append');
% fclose(fid);


% --- Executes on button press in ClearAxes.
function ClearAxes_Callback(hObject, eventdata, handles)
% hObject    handle to ClearAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ClearAxes
cla(handles.axes1);
guidata(hObject,handles);

% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% 
% 
% 
% api_key=heater_nr4&
% 
% url = 'http://192.168.2.121:5001/heater/heater_nr:4';
% 
% url = 'http://192.168.2.121:5001/heater/update/';
% writeApiKey = 'heater_nr';
% data = 4;
% data = num2str(data);
% data = ['api_key=',writeApiKey,'&field1=',data];
% 
% options  = weboptions('heater_nr',4,'power',0);
% 
% 
% 
% resp = webwrite(url,data)

hObject.UserData = 1;
guidata(hObject,handles);

function TsetCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to TsetCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TsetCurrent as text
%        str2double(get(hObject,'String')) returns contents of TsetCurrent as a double


% --- Executes during object creation, after setting all properties.
function TsetCurrent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TsetCurrent (see GCBO)
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
handles.avs_Device.Destructor;

try
    fclose(handles.AVSByPass.s);
    rmpath(handles.AVSPath);
catch
end
delete(hObject);



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
    elseif value >= 1000 
        warndlg('Max Power beyond 1 Watt');
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



function PowerStep_Callback(hObject, eventdata, handles)
% hObject    handle to PowerStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PowerStep as text
%        str2double(get(hObject,'String')) returns contents of PowerStep as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','0.001');
    elseif value >= 500 
        warndlg('Step Power beyond 500 mW');
    end        
else
    set(hObject,'String','0.001'); % 1 microvatio
end
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function PowerStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PowerStep (see GCBO)
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
TipoCurva = {'Ascendente';'Descendente'};
Curva = TipoCurva{get(handles.Scan_Type,'Value')};
TempRange = [str2double(get(handles.Temp1,'String')) str2double(get(handles.Temp2,'String'))];
set(handles.Start,'BackgroundColor',handles.Disable_Color);
% a = load('RefValues.mat');
switch Curva
    case 'Ascendente'
        SetPt = min(TempRange);
    case 'Descendente'
        SetPt = max(TempRange);
end
% BasalPower = spline(a.RefTemps,a.RefPowers*1e-6,SetPt);  % Actualizar con los datos de caracterizacion.
% Pasar a modo manual del BlueFors
PID_mode = handles.BF.ReadPIDStatus;
if PID_mode
    handles.BF.SetTempControl(0); %Manual
    handles.BF.SetPt = SetPt;
    guidata(hObject,handles);

end
start(handles.AutoPwr);
% if BasalPower > handles.BF.ReadMaxPower
%     warndlg('Setting Power above Max Heater Power, consider changing Max Power','RT Charaterization');
%     return;
% end
% handles.BF.SetPower(BasalPower);
% msgbox('Power set to reach Set Temp','RT Characterization');

guidata(hObject,handles);



% --- Executes on button press in ApplyPower.
function ApplyPower_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TipoCurva = {'Ascendente';'Descendente'};
Curva = TipoCurva{get(handles.Scan_Type,'Value')};
switch Curva
    case 'Ascendente'
        handles.SetPower = handles.BF.ReadPower + str2double(handles.PowerStep.String)*1e-6;
    case 'Descendente'
        handles.SetPower = max(handles.BF.ReadPower - str2double(handles.PowerStep.String)*1e-6,0);
end

guidata(hObject,handles);    

% --- Executes on button press in autopower.
function autopower_Callback(hObject, eventdata, handles)
% hObject    handle to autopower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autopower
if handles.autopower.Value
    handles.ApplyPower.Enable = 'off';
else
    handles.ApplyPower.Enable = 'on';
    stop(handles.AutoPwr);
end

pause(1);
guidata(hObject,handles);


% --- Executes on button press in avs.
function avs_Callback(hObject, eventdata, handles)
% hObject    handle to avs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avs


% --- Executes on button press in PowerControl.
function PowerControl_Callback(hObject, eventdata, handles)
% hObject    handle to PowerControl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PowerControl


    


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
delete(handles.AutoPwr);
delete(handles.timer);
catch
end

close(handles.figure1);



function Nciclos_Callback(hObject, eventdata, handles)
% hObject    handle to Nciclos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Nciclos as text
%        str2double(get(hObject,'String')) returns contents of Nciclos as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','1');   
    end        
else
    set(hObject,'String','1'); % 1 microvatio
end
value = str2double(get(hObject,'String'));
R = get(handles.AutoPwr,'Running');
if strcmp(R,'on')
    stop(handles.AutoPwr);    
    handles.AutoPwr.Period = 5*value;
    start(handles.AutoPwr);
else
    handles.AutoPwr.Period = 5*value;
end

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Nciclos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Nciclos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CurrentByPass_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentByPass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CurrentByPass as text
%        str2double(get(hObject,'String')) returns contents of CurrentByPass as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0 || value > 100
        set(hObject,'String','0');   
    end        
else
    set(hObject,'String','0'); % 1 microvatio
end
value = str2double(get(hObject,'String'));

handles.AVSByPass.SetCurrent(value);


guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function CurrentByPass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentByPass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ActivateAVSByPass.
function ActivateAVSByPass_Callback(hObject, eventdata, handles)
% hObject    handle to ActivateAVSByPass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ActivateAVSByPass

if get(hObject,'Value')
    handles.AVSByPass = handles.AVSByPass.AVSByPass_init();
    set(handles.Exc_List,'Value',5); %100uV
    set(handles.Range_List,'Value',2); % 2R
    set([handles.text22 handles.CurrentByPass],'Enable','on');
else
    set([handles.text22 handles.CurrentByPass],'Enable','off');   
end
Exc_List_Callback(handles.Exc_List,[],handles);
Range_List_Callback(handles.Range_List,[],handles);

guidata(hObject,handles);
