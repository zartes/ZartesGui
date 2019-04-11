function varargout = GraphicTESData(varargin)
% GRAPHICTESDATA MATLAB code for GraphicTESData.fig
%      GRAPHICTESDATA, by itself, creates a new GRAPHICTESDATA or raises the existing
%      singleton*.
%
%      H = GRAPHICTESDATA returns the handle to a new GRAPHICTESDATA or the handle to
%      the existing singleton*.
%
%      GRAPHICTESDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRAPHICTESDATA.M with the given input arguments.
%
%      GRAPHICTESDATA('Property','Value',...) creates a new GRAPHICTESDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GraphicTESData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GraphicTESData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GraphicTESData

% Last Modified by GUIDE v2.5 17-Jan-2019 14:22:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GraphicTESData_OpeningFcn, ...
                   'gui_OutputFcn',  @GraphicTESData_OutputFcn, ...
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


% --- Executes just before GraphicTESData is made visible.
function GraphicTESData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GraphicTESData (see VARARGIN)

% Choose default command line output for GraphicTESData
handles.output = hObject;
handles.str = varargin{1};
handles.menu = varargin{2};
position = get(handles.figure1,'Position');
set(handles.figure1,'Color',[200 200 200]/255,'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GraphicTESData wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GraphicTESData_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
set(handles.figure1,'Visible','on');


% --- Executes on button press in YDataButton.
function YDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to YDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[s,~] = listdlg('PromptString','Select one model parameters:',...
    'SelectionMode','single','ListString',handles.str);
if isempty(s)
    return;
end
set(handles.YDataStr,'String',handles.str{s});
set([handles.YDataRn handles.YDataTbath],'Enable','on')
if ~isempty(handles.XDataStr.String)
    set([handles.YDataXData],'Enable','on')
end
guidata(hObject,handles);

% --- Executes on button press in YDataRn.
function YDataRn_Callback(hObject, eventdata, handles)
% hObject    handle to YDataRn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data.param1 = get(handles.YDataStr,'String');
Data.case = 1;
handles.menu.UserData = Data;
close(handles.figure1);

% --- Executes on button press in YDataTbath.
function YDataTbath_Callback(hObject, eventdata, handles)
% hObject    handle to YDataTbath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data.param1 = get(handles.YDataStr,'String');
Data.case = 2;
handles.menu.UserData = Data;
close(handles.figure1);

% --- Executes on button press in XDataButton.
function XDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to XDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[s,~] = listdlg('PromptString','Select one model parameters:',...
    'SelectionMode','single','ListString',handles.str);
if isempty(s)
    return;
end
set(handles.XDataStr,'String',handles.str{s});
if ~isempty(handles.YDataStr.String)
    set([handles.YDataXData],'Enable','on')
end
guidata(hObject,handles);


% --- Executes on button press in YDataXData.
function YDataXData_Callback(hObject, eventdata, handles)
% hObject    handle to YDataXData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data.param1 = get(handles.YDataStr,'String');
Data.param2 = get(handles.XDataStr,'String');
Data.case = 3;
handles.menu.UserData = Data;
close(handles.figure1);

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
