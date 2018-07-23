function varargout = Conf_Setup(varargin)
% CONF_SETUP MATLAB code for Conf_Setup.fig
%      CONF_SETUP, by itself, creates a new CONF_SETUP or raises the existing
%      singleton*.
%
%      H = CONF_SETUP returns the handle to a new CONF_SETUP or the handle to
%      the existing singleton*.
%
%      CONF_SETUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONF_SETUP.M with the given input arguments.
%
%      CONF_SETUP('Property','Value',...) creates a new CONF_SETUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Conf_Setup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Conf_Setup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Conf_Setup

% Last Modified by GUIDE v2.5 20-Jul-2018 13:43:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Conf_Setup_OpeningFcn, ...
                   'gui_OutputFcn',  @Conf_Setup_OutputFcn, ...
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


% --- Executes just before Conf_Setup is made visible.
function Conf_Setup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Conf_Setup (see VARARGIN)

% Choose default command line output for Conf_Setup
handles.output = hObject;

% Configuration of the DSA device
ConfInstrs = {'AUTO 0';'LGRS';'SF 10Hz';'FRS 4Dec';'PSUN';'VTRM';'VHZ';'STBL';...
    'AVG 5';'C2AC 1';'PSP2';'MGDB';'YASC'};
handles.Table.Data = ConfInstrs;



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Conf_Setup wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Conf_Setup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Add.
function Add_Callback(hObject, eventdata, handles)
% hObject    handle to Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Table.Data = [handles.RangeTable.Data; cell(1,3)];

% --- Executes on button press in Remove.
function Remove_Callback(hObject, eventdata, handles)
% hObject    handle to Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if size(handles.Table.Data,1) > 1
    handles.Table.Data(end,:) = [];
end


% --- Executes on selection change in Device.
function Device_Callback(hObject, eventdata, handles)
% hObject    handle to Device (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Device contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Device


% --- Executes during object creation, after setting all properties.
function Device_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Device (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
