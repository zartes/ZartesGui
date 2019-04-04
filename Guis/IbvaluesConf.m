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

% Last Modified by GUIDE v2.5 29-Mar-2019 14:20:13

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
try
    handles.src = varargin{1};
    handles.SetupTES = guidata(handles.src);
    handles.SetupTES.IV.ibias = [];
    handles.SetupTES.IV.vout = [];
    handles.Z_Method.Value = handles.SetupTES.TF_Menu.Value;
    Z_Method_Callback(handles.Z_Method,[],handles);
    handles.Sine_Amp.String = handles.SetupTES.Sine_Amp.String;
    handles.Sine_Amp_Units.Value = handles.SetupTES.Sine_Amp_Units.Value;
    handles.Sine_Freq.String = handles.SetupTES.Sine_Freq.String;
    handles.Sine_Freq_Units.Value = handles.SetupTES.Sine_Freq_Units.Value;
    
    handles.Noise_Method.Value = handles.SetupTES.Noise_Menu.Value;
    Noise_Method_Callback(handles.Noise_Method,[],handles);
    handles.Noise_Amp.String = handles.SetupTES.Noise_Amp.String;
    handles.Noise_Amp_Units.Value = handles.SetupTES.Noise_Amp_Units.Value;
    
catch
end

handles.TempDir = [];
handles.TempName = [];

handles.IbiasDir = [];
handles.IbiasName = [];


position = get(handles.figure1,'Position');
set(handles.figure1,'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized'); % ,'Color',[0 110 170]/255

handles.menu(1) = uimenu('Parent',handles.figure1,'Label',...
    'Configuration File');
handles.Menu_Conf = uimenu('Parent',handles.menu(1),'Label',...
    'Open','Callback',{@OpenConfFile});

handles.menu(2) = uimenu('Parent',handles.figure1,'Label',...
    'Help');
handles.UserGuide = uimenu('Parent',handles.menu(2),'Label',...
    'User Guide','Callback',{@UserGuide});
handles.About = uimenu('Parent',handles.menu(2),'Label',...
    'About','Callback',{@About});


% Initializing Table values
Conf = Default_Conf;
Update_Setup(Conf,handles);

handles = guidata(hObject);

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
guidata(hObject,handles);

function UserGuide(src,evnt)
winopen('Automatic_Acquisition_Configuration_UserGuide.pdf');

function About(src,evnt)
fig = figure('Visible','off','NumberTitle','off','Name','ZarTES v1.0','MenuBar','none','Units','Normalized');
ax = axes;
data = imread('ICMA-CSIC.jpg');
image(data)
ax.Visible = 'off';
fig.Position = [0.35 0.35 0.3 0.22];
fig.Visible = 'on';

function Conf = Default_Conf

Conf.Temp_Manual.On = 1;
Conf.TempFromFile.On = 0;
Conf.Temps.File = [];
Conf.Temps.Values = 0.05:0.005:0.075;
Conf.Temp_FromFile = 0;

Conf.FieldScan.On = 1;
Conf.FieldScan.Rn = 0.7;
Conf.FieldScan.BVvalue = -1000:100:1000;

Conf.BFieldIC.On = 1;
Conf.BFieldIC.BVvalue = -1000:100:1000;
Conf.BFieldIC.IbiasValues.p = 0:5:500;
Conf.BFieldIC.IbiasValues.n = 0:-5:-500;

Conf.BField.FromScan = 0;
Conf.BField.Symmetric = 1;
Conf.BField.P = 0;
Conf.BField.N = 0;

Conf.IVcurves.On = 1;
Conf.IVcurves.Manual.On = 1;
Conf.IVcurves.SmartRange.On = 0;
Conf.IVcurves.Manual.Values.p = 500:-5:0;
Conf.IVcurves.Manual.Values.n = -500:5:0;

Conf.TF.Zw.DSA.On = 1;
Conf.TF.Zw.DSA.Method.Value = 1;
Conf.TF.Zw.DSA.Method.String = 'Sweep Sine';
Conf.TF.Zw.DSA.Exc.Units.String = 'mV';
Conf.TF.Zw.DSA.Exc.Units.Value = 1;
Conf.TF.Zw.DSA.Exc.Value = 20;

Conf.TF.Zw.PXI.On = 1;
Conf.TF.Zw.PXI.Method.Value = 1;
Conf.TF.Zw.PXI.Method.String = 'White Noise';
Conf.TF.Zw.PXI.Exc.Units.String = 'mV';
Conf.TF.Zw.PXI.Exc.Units.Value = 1;
Conf.TF.Zw.PXI.Exc.Value = 20;

Conf.TF.Noise.DSA.On = 1;
Conf.TF.Noise.PXI.On = 1;
Conf.TF.rpp = [0.9:-0.05:0.2 0.19:-0.01:0.1];
Conf.TF.rpn = (0.90:-0.1:0.1);

Conf.Pulse.PXI.On = 1;
Conf.Pulse.PXI.NCounts = 10;
Conf.Pulse.PXI.rpp = [0.9:-0.05:0.2 0.19:-0.01:0.1];
Conf.Pulse.PXI.rpn = (0.90:-0.1:0.1);

Conf.Spectrum.PXI.On = 1;
Conf.Spectrum.PXI.Rn = 0.7;
Conf.Spectrum.PXI.NCounts = 20000;


function OpenConfFile(src,evnt)
handles = guidata(src);
[Name, Dir] = uigetfile({'*.xml','Example file (*.xml)'},...
    'Select file',[pwd '\*.xml']);
if ~isempty(Name)&&~isequal(Name,0)
    handles.ConfDir = Dir;
    handles.ConfName = Name;
else
    warndlg('No Configuration File Selected!','ZarTES v1.0')
    return;
end

S = xml2struct([handles.ConfDir handles.ConfName]);

Conf.Temps.Values = str2double(strsplit(S.Config.Temps.Values.Text,' '));
Conf.Temps.File = S.Config.Temps.File.Text;

Conf.FieldScan.On = str2double(S.Config.FieldScan.On.Text);
Conf.FieldScan.Rn = str2double(S.Config.FieldScan.Rn.Text);
Conf.FieldScan.BVvalue = str2double(strsplit(S.Config.FieldScan.BVvalues.Text,' '));

Conf.BFieldIC.On = str2double(S.Config.BFieldIC.On.Text);
Conf.BFieldIC.BVvalue = str2double(strsplit(S.Config.BFieldIC.BVvalues.Text,' '));
Conf.BFieldIC.IbiasValues.p = str2double(strsplit(S.Config.BFieldIC.IbiasValues.p.Text,' '));
Conf.BFieldIC.IbiasValues.n = str2double(strsplit(S.Config.BFieldIC.IbiasValues.n.Text,' '));

Conf.BField.FromScan = str2double(S.Config.BField.FromScan.Text);
Conf.BField.Symmetric = str2double(S.Config.BField.Symmetric.Text);
Conf.BField.P = str2double(S.Config.BField.P.Text);
Conf.BField.N = str2double(S.Config.BField.N.Text);

Conf.IVcurves.On = str2double(S.Config.IVcurves.On.Text);
Conf.IVcurves.Manual.On = str2double(S.Config.IVcurves.Manual.On.Text);
Conf.IVcurves.Manual.Values.p = str2double(strsplit(S.Config.IVcurves.Manual.Values.p.Text,' '));
Conf.IVcurves.Manual.Values.n = str2double(strsplit(S.Config.IVcurves.Manual.Values.n.Text,' '));
Conf.IVcurves.SmartRange.On = str2double(S.Config.IVcurves.SmartRange.On.Text);

Conf.TF.Zw.DSA.On = str2double(S.Config.TF.Zw.DSA.On.Text);
Conf.TF.Zw.DSA.Method.Value = str2double(S.Config.TF.Zw.DSA.Method.Value.Text);
Conf.TF.Zw.DSA.Method.String = S.Config.TF.Zw.DSA.Method.String.Text;
Conf.TF.Zw.DSA.Exc.Units.Value = str2double(S.Config.TF.Zw.DSA.Exc.Units.Value.Text);
Conf.TF.Zw.DSA.Exc.Units.String = S.Config.TF.Zw.DSA.Exc.Units.String.Text;
Conf.TF.Zw.DSA.Exc.Value = str2double(S.Config.TF.Zw.DSA.Exc.Value.Text);

Conf.TF.Noise.DSA.On = str2double(S.Config.TF.Noise.DSA.On.Text);

Conf.TF.Zw.PXI.On = str2double(S.Config.TF.Zw.PXI.On.Text);
Conf.TF.Zw.PXI.Method.Value = str2double(S.Config.TF.Zw.DSA.Method.Value.Text);
Conf.TF.Zw.PXI.Method.String = S.Config.TF.Zw.DSA.Method.String.Text;
Conf.TF.Zw.PXI.Exc.Units.Value = str2double(S.Config.TF.Zw.DSA.Exc.Units.Value.Text);
Conf.TF.Zw.PXI.Exc.Units.String = S.Config.TF.Zw.DSA.Exc.Units.String.Text;
Conf.TF.Zw.PXI.Exc.Value = str2double(S.Config.TF.Zw.DSA.Exc.Value.Text);

