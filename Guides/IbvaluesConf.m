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

% Last Modified by GUIDE v2.5 09-Jul-2018 14:25:33

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
handles.output = hObject;

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
varargout{1} = handles.output;


% --- Executes on button press in Accept.
function Accept_Callback(hObject, eventdata, handles)
% hObject    handle to Accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Negative.
function Negative_Callback(hObject, eventdata, handles)
% hObject    handle to Negative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Negative


% --- Executes on button press in Browse.
function Browse_Callback(hObject, eventdata, handles)
% hObject    handle to Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
