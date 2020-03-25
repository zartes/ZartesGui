function varargout = ZarTES(varargin)
% ZARTES MATLAB code for ZarTES.fig
%      ZARTES, by itself, creates a new ZARTES or raises the existing
%      singleton*.
%
%      H = ZARTES returns the handle to a new ZARTES or the handle to
%      the existing singleton*.
%
%      ZARTES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ZARTES.M with the given input arguments.
%
%      ZARTES('Property','Value',...) creates a new ZARTES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ZarTES_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ZarTES_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ZarTES

% Last Modified by GUIDE v2.5 25-Mar-2020 09:40:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ZarTES_OpeningFcn, ...
                   'gui_OutputFcn',  @ZarTES_OutputFcn, ...
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


% --- Executes just before ZarTES is made visible.
function ZarTES_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ZarTES (see VARARGIN)

% Choose default command line output for ZarTES

handles.output = hObject;
position = get(handles.figure1,'Position');
set(handles.figure1,'Color',[0 120 180]/255,'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ZarTES wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ZarTES_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
set(handles.figure1,'Visible','on');

% --- Executes on button press in Launch_Setup.
function Launch_Setup_Callback(hObject, eventdata, handles)
% hObject    handle to Launch_Setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
d = pwd;
run([d filesep 'Guis' filesep 'SetupTEScontrolers']);

% --- Executes on button press in Lauch_Analysis.
function Lauch_Analysis_Callback(hObject, eventdata, handles)
% hObject    handle to Lauch_Analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

d = pwd;
addpath([pwd filesep 'AnalysisFcn']);
addpath([pwd filesep 'Guis']);
run([d filesep 'AnalysisFcn' filesep 'Analyzer']);

%Añadir el path de AnalysisFcn


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

rmpath([pwd filesep 'AnalysisFcn']);
rmpath([pwd filesep 'Guis']);
rmpath([pwd filesep 'DataBase']);
delete(hObject);


% --- Executes on button press in Launch_DB.
function Launch_DB_Callback(hObject, eventdata, handles)
% hObject    handle to Launch_DB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
d = pwd;
addpath([pwd filesep 'DataBase']);
run([d filesep 'DataBase' filesep 'DBInterface.m']);