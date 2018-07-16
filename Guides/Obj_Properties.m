function varargout = Obj_Properties(varargin)
% OBJ_PROPERTIES M-file for Obj_Properties.fig
%      OBJ_PROPERTIES, by itself, creates a new OBJ_PROPERTIES or raises the existing
%      singleton*.
%
%      H = OBJ_PROPERTIES returns the handle to a new OBJ_PROPERTIES or the handle to
%      the existing singleton*.
%
%      OBJ_PROPERTIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OBJ_PROPERTIES.M with the given input arguments.
%
%      OBJ_PROPERTIES('Property','Value',...) creates a new OBJ_PROPERTIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Obj_Properties_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Obj_Properties_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Obj_Properties

% Last Modified by GUIDE v2.5 13-Jul-2018 11:49:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Obj_Properties_OpeningFcn, ...
                   'gui_OutputFcn',  @Obj_Properties_OutputFcn, ...
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


% --- Executes just before Obj_Properties is made visible.
function Obj_Properties_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Obj_Properties (see VARARGIN)

% Choose default command line output for Obj_Properties
handles.output = hObject;
if ~isempty(varargin{1})
    handles.Obj = varargin{1};
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Obj_Properties wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Obj_Properties_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

position = get(handles.figure1,'Position');
set(handles.figure1,'Color',[0.3 0.35 0.59],'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized','Name',handles.Obj.Label);


content.ParametersStr = properties(handles.Obj.UserData);

for i = 1:length(content.ParametersStr)
    eval('data{i,1} = content.ParametersStr{i};');
    if strcmp(eval(['class(handles.Obj.UserData.' content.ParametersStr{i} ')']),'PhysicalMeasurement')
        eval(['data{i,2} = handles.Obj.UserData.' content.ParametersStr{i} '.Value;']);
        eval(['data{i,3} = handles.Obj.UserData.' content.ParametersStr{i} '.Units;']);
    elseif ~strcmp(eval(['class(handles.Obj.UserData.' content.ParametersStr{i} ')']),'cell')        
        eval(['data{i,2} = handles.Obj.UserData.' content.ParametersStr{i} ';']);
        data{i,3} = '';
    else
        for j = 1:length(eval(['handles.Obj.UserData.' content.ParametersStr{i}]))
            % Casos en los que el dato es un cell 
            if j ~= length(eval(['handles.Obj.UserData.' content.ParametersStr{i}]))
            data{i,2} = ['{' eval(['handles.Obj.UserData.' content.ParametersStr{i} '{j}']) ';'];
            else
                data{i,2} = [data{i,2} eval(['handles.Obj.UserData.' content.ParametersStr{i} '{j}']) '}'];
            end
        end
    end
end
set(handles.tabla,'Data',data);
% data_conf = data;
% 
% set(handles.Conf_File,'String',handles.ConfFile,'Value',handles.ConfFileNum);    
%     Conf_File_Callback(handles.Conf_File,[],handles);    
    
    
set(handles.figure1,'Visible','on');
guidata(hObject,handles);
% --- Executes on button press in Default_File.
function Default_File_Callback(hObject, eventdata, handles)
% hObject    handle to Default_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Obj.UserData = handles.Obj.UserData.Constructor;
content.ParametersStr = properties(handles.Obj.UserData);

for i = 1:length(content.ParametersStr)
    eval('data{i,1} = content.ParametersStr{i};');
    eval(['data{i,2} = handles.Obj.UserData.' content.ParametersStr{i} '.Value;']);
    eval(['data{i,3} = handles.Obj.UserData.' content.ParametersStr{i} '.Units;']);
end
set(handles.tabla,'Data',data);

guidata(hObject,handles);




% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure1_DeleteFcn(handles.figure1,[],handles);

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


data = get(handles.tabla,'Data');
OrigParameters = properties(handles.Obj.UserData);
ParametersStr = data(:,1);


for i = 1:size(OrigParameters,1)
    aux = strfind(ParametersStr,OrigParameters{i});
    indx = find(cellfun(@length, aux)==1);
    auxStr = num2str(data{indx,2});
    if isempty(auxStr)
        auxStr = '[]';
    end
    switch class(eval(['handles.Obj.UserData.' OrigParameters{i} ]))
        case 'PhysicalMeasurement'
            eval(['handles.Obj.UserData.' OrigParameters{i} '.Value = ' auxStr ';'])
            eval(['handles.Obj.UserData.' OrigParameters{i} '.Units = ''' data{indx,3} ''';'])
        case 'char'
            eval(['handles.Obj.UserData.' OrigParameters{i} ' = ''' data{indx,2} ''';'])
        case 'double'
            eval(['handles.Obj.UserData.' OrigParameters{i} ' = ' auxStr ';'])
        otherwise 
    end
end

uiwait(msgbox('Properties were successfully saved!','ZarTES v.1'));

delete(handles.figure1);

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
try
    if strcmp(eventdata.Key,'escape')
        cancel_Callback(handles.cancel,eventdata,handles);
    elseif strcmp(eventdata.Key,'return')
        save_Callback(handles.save,eventdata,handles);
    end
catch
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);


% --- Executes when entered data in editable cell(s) in tabla.
function tabla_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tabla (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
