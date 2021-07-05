function varargout = ElectNoiseViewer(varargin)
% ELECTNOISEVIEWER MATLAB code for ElectNoiseViewer.fig
%      ELECTNOISEVIEWER, by itself, creates a new ELECTNOISEVIEWER or raises the existing
%      singleton*.
%
%      H = ELECTNOISEVIEWER returns the handle to a new ELECTNOISEVIEWER or the handle to
%      the existing singleton*.
%
%      ELECTNOISEVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ELECTNOISEVIEWER.M with the given input arguments.
%
%      ELECTNOISEVIEWER('Property','Value',...) creates a new ELECTNOISEVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ElectNoiseViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ElectNoiseViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ElectNoiseViewer

% Last Modified by GUIDE v2.5 05-Jul-2021 12:15:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ElectNoiseViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @ElectNoiseViewer_OutputFcn, ...
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


% --- Executes just before ElectNoiseViewer is made visible.
function ElectNoiseViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ElectNoiseViewer (see VARARGIN)

% Choose default command line output for ElectNoiseViewer
handles.output = hObject;

handles.output = hObject;
handles.varargin = varargin;
position = get(handles.figure1,'Position');
set(handles.figure1,'Color',[0 0.2 0.5],'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');

handles.VersionStr = handles.varargin{1}.version; %'ZarTES v4.1';
set(handles.figure1,'Name',['Electrical Noise Identification    ---   ' handles.VersionStr]);


InicialConf(handles.varargin{1}.circuitNoise,handles);
habilitar(hObject);
handles.circuitNoise = handles.varargin{1}.circuitNoise;

% % Update guide with the current parameters
% if ~handles.circuitNoise.ModelBased
%     if isempty(handles.circuitNoise.Array)
%         handles.ManualSingle.Value = 1;
%         ManualSingle_Callback(handles.ManualSingle,[],handles);
%         set(handles.ElectValue,'String',num2str(handles.circuitNoise.Value*1e12));
%         set(handles.View,'Enable','off');
%     else
%         handles.ManualArray.Value = 1;
%         ManualArray_Callback(handles.ManualArray,[],handles);
%         set(handles.LoadedFile,'String',handles.circuitNoise.File);
%         set(handles.View,'Enable','on');
%     end
% else
%     if handles.ModelBased.Value
%         ModelBased_Callback(handles.ModelBased,[],handles);
%         if isempty(handles.ModelArray.Value)
%             handles.ModelSingle.Value = 1;
%             ModelSingle_Callback(handles.ModelSingle,[],handles);
%             set(handles.ModelSingleValue,'String',num2str(handles.circuitNoise.Value*1e12));
%             set(handles.View,'Enable','off');
%         end
%     end
%     if handles.ModelSingle.Value
%         ModelBased_Callback(handles.ModelBased,[],handles);            
%         ModelArray_Callback(handles.ModelArray,[],handles);
%         set(handles.LoadedModelFile,'String',handles.circuitNoise.File);
%         set(handles.ModelView,'Enable','off');
%     end
% end

handles.h = handles.varargin{2};
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ElectNoiseViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ElectNoiseViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
set(handles.figure1,'Visible','on');
varargout{1} = handles.output;



function ElectValue_Callback(hObject, eventdata, handles)
% hObject    handle to ElectValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ElectValue as text
%        str2double(get(hObject,'String')) returns contents of ElectValue as a double
num = str2double(get(hObject,'String'))*1e-12;
if ~isnumeric(num)
    warndlg('Incorrect number value',handles.VersionStr);
    return;
end
handles.circuitNoise.Value = num;
handles.circuitNoise.Array = [];
handles.circuitNoise.NoFiltArray = [];
handles.circuitNoise.File = [];
handles.circuitNoise.Selected_Tipo = 1;
handles.circuitNoise.ModelBased = 0;
set(handles.View,'Enable','off');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ElectValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ElectValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FromFile.
function FromFile_Callback(hObject, eventdata, handles)
% hObject    handle to FromFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.txt', 'Pick a txt file');
    if isequal(filename,0) || isequal(pathname,0)
       disp('User pressed cancel')
       return;
    end
    Data = importdata([pathname filesep filename]);
    fNoise = Data(:,1);
    SigNoise = Data(:,2);

    f = logspace(1,5,321)';
    
    SigNoise = spline(fNoise,SigNoise,f);
    SigNoise = handles.varargin{1}.V2I(SigNoise);
    handles.circuitNoise.NoFiltArray = SigNoise;
    % Filtrar ruido
    
    SigNoise = handles.varargin{1}.ElectrThermalModel.NoiseFiltering(handles.circuitNoise.NoFiltArray);
    
    handles.circuitNoise.Array = SigNoise;
    handles.circuitNoise.File = [pathname filesep filename];
    handles.circuitNoise.Selected_Tipo = 1;
    handles.circuitNoise.Value = [];
    handles.circuitNoise.ModelBased = 0;
 
    set(handles.LoadedFile,'String',handles.circuitNoise.File);
    
    set(handles.View,'Enable','on');
    guidata(hObject,handles);
    