Conf.TF.Noise.PXI.On = str2double(S.Config.TF.Noise.PXI.On.Text);

Conf.TF.rpp = str2double(strsplit(S.Config.TF.Zw.rpp.Text,' '));
Conf.TF.rpn = str2double(strsplit(S.Config.TF.Zw.rpn.Text,' '));

Conf.Pulse.PXI.On = str2double(S.Config.Pulse.PXI.On.Text);
Conf.Pulse.PXI.NCounts = str2double(S.Config.Pulse.PXI.NCounts.Text);
Conf.Pulse.PXI.rpp = str2double(strsplit(S.Config.TF.Zw.rpp.Text,' '));
Conf.Pulse.PXI.rpn = str2double(strsplit(S.Config.TF.Zw.rpn.Text,' '));

Conf.Spectrum.PXI.On = str2double(S.Config.Spectrum.PXI.On.Text);
Conf.Spectrum.PXI.Rn = str2double(S.Config.Spectrum.PXI.Rn.Text);
Conf.Spectrum.PXI.NCounts = str2double(S.Config.Spectrum.PXI.NCounts.Text);

StrSummary = handles.Summary_Table.ColumnName;
SummaryFields = fieldnames(S.Config.Summary);

handles.Summary_Table.Data = {[]};
i = 1;

for n = 1:length(SummaryFields)
    j = mod(n,8);
    if j == 0
        j = 8;
    end
    handles.Summary_Table.Data{i,j} = eval(['S.Config.Summary.' SummaryFields{n} '.Text']);
    if mod(n,8) == 0
        i = i+1;
    end
    
end
Update_Setup(Conf,handles,1);

function Update_Setup(Conf,handles,opt)

if isempty(Conf.Temps.File)
    handles.Temp_Manual.Value = 1;
    Temp_Panel_SelectionChangedFcn(handles.Temp_Manual, [], handles)
else
    handles.Temp_FromFile.Value = 1;
    Temp_Panel_SelectionChangedFcn(handles.Temp_Panel, [], handles)
    handles.Temp_Save_Str.String = Conf.Temps.File;
    
    handles.TempName = Conf.Temps.File(max(strfind(Conf.Temps.File,filesep))+1:end);
    handles.TempDir = Conf.Temps.File(1:max(strfind(Conf.Temps.File,filesep)));
end
handles.Temp.Values = Conf.Temps.Values';

handles.BField_Scan.Value = Conf.FieldScan.On;
handles.Field_Rn.String = num2str(Conf.FieldScan.Rn);

handles.FieldScan.BVvalue = Conf.FieldScan.BVvalue';
BField_Scan_Callback(handles.BField_Scan,[],handles);


handles.FromFieldScan.Value = Conf.BField.FromScan;
handles.Field_Symmetric.Value = Conf.BField.Symmetric;
Field_Symmetric_Callback(handles.Field_Symmetric,[],handles);
handles.AQ_Field.String = num2str(Conf.BField.P);
handles.AQ_Field_Negative.String = num2str(Conf.BField.N);
FromFieldScan_Callback(handles.FromFieldScan,[],handles);


handles.BField_IC.Value = Conf.BFieldIC.On;

handles.BFieldIC.BVvalue = Conf.BFieldIC.BVvalue';
handles.BFieldIC.IbiasValues.p = Conf.BFieldIC.IbiasValues.p';
handles.BFieldIC.IbiasValues.n = Conf.BFieldIC.IbiasValues.n';
BField_IC_Callback(handles.BField_IC,[],handles);


handles.AQ_IVs.Value = Conf.IVcurves.On;
AQ_IVs_Callback(handles.AQ_IVs, [], handles);
handles.ManualIbias.Value = Conf.IVcurves.Manual.On;

handles.IVcurves.Manual.Values.p = Conf.IVcurves.Manual.Values.p';
handles.IVcurves.Manual.Values.n = Conf.IVcurves.Manual.Values.n';

ManualIbias_Callback(handles.ManualIbias,[],handles);

handles.SmartIbias.Value = Conf.IVcurves.SmartRange.On;
SmartIbias_Callback(handles.SmartIbias,[],handles);


handles.DSA_TF_Zw.Value = Conf.TF.Zw.DSA.On;
DSA_TF_Zw_Callback(handles.DSA_TF_Zw,[],handles);
handles.DSA_TF_Zw_Menu.Value = Conf.TF.Zw.DSA.Method.Value;
handles.DSA_Input_Amp.String = num2str(Conf.TF.Zw.DSA.Exc.Value);
handles.DSA_Input_Amp_Units.Value = Conf.TF.Zw.DSA.Exc.Units.Value;

handles.PXI_TF_Zw.Value = Conf.TF.Zw.PXI.On;
PXI_TF_Zw_Callback(handles.PXI_TF_Zw,[],handles);
handles.PXI_TF_Zw_Menu.Value = Conf.TF.Zw.PXI.Method.Value;
handles.PXI_Input_Amp.String = num2str(Conf.TF.Zw.PXI.Exc.Value);
handles.PXI_Input_Amp_Units.Value = Conf.TF.Zw.PXI.Exc.Units.Value;


handles.DSA_TF_Noise.Value = Conf.TF.Noise.DSA.On;
DSA_TF_Noise_Callback(handles.DSA_TF_Noise,[],handles);

handles.PXI_TF_Noise.Value = Conf.TF.Noise.PXI.On;
PXI_TF_Noise_Callback(handles.PXI_TF_Noise,[],handles);

handles.PXI_Pulse.Value = Conf.Pulse.PXI.On;
handles.PulseNCounts.String = num2str(Conf.Pulse.PXI.NCounts);

handles.TF_Zw.rpp = Conf.TF.rpp';
handles.TF_Zw.rpn = Conf.TF.rpn';
PXI_Pulse_Callback(handles.PXI_Pulse,[],handles);

handles.AQ_Spectrum.Value = Conf.Spectrum.PXI.On;
handles.Spectrum_Rn.String = num2str(Conf.Spectrum.PXI.Rn);
handles.Spectrum_NCounts.String = num2str(Conf.Spectrum.PXI.NCounts);
AQ_Spectrum_Callback(handles.AQ_Spectrum,[],handles);

if nargin < 3
    Refresh_Table_Callback(handles.Refresh_Table,[],handles);
end
guidata(handles.figure1,handles);



% --- Executes on button press in Field_Start.
function Field_Start_Callback(hObject, eventdata, handles)
% hObject    handle to Field_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%% Bath Temperature Range Setting
%%%% Field values Setting
Data = [];
for i = 1:size(handles.Field_Table.Data,1)
    if ~isempty(handles.Field_Table.Data{i,1})
        if isempty(handles.Field_Table.Data{i,2})
            Data = [Data str2double(handles.Field_Table.Data{i,1})];
        elseif ~isempty(handles.Field_Table.Data{i,3})
            Data = [Data eval([num2str(handles.Field_Table.Data{i,1}) ':' ...
                num2str(handles.Field_Table.Data{i,2}) ':' ...
                num2str(handles.Field_Table.Data{i,3}) ])];
        end
    end
end
Conf.Field = Data;

Data = [];
for i = 1:size(handles.Temp_Table.Data,1)
    if ~isempty(handles.Temp_Table.Data{i,1})
        if isempty(handles.Temp_Table.Data{i,2})
            Data = [Data str2double(handles.Temp_Table.Data{i,1})];
        elseif ~isempty(handles.Temp_Table.Data{i,3})
            Data = [Data eval([num2str(handles.Temp_Table.Data{i,1}) ':' ...
                num2str(handles.Temp_Table.Data{i,2}) ':' ...
                num2str(handles.Temp_Table.Data{i,3}) ])];
        end
    end
end
Data = unique(sort(Data));
% Remove possible 0 values
Data(Data == 0) = [];
Temps = Data;

%%%% I bias Range Setting
Data = [];
for i = 1:size(handles.Ibias_Table.Data,1)
    if ~isempty(handles.Ibias_Table.Data{i,1})
        if isempty(handles.Ibias_Table.Data{i,2})
            Data = [Data str2double(handles.Ibias_Table.Data{i,1})];
        elseif isnan(handles.Ibias_Table.Data{i,2})
            Data = handles.Ibias_Table.Data{i,1};
        elseif ~isempty(handles.Ibias_Table.Data{i,3})
            Data = [Data eval([num2str(handles.Ibias_Table.Data{i,1}) ':' ...
                num2str(handles.Ibias_Table.Data{i,2}) ':' ...
                num2str(handles.Ibias_Table.Data{i,3}) ])];
        end
    end
