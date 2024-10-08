function varargout = Conf_Setup_PXI(varargin)
% CONF_SETUP_PXI MATLAB code for Conf_Setup_PXI.fig
%      CONF_SETUP_PXI, by itself, creates a new CONF_SETUP_PXI or raises the existing
%      singleton*.
%
%      H = CONF_SETUP_PXI returns the handle to a new CONF_SETUP_PXI or the handle to
%      the existing singleton*.
%
%      CONF_SETUP_PXI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONF_SETUP_PXI.M with the given input arguments.
%
%      CONF_SETUP_PXI('Property','Value',...) creates a new CONF_SETUP_PXI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Conf_Setup_PXI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Conf_Setup_PXI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Conf_Setup_PXI

% Last Modified by GUIDE v2.5 24-Jul-2018 11:06:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Conf_Setup_PXI_OpeningFcn, ...
    'gui_OutputFcn',  @Conf_Setup_PXI_OutputFcn, ...
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


% --- Executes just before Conf_Setup_PXI is made visible.
function Conf_Setup_PXI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Conf_Setup_PXI (see VARARGIN)

% Choose default command line output for Conf_Setup_PXI
handles.output = hObject;
handles.varargin = varargin;
position = get(handles.figure1,'Position');
set(handles.figure1,'Color',[0 0.2 0.5],'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');


if isfield('Label','varargin') && strcmp(varargin{1}.Label,'PXI_Acquisition_card Properties')
    handles.Options.String = {'ConfStructs';'WaveFormInfo';'Options';'ObjHandle'};
    handles.Options.Value = 1;
    UserData = varargin{1}.UserData;
    a = fieldnames(UserData.ConfStructs);
    handles.SubStructure.String = a;
    % SubStructure within Horizontal setup
    eval(['b = fieldnames(UserData.ConfStructs.' a{1} ');']);
    for i = 1:length(b)
        ConfInstrs{i,1} = b{i};
        ConfInstrs{i,2} = num2str(eval(['UserData.ConfStructs.' a{1} '.' b{i} ';']));
    end
    
else
    
    switch varargin{1}.Tag
        case 'PXI_Conf_Mode'  % TF or Noise
            
        case 'PXI_TF_Zw_Conf'
            handles.figure1.Name = 'PXI Configuration';
            handles.Options.String = {'Zw'};
            % Horizontal setting
            a = fieldnames(varargin{3}.PXI.ConfStructs);
            handles.SubStructure.String = a;
            % SubStructure within Horizontal setup
            eval(['b = fieldnames(varargin{3}.PXI.ConfStructs.' a{1} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['varargin{3}.PXI.ConfStructs.' a{1} '.' b{i} ';']));
            end
        case 'PXI_TF_Noise_Conf'
            handles.figure1.Name = 'PXI Configuration';
            handles.Options.String = {'Noise'};
            % Horizontal setting
            a = fieldnames(varargin{3}.PXI.ConfStructs);
            handles.SubStructure.String = a;
            % SubStructure within Horizontal setup
            eval(['b = fieldnames(varargin{3}.PXI.ConfStructs.' a{1} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['varargin{3}.PXI.ConfStructs.' a{1} '.' b{i} ';']));
            end
            
        case 'PXI_Pulse_Conf'  % Pulses
            handles.figure1.Name = 'PXI Configuration';
            handles.Options.String = {'Pulses'};
            a = fieldnames(varargin{3}.PXI.ConfStructs);
            handles.SubStructure.String = a;
            % SubStructure within Horizontal setup
            eval(['b = fieldnames(varargin{3}.PXI.ConfStructs.' a{1} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['varargin{3}.PXI.ConfStructs.' a{1} '.' b{i} ';']));
            end
            
    end
    
end
% Configuration of the DSA options
handles.ConfInstrs = ConfInstrs;

handles.Table.Data = handles.ConfInstrs;

% Disabling first column
handles.Table.ColumnEditable = [false true false];
handles.Table.ColumnName = {'Prop.';'Value';'Unit'};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Conf_Setup_PXI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Conf_Setup_PXI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
handles.figure1.Visible = 'on';


% --- Executes on button press in Add.
function Add_Callback(hObject, eventdata, handles)
% hObject    handle to Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Table.Data = [handles.Table.Data; cell(size(handles.Table.Data))];
guidata(hObject,handles);

% --- Executes on button press in Remove.
function Remove_Callback(hObject, eventdata, handles)
% hObject    handle to Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if size(handles.Table.Data,1) > 1
    handles.Table.Data(end,:) = [];
end
guidata(hObject,handles);

% --- Executes on selection change in Options.
function Options_Callback(hObject, eventdata, handles)
% hObject    handle to Options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Options contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Options

