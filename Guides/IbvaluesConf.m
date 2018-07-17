function varargout = IbvaluesConf(varargin)
% IBVALUESCONF MATLAB code for IbvaluesConf.fig
%      IBVALUESCONF, by itself, creates a new IBVALUESCONF or raises the existing
%      singleton*.
%
%      H = IBVALUESCONF returns the handle to a new IBVALUESCONF or the handle to
%      the existing singleton*.
%
%      IBVALUESCONF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IBVALUESCONF.M with the given input arguments.
%
%      IBVALUESCONF('Property','Value',...) creates a new IBVALUESCONF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IbvaluesConf_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IbvaluesConf_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IbvaluesConf

% Last Modified by GUIDE v2.5 10-Jul-2018 14:02:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IbvaluesConf_OpeningFcn, ...
                   'gui_OutputFcn',  @IbvaluesConf_OutputFcn, ...
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


% --- Executes just before IbvaluesConf is made visible.
function IbvaluesConf_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IbvaluesConf (see VARARGIN)

% Choose default command line output for IbvaluesConf
handles.output = [];
try
    handles.Name_Temp = varargin{1}{2};
catch
end
handles.Name = [];
handles.Dir = [];

position = get(handles.figure1,'Position');
set(handles.figure1,'Color',[0.95 0.95 0.95],'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');

% Initializing Table values
handles.RangeTable.Data = num2cell([500 -10 0]);
uibuttongroup1_SelectionChangedFcn(handles.Manual,[],handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes IbvaluesConf wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = IbvaluesConf_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

set(handles.figure1,'Visible','on');
% waitfor(handles.figure1);
varargout{1} = handles.figure1;
% guidata(hObject,handles);

% --- Executes on button press in Accept.
function Accept_Callback(hObject, eventdata, handles)
% hObject    handle to Accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data = [];
for i = 1:size(handles.RangeTable.Data,1)
    Data = [Data eval([num2str(handles.RangeTable.Data{i,1}) ':' ...
        num2str(handles.RangeTable.Data{i,2}) ':' ...
        num2str(handles.RangeTable.Data{i,3}) ])];
end

Ibvalues = eval(['repmat(Data,1,' handles.NRepeat.String ');']);

if handles.Negative.Value
    Ibvalues = [Ibvalues -Ibvalues];
end

dlmwrite(handles.Name_Temp,Ibvalues');

figure1_DeleteFcn(handles.figure1,eventdata,handles);   

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure1_DeleteFcn(handles.figure1,eventdata,handles);   

% --- Executes on button press in Negative.
function Negative_Callback(hObject, eventdata, handles)
% hObject    handle to Negative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Negative


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

try
    if strcmp(eventdata.Key,'escape')
        % Remove paths
        figure1_DeleteFcn(handles.figure1,eventdata,handles);            
       
    elseif strcmp(eventdata.Key,'return')
        if strcmp(get(handles.Accept,'Enable'),'on')
            Accept_Callback(handles.Start,eventdata,handles);
        end
    end
catch
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);


% --- Executes when selected object is changed in uibuttongroup1.
function Tag = uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Tag = hObject.Tag;
switch Tag
    case 'Manual'
        handles.RangeTable.Enable = 'on';
        handles.Browse.Enable = 'off';
    otherwise
        handles.RangeTable.Enable = 'off';
        handles.Browse.Enable = 'on';
end    

% --- Executes on button press in Browse.
function Browse_Callback(hObject, eventdata, handles)
% hObject    handle to Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Tag = handles.uibuttongroup1.SelectedObject.Tag;

switch Tag
    case 'FromFile'
        handles.RangeTable.Enable = 'off';
        [Name, Dir] = uigetfile({'*.txt','Example file (*.txt)'},...
            'Select file','tmp\*.txt');
        if ~isempty(Name)&&~isequal(Name,0)
            handles.Dir = Dir;
            handles.Name = Name;
            set(handles.IbiasFileStr,'String',[Dir Name],...
                'TooltipString',[Dir Name]);
            [suc,msg,msgid] = copyfile([handles.Dir handles.Name],handles.Name_Temp);
            if ~suc
                warndlg(msg,msgid);
            end
        else
            set(handles.IbiasFileStr,'String','No file selected');
            return;
        end
        
    case 'FromGraph'
        handles.RangeTable.Enable = 'off';
        [Name, Dir] = uigetfile({'*.fig','Example file (*.fig)'},...
            'Select graph file','tmp\*.fig');
        
        if ~isempty(Name)&&~isequal(Name,0)
            uiopen([Dir Name],1)
        else
            disp('No Graph File selected');
            return;
        end
        FigHandle = gcf;
        FigHandle.WindowButtonDownFcn = {@Fig_XRange};        
        
        % En esta parte hay que añadir más cosas
        
end




% --- Executes on button press in Add.
function Add_Callback(hObject, eventdata, handles)
% hObject    handle to Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.RangeTable.Data = [handles.RangeTable.Data; cell(1,3)];

% --- Executes on button press in Remove.
function Remove_Callback(hObject, eventdata, handles)
% hObject    handle to Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if size(handles.RangeTable.Data,1) > 1
    handles.RangeTable.Data(end,:) = [];
end


function NRepeat_Callback(hObject, eventdata, handles)
% hObject    handle to NRepeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NRepeat as text
%        str2double(get(hObject,'String')) returns contents of NRepeat as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','1');
    end    
else
    set(hObject,'String','1');
end

% --- Executes during object creation, after setting all properties.
function NRepeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NRepeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Fig_XRange(src,evnt)

sel_typ = get(gcbf,'SelectionType');
switch sel_typ
    case 'normal'   %Right button
%         waitforbuttonpress;
        point1 = get(gca,'CurrentPoint');    % button down detected
        finalRect = rbbox;                   % return figure units
        point2 = get(gca,'CurrentPoint');    % button up detected
        point1 = point1(1,1:2);              % extract x and y
        point2 = point2(1,1:2);
    case 'extend'   %Middle button
        set(src,'Selected','on')
        set(src,'Selected','on')
        
    case 'alt'      %Left button
%         
%         set(src,'Selected','on')
%         set(src,'SelectionHighlight','off')
%         
%         waitforbuttonpress;
%         point1 = get(gca,'CurrentPoint');    % button down detected
%         finalRect = rbbox;                   % return figure units
%         point2 = get(gca,'CurrentPoint');    % button up detected
%         point1 = point1(1,1:2);              % extract x and y
%         point2 = point2(1,1:2);
%         
%         [point1 point2]
end