end
Data = eval(['repmat(Data,1,' handles.Ibias_NRepeat.String ');']);

Ibvalues.p = [];
Ibvalues.n = [];

indp = find(Data >= 0);
Ibvalues.p = unique(Data(Data >= 0),'stable');
indn = find(Data <= 0);
Ibvalues.n = unique(Data(Data <= 0),'stable');

if ~isempty(indp)
    if (Data(indp(1)) == Data(indp(end)))&& Data(indp(1)) == 0
        Ibvalues.p(1) = [];
        Ibvalues.p(end+1) = 0;
    end
end
if handles.Ibias_Negative.Value
    Ibvalues.n = -Ibvalues.p;
end
if ~isempty(indn)
    if (Data(indn(1)) == Data(indn(end)))&& Data(indn(1)) == 0
        Ibvalues.n(1) = [];
        Ibvalues.n(end+1) = 0;
    end
end


Conf.OP2Field.On = handles.RemanentOpt.Value;

Conf.Rn = str2double(handles.Field_Rn.String);
Conf.Temp = Temps;
Conf.Ibvalues.Values = Ibvalues;

Start_Automatic_Acquisition(handles,handles.SetupTES,Conf);
guidata(hObject,handles);


% --- Executes on button press in Field_Cancel.
function Field_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Field_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure1_DeleteFcn(handles.figure1,eventdata,handles);

% --- Executes on button press in Ibias_Negative.
function Ibias_Negative_Callback(hObject, eventdata, handles)
% hObject    handle to Ibias_Negative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Ibias_Negative


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
        % Ibias_Remove paths
        figure1_DeleteFcn(handles.figure1,eventdata,handles);
        
    elseif strcmp(eventdata.Key,'return')
        if strcmp(get(handles.Field_Start,'Enable'),'on')
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


% --- Executes when selected object is changed in Ibias_Panel.
function Tag = Ibias_Panel_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Ibias_Panel
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Tag = hObject.Tag;
switch Tag
    case 'Manual'
        handles.Ibias_Table.Enable = 'on';
        handles.Ibias_Browse.Enable = 'off';
    otherwise
        handles.Ibias_Table.Enable = 'off';
        handles.Ibias_Browse.Enable = 'on';
end

% --- Executes on button press in Ibias_Browse.
function Ibias_Browse_Callback(hObject, eventdata, handles)
% hObject    handle to Ibias_Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Tag = handles.Ibias_Panel.SelectedObject.Tag;

switch Tag
    case 'FromFile'
        handles.Ibias_Table.Enable = 'off';
        [Name, Dir] = uigetfile({'*.txt','Example file (*.txt)'},...
            'Select file','tmp\*.txt');
        if ~isempty(Name)&&~isequal(Name,0)
            handles.IbiasDir = Dir;
            handles.IbiasName = Name;
            set(handles.Ibias_File_Str,'String',[Dir Name],...
                'TooltipString',[Dir Name]);
        else
            set(handles.Ibias_File_Str,'String','No file selected');
            return;
        end
        
        %     case 'FromGraph'
        %         handles.Ibias_Table.Enable = 'off';
        %         [Name, Dir] = uigetfile({'*.fig','Example file (*.fig)'},...
        %             'Select graph file','tmp\*.fig');
        %
        %         if ~isempty(Name)&&~isequal(Name,0)
        %             uiopen([Dir Name],1)
        %         else
        %             disp('No Graph File selected');
        %             return;
        %         end
        %         FigHandle = gcf;
        %         FigHandle.WindowButtonDownFcn = {@Fig_XRange};
        %
        %         % En esta parte hay que añadir más cosas
        
end