% --- Executes on button press in View.
function View_Callback(hObject, eventdata, handles)
% hObject    handle to View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure; 
loglog(logspace(1,5,321),handles.circuitNoise.NoFiltArray,'DisplayName','No Filtered Noise');
hold on;
loglog(logspace(1,5,321),handles.circuitNoise.Array,'DisplayName','Filtered Noise');
xlabel('Freq (Hz)');
ylabel('Amplitude (A/{Hz}^{1/2})');
set(gca,'Yscale','log','Xscale','log')


% --- Executes on button press in ModelFromFile.
function ModelFromFile_Callback(hObject, eventdata, handles)
% hObject    handle to ModelFromFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Noise = TES_BasalNoises;


[filename, pathname] = uigetfile('*.txt', 'Pick a txt file');
    if isequal(filename,0) || isequal(pathname,0)
       disp('User pressed cancel')
       return;
%     else
%        disp(['User selected ', fullfile(pathname, filename)])
    end
    fig = figure('Visible','off');
    Noise = Noise.NoisefromFile([pathname filename],fig,handles.varargin{1});
    
    
    
    % Filtrar la señal de ruido
    handles.circuitNoise.NoFiltArray = Noise.SigNoise;
    % Filtrar ruido
    
    Noise.SigNoise = handles.varargin{1}.ElectrThermalModel.NoiseFiltering(handles.circuitNoise.NoFiltArray);
    
    
    Tbath = str2double(Noise.fileNoise(find(Noise.fileNoise == '_', 1, 'last')+1:strfind(Noise.fileNoise,'mK.txt')-1));
    if ~isnumeric(Tbath)
        msgbox('No valid Tbath value was automatically detected from file name',handles.VersionStr);
        Tbath = [];
    end
        
       
    reply = inputdlg('Introduce a Tbath (mK) value',handles.VersionStr,[1 50],{num2str(Tbath)});
%     reply = input('Introduce a Tbath value','50mK');
    if isempty(reply)
        warndlg('No Tbath value selected',handles.VersionStr);
        return;
    end
    Tbath = str2double(reply)*1e-3;
    if ~isnumeric(Tbath)
        warndlg('Invalid Tbath value',handles.VersionStr);
        return;
    end
    [f,N,Noise] = Noise.NnoiseModel(handles.varargin{1},Tbath);
    handles.circuitNoise.Array = N;
    handles.circuitNoise.Value = [];
    handles.circuitNoise.File = Noise.fileNoise;
    handles.circuitNoise.Selected_Tipo = 2;
    handles.circuitNoise.ModelBased = 1;
    set(handles.LoadedModelFile,'String',handles.circuitNoise.File);
        
    set(handles.ModelView,'Enable','on');

    
    guidata(hObject,handles);
% --- Executes on button press in ModelView.
function ModelView_Callback(hObject, eventdata, handles)
% hObject    handle to ModelView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


figure;
loglog(logspace(1,5,321),handles.circuitNoise.NoFiltArray*1e-12,'DisplayName','No Filtered Noise');
hold on;
loglog(logspace(1,5,321),handles.circuitNoise.Array,'DisplayName','Model Based Noise');
xlabel('Freq (Hz)');
ylabel('Amplitude (A/{Hz}^{1/2})');
set(gca,'Yscale','log','Xscale','log')

function ModelSingleValue_Callback(hObject, eventdata, handles)
% hObject    handle to ModelSingleValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ModelSingleValue as text
%        str2double(get(hObject,'String')) returns contents of ModelSingleValue as a double


% Elegir entre media, mediana, algun valor de un percentil...etc.

handles.ElectricalNoise.ModelBased = 1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ModelSingleValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ModelSingleValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function habilitar(src)

handles = guidata(src);

ManualArray = get(handles.ManualArray,'Value');
ManualSingle = get(handles.ManualSingle,'Value');
ModelBased = get(handles.ModelBased,'Value');
BotonesPrimarios = sum([ManualArray ManualSingle*2 ModelBased*3]);

switch BotonesPrimarios
    case 1 % Manual Array
        set([handles.ElectValue],'Enable','off'); 
        set(handles.FromFile,'Enable','on');   
        set([handles.ModelSingleValue handles.ModelFromFile handles.ModelSingleChoose],'Enable','off');
%         ManualArray_Callback(handles.ManualArray,[],handles);
    case 2 % Manual Single
        set([handles.FromFile handles.View],'Enable','off'); 
        set(handles.ElectValue,'Enable','on'); 
        set([handles.ModelSingleValue handles.ModelFromFile handles.ModelSingleChoose],'Enable','off');