if isfield('Label','varargin') && strcmp(handles.varargin{1}.Label,'PXI_Acquisition_card Properties')
    UserData = handles.varargin{1}.UserData;
    PXI_Str = {'ConfStructs';'WaveFormInfo';'Options';'ObjHandle'};
    if size(eval(['UserData.' PXI_Str{handles.Options.Value} ]'),2) == 1
        if handles.Options.Value == 1
            eval(['a = fieldnames(UserData.' PXI_Str{handles.Options.Value} ');']);
            handles.SubStructure.String = a;
            handles.SubStructure.Visible = 'on';
            handles.SubStructure.Value = 1;
            % SubStructure within Horizontal setup
            eval(['b = fieldnames(UserData.' PXI_Str{handles.Options.Value} '.' a{handles.SubStructure.Value} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['UserData.' PXI_Str{handles.Options.Value} '.' a{handles.SubStructure.Value} '.' b{i} ';']));
            end
        else
            handles.SubStructure.Value = 1;
            handles.SubStructure.Visible = 'off';
            % SubStructure within Horizontal setup
            eval(['b = fieldnames(UserData.' PXI_Str{handles.Options.Value} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['UserData.' PXI_Str{handles.Options.Value} '.' b{i} ';']));
            end
        end
    elseif size(eval(['UserData.' PXI_Str{handles.Options.Value} ]'),2) == 2
        handles.SubStructure.Visible = 'on';
        handles.SubStructure.String = {'1';'2'};
        handles.SubStructure.Value = 1;
        eval(['b = fieldnames(UserData.' PXI_Str{handles.Options.Value} '(' num2str(handles.SubStructure.Value) '));']);
        for i = 1:length(b)
            ConfInstrs{i,1} = b{i};
            ConfInstrs{i,2} = num2str(eval(['UserData.' PXI_Str{handles.Options.Value} '(' num2str(handles.SubStructure.Value) ').' b{i} ';']));
        end
    else
        handles.SubStructure.Visible = 'off';
        handles.SubStructure.String = {''};
        handles.SubStructure.Value = 1;
        try
            eval(['b = fieldnames(UserData.' PXI_Str{handles.Options.Value} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['UserData.' PXI_Str{handles.Options.Value} '(' num2str(handles.SubStructure.Value) ').' b{i} ';']));
            end
        catch
            ConfInstrs{1,1} = '';
        end
    end
else
    
    switch handles.varargin{1}.Tag
        
        case 'PXI_TF_Zw_Conf'
            a = fieldnames(handles.varargin{3}.PXI.ConfStructs);
            handles.SubStructure.String = a;
            % SubStructure within Horizontal setup
            eval(['b = fieldnames(handles.varargin{3}.PXI.ConfStructs.' a{handles.SubStructure.Value} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['handles.varargin{3}.PXI.ConfStructs.' a{handles.SubStructure.Value} '.' b{i} ';']));
            end
        case 'PXI_TF_Noise_Conf'
            a = fieldnames(handles.varargin{3}.PXI.ConfStructs);
            handles.SubStructure.String = a;
            % SubStructure within Horizontal setup
            eval(['b = fieldnames(handles.varargin{3}.PXI.ConfStructs.' a{handles.SubStructure.Value} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['handles.varargin{3}.PXI.ConfStructs.' a{handles.SubStructure.Value} '.' b{i} ';']));
            end
            
        case 'PXI_Pulse_Conf'  % Pulses
            handles.Options.String = {'Pulses'};
            
            % Horizontal setting
            a = fieldnames(handles.varargin{3}.PXI.ConfStructs);
            handles.SubStructure.String = a;
            % SubStructure within Horizontal setup
            eval(['b = fieldnames(handles.varargin{3}.PXI.ConfStructs.' a{handles.SubStructure.Value} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['handles.varargin{3}.PXI.ConfStructs.' a{handles.SubStructure.Value} '.' b{i} ';']));
            end
            
    end
end

% Configuration of the PXI options
handles.ConfInstrs = ConfInstrs;

handles.Table.Data = handles.ConfInstrs;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Options_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.varargin{1}.UserData = [];
figure1_DeleteFcn(handles.figure1,eventdata,handles);



% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.figure1);


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield('Label','varargin') && strcmp(handles.varargin{1}.Label,'PXI_Acquisition_card Properties')
    UserData = handles.varargin{1}.UserData;
    hndls = guidata(handles.varargin{1});
    hndls.PXI = UserData;
    guidata(hndls.SetupTES,hndls);
else
    handles.varargin{1}.UserData = handles.varargin{3}.PXI.ConfStructs;
end

figure1_DeleteFcn(handles.figure1,eventdata,handles);




% --- Executes on selection change in SubStructure.
function SubStructure_Callback(hObject, eventdata, handles)
% hObject    handle to SubStructure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SubStructure contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SubStructure

if isfield('Label','varargin') && strcmp(handles.varargin{1}.Label,'PXI_Acquisition_card Properties')
    UserData = handles.varargin{1}.UserData;
    PXI_Str = {'ConfStructs';'WaveFormInfo';'Options';'ObjHandle'};
    if size(eval(['UserData.' PXI_Str{handles.Options.Value} ]'),2) == 1
        if handles.Options.Value == 1
            eval(['a = fieldnames(UserData.' PXI_Str{handles.Options.Value} ');']);
            handles.SubStructure.String = a;
            handles.SubStructure.Visible = 'on';
            % SubStructure within Horizontal setup
            eval(['b = fieldnames(UserData.' PXI_Str{handles.Options.Value} '.' a{handles.SubStructure.Value} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['UserData.' PXI_Str{handles.Options.Value} '.' a{handles.SubStructure.Value} '.' b{i} ';']));
            end
        else
            handles.SubStructure.Visible = 'off';
            % SubStructure within Horizontal setup
            eval(['b = fieldnames(UserData.' PXI_Str{handles.Options.Value} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['UserData.' PXI_Str{handles.Options.Value} '.' b{i} ';']));
            end
        end
    elseif size(eval(['UserData.' PXI_Str{handles.Options.Value} ]'),2) == 2
        handles.SubStructure.Visible = 'on';
        handles.SubStructure.String = {'1';'2'};
        eval(['b = fieldnames(UserData.' PXI_Str{handles.Options.Value} '(' num2str(handles.SubStructure.Value) '));']);
        for i = 1:length(b)
            ConfInstrs{i,1} = b{i};
            ConfInstrs{i,2} = num2str(eval(['UserData.' PXI_Str{handles.Options.Value} '(' num2str(handles.SubStructure.Value) ').' b{i} ';']));
        end
    else
        handles.SubStructure.Visible = 'off';
        handles.SubStructure.String = {''};
        try
            eval(['b = fieldnames(UserData.' PXI_Str{handles.Options.Value} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['UserData.' PXI_Str{handles.Options.Value} '(' num2str(handles.SubStructure.Value) ').' b{i} ';']));
            end
        catch
            ConfInstrs{1,1} = '';
        end
    end
else
    
    switch handles.varargin{1}.Tag
        case 'PXI_TF_Zw_Conf'  % TF or Noise
            a = fieldnames(handles.varargin{3}.PXI.ConfStructs);
            % SubStructure within Horizontal setup
            eval(['b = fieldnames(handles.varargin{3}.PXI.ConfStructs.' a{handles.SubStructure.Value} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['handles.varargin{3}.PXI.ConfStructs.' a{handles.SubStructure.Value} '.' b{i} ';']));
            end
        case 'PXI_TF_Noise_Conf'
            a = fieldnames(handles.varargin{3}.PXI.ConfStructs);
            % SubStructure within Horizontal setup
            eval(['b = fieldnames(handles.varargin{3}.PXI.ConfStructs.' a{handles.SubStructure.Value} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['handles.varargin{3}.PXI.ConfStructs.' a{handles.SubStructure.Value} '.' b{i} ';']));
            end
        case 'PXI_Pulse_Conf'  % Pulses
            handles.Options.String = {'Pulses'};
            a = fieldnames(handles.varargin{3}.PXI.ConfStructs);
            % SubStructure within Horizontal setup
            eval(['b = fieldnames(handles.varargin{3}.PXI.ConfStructs.' a{handles.SubStructure.Value} ');']);
            for i = 1:length(b)
                ConfInstrs{i,1} = b{i};
                ConfInstrs{i,2} = num2str(eval(['handles.varargin{3}.PXI.ConfStructs.' a{handles.SubStructure.Value} '.' b{i} ';']));
            end
            
    end
end

% Configuration of the DSA options
handles.ConfInstrs = ConfInstrs;

handles.Table.Data = handles.ConfInstrs;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function SubStructure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SubStructure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in Table.
function Table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
a = handles.SubStructure.String;
aN = handles.SubStructure.Value;
data = handles.Table.Data;

PXI_Str = {'ConfStructs';'WaveFormInfo';'Options';'ObjHandle'};
if isfield('Label','varargin') && strcmp(handles.varargin{1}.Label,'PXI_Acquisition_card Properties')
    UserData = handles.varargin{1}.UserData;
    eval(['UserData.' PXI_Str{handles.Options.Value} '.' a{aN} '.' data{eventdata.Indices(1),eventdata.Indices(2)-1} ' = ' eventdata.NewData ';']);
    handles.varargin{1}.UserData = UserData;
else
    try
        eval(['handles.varargin{3}.PXI.' PXI_Str{handles.Options.Value} '.' a{aN} '.' data{eventdata.Indices(1),eventdata.Indices(2)-1} ' = ' eventdata.NewData ';']);
    catch
        eval(['handles.varargin{3}.PXI.' PXI_Str{handles.Options.Value} '.' a{aN} '.' data{eventdata.Indices(1),eventdata.Indices(2)-1} ' = ''' eventdata.NewData ''';']);
    end
end
guidata(hObject,handles);