% % --- Executes on button press in Ibias_Add.
% function Ibias_Add_Callback(hObject, eventdata, handles)
% % hObject    handle to Ibias_Add (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% handles.Ibias_Table.Data = [handles.Ibias_Table.Data; cell(1,3)];
%
% % --- Executes on button press in Ibias_Remove.
% function Ibias_Remove_Callback(hObject, eventdata, handles)
% % hObject    handle to Ibias_Remove (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% if size(handles.Ibias_Table.Data,1) > 1
%     handles.Ibias_Table.Data(end,:) = [];
% end


function Ibias_NRepeat_Callback(hObject, eventdata, handles)
% hObject    handle to Ibias_NRepeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ibias_NRepeat as text
%        str2double(get(hObject,'String')) returns contents of Ibias_NRepeat as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','1');
    end
else
    set(hObject,'String','1');
end

% --- Executes during object creation, after setting all properties.
function Ibias_NRepeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ibias_NRepeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%
% function Fig_XRange(src,evnt)
%
% sel_typ = get(gcbf,'SelectionType');
% switch sel_typ
%     case 'normal'   %Right button
% %         waitforbuttonpress;
%         point1 = get(gca,'CurrentPoint');    % button down detected
%         finalRect = rbbox;                   % return figure units
%         point2 = get(gca,'CurrentPoint');    % button up detected
%         point1 = point1(1,1:2);              % extract x and y
%         point2 = point2(1,1:2);
%     case 'extend'   %Middle button
%         set(src,'Selected','on')
%         set(src,'Selected','on')
%
%     case 'alt'      %Left button
% %
% %         set(src,'Selected','on')
% %         set(src,'SelectionHighlight','off')
% %
% %         waitforbuttonpress;
% %         point1 = get(gca,'CurrentPoint');    % button down detected
% %         finalRect = rbbox;                   % return figure units
% %         point2 = get(gca,'CurrentPoint');    % button up detected
% %         point1 = point1(1,1:2);              % extract x and y
% %         point2 = point2(1,1:2);
% %
% %         [point1 point2]
% end


% --- Executes on button press in Temp_Browse.
function Temp_Browse_Callback(hObject, eventdata, handles)
% hObject    handle to Temp_Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Tag = handles.Temp_Panel.SelectedObject.Tag;

switch Tag
    case 'Temp_FromFile'
        handles.Temp_Table.Enable = 'off';
        [Name, Dir] = uigetfile({'*.txt','Example file (*.txt)'},...
            'Select file','tmp\*.txt');
        if ~isempty(Name)&&~isequal(Name,0)
            handles.TempDir = Dir;
            handles.TempName = Name;
            fid = fopen([Dir Name]);
            Data = fscanf(fid,'%f');
            Data = unique(Data);
            fclose(fid);
            handles.Temp_Table.Data = {[]};
            %%% Updating the Temp Table values
            handles.Temp_Table.Data{size(Data,1),3} = [];
            handles.Temp_Table.Data(:,size(Data,2)) = cellstr(num2str(Data));
            handles.Temp_Table.Enable = 'on';
        else
            handles.TempDir = [];
            handles.TempName = [];
            set(handles.Temp_File_Str,'String','No file selected');
            return;
        end
end
guidata(hObject,handles);

% % --- Executes on button press in Temp_Add.
% function Temp_Add_Callback(hObject, eventdata, handles)
% % hObject    handle to Temp_Add (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% handles.Temp_Table.Data = [handles.Temp_Table.Data; cell(1,3)];
%
% % --- Executes on button press in Temp_Remove.
% function Temp_Remove_Callback(hObject, eventdata, handles)
% % hObject    handle to Temp_Remove (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% if size(handles.Temp_Table.Data,1) > 1
%     handles.Temp_Table.Data(end,:) = [];
% end

% --- Executes when selected object is changed in Temp_Panel.
function Temp_Panel_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Temp_Panel
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch hObject.Tag
    case 'Temp_Manual'
        handles.Temp_Table.Enable = 'on';
        handles.Temp_Browse.Enable = 'off';
        
    otherwise
        handles.Temp_Table.Enable = 'on';
        handles.Temp_Browse.Enable = 'on';
end
guidata(hObject,handles);


% --- Executes on button press in Temp_Save.
function Temp_Save_Callback(hObject, eventdata, handles)
% hObject    handle to Temp_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Temp_Name, Temp_Dir] = uiputfile( ...
    {'\tmp\temps.txt'}, ...
    'Save as');
if ~isempty(Temp_Name)
    Data = [];
    for i = 1:size(handles.Temp_Table.Data,1)
        if ~isempty(handles.Temp_Table.Data{i,1})
            if isempty(handles.Temp_Table.Data{i,2})
                Data = [Data str2double(handles.Temp_Table.Data{i,1})];
            elseif ~isempty(handles.Temp_Table.Data{i,3})
                Data = [Data eval([num2str(handles.Temp_Table.Data{i,1}) ':' ...
                    num2str(handles.Temp_Table.Data{i,2}) ':' ...
                    num2str(handles.Temp_Table.Data{i,3}) ])];
            end
        end
    end
    Data = unique(sort(Data));
    % Remove possible 0 values
    Data(Data == 0) = [];
    Temps = Data;
    
    fid = fopen([Temp_Dir filesep Temp_Name],'a+');
    fprintf(fid,'%f \n',Temps');
    fclose(fid);
    
    handles.Temp_Save_Str.String = [Temp_Dir filesep Temp_Name];
    handles.TempDir = Temp_Dir;
    handles.TempName = Temp_Name;
else
    warndlg('Temp file was not saved','ZarTES v1.0');
    handles.Temp_Save_Str.String = 'Temp file was not saved';
    handles.TempDir = [];
    handles.TempName = [];
end
guidata(hObject,handles);


% --- Executes on selection change in Noise_Method.
function Noise_Method_Callback(hObject, eventdata, handles)
% hObject    handle to Noise_Method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Noise_Method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Noise_Method
if hObject.Value == 1
    set([handles.Noise_Amp handles.Noise_Amp_Units],'Enable','off');
else
    set([handles.Noise_Amp handles.Noise_Amp_Units],'Enable','on');
end

% --- Executes during object creation, after setting all properties.
function Noise_Method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Noise_Method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DSA_Noise_Conf.
function DSA_Noise_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_Noise_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

waitfor(Conf_Setup(hObject,handles.Noise_Method.Value,handles));


function Noise_Amp_Callback(hObject, eventdata, handles)
% hObject    handle to Noise_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Noise_Amp as text
%        str2double(get(hObject,'String')) returns contents of Noise_Amp as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','100');
        handles.Noise_Amp_Units.Value = 2;
        Noise_Amp_Callback(hObject, [], handles)
    end
else
    set(hObject,'String','100');
    handles.Noise_Amp_Units.Value = 2;
    Noise_Amp_Callback(hObject, [], handles)
end

% --- Executes during object creation, after setting all properties.
function Noise_Amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Noise_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Noise_Amp_Units.
function Noise_Amp_Units_Callback(hObject, eventdata, handles)
% hObject    handle to Noise_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Noise_Amp_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Noise_Amp_Units
Amp = str2double(handles.Noise_Amp.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Amp = Amp/1e-06;
    case -1
        Amp = Amp/1e-03;
    case 0
        Amp = Amp/1;
    case 1
        Amp = Amp/1e03;
    case 2
        Amp = Amp/1e06;
end
handles.Noise_Amp.String = num2str(Amp);
hObject.UserData = NewValue;

% --- Executes during object creation, after setting all properties.
function Noise_Amp_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Noise_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Z_Method.
function Z_Method_Callback(hObject, eventdata, handles)
% hObject    handle to Z_Method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Z_Method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Z_Method
if hObject.Value == 1
    set([handles.Sine_Amp handles.Sine_Amp_Units],'Enable','on');
    set([handles.Sine_Freq handles.Sine_Freq_Units],'Enable','off');
else
    set([handles.Sine_Amp handles.Sine_Amp_Units],'Enable','off');
    set([handles.Sine_Freq handles.Sine_Freq_Units],'Enable','on');
end

% --- Executes during object creation, after setting all properties.
function Z_Method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Z_Method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DSA_TF_Conf.
function DSA_TF_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_TF_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

waitfor(Conf_Setup(hObject,handles.Z_Method.Value,handles));

pause();

function Sine_Amp_Callback(hObject, eventdata, handles)
% hObject    handle to Sine_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Sine_Amp as text
%        str2double(get(hObject,'String')) returns contents of Sine_Amp as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','50');
        handles.Sine_Amp_Units.Value = 2;
        Z_Amp_Callback(hObject, [], handles)
    end
else
    set(hObject,'String','50');
    handles.Sine_Amp_Units.Value = 2;
    Z_Amp_Callback(hObject, [], handles)
end

% --- Executes during object creation, after setting all properties.
function Sine_Amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sine_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Sine_Amp_Units.
function Sine_Amp_Units_Callback(hObject, eventdata, handles)
% hObject    handle to Sine_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Sine_Amp_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Sine_Amp_Units
Amp = str2double(handles.Sine_Amp.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Amp = Amp/1e-06;
    case -1
        Amp = Amp/1e-03;
    case 0
        Amp = Amp/1;
    case 1
        Amp = Amp/1e03;
    case 2
        Amp = Amp/1e06;
end
handles.Sine_Amp.String = num2str(Amp);
hObject.UserData = NewValue;

% --- Executes during object creation, after setting all properties.
function Sine_Amp_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sine_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Sine_Freq_Callback(hObject, eventdata, handles)
% hObject    handle to Sine_Freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Sine_Freq as text
%        str2double(get(hObject,'String')) returns contents of Sine_Freq as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','1');
        handles.Sine_Freq_Units.Value = 1;
        Z_Freq_Callback(hObject, [], handles)
    end
else
    set(hObject,'String','1');
    handles.Sine_Freq_Units.Value = 1;
    Z_Freq_Callback(hObject, [], handles)
end


% --- Executes during object creation, after setting all properties.
function Sine_Freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sine_Freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Sine_Freq_Units.
function Sine_Freq_Units_Callback(hObject, eventdata, handles)
% hObject    handle to Sine_Freq_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Sine_Freq_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Sine_Freq_Units
Freq = str2double(handles.Sine_Freq.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Freq = Freq/1e-06;
    case -1
        Freq = Freq/1e-03;
    case 0
        Freq = Freq/1;
    case 1
        Freq = Freq/1e03;
    case 2
        Freq = Freq/1e06;
end
handles.Sine_Freq.String = num2str(Freq);
hObject.UserData = NewValue;

% --- Executes during object creation, after setting all properties.
function Sine_Freq_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sine_Freq_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AQ_DSA.
function AQ_DSA_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_DSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AQ_DSA
if hObject.Value == 0 && handles.AQ_PXI.Value == 0
    hObject.Value = 1;
end

% --- Executes on button press in AQ_PXI.
function AQ_PXI_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_PXI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AQ_PXI
if hObject == 0 && handles.AQ_DSA.Value == 0
    hObject.Value = 1;
end


% --- Executes on button press in Pulse_Conf.
function Pulse_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to Pulse_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

waitfor(Conf_Setup_PXI(handles.SetupTES.PXI_Pulses_Conf,handles.SetupTES.PXI_Mode.Value,handles.SetupTES));
handles.SetupTES.PXI.ConfStructs = hObject.UserData;
handles.SetupTES.Actions_Str.String = 'PXI Acquisition Card: Configuration changes';
SetupTEScontrolers('Actions_Str_Callback',handles.SetupTES.Actions_Str,[],handles.SetupTES)

guidata(hObject,handles);

% --- Executes on button press in AQ_Zw.
function AQ_Zw_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_Zw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AQ_Zw

if ~hObject.Value
    set([handles.AQ_DSA handles.AQ_PXI ...
        handles.Z_Method handles.DSA_TF_Conf ...
        handles.Sine_Amp handles.Sine_Amp_Units ...
        handles.Sine_Freq handles.Sine_Freq_Units ...
        handles.Noise_Method handles.DSA_Noise_Conf ...
        handles.Noise_Amp handles.Noise_Amp_Units ...
        handles.Summary_Table],'Enable','off');
else
    set([handles.AQ_DSA handles.AQ_PXI ...
        handles.DSA_TF_Conf handles.DSA_Noise_Conf ...
        handles.Z_Method handles.Noise_Method ...
        handles.Summary_Table],'Enable','on');
    set([handles.AQ_DSA handles.AQ_PXI],'Value',1);
    Z_Method_Callback(handles.Z_Method,[],handles);
    Noise_Method_Callback(handles.Noise_Method,[],handles);
    
end


% --- Executes on button press in AQ_Pulse.
function AQ_Pulse_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_Pulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AQ_Pulse

if hObject.Value
    set(handles.Pulse_Conf,'Enable','on');
else
    set(handles.Pulse_Conf,'Enable','off');
end

function Edit_Protect(hObject)
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','1');
    end
else
    set(hObject,'String','1');
end


% --- Executes on button press in AQ_IVs.
function AQ_IVs_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_IVs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AQ_IVs
ch = findobj('Parent',handles.Ibias_Range_Panel,'-not','Tag',hObject.Tag,'-not','Tag','Ibias_Panel');
ch1 = findobj('Parent',handles.Ibias_Panel);
if hObject.Value
    set([ch; ch1],'Enable','on');
else
    set([ch; ch1],'Enable','off');
end


% --- Executes on button press in BField_Scan.
function BField_Scan_Callback(hObject, eventdata, handles)
% hObject    handle to BField_Scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BField_Scan

ch = findobj('Parent',handles.AQ_FieldScan_Panel);
if hObject.Value
    set(ch,'Enable','on');
else
    set(ch,'Enable','off');
end

guidata(hObject,handles);

% --- Executes on button press in Field_Add.
function Field_Add_Callback(hObject, eventdata, handles)
% hObject    handle to Field_Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Field_Table.Data = [handles.Field_Table.Data; cell(1,3)];
guidata(hObject,handles);

% --- Executes on button press in Field_Remove.
function Field_Remove_Callback(hObject, eventdata, handles)
% hObject    handle to Field_Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if size(handles.Field_Table.Data,1) > 1
    handles.Field_Table.Data(end,:) = [];
end
guidata(hObject,handles);


function Field_Rn_Callback(hObject, eventdata, handles)
% hObject    handle to Field_Rn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Field_Rn as text
%        str2double(get(hObject,'String')) returns contents of Field_Rn as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if (value < 0|| value > 1)
        set(hObject,'String','0.5');
    end
else
    set(hObject,'String','0.5');
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Field_Rn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Field_Rn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Field_Ibias_Callback(hObject, eventdata, handles)
% hObject    handle to Field_Ibias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Field_Ibias as text
%        str2double(get(hObject,'String')) returns contents of Field_Ibias as a double
Edit_Protect(hObject)
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Field_Ibias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Field_Ibias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Bath_Start.
function Bath_Start_Callback(hObject, eventdata, handles)
% hObject    handle to Bath_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% Configuración del Panel de Temperatura

Conf.Temps.Values = handles.Temp.Values;
Conf.Temps.File = [handles.TempDir handles.TempName];

%% Configuración del Panel de Campo

Conf.FieldScan.On = handles.BField_Scan.Value;
Conf.FieldScan.Rn = str2double(handles.Field_Rn.String);
Conf.FieldScan.BVvalues = handles.FieldScan.BVvalue;

Conf.BFieldIC.On = handles.BField_IC.Value;
Conf.BFieldIC.BVvalues = handles.BFieldIC.BVvalue;
Conf.BFieldIC.IbiasValues = handles.BFieldIC.IbiasValues;

Conf.BField.FromScan = handles.FromFieldScan.Value;
Conf.BField.Symmetric = handles.Field_Symmetric.Value;
Conf.BField.P = str2double(handles.AQ_Field.String);
Conf.BField.N = str2double(handles.AQ_Field_Negative.String);

%% Configuración del Panel de Ibias

Conf.IVcurves.On = handles.AQ_IVs.Value;
Conf.IVcurves.Manual.On = handles.ManualIbias.Value;
Conf.IVcurves.Manual.Values = handles.IVcurves.Manual.Values;
Conf.IVcurves.SmartRange.On = handles.SmartIbias.Value;

%%%% Poner la configuracion para la characterización de Z(w)-Ruido y
%%%% pulsos
Conf.TF.Zw.DSA.On = handles.DSA_TF_Zw.Value;
Conf.TF.Zw.PXI.On = handles.PXI_TF_Zw.Value;
Conf.TF.Zw.rpp = handles.TF_Zw.rpp;
Conf.TF.Zw.rpn = handles.TF_Zw.rpn;


Conf.TF.Noise.DSA.On = handles.DSA_TF_Noise.Value;
Conf.TF.Noise.PXI.On = handles.PXI_TF_Noise.Value;

Conf.Pulse.PXI.On = handles.PXI_Pulse.Value;
Conf.Pulse.PXI.NCounts = str2double(handles.PulseNCounts.String);

Conf.Spectrum.PXI.On = handles.AQ_Spectrum.Value;
Conf.Spectrum.PXI.Rn = str2double(handles.Spectrum_Rn.String);
Conf.Spectrum.PXI.NCounts = str2double(handles.Spectrum_NCounts.String);


%%%% Refresh Summary Table

Conf.Summary = handles.Summary_Table.Data;


Start_Automatic_Acquisition(handles,handles.SetupTES,Conf);

handles.src.UserData = Conf;

guidata(hObject,handles);

% --- Executes on button press in Bath_Cancel.
function Bath_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Bath_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function AQ_Field_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_Field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AQ_Field as text
%        str2double(get(hObject,'String')) returns contents of AQ_Field as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
else
    set(hObject,'String','0');
end
if handles.Field_Symmetric.Value == 1
    set(handles.AQ_Field_Negative,'String',num2str(value));
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function AQ_Field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AQ_Field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Refresh_Table.
function Refresh_Table_Callback(hObject, eventdata, handles)
% hObject    handle to Refresh_Table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Temps = handles.Temp.Values;

if ~isempty(Temps)
    % IV Curves
    if handles.AQ_IVs.Value
        IV_Ticks(1:length(Temps),1) = {'Yes'};
    else
        IV_Ticks(1:length(Temps),1) = {'No'};
    end
    % BField Scan
    if handles.BField_Scan.Value
        BScan(1:length(Temps),1) = {'Yes'};
    else
        BScan(1:length(Temps),1) = {'No'};
    end
    % Critical Currents
    if handles.BField_IC.Value
        ICField(1:length(Temps),1) = {'Yes'};
    else
        ICField(1:length(Temps),1) = {'No'};
    end
    
    % TF - Zw (DSA) or (PXI)
    if handles.DSA_TF_Zw.Value || handles.PXI_TF_Zw.Value
        TF_Zw_Ticks(1:length(Temps),1) = {'No'};
        TF_Zw_Ticks(round(Temps*1e3) == 50 | round(Temps*1e3) == 70) = {'Yes'};
    else
        TF_Zw_Ticks(1:length(Temps),1) = {'No'};
    end
    % TF - Noise (DSA) or (PXI)
    if handles.DSA_TF_Noise.Value || handles.PXI_TF_Noise.Value
        TF_Noise_Ticks(1:length(Temps),1) = {'No'};
        TF_Noise_Ticks(round(Temps*1e3) == 50 | round(Temps*1e3) == 70) = {'Yes'};
    else
        TF_Noise_Ticks(1:length(Temps),1) = {'No'};
    end
    % Pulses (PXI)
    if handles.PXI_Pulse.Value
        Pulse_Ticks(1:length(Temps),1) = {'No'};
        Pulse_Ticks(round(Temps*1e3) == 50 | round(Temps*1e3) == 70) = {'Yes'};
    else
        Pulse_Ticks(1:length(Temps),1) = {'No'};
    end
    
    if handles.AQ_Spectrum.Value
        Spectrum_Ticks(1:length(Temps),1) = {'No'};
        Spectrum_Ticks(round(Temps*1e3) == 50 | round(Temps*1e3) == 70) = {'Yes'};
    else
        Spectrum_Ticks(1:length(Temps),1) = {'No'};
    end
    
    handles.Summary_Table.Data = [num2cell(Temps) IV_Ticks BScan ICField TF_Zw_Ticks TF_Noise_Ticks Pulse_Ticks Spectrum_Ticks];
else
    warndlg('No Temperature values selected!','ZarTES v1.0');
end

function Pulse_Rn_Callback(hObject, eventdata, handles)
% hObject    handle to Pulse_Rn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pulse_Rn as text
%        str2double(get(hObject,'String')) returns contents of Pulse_Rn as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if (value <= 0)||(value > 1)
        set(hObject,'String','0.7');
    end
else
    set(hObject,'String','0.7');
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Pulse_Rn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pulse_Rn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Field_Symmetric.
function Field_Symmetric_Callback(hObject, eventdata, handles)
% hObject    handle to Field_Symmetric (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Field_Symmetric
if hObject.Value
    set([handles.text38 handles.AQ_Field_Negative],'Enable','off');
    handles.AQ_Field_Negative.String = handles.AQ_Field.String;
else
    if ~handles.FromFieldScan.Value
        set([handles.text38 handles.AQ_Field_Negative],'Enable','on');
    end
end
guidata(hObject,handles);

function AQ_Field_Negative_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_Field_Negative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AQ_Field_Negative as text
%        str2double(get(hObject,'String')) returns contents of AQ_Field_Negative as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
else
    set(hObject,'String','0');
end

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function AQ_Field_Negative_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AQ_Field_Negative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DSA_TF_Noise_Conf.
function DSA_TF_Noise_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_TF_Noise_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
waitfor(Conf_Setup(hObject,[],handles));
guidata(hObject,handles);

% --- Executes on selection change in DSA_Input_Freq_Units.
function DSA_Input_Freq_Units_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_Input_Freq_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DSA_Input_Freq_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DSA_Input_Freq_Units
Freq = str2double(handles.DSA_Input_Freq.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Freq = Freq/1e-06;
    case -1
        Freq = Freq/1e-03;
    case 0
        Freq = Freq/1;
    case 1
        Freq = Freq/1e03;
    case 2
        Freq = Freq/1e06;
end
handles.DSA_Input_Freq.String = num2str(Freq);
hObject.UserData = NewValue;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function DSA_Input_Freq_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DSA_Input_Freq_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DSA_Input_Freq_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_Input_Freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DSA_Input_Freq as text
%        str2double(get(hObject,'String')) returns contents of DSA_Input_Freq as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','1');
        handles.DSA_Input_Freq_Units.Value = 1;
        DSA_Input_Freq_Callback(hObject, [], handles)
    end
else
    set(hObject,'String','1');
    handles.DSA_Input_Freq_Units.Value = 1;
    DSA_Input_Freq_Callback(hObject, [], handles)
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function DSA_Input_Freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DSA_Input_Freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DSA_Input_Amp_Units.
function DSA_Input_Amp_Units_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_Input_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DSA_Input_Amp_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DSA_Input_Amp_Units
Amp = str2double(handles.DSA_Input_Amp.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;
if NewValue ~= 4
    switch OldValue-NewValue
        case -2
            Amp = Amp/1e-06;
        case -1
            Amp = Amp/1e-03;
        case 0
            Amp = Amp/1;
        case 1
            Amp = Amp/1e03;
        case 2
            Amp = Amp/1e06;
    end
else
    Amp = 0.05;
end
handles.DSA_Input_Amp.String = num2str(Amp);
hObject.UserData = NewValue;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function DSA_Input_Amp_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DSA_Input_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DSA_Input_Amp_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_Input_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DSA_Input_Amp as text
%        str2double(get(hObject,'String')) returns contents of DSA_Input_Amp as a double

value = str2double(get(hObject,'String'));
if handles.DSA_Input_Amp_Units.Value ~= 4
    if ~isempty(value)&&~isnan(value)
        if value <= 0
            set(hObject,'String','50');
            handles.DSA_Input_Amp_Units.Value = 2;
            DSA_Input_Amp_Callback(hObject, [], handles)
        end
    else
        set(hObject,'String','50');
        handles.DSA_Input_Amp_Units.Value = 2;
        DSA_Input_Amp_Callback(hObject, [], handles)
    end
else
    if ~isempty(value)&&~isnan(value)
        if (value <= 0)||(value > 1)
            set(hObject,'String','0.05');
            handles.DSA_Input_Amp_Units.Value = 4;
            DSA_Input_Amp_Callback(hObject, [], handles)
        end
    else
        set(hObject,'String','0.05');
        handles.DSA_Input_Amp_Units.Value = 4;
        DSA_Input_Amp_Callback(hObject, [], handles)
    end
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function DSA_Input_Amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DSA_Input_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DSA_TF_Zw_Conf.
function DSA_TF_Zw_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_TF_Zw_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
waitfor(Conf_Setup(hObject,handles.DSA_TF_Zw_Menu.Value,handles));
handles.SetupTES = guidata(handles.SetupTES.SetupTES);
DSA_TF_Zw_Menu_Callback(handles.DSA_TF_Zw_Menu,[],handles);
guidata(hObject,handles);

% --- Executes on selection change in DSA_TF_Zw_Menu.
function DSA_TF_Zw_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_TF_Zw_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DSA_TF_Zw_Menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DSA_TF_Zw_Menu
switch hObject.Value
    case 1
        Srch = strfind(handles.SetupTES.DSA.Config.SSine,'SRLV ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        handles.DSA_Input_Amp_Units.Value = 2;
        Str = handles.SetupTES.DSA.Config.SSine{Srch == 1};
        handles.DSA_Input_Amp.String = Str(strfind(Str,'SRLV ')+5:end-2);
        
        set([handles.DSA_Input_Freq handles.DSA_Input_Freq_Units],'Enable','off');
        
    case 2
        Srch = strfind(handles.SetupTES.DSA.Config.FSine,'SRLV ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        handles.DSA_Input_Amp_Units.Value = 2;
        Str = handles.SetupTES.DSA.Config.FSine{Srch == 1};
        handles.DSA_Input_Amp.String = Str(strfind(Str,'SRLV ')+5:end-2);
        
        Srch = strfind(handles.SetupTES.DSA.Config.FSine,'FSIN ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        handles.DSA_Input_Freq_Units.Value = 1;
        Str = handles.SetupTES.DSA.Config.FSine{Srch == 1};
        handles.DSA_Input_Freq.String = Str(strfind(Str,'FSIN ')+5:end-2);
        
        set([handles.DSA_Input_Amp handles.DSA_Input_Amp_Units ...
            handles.DSA_Input_Freq handles.DSA_Input_Freq_Units],'Enable','on');
    case 3
        Srch = strfind(handles.SetupTES.DSA.Config.WNoise,'SRLV ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        handles.DSA_Input_Amp_Units.Value = 2;
        Str = handles.SetupTES.DSA.Config.WNoise{Srch == 1};
        handles.DSA_Input_Amp.String = Str(strfind(Str,'SRLV ')+5:end-2);
        set([handles.DSA_Input_Freq handles.DSA_Input_Freq_Units],'Enable','off');
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function DSA_TF_Zw_Menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DSA_TF_Zw_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PXI_Input_Amp_Units.
function PXI_Input_Amp_Units_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Input_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PXI_Input_Amp_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PXI_Input_Amp_Units
Amp = str2double(handles.PXI_Input_Amp.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

if NewValue ~= 4
    switch OldValue-NewValue
        case -2
            Amp = Amp/1e-06;
        case -1
            Amp = Amp/1e-03;
        case 0
            Amp = Amp/1;
        case 1
            Amp = Amp/1e03;
        case 2
            Amp = Amp/1e06;
    end
else
    Amp = 0.05;
end
handles.PXI_Input_Amp.String = num2str(Amp);
hObject.UserData = NewValue;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function PXI_Input_Amp_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PXI_Input_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PXI_TF_Zw_Menu.
function PXI_TF_Zw_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_TF_Zw_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PXI_TF_Zw_Menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PXI_TF_Zw_Menu
if hObject.Value == 1
    set([handles.PXI_Input_Freq handles.PXI_Input_Freq_Units],'Enable','off');
else
    set([handles.PXI_Input_Amp handles.PXI_Input_Amp_Units],'Enable','on');
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function PXI_TF_Zw_Menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PXI_TF_Zw_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PXI_Input_Amp_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Input_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PXI_Input_Amp as text
%        str2double(get(hObject,'String')) returns contents of PXI_Input_Amp as a double
value = str2double(get(hObject,'String'));
if handles.PXI_Input_Amp_Units.Value ~= 4
    if ~isempty(value)&&~isnan(value)
        if value <= 0
            set(hObject,'String','100');
            handles.PXI_Input_Amp_Units.Value = 2;
            PXI_Input_Amp_Callback(hObject, [], handles)
        end
    else
        set(hObject,'String','100');
        handles.PXI_Input_Amp_Units.Value = 2;
        PXI_Input_Amp_Callback(hObject, [], handles)
    end
else
    if ~isempty(value)&&~isnan(value)
        if (value <= 0)||(value > 1)
            set(hObject,'String','0.05');
            handles.PXI_Input_Amp_Units.Value = 4;
            PXI_Input_Amp_Callback(hObject, [], handles)
        end
    else
        set(hObject,'String','0.05');
        handles.PXI_Input_Amp_Units.Value = 4;
        PXI_Input_Amp_Callback(hObject, [], handles)
    end
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function PXI_Input_Amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PXI_Input_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PXI_TF_Zw_Conf.
function PXI_TF_Zw_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_TF_Zw_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject.UserData = [];
waitfor(Conf_Setup_PXI(hObject,[],handles.SetupTES));
if ~isempty(hObject.UserData)
    handles.SetupTES.PXI.ConfStructs = hObject.UserData;
end
guidata(hObject,handles);

% waitfor(Conf_Setup_PXI(hObject,[],handles.SetupTES));
% guidata(hObject,handles);

% --- Executes on selection change in PXI_Input_Freq_Units.
function PXI_Input_Freq_Units_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Input_Freq_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PXI_Input_Freq_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PXI_Input_Freq_Units
Freq = str2double(handles.PXI_Input_Freq.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Freq = Freq/1e-06;
    case -1
        Freq = Freq/1e-03;
    case 0
        Freq = Freq/1;
    case 1
        Freq = Freq/1e03;
    case 2
        Freq = Freq/1e06;
end
handles.PXI_Input_Freq.String = num2str(Freq);
hObject.UserData = NewValue;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function PXI_Input_Freq_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PXI_Input_Freq_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PXI_Input_Freq_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Input_Freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PXI_Input_Freq as text
%        str2double(get(hObject,'String')) returns contents of PXI_Input_Freq as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','1');
        handles.PXI_Input_Freq_Units.Value = 1;
        PXI_Input_Freq_Callback(hObject, [], handles)
    end
else
    set(hObject,'String','1');
    handles.PXI_Input_Freq_Units.Value = 1;
    PXI_Input_Freq_Callback(hObject, [], handles)
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function PXI_Input_Freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PXI_Input_Freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PXI_TF_Noise_Conf.
function PXI_TF_Noise_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_TF_Noise_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject.UserData = [];
waitfor(Conf_Setup_PXI(hObject,[],handles.SetupTES));
if ~isempty(hObject.UserData)
    handles.SetupTES.PXI.ConfStructs = hObject.UserData;
end
guidata(hObject,handles);


% --- Executes on button press in PXI_Pulse_Conf.
function PXI_Pulse_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Pulse_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
waitfor(Conf_Setup_PXI(hObject,[],handles.SetupTES));
handles.SetupTES.PXI.ConfStructs = hObject.UserData;
guidata(hObject,handles);

% --- Executes on button press in DSA_TF_Zw.
function DSA_TF_Zw_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_TF_Zw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DSA_TF_Zw
ch = handles.DSA_TF_Zw_Panel.Children;
if hObject.Value
    set(ch,'Enable','on');
    % Actualizacion del setup de configuracion
    DSA_TF_Zw_Menu_Callback(handles.DSA_TF_Zw_Menu,[],handles);
else
    set(ch,'Enable','off');
end
if handles.DSA_TF_Zw.Value || handles.PXI_TF_Zw.Value || handles.DSA_TF_Noise.Value || handles.PXI_TF_Noise.Value || handles.PXI_Pulse.Value
    set([handles.AQ_TF_Rn_P_Set handles.AQ_TF_Rn_N_Set],'Enable','on');
else
    set([handles.AQ_TF_Rn_P_Set handles.AQ_TF_Rn_N_Set],'Enable','off');
end

guidata(hObject,handles);

% --- Executes on button press in PXI_TF_Zw.
function PXI_TF_Zw_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_TF_Zw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PXI_TF_Zw
ch = handles.PXI_TF_Zw_Panel.Children;
if hObject.Value
    set(ch,'Enable','on');
    PXI_TF_Zw_Menu_Callback(handles.PXI_TF_Zw_Menu,[],handles);
else
    set(ch,'Enable','off');
end
if handles.DSA_TF_Zw.Value || handles.PXI_TF_Zw.Value || handles.DSA_TF_Noise.Value || handles.PXI_TF_Noise.Value || handles.PXI_Pulse.Value
    set([handles.AQ_TF_Rn_P_Set handles.AQ_TF_Rn_N_Set],'Enable','on');
else
    set([handles.AQ_TF_Rn_P_Set handles.AQ_TF_Rn_N_Set],'Enable','off');
end
guidata(hObject,handles);

% --- Executes on button press in PXI_TF_Noise.
function PXI_TF_Noise_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_TF_Noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PXI_TF_Noise
ch = handles.PXI_TF_Noise_Panel.Children;
if hObject.Value
    set(ch,'Enable','on');
else
    set(ch,'Enable','off');
end
if handles.DSA_TF_Zw.Value || handles.PXI_TF_Zw.Value || handles.DSA_TF_Noise.Value || handles.PXI_TF_Noise.Value || handles.PXI_Pulse.Value
    set([handles.AQ_TF_Rn_P_Set handles.AQ_TF_Rn_N_Set],'Enable','on');
else
    set([handles.AQ_TF_Rn_P_Set handles.AQ_TF_Rn_N_Set],'Enable','off');
end
guidata(hObject,handles);

% --- Executes on button press in DSA_TF_Noise.
function DSA_TF_Noise_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_TF_Noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DSA_TF_Noise
ch = handles.DSA_TF_Noise_Panel.Children;
if hObject.Value
    set(ch,'Enable','on');
else
    set(ch,'Enable','off');
end
if handles.DSA_TF_Zw.Value || handles.PXI_TF_Zw.Value || handles.DSA_TF_Noise.Value || handles.PXI_TF_Noise.Value || handles.PXI_Pulse.Value
    set([handles.AQ_TF_Rn_P_Set handles.AQ_TF_Rn_N_Set],'Enable','on');
else
    set([handles.AQ_TF_Rn_P_Set handles.AQ_TF_Rn_N_Set],'Enable','off');
end
guidata(hObject,handles);

% --- Executes on button press in PXI_Pulse.
function PXI_Pulse_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Pulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PXI_Pulse
ch = handles.PXI_Pulse_Panel.Children;
if hObject.Value
    set(ch,'Enable','on');
else
    set(ch,'Enable','off');
end
if handles.DSA_TF_Zw.Value || handles.PXI_TF_Zw.Value || handles.DSA_TF_Noise.Value || handles.PXI_TF_Noise.Value || handles.PXI_Pulse.Value
    set([handles.AQ_TF_Rn_P_Set handles.AQ_TF_Rn_N_Set],'Enable','on');
else
    set([handles.AQ_TF_Rn_P_Set handles.AQ_TF_Rn_N_Set],'Enable','off');
end
guidata(hObject,handles);


% --- Executes on button press in BField_IC.
function BField_IC_Callback(hObject, eventdata, handles)
% hObject    handle to BField_IC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BField_IC

ch = findobj('Parent',handles.AQ_IC_Panel);
if hObject.Value
    set(ch,'Enable','on');
else
    set(ch,'Enable','off');
end

guidata(hObject,handles);

% --- Executes on button press in FromFieldScan.
function FromFieldScan_Callback(hObject, eventdata, handles)
% hObject    handle to FromFieldScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FromFieldScan
if hObject.Value
    handles.BField_Scan.Value = 1;
    BField_Scan_Callback(handles.BField_Scan,[],handles);
    set([handles.AQ_Field handles.text37 handles.AQ_Field_Negative handles.text38],'Enable','off');
    
else
    set([handles.AQ_Field handles.text37 handles.AQ_Field_Negative handles.text38],'Enable','on');
    Field_Symmetric_Callback(handles.Field_Symmetric,[],handles);
end
guidata(hObject,handles);


% --- Executes on button press in ManualIbias.
function ManualIbias_Callback(hObject, eventdata, handles)
% hObject    handle to ManualIbias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ManualIbias
if hObject.Value
    set([handles.Ibias_Set handles.Ibias_Negative handles.Ibias_NRepeat handles.Ibias_NRepeat_Str],'Enable','on')
else
    set([handles.Ibias_Set handles.Ibias_Negative handles.Ibias_NRepeat handles.Ibias_NRepeat_Str],'Enable','off')
end
guidata(hObject,handles);


% --- Executes on button press in SmartIbias.
function SmartIbias_Callback(hObject, eventdata, handles)
% hObject    handle to SmartIbias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SmartIbias
if hObject.Value
    set([handles.Ibias_Set handles.Ibias_Negative handles.Ibias_NRepeat handles.Ibias_NRepeat_Str],'Enable','off')
else
    set([handles.Ibias_Set handles.Ibias_Negative handles.Ibias_NRepeat handles.Ibias_NRepeat_Str],'Enable','on')
end
guidata(hObject,handles);



function PulseNcounts_Callback(hObject, eventdata, handles)
% hObject    handle to PulseNcounts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PulseNcounts as text
%        str2double(get(hObject,'String')) returns contents of PulseNcounts as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','1');
    end
else
    set(hObject,'String','1');
end

% --- Executes during object creation, after setting all properties.
function PulseNcounts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PulseNcounts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Save_Conf.
function Save_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


Conf.Temps.Values = handles.Temp.Values';
Conf.Temps.File = [handles.TempDir handles.TempName];

Conf.FieldScan.On = handles.BField_Scan.Value;
Conf.FieldScan.Rn = str2double(handles.Field_Rn.String);
Conf.FieldScan.BVvalues = handles.FieldScan.BVvalue';

Conf.BFieldIC.On = handles.BField_IC.Value;
Conf.BFieldIC.BVvalues = handles.BFieldIC.BVvalue';
Conf.BFieldIC.IbiasValues.p = handles.BFieldIC.IbiasValues.p';
Conf.BFieldIC.IbiasValues.n = handles.BFieldIC.IbiasValues.n';

Conf.BField.FromScan = handles.FromFieldScan.Value;
Conf.BField.Symmetric = handles.Field_Symmetric.Value;
Conf.BField.P = str2double(handles.AQ_Field.String);
Conf.BField.N = str2double(handles.AQ_Field_Negative.String);

%% Configuración del Panel de Ibias

Conf.IVcurves.On = handles.AQ_IVs.Value;
Conf.IVcurves.Manual.On = handles.ManualIbias.Value;
Conf.IVcurves.Manual.Values.p = handles.IVcurves.Manual.Values.p';
Conf.IVcurves.Manual.Values.n = handles.IVcurves.Manual.Values.n';
Conf.IVcurves.SmartRange.On = handles.SmartIbias.Value;

%%%% Poner la configuracion para la characterización de Z(w)-Ruido y
%%%% pulsos
Conf.TF.Zw.DSA.On = handles.DSA_TF_Zw.Value;
Conf.TF.Zw.DSA.Method.Value = handles.DSA_TF_Zw_Menu.Value;
contents = cellstr(get(handles.DSA_TF_Zw_Menu,'String'));
Conf.TF.Zw.DSA.Method.String = contents{get(handles.DSA_TF_Zw_Menu,'Value')};
Conf.TF.Zw.DSA.Exc.Units.Value = handles.DSA_Input_Amp_Units.Value;
contents = cellstr(get(handles.DSA_Input_Amp_Units,'String'));
Conf.TF.Zw.DSA.Exc.Units.String = contents{get(handles.DSA_Input_Amp_Units,'Value')};
Conf.TF.Zw.DSA.Exc.Value = str2double(handles.DSA_Input_Amp.String);


Conf.TF.Zw.PXI.On = handles.PXI_TF_Zw.Value;
Conf.TF.Zw.PXI.Method.Value = handles.PXI_TF_Zw_Menu.Value;
contents = cellstr(get(handles.PXI_TF_Zw_Menu,'String'));
Conf.TF.Zw.PXI.Method.String = contents{get(handles.PXI_TF_Zw_Menu,'Value')};
Conf.TF.Zw.PXI.Exc.Units.Value = handles.PXI_Input_Amp_Units.Value;
contents = cellstr(get(handles.PXI_Input_Amp_Units,'String'));
Conf.TF.Zw.PXI.Exc.Units.String = contents{get(handles.PXI_Input_Amp_Units,'Value')};
Conf.TF.Zw.PXI.Exc.Value = str2double(handles.PXI_Input_Amp.String);

Conf.TF.Zw.rpp = handles.TF_Zw.rpp';
Conf.TF.Zw.rpn = handles.TF_Zw.rpn';


Conf.TF.Noise.DSA.On = handles.DSA_TF_Noise.Value;
Conf.TF.Noise.PXI.On = handles.PXI_TF_Noise.Value;

Conf.Pulse.PXI.On = handles.PXI_Pulse.Value;
Conf.Pulse.PXI.NCounts = str2double(handles.PulseNCounts.String);

Conf.Spectrum.PXI.On = handles.AQ_Spectrum.Value;
Conf.Spectrum.PXI.Rn = str2double(handles.Spectrum_Rn.String);
Conf.Spectrum.PXI.NCounts = str2double(handles.Spectrum_NCounts.String);


%%%% Refresh Summary Table

StrSummary = handles.Summary_Table.ColumnName;
for j = 1:size(handles.Summary_Table.Data,1)
    for i = 1:size(handles.Summary_Table.Data,2)
        eval(['Conf.Summary.' StrSummary{i} num2str(j) ' = handles.Summary_Table.Data{j,i};']);
    end
end

s.Config = Conf;

if ischar(eventdata)
    struct2xml(s,[eventdata filesep 'Conf_File.xml']);
elseif isempty(eventdata)||strcmp(eventdata.EventName,'Action')
    [FileName,PathName,~] = uiputfile('.\*.xml','Select a file or a new file name for save current configuration');
    if ~isequal(FileName,0)
        struct2xml(s,[PathName FileName]);
    end    
end
    



% --- Executes on button press in AQ_TF_Rn_P_Set.
function AQ_TF_Rn_P_Set_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_TF_Rn_P_Set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject.UserData = [];
waitfor(Conf_Setup(hObject,[],handles));

if ~isempty(hObject.UserData)
    handles.TF_Zw.rpp = sort(hObject.UserData{1},'descend');
    guidata(hObject,handles);
end

% --- Executes on button press in AQ_TF_Rn_N_Set.
function AQ_TF_Rn_N_Set_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_TF_Rn_N_Set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject.UserData = [];
waitfor(Conf_Setup(hObject,[],handles));

if ~isempty(hObject.UserData)
    handles.TF_Zw.rpn = sort(hObject.UserData{1},'descend');
    guidata(hObject,handles);
end

% --- Executes on button press in AQ_Temp_Set.
function AQ_Temp_Set_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_Temp_Set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject.UserData = [];
waitfor(Conf_Setup(hObject,[],handles));

if ~isempty(hObject.UserData)
    button = questdlg('Set Mixing Chamber Temperatures (Ascend by default)',...
        'ZarTES v1.0','Ascend','Descend','Ascend');
    switch button
        case 'Ascend'
            handles.Temp.Values = sort(hObject.UserData{1},'ascend');
        case 'Descend'
            handles.Temp.Values = sort(hObject.UserData{1},'descend');
        otherwise
            handles.Temp.Values = sort(hObject.UserData{1},'ascend');
    end    
    Refresh_Table_Callback(handles.Refresh_Table,[],handles);
    guidata(hObject,handles);
end

% --- Executes on button press in AQ_FieldScan_Set.
function AQ_FieldScan_Set_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_FieldScan_Set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject.UserData = [];
waitfor(Conf_Setup(hObject,[],handles));

if ~isempty(hObject.UserData)
    handles.FieldScan.BVvalues = hObject.UserData{1};
    guidata(hObject,handles);
end

% --- Executes on button press in AQ_IC_Field_Set.
function AQ_IC_Field_Set_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_IC_Field_Set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject.UserData = [];
waitfor(Conf_Setup(hObject,[],handles));

if ~isempty(hObject.UserData)
    handles.BFieldIC.BVvalue = hObject.UserData{1};
    guidata(hObject,handles);
end


% --- Executes on button press in AQ_Spectrum.
function AQ_Spectrum_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_Spectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AQ_Spectrum
ch = handles.Spectrum_Panel.Children;
if hObject.Value
    set(ch,'Enable','on');
else
    set(ch,'Enable','off');
end
guidata(hObject,handles);

% --- Executes on button press in Ibias_Set.
function Ibias_Set_Callback(hObject, eventdata, handles)
% hObject    handle to Ibias_Set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject.UserData = [];
waitfor(Conf_Setup(hObject,[],handles));

if ~isempty(hObject.UserData)
    handles.IVcurves.Manual.Values.p = sort(hObject.UserData{1}(hObject.UserData{1} >= 0),'descend');
    handles.IVcurves.Manual.Values.n = sort(hObject.UserData{1}(hObject.UserData{1} <= 0),'ascend');
    guidata(hObject,handles);
end

% --- Executes on button press in PXI_Spectrum_Conf.
function PXI_Spectrum_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Spectrum_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

waitfor(Conf_Setup_PXI(handles.PXI_Pulse_Conf,[],handles.SetupTES));
guidata(hObject,handles);


function Spectrum_Rn_Callback(hObject, eventdata, handles)
% hObject    handle to Spectrum_Rn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Spectrum_Rn as text
%        str2double(get(hObject,'String')) returns contents of Spectrum_Rn as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if (value < 0|| value > 1)
        set(hObject,'String','0.5');
    end
else
    set(hObject,'String','0.5');
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Spectrum_Rn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Spectrum_Rn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Spectrum_NCounts_Callback(hObject, eventdata, handles)
% hObject    handle to Spectrum_NCounts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Spectrum_NCounts as text
%        str2double(get(hObject,'String')) returns contents of Spectrum_NCounts as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','1');
    end
else
    set(hObject,'String','1');
end

% --- Executes during object creation, after setting all properties.
function Spectrum_NCounts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Spectrum_NCounts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Field_Manual.
function Field_Manual_Callback(hObject, eventdata, handles)
% hObject    handle to Field_Manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Field_Manual
if hObject.Value
    set([handles.Field_Symmetric handles.AQ_Field handles.text37],'Enable','on');
    Field_Symmetric_Callback(handles.Field_Symmetric,[],handles);
    
end
guidata(hObject,handles);


% --- Executes on button press in BFieldIC_Ibias.
function BFieldIC_Ibias_Callback(hObject, eventdata, handles)
% hObject    handle to BFieldIC_Ibias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject.UserData = [];
waitfor(Conf_Setup(hObject,[],handles));

if ~isempty(hObject.UserData)
    handles.BFieldIC.IbiasValues.p = sort(hObject.UserData{1}(hObject.UserData{1} >= 0),'ascend');
    handles.BFieldIC.IbiasValues.n = sort(hObject.UserData{1}(hObject.UserData{1} <= 0),'descend');
    guidata(hObject,handles);
end


function Conf = GenerateConf(handles)



% --- Executes on button press in AQ_Pause.
function AQ_Pause_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_Pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Active_Color = [120 170 50]/255;
% Gray color - Disable elements
Disable_Color = [204 204 204]/255;
if hObject.Value
    hObject.BackgroundColor = Active_Color;
    msgbox('Press F5 to continue!','ZarTES v1.0')
    keyboard;
    
    hObject.BackgroundColor = Disable_Color;
    hObject.Value = 1;
end



function FinalMCT_Callback(hObject, eventdata, handles)
% hObject    handle to FinalMCT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FinalMCT as text
%        str2double(get(hObject,'String')) returns contents of FinalMCT as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value < 0
        set(hObject,'String','0');
    end
    if value > 1
        set(hObject,'String','0');
    end        
else
    set(hObject,'String','0');
end

% --- Executes during object creation, after setting all properties.
function FinalMCT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FinalMCT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