%         ManualSingle_Callback(handles.ManualArray,[],handles);
    case 3 % Model Based
        set([handles.FromFile handles.View handles.ElectValue],'Enable','off');      
%         ModelBased_Callback(handles.ModelBased,[],handles);
        if handles.ModelArray.Value
            set(handles.ModelFromFile,'Enable','on');
            set([handles.ModelSingleValue handles.ModelSingleChoose],'Enable','off');
%             ModelArray_Callback(handles.ModelArray,[],handles);
        elseif handles.ModelSingle.Value
            set([handles.ModelSingleValue handles.ModelSingleChoose],'Enable','on');
            set(handles.ModelFromFile,'Enable','off');
%             ModelSingle_Callback(handles.ModelArray,[],handles);
        end
    otherwise
        
end


guidata(src,handles);

function InicialConf(ElectricalNoise,handles)

switch ElectricalNoise.Selected_Tipo
    case 1 % Value
        set([handles.LoadedFile handles.LoadedModelFile],'String','');        
        if ElectricalNoise.ModelBased == 0
            set(handles.ElectValue,'String',num2str(ElectricalNoise.Value*1e12));
            handles.ManualSingle.Value = 1;
        else
            handles.ModelBased.Value = 1;
            handles.ModelSingle.Value = 1;
            set(handles.ModelSingleValue,'String',num2str(ElectricalNoise.Value*1e12));
            set(handles.LoadedModelFile,'String',num2str(ElectricalNoise.File));   
        end
        
        
    case 2 % Array        
        if ElectricalNoise.ModelBased == 0
            handles.ManualArray.Value = 1;
            set(handles.LoadedFile,'String',ElectricalNoise.File);
            set(handles.LoadedModelFile,'String','');
        else
            handles.ModelBased.Value = 1;
            handles.ModelArray.Value = 1;
            set(handles.LoadedModelFile,'String',num2str(ElectricalNoise.File));            
            set(handles.LoadedFile,'String','');
        end
        set(handles.ElectValue,'String','');
    
end 





% --- Executes on button press in ManualArray.
function ManualArray_Callback(hObject, eventdata, handles)
% hObject    handle to ManualArray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ManualArray
habilitar(hObject);


% --- Executes on button press in ManualSingle.
function ManualSingle_Callback(hObject, eventdata, handles)
% hObject    handle to ManualSingle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ManualSingle
habilitar(hObject)


% --- Executes on button press in ModelBased.
function ModelBased_Callback(hObject, eventdata, handles)
% hObject    handle to ModelBased (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ModelBased
habilitar(hObject)


% --- Executes on button press in ModelArray.
function ModelArray_Callback(hObject, eventdata, handles)
% hObject    handle to ModelArray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ModelArray
handles.circuitNoise.Selected_Tipo = 2;
guidata(hObject,handles);
habilitar(hObject)


% --- Executes on button press in ModelSingle.
function ModelSingle_Callback(hObject, eventdata, handles)
% hObject    handle to ModelSingle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ModelSingle
if ~isempty(handles.circuitNoise.File)
    switch handles.ModelSingleChoose.Value
        case 1 %Mean value
            handles.circuitNoise.Value = nanmean(handles.circuitNoise.Array);
        case 2 %Median value
            handles.circuitNoise.Value = nanmedian(handles.circuitNoise.Array);
        case 3 %Mode value
            handles.circuitNoise.Value = mode(handles.circuitNoise.Array);
    end
    
    handles.ModelSingleValue.String = num2str(handles.circuitNoise.Value*1e12);
    handles.circuitNoise.Selected_Tipo = 1;
end
guidata(hObject,handles);
habilitar(hObject)


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.h,'UserData',handles.circuitNoise);

close(handles.figure1);
% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.figure1);
% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


delete(hObject);



% --- Executes on selection change in ModelSingleChoose.
function ModelSingleChoose_Callback(hObject, eventdata, handles)
% hObject    handle to ModelSingleChoose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ModelSingleChoose contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ModelSingleChoose
if ~isempty(handles.circuitNoise.File)
    switch handles.ModelSingleChoose.Value
        case 1 %Mean value
            handles.circuitNoise.Value = nanmean(handles.circuitNoise.Array);
        case 2 %Median value
            handles.circuitNoise.Value = nanmedian(handles.circuitNoise.Array);
        case 3 %Mode value
            handles.circuitNoise.Value = mode(handles.circuitNoise.Array);
    end
    
    handles.ModelSingleValue.String = num2str(handles.circuitNoise.Value*1e12);
    handles.circuitNoise.Selected_Tipo = 1;
end

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ModelSingleChoose_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ModelSingleChoose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
