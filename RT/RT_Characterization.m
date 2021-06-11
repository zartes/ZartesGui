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

% Last Modified by GUIDE v2.5 11-Jun-2021 12:03:41

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

handles.CurrentPath = pwd;
handles.MainDir = handles.CurrentPath(1:find(handles.CurrentPath == filesep, 1, 'last' ));
handles.d = dir(handles.MainDir);
for i = 3:length(handles.d) % Los dos primeros son '.' y '..'
    if handles.d(i).isdir
        addpath([handles.MainDir handles.d(i).name])
    end
end
% handles.AVSPath = [pwd filesep 'AVS47'];
% addpath(handles.AVSPath);

% Green color - Active
handles.Active_Color = [120 170 50]/255;
% Gray color - Disable elements
handles.Disable_Color = [204 204 204]/255;

%% Conexión con el BlueFors
% DEVICE_IP = 'localhost';
% TIMEOUT = 10;

handles.BF = BlueFors;
handles.BF = handles.BF.Constructor;

handles.P = num2str(handles.BF.P);
handles.I = num2str(handles.BF.I);
handles.D = num2str(handles.BF.D);
set(handles.MaxPower,'String',num2str(handles.BF.ReadMaxPower));


T_MC = handles.BF.ReadTemp;
handles.MCTemp.String = num2str(T_MC);
Period = 5;
handles.timer = timer(...
    'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
    'Period', Period, ...                        % Initial period is 1 sec.
    'TimerFcn', {@update_Temp_display},'UserData',handles,'Name','TEStimer');
start(handles.timer);
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

Channel = get(handles.Channel_List,'Value')-1;
Rango = get(handles.Range_List,'Value')-1;
RangoContent = get(handles.Range_List,'String');
RangoStr = RangoContent{Rango+1};

Excitacion = get(handles.Exc_List,'Value')-1;
ExcitacionContent = get(handles.Exc_List,'String');
ExcitacionStr = ExcitacionContent{Excitacion+1};

[avs_Device] = InicializaRTs(Channel,Rango,Excitacion);

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
[R, T] = MedidaRTs(avs_Device,handles,Curva,TempRange,TempStep,ToleranceError,handles.axes1);

avs_Device.Destructor;
% h = findobj('Type','Line');
% set(h,'Visible','off');

plot(handles.axes1,T,R,'DisplayName',['Ch' num2str(Channel) '-' RangoStr '-' ExcitacionStr '-' Curva ],'Marker','*');
xlabel(handles.axes1,'Temperature (K)','LineWidth',2,'FontSize',12,'FontWeight','bold');
ylabel(handles.axes1,'Resistance (Ohm)','LineWidth',2,'FontSize',12,'FontWeight','bold');

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
data = [T' R'];
try
    save([pathname filename],'data','-ascii');
catch
    return;
end

hf = figure;
ax = axes;
plot(ax,T,R,'DisplayName',['Ch' num2str(Channel) '-' RangoStr '-' ExcitacionStr '-' Curva ],'Marker','*');
xlabel(ax,'Temperature (K)','LineWidth',2,'FontSize',12,'FontWeight','bold');
ylabel(ax,'Resistance (Ohm)','LineWidth',2,'FontSize',12,'FontWeight','bold');
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
rmpath(handles.AVSPath);
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
handles.BF.SetMaxPower(value*1e-3);

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
        set(hObject,'String','0.001');   
    end        
else
    set(hObject,'String','0.001'); % 1 microvatio
end



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
