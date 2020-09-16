function varargout = SetupTEScontrolers(varargin)
% SETUPTESCONTROLERS MATLAB code for SetupTEScontrolers.fig
%      SETUPTESCONTROLERS, by itself, creates a new SETUPTESCONTROLERS or raises the existing
%      singleton*.
%
%      H = SETUPTESCONTROLERS returns the handle to a new SETUPTESCONTROLERS or the handle to
%      the existing singleton*.
%
%      SETUPTESCONTROLERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETUPTESCONTROLERS.M with the given input arguments.
%
%      SETUPTESCONTROLERS('Property','Value',...) creates a new SETUPTESCONTROLERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SetupTEScontrolers_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SetupTEScontrolers_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SetupTEScontrolers

% Last Modified by GUIDE v2.5 01-Jun-2020 19:07:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SetupTEScontrolers_OpeningFcn, ...
    'gui_OutputFcn',  @SetupTEScontrolers_OutputFcn, ...
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

% --- Executes just before SetupTEScontrolers is made visible.
function SetupTEScontrolers_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SetupTEScontrolers (see VARARGIN)

% Choose default command line output for SetupTEScontrolers
handles.output = hObject;
set(handles.SetupTES,'Units','Normalized','Visible','off');
position = get(handles.SetupTES,'Position');
set(handles.SetupTES,'Position',...
    [0.05 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');  % ,'Color',[0 120 180]/255


% Connection to Labview program for controlling mix chamber temperature
try
    e = actxserver('LabVIEW.Application');
    vipath = 'C:\Users\Athena\Desktop\Software\2014_Oxford TES\IGHSUBS.LLB\IGHFrontPanel.vi';
    handles.vi_IGHFrontPanel = invoke(e,'GetVIReference',vipath);
    vipath3 = 'C:\Users\Athena\Desktop\Software\2014_Oxford TES\KELVPNLS.LLB\KelvPromptForT.vi';
    handles.vi_PromptForT = invoke(e,'GetVIReference',vipath3);
    vipath5 = 'C:\Users\Athena\Desktop\Software\2014_Oxford TES\IGHSUBS.LLB\IGHChangeSettings.vi';
    handles.vi_IGHChangeSettings = invoke(e,'GetVIReference',vipath5);
    
    %     handles.vi.Run(1);
    T_MC = handles.vi_IGHFrontPanel.GetControlValue('M/C');
    handles.MCTemp.String = num2str(T_MC);
    
    Period = 15;
    handles.timer = timer(...
        'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
        'Period', Period, ...                        % Initial period is 1 sec.
        'TimerFcn', {@update_Temp_display},'UserData',handles,'Name','TEStimer');
    
    handles.timer_T = timer(...
        'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
        'Period', Period, ...                        % Initial period is 1 sec.
        'TimerFcn', {@update_Temp_Color},'UserData',handles,'Name','T_TEStimer');
    %     guidata(handles.timer,handles);
    start(handles.timer);
    
    
    
catch
    
end


% Set correct paths (addition)
handles.CurrentPath = pwd;
handles.MainDir = handles.CurrentPath(1:find(handles.CurrentPath == filesep, 1, 'last' ));
handles.d = dir(handles.MainDir);
for i = 3:length(handles.d) % Los dos primeros son '.' y '..'
    if handles.d(i).isdir
        addpath([handles.MainDir handles.d(i).name])
    end
end

% Initializacion of active or disable elements
% Green color - Active
handles.Active_Color = [120 170 50]/255;
% Gray color - Disable elements
handles.Disable_Color = [204 204 204]/255;


% Initialization of setting parameters
handles.TempFileDir = [];
handles.TempFileName = [];
handles.FieldFileDir = [];
handles.FieldFileName = [];

% For graphical representation purposes
handles.FileName = [];
handles.FileDir = [];

% Estimation of Current Generator Source Offset (I-V curves)
handles.DataFitN = [];
handles.DataFitS = [];
handles.OffsetX = [];
handles.OffsetY = [];

handles.Datos = [];
handles.DSA_TF_Data = [];
handles.DSA_Noise_Data = [];
handles.PXI_TF_Data = [];
handles.PXI_NoiseData = [];
handles.IVset = [];

handles.IVDelay = IV_Delay;
handles.IVDelay = handles.IVDelay.Constructor;
handles.IVDelay.OriginalRes = 5;
handles.IVDelay.MinRes = 1;

handles.BoptDelay = IV_Delay;
handles.BoptDelay = handles.BoptDelay.Constructor;

handles.ICDelay = IV_Delay;
handles.ICDelay = handles.ICDelay.Constructor;

handles = Menu_Generation(handles);  % Here, the constructor is applied
% After Constructor, all the values have to be defined in the guide

% Electronic Magnicon
handles.SQ_Source.Value = handles.Squid.SourceCH;
a = cellstr(handles.SQ_Rf.String);
for i = 1:length(a)
    a{i} = strtrim(a{i});
end

IndexC = strfind(a, num2str(handles.Squid.Rf.Value));
handles.SQ_Rf.Value = find(not(cellfun('isempty', IndexC)),1); %#ok<STRCL1>

% DSA

% PXI
handles.PXI.ConfStructs;
handles.PXI.WaveFormInfo;
handles.PXI.Options;

% Field Source

handles.CurSource_Vmax.String = num2str(handles.CurSour.Vmax.Value);
IndexC = strfind(cellstr(handles.CurSource_Vmax_Units.String), handles.CurSour.Vmax.Units);
handles.CurSource_Vmax_Units.Value = find(not(cellfun('isempty',IndexC)),1);
% handles.CurSource_Vmax_Units.Value = find(contains(cellstr(handles.CurSource_Vmax_Units.String),handles.CurSour.Vmax.Units)==1,1);

a_str = {'New Figure';'Open File';'Link Plot';'Hide Plot Tools';'Show Plot Tools and Dock Figure'};
for i = 1:length(a_str)
    eval(['a = findall(handles.FigureToolBar,''ToolTipString'',''' a_str{i} ''');']);
    a.Visible = 'off';
end


pause(0.5);

handles.EnableStr = {'off';'on'};
handles.DevStr = {'Multi';'Squid';'SpecAnal';'PXI';'CurSour'};
handles.DevStrOn = [1 1 1 1 1];

% Initialize connection of devices
for i = 1:size(handles.HndlStr,1)
    eval(['handles.' handles.HndlStr{i,1} ' = handles.Menu_' handles.HndlStr{i,1} '_sub(end).UserData;'])
    if eval(['handles.Devices.' handles.HndlStr{i,1} ' == 1;'])
        try
            eval(['handles.' handles.HndlStr{i,1} '= handles.' handles.HndlStr{i,1} '.Initialize;']);
            if isvalid(eval(['handles.' handles.HndlStr{i,1} '.ObjHandle']))
                handles.DevStrOn(i) = 1;
            else
                handles.DevStrOn(i) = 0;
            end
        catch
            eval(['handles.Devices.' handles.HndlStr{i,1} ' = 0;'])
            handles.DevStrOn(i) = 0;
        end
    end
end
handles = Menu_Update(handles.DevStrOn,handles);

% Generation of log file
handles.LogName = [pwd filesep 'Log_ZarTES ' datestr(now) '.txt'];
handles.LogName(strfind(handles.LogName(3:end),':')+2) = '-';
handles.LogFID = fopen(handles.LogName,'a+');
fprintf(handles.LogFID,['Session starts: ' datestr(now) '\n']);
handles.Position_old = handles.SetupTES.Position;
handles.SetupTES.UserData = handles.Position_old;

% Test and Loaded data to represent
handles.Draw_Select.String = {'I-V Curves';'Z(w)';'Noise';'Pulse';'R(T)s'};
handles.Draw_Select.Value = 1;
handles.IbiasRange = num2cell([500 -10 0]);
handles.FieldRange = num2cell([-1000 100 1000]);
handles.TestData.IVs = [];
handles.TestData.VField = [];
handles.TestData.Noise.DSA = {[]};
handles.TestData.Noise.PXI = {[]};
handles.TestData.TF.DSA = {[]};
handles.TestData.TF.PXI = {[]};
handles.TestData.Pulses = {[]};

handles.LoadData.IVs = [];
handles.LoadData.TF = {[]};
handles.LoadData.Noise = {[]};
handles.LoadData.Pulse = {[]};
handles.LoadData.RTs = {[]};

handles.SQ_Calibration.Value = 1;
SQ_Calibration_Callback(handles.SQ_Calibration, [], handles)



% Update handles structure
guidata(hObject, handles);
% UIWAIT makes SetupTEScontrolers wait for user response (see UIRESUME)
% uiwait(handles.SetupTES);

% --- Outputs from this function are returned to the command line.
function varargout = SetupTEScontrolers_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
set(handles.SetupTES,'ButtonDownFcn',{@SaveMenuGraph});
ax = handles.Result_Axes;
data = imread('athena-mission.jpg');
figure(handles.SetupTES);
image(data);
ax.Visible = 'off';
set(handles.SetupTES,'Visible','on');
handles.VersionStr = 'ZarTES v1.0';
waitfor(warndlg('Please, check the following circuit values',handles.VersionStr));
Obj_Properties(handles.Menu_Circuit);
guidata(hObject,handles);


%%%%%%%%%%%%%%%%%%%%%% OTHER FUNCTIONALITIES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles = Menu_Generation(handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization of classes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.Circuit = Circuit;
handles.Circuit = handles.Circuit.Constructor;
handles.menu(1) = uimenu('Parent',handles.SetupTES,'Label',...
    'Circuit');
handles.Menu_Circuit = uimenu('Parent',handles.menu(1),'Label',...
    'Circuit Properties','Callback',{@Obj_Properties},'UserData',handles.Circuit);
handles.Menu_Import_mN = uimenu('Parent',handles.menu(1),'Label',...
    'Update mN from file','Callback',{@mN_from_file},'UserData',handles.Circuit);
handles.Menu_Import_mS = uimenu('Parent',handles.menu(1),'Label',...
    'Update mS from file','Callback',{@mS_from_file},'UserData',handles.Circuit);
handles.Menu_RnRpar = uimenu('Parent',handles.menu(1),'Label',...
    'Update Rn and Rpar from (mN, mS)','Callback',{@RnRpar_from_mNmS},'UserData',handles.Circuit);
handles.Menu_Offset = uimenu('Parent',handles.menu(1),'Label',...
    'Estimate Current Offset','Callback',{@OffsetCurrent},'UserData',handles.Circuit);



handles.HndlStr(:,1) = {'Multi';'Squid';'CurSour';'DSA';'PXI'};
handles.HndlStr(:,2) = {'Multimeter';'ElectronicMagnicon';'CurrentSource';'SpectrumAnalyzer';'PXI_Acquisition_card'};

% instrreset;
% Menu is generated here
handles.menu(2) = uimenu('Parent',handles.SetupTES,'Label',...
    'Devices');

for i = 1:size(handles.HndlStr,1)
    eval(['handles.' handles.HndlStr{i,1} '=' handles.HndlStr{i,2} ';']);
    eval(['handles.' handles.HndlStr{i,1} '= handles.' handles.HndlStr{i,1} '.Constructor;']);
    eval(['handles.Devices.' handles.HndlStr{i,1} ' = 1;']); % By default all are activated
    eval(['handles.Menu_' handles.HndlStr{i,1} ' = uimenu(''Parent'',handles.menu(2),''Label'','...
        '[''&' handles.HndlStr{i,2} ''']);']);
    eval(['Mthds = methods(handles.' handles.HndlStr{i,1} ');']);
    jj = 1;
    % The firts menu is the one uses for initialize the device
    % connection
    eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ')  = uimenu(''Parent'',handles.Menu_' handles.HndlStr{i,1} ',''Label'','...
        ''' Initialize '',''Callback'',{@Obj_Actions},''UserData'',handles.' handles.HndlStr{i,1} ',''Separator'',''on'');']);
    jj = jj + 1;
    for j = 1:size(Mthds,1) %#ok<USENS>
        if isempty(cell2mat(strfind({'Constructor';'Destructor';'Initialize';handles.HndlStr{i,2}},Mthds{j})))
            eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ')  = uimenu(''Parent'',handles.Menu_' handles.HndlStr{i,1} ',''Label'','...
                '''' Mthds{j} ''',''Callback'',{@Obj_Actions},''UserData'',handles.' handles.HndlStr{i,1} ',''Enable'',''off'');']);
            jj = jj + 1;
        end
    end
    if ~strcmp(handles.HndlStr(:,1),'PXI')
        eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ') = uimenu(''Parent'',handles.Menu_' handles.HndlStr{i,1} ',''Label'','...
            '''' handles.HndlStr{i,2} ' Properties'',''Callback'',{@Obj_Properties},''UserData'',handles.' handles.HndlStr{i,1} ',''Separator'',''on'');']);
    else
        eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ') = uimenu(''Parent'',handles.Menu_' handles.HndlStr{i,1} ',''Label'','...
            '''' handles.HndlStr{i,2} ' Properties'',''Callback'',{@Conf_Setup_PXI},''UserData'',handles.' handles.HndlStr{i,1} ',''Separator'',''on'');']);
    end
    
end

%%%%%% Automatic Measurements
handles.menu(3) = uimenu('Parent',handles.SetupTES,'Label',...
    'Automatic Measurements');
handles.Menu_Auto_Meas_IV = uimenu('Parent',handles.menu(3),'Label',...
    'I-V parameters','Tag','I-V parameters','Callback',{@ChangeDelayParam},'Separator','on');
handles.Menu_Auto_Meas_Bopt = uimenu('Parent',handles.menu(3),'Label',...
    'B opt parameters','Tag','B opt parameters','Callback',{@ChangeDelayParam});
handles.Menu_Auto_Meas_IC = uimenu('Parent',handles.menu(3),'Label',...
    'Critical I parameters','Tag','Critical I parameters','Callback',{@ChangeDelayParam});


%%%%%%% Start Acquisition
handles.menu(4) = uimenu('Parent',handles.SetupTES,'Label',...
    'Acquisition');
handles.Menu_ACQ_Conf = uimenu('Parent',handles.menu(4),'Label',...
    'Configuration Panel','Callback',{@IbvaluesConf},'Separator','on');

handles.menu(5) = uimenu('Parent',handles.SetupTES,'Label',...
    'Help');
handles.Menu_Guide = uimenu('Parent',handles.menu(5),'Label',...
    'User Guide','Callback',{@UserGuide});
handles.Menu_About = uimenu('Parent',handles.menu(5),'Label',...
    'About','Callback',{@About});

function ChangeDelayParam(src,evnt)

handles = guidata(src);
switch src.Label
    case 'I-V parameters'  
        handles.IVDelay = handles.IVDelay.View(src.Label);        
        handles.Actions_Str.String = 'I-V Curve time slots have changed';        
    case 'B opt parameters'        
        handles.BoptDelay = handles.BoptDelay.View(src.Label);
        handles.Actions_Str.String = 'B opt time slots have changed';
    case 'Critical I parameters'
        handles.ICDelay = handles.ICDelay.View(src.Label);
        handles.Actions_Str.String = 'Critical I time slots have changed';        
end
Actions_Str_Callback(handles.Actions_Str,[],handles);
guidata(src,handles);

function UserGuide(src,evnt)
winopen('SetupTESControlers_UserGuide.pdf');

function About(src,evnt)
handles = guidata(src);
fig = figure('Visible','off','NumberTitle','off','Name',handles.VersionStr,'MenuBar','none','Units','Normalized');
ax = axes;
data = imread('ICMA-CSIC.jpg');
image(data)
ax.Visible = 'off';
fig.Position = [0.35 0.35 0.3 0.22];
fig.Visible = 'on';

function mN_from_file(src,evnt)
handles = guidata(src);
[filename, pathname] = uigetfile( ...
    {'*.txt', 'txt file '; ...
    '*.*',                   'All Files (*.*)'}, ...
    'Pick a I-V Curve file only Normal values ');
if isequal(filename,0) || isequal(pathname,0)
    disp('User pressed cancel')
else
    disp(['User selected ', fullfile(pathname, filename)])
end
IV = TES_IVCurveSet;
ind_i = strfind(filename,'mK_Rf');
ind_f = strfind(filename,'K_down_');
if isempty(ind_f)
    ind_f = strfind(filename,'K_up_');
end
pre_Rf = str2double(filename(ind_i+5:ind_f-1))*1000;
data = importdata([pathname filesep filename]);
if isstruct(data)
    data = data.data;
end
j = size(data,2);
switch j
    case 2
        Dibias = (data(:,1)-data(end,1))*1e-6;
        Dvout = data(:,4);
    case 4
        Dibias = data(:,2)*1e-6;
        Dvout = data(:,4);
end
IV.ibias = Dibias;
IV.vout = Dvout;
IV.file = filename;
IV.Tbath = sscanf(char(regexp(filename,'\d+.?\d+mK*','match')),'%fmK')*1e-3;
IV.IVsetPath = pathname;
IV.CorrectionMethod = 'Respect to Normal Curve';
IV.good = 1;

[DataFit,Xcros,Ycros,SlopeN,SlopeS] = IV.IV_estimation_mN_mS(IV.ibias,IV.vout);
mN = 1/SlopeN;
% Rn = (handles.Circuit.Rsh.Value*handles.Circuit.Rf.Value*handles.Circuit.invMf.Value/...
%     (mN*handles.Circuit.invMin.Value)-handles.Circuit.Rsh.Value-handles.Circuit.Rpar.Value);
% mN = 8;
% Rn = 6;
ButtonName = questdlg(['mN value is: ' num2str(mN) ', Do you want to update it?'], ...
    'Circuit Update', ...
    'Yes', 'No', 'Yes');
switch ButtonName
    case 'Yes'        
        handles.Circuit.mN.Value = mN;
        handles.Menu_Circuit.UserData = handles.Circuit;
        handles.DataFitN = DataFit;
end % switch
guidata(src.Parent.Parent,handles);

function mS_from_file(src,evnt)
handles = guidata(src);
[filename, pathname] = uigetfile( ...
    {'*.txt', 'txt file '; ...
    '*.*',                   'All Files (*.*)'}, ...
    'Pick a I-V Curve only Superconductor values ');
if isequal(filename,0) || isequal(pathname,0)
    disp('User pressed cancel')
else
    disp(['User selected ', fullfile(pathname, filename)])
end
IV = TES_IVCurveSet;
ind_i = strfind(filename,'mK_Rf');
ind_f = strfind(filename,'K_down_');
if isempty(ind_f)
    ind_f = strfind(filename,'K_up_');
end
pre_Rf = str2double(filename(ind_i+5:ind_f-1))*1000;
data = importdata([pathname filesep filename]);
if isstruct(data)
    data = data.data;
end
j = size(data,2);
switch j
    case 2
        Dibias = (data(:,1)-data(end,1))*1e-6;
        Dvout = data(:,4);
    case 4
        Dibias = data(:,2)*1e-6;
        Dvout = data(:,4);
end
IV.ibias = Dibias;
IV.vout = Dvout;
IV.file = filename;
IV.Tbath = sscanf(char(regexp(filename,'\d+.?\d+mK*','match')),'%fmK')*1e-3;
IV.IVsetPath = pathname;
IV.CorrectionMethod = 'Respect to Normal Curve';
IV.good = 1;

[DataFit,Xcros,Ycros,SlopeN,SlopeS] = IV.IV_estimation_mN_mS(IV.ibias,IV.vout);
mS = 1/SlopeS;
% Rn = (handles.Circuit.Rsh.Value*handles.Circuit.Rf.Value*handles.Circuit.invMf.Value/...
%     (mN*handles.Circuit.invMin.Value)-handles.Circuit.Rsh.Value-handles.Circuit.Rpar.Value);
% mN = 8;
% Rn = 6;
ButtonName = questdlg(['mS value is: ' num2str(mS) ', Do you want to update it?'], ...
    'Circuit Update', ...
    'Yes', 'No', 'Yes');
switch ButtonName
    case 'Yes'        
        handles.Circuit.mS.Value = mS;
        handles.Menu_Circuit.UserData = handles.Circuit;
        handles.DataFitS = DataFit;
end % switch
guidata(src.Parent.Parent,handles);

function RnRpar_from_mNmS(src,evnt)
handles = guidata(src);
Rpar = (handles.Circuit.Rf.Value*handles.Circuit.invMf.Value/(handles.Circuit.mS.Value*handles.Circuit.invMin.Value)-1)*handles.Circuit.Rsh.Value;
Rn = (handles.Circuit.Rsh.Value*handles.Circuit.Rf.Value*handles.Circuit.invMf.Value/(handles.Circuit.mN.Value*handles.Circuit.invMin.Value)-handles.Circuit.Rsh.Value-Rpar);
waitfor(msgbox(['IV curve estimated parameters: mN = '...
    num2str(handles.Circuit.mN.Value) '; mS = ' num2str(handles.Circuit.mS.Value)...
    '; Rn = ' num2str(Rn) ' Ohm; Rpar = ' num2str(Rpar) ' Ohm'],handles.VersionStr));

ButtonName = questdlg('Do you want to update Rn and Rpar values?',...
    handles.VersionStr, ...
    'Yes', 'No', 'Yes');
switch ButtonName
    case 'Yes'
        handles.Circuit.Rpar.Value = Rpar;
        handles.Circuit.Rn.Value = Rn;
        handles.Menu_Circuit.UserData = handles.Circuit;
end

guidata(src.Parent.Parent,handles);

function OffsetCurrent(src,evnt)
handles = guidata(src);
if isempty(handles.DataFitN)||isempty(handles.DataFitS)
    waitfor(warndlg('No data of normal or superconductor I-V curves were imported!',handles.VersionStr));
    return;
end
Xcros = (handles.DataFitN.PN(2)-handles.DataFitS.PS(2))/...
    (handles.DataFitS.PS(1)-handles.DataFitN.PN(1));
Ycros = handles.DataFitN.PN(1)*Xcros+handles.DataFitN.PN(2);
handles.OffsetX = Xcros;
handles.OffsetY = Ycros;
waitfor(msgbox(['Current Offset Point, Ibias = ' num2str(Xcros) ' uA, Vout = ' num2str(Ycros) ' V'],handles.VersionStr));

handles.Menu_Circuit.UserData = handles.Circuit;
guidata(src.Parent.Parent,handles);


function ACQ_Ibias(src,evnt)

handles = guidata(src);
waitfor(IbvaluesConf(src));
handles.Ibias = src.UserData;
guidata(src,handles)

function handles = Menu_Update(DevicesOn,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(DevicesOn)
    eval(['Mthds = methods(handles.' handles.HndlStr{i,1} ');']);
    jj = 2;
    for j = 1:size(Mthds,1) %#ok<USENS>
        if isempty(cell2mat(strfind({'Constructor';'Destructor';'Initialize';handles.HndlStr{i,2}},Mthds{j})))
            eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ').UserData = handles.' handles.HndlStr{i,1} ';']);
            if DevicesOn(i)
                eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ').Enable = ''on'';']);
            else
                eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ').Enable = ''off'';']);
            end
            jj = jj + 1;
        end
    end
    eval(['handles.Menu_' handles.HndlStr{i,1} '_sub(' num2str(jj) ').UserData = handles.' handles.HndlStr{i,1} ';']);
end

function Obj_Actions(src,evnt)
handles  = guidata(src);
if ~isempty(strfind(src.Label,'Initialize')) % Device are checked if they are initialize.  If so, they are not initialize again.
    Parent = evnt.Source.Parent.Label(2:end); % First character is reserved for &
    switch Parent
        case 'Multimeter'
            if ~isempty(handles.Multi.ObjHandle)
                return;
            else
                handles.Multi = handles.Multi.Initialize;
                handles.DevStrOn(1) = 1;
            end
        case 'ElectronicMagnicon'
            if ~isempty(handles.Squid.ObjHandle)
                return;
            else
                handles.Squid = handles.Squid.Initialize;
                handles.DevStrOn(2) = 1;
            end
        case 'SpectrumAnalyzer'
            if ~isempty(handles.DS.ObjHandle)
                return;
            else
                handles.DSA = handles.DSA.Initialize;
                handles.DevStrOn(3) = 1;
            end
        case 'PXI_Acquisition_card'
            if ~isempty(handles.PXI.ObjHandle)
                return;
            else
                handles.PXI = handles.PXI.Initialize;
                handles.DevStrOn(4) = 1;
            end
        case 'CurrentSource'
            if ~isempty(handles.CurSour.ObjHandle)
                return;
            else
                handles.CurSour = handles.CurSour.Initialize;
                handles.DevStrOn(5) = 1;
            end
            
        otherwise
    end
    handles = Menu_Update(handles.DevStrOn,handles);  % Sub_menus are now available.
else
    try
        eval(['[a, b] = src.UserData.' src.Label]);
    catch
        eval(['src.UserData.' src.Label]);
    end
end


guidata(src,handles);

function Edit_Protect(hObject)
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','1');
    end
else
    set(hObject,'String','1');
end

function Actions_Str_Callback(hObject, eventdata, handles)
warning off;
fprintf(handles.LogFID,[hObject.String '\n']);
warning on;
% --- Executes during object deletion, before destroying properties.
function SetupTES_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to SetupTES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Cerrar el archivo log creado en los cambios de String de Actions_Str.
try
    fprintf(handles.LogFID,['Session ends: ' datestr(now) '\n']);
    fclose(handles.LogFID);
    buttonquest = questdlg('Do you want to erase Log File?',handles.VersionStr,'Yes','No','No');
    switch buttonquest
        case 'Yes'
            delete(handles.LogName);
    end
catch
end
try
    handles.vi.Abort;
    stop(handles.timer);
catch
end
try
    stop(handles.timer_T);
end
delete(timerfind('Name','TEStimer'));
delete(timerfind('Name','T_TEStimer'));
try
    for i = 1:length(handles.DevStrOn)
        if handles.DevStrOn(i)
            try
                eval(['handles.' handles.HndlStr{i,1} '.Destructor;']);
            catch
            end
        end
    end
catch
end

try
    for i = 3:length(handles.d) % Los dos primeros son '.' y '..'
        if handles.d(i).isdir
            rmpath([handles.MainDir handles.d(i).name])
        end
    end
catch
end
% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Active_Color = [120 170 50]/255;
% Gray color - Disable elements
Disable_Color = [204 204 204]/255;
hObject.BackgroundColor = Disable_Color;
if hObject.Value
%     hObject.BackgroundColor = Active_Color;
    hObject.UserData = 1;
else
%     
    hObject.UserData = 0;
end
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%  RIGHT BUTTON GRAPH FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%

function SaveMenuGraph(src,evnt)
cmenu = uicontextmenu('Visible','on');
c = uimenu(cmenu,'Label','Save Graph','Callback',{@SaveGraph},'UserData',src);
set(src,'uicontextmenu',cmenu);

function SaveGraph(src,evnt)

Parent = src.UserData;
ha = findobj(Parent,'Type','Axes','Visible','on');
if ~isempty(ha)
    fg = figure;
    copyobj(ha,fg);
end


%%%%%%%%%%%%%%%%%%  ELECTRONIC MAGNICON FUNCTIONS  %%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in SQ_Source.
function SQ_Source_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns SQ_Source contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SQ_Source
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
else
    warndlg('Change this parameter consistently with the SQUID Device!',handles.VersionStr);
    handles.Squid.SourceCH = hObject.Value;
    handles.Actions_Str.String = ['Electronic Magnicon: Channel Source ' num2str(handles.Squid.SourceCH)];
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function SQ_Source_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in SQ_TES2NormalState.
function SQ_TES2NormalState_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_TES2NormalState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of SQ_TES2NormalState
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
else
    if hObject.Value
        hObject.BackgroundColor = handles.Active_Color;  % Green Color
        hObject.Enable = 'off';
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        
        if isequal(eventdata,-1)
            handles.Squid.TES2NormalState(eventdata);
            handles.SQ_Ibias_Units.Value = 3;
            handles.SQ_Ibias.String = '-500';
        else
            handles.Squid.TES2NormalState(1);
            handles.SQ_Ibias_Units.Value = 3;
            handles.SQ_Ibias.String = '500';
        end
        handles.SQ_Read_I.Value = 1;
        SQ_Read_I_Callback(handles.SQ_Read_I,[],handles);
        
        handles.Multi_Read.Value = 1;
        Multi_Read_Callback(handles.Multi_Read,[],handles);
        
        hObject.UserData = [];
        handles.Actions_Str.String = 'Electronic Magnicon: TES in Normal State';
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        pause(0.6);
        hObject.BackgroundColor = handles.Disable_Color;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end

% --- Executes on button press in SQ_Reset_Closed_Loop.
function SQ_Reset_Closed_Loop_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Reset_Closed_Loop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of SQ_Reset_Closed_Loop
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
else
    if hObject.Value
        hObject.BackgroundColor = handles.Active_Color;  % Green Color
        hObject.Enable = 'off';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        handles.Squid.ResetClossedLoop;
        handles.Actions_Str.String = 'Electronic Magnicon: Closed Loop Reset';
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        handles.Multi_Read.Value = 1;
        Multi_Read_Callback(handles.Multi_Read,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        pause(0.6);
        hObject.BackgroundColor = handles.Disable_Color;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end

% --- Executes on button press in SQ_Calibration.
function SQ_Calibration_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SQ_Calibration
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
else
    if hObject.Value
        hObject.BackgroundColor = handles.Active_Color;  % Green Color
        hObject.Enable = 'off';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        try
            content = cellstr(handles.SQ_Rf.String);
            newRf = str2double(content{handles.SQ_Rf.Value});
            handles.Squid.Rf.Value = newRf;
            handles.Squid = handles.Squid.Calibration;
            handles.SQ_Rf_real.String = num2str(handles.Squid.Rf.Value);
            handles.Circuit.Rf.Value = handles.Squid.Rf.Value;
            handles.Menu_Circuit.UserData = handles.Circuit;
            handles.Actions_Str.String = ['Electronic Magnicon: RF set at : ' num2str(handles.Circuit.Rf.Value) ' Ohms'];
            Actions_Str_Callback(handles.Actions_Str,[],handles);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            pause(0.2);
            hObject.BackgroundColor = handles.Disable_Color;
            hObject.Value = 0;
            hObject.Enable = 'on';
        catch
            hObject.BackgroundColor = handles.Disable_Color;
            hObject.Value = 0;
            hObject.Enable = 'on';
        end
        
    end
end
guidata(hObject,handles);

% --- Executes on button press in LNCS_Active.
function LNCS_Active_Callback(hObject, eventdata, handles)
% hObject    handle to LNCS_Active (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LNCS_Active

if hObject.Value
    handles.Squid.Set_Current_Value(0);
    handles.Squid.Connect_LNCS;
else
    handles.Squid.Set_Current_Value_LNCS(0);
    handles.Squid.Disconnect_LNCS;
end

guidata(hObject,handles);

% --- Executes on button press in SQ_Set_I.
function SQ_Set_I_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Set_I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of SQ_Set_I
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
else
    if hObject.Value
        hObject.BackgroundColor = handles.Active_Color;  % Green Color
        hObject.Enable = 'off';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        % Change to uA to ensure the correct units
        handles.SQ_Ibias_Units.Value = 3;
        SQ_Ibias_Units_Callback(handles.SQ_Ibias_Units,[],handles);
        Ibvalue = str2double(handles.SQ_Ibias.String);
        pause(0.3);
        
        if ~handles.LNCS_Active.Value
            if abs(Ibvalue) > 500
                warndlg('Value out of range (max I bias ±500 uA), select LNCS for greater current values',handles.VersionStr);
                hObject.BackgroundColor = handles.Disable_Color;
                hObject.Value = 0;
                hObject.Enable = 'on';
                return;
            else                
                handles.Squid.Set_Current_Value(Ibvalue)  % uA.
            end
        else            
            handles.Squid.Set_Current_Value_LNCS(Ibvalue);
        end
        
        handles.Actions_Str.String = ['Electronic Magnicon: I bias set to ' num2str(Ibvalue) ' uA'];
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        
        handles.SQ_Read_I.Value = 1;
        SQ_Read_I_Callback(handles.SQ_Read_I,[],handles);
        
        handles.Multi_Read.Value = 1;
        Multi_Read_Callback(handles.Multi_Read,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        hObject.BackgroundColor = handles.Disable_Color;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end

% --- Executes on button press in SQ_Read_I.
function SQ_Read_I_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Read_I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of SQ_Read_I
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
else
    if hObject.Value
        hObject.BackgroundColor = handles.Active_Color;  % Green Color
        hObject.Enable = 'off';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        if ~handles.LNCS_Active.Value
            Ireal = handles.Squid.Read_Current_Value;
        else
            Ireal = handles.Squid.Read_Current_Value_LNCS;
        end
        handles.SQ_realIbias.String = num2str(Ireal.Value);
        handles.SQ_realIbias_Units.Value = 3; % uA
        handles.Actions_Str.String = ['Electronic Magnicon: Measured I bias ' num2str(Ireal.Value) ' uA'];
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        
        Multi_Read_Callback(handles.Multi_Read, [], handles)
        
        % Update TestData.IVs
        handles.TestData.IVs = [handles.TestData.IVs; Ireal.Value str2double(handles.Multi_Value.String)];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        hObject.BackgroundColor = handles.Disable_Color;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end
guidata(hObject,handles);

function SQ_Ibias_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Ibias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SQ_Ibias as text
%        str2double(get(hObject,'String')) returns contents of SQ_Ibias as a double
value = str2double(hObject.String);
if ~isempty(value)&&~isnan(value)
else
    hObject.String = '40';
    handles.SQ_Ibias_Units.Value = 3;
end

contents = cellstr(get(handles.SQ_Ibias_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: I bias '...
    handles.SQ_Ibias.String ' ' contents{get(handles.SQ_Ibias_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_Ibias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Ibias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SQ_Ibias_Units.
function SQ_Ibias_Units_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Ibias_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns SQ_Ibias_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SQ_Ibias_Units
Ibias = str2double(handles.SQ_Ibias.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Ibias = Ibias/1e-06;
    case -1
        Ibias = Ibias/1e-03;
    case 0
        Ibias = Ibias/1;
    case 1
        Ibias = Ibias/1e03;
    case 2
        Ibias = Ibias/1e06;
end
handles.SQ_Ibias.String = num2str(Ibias);
hObject.UserData = NewValue;
contents = cellstr(get(handles.SQ_Ibias_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: I bias '...
    handles.SQ_Ibias.String ' ' contents{get(handles.SQ_Ibias_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_Ibias_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Ibias_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SQ_realIbias_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_realIbias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of SQ_realIbias as text
%        str2double(get(hObject,'String')) returns contents of SQ_realIbias as a double
Edit_Protect(hObject)
contents = cellstr(get(handles.SQ_realIbias_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: Measured I bias '...
    handles.SQ_realIbias.String ' ' contents{get(handles.SQ_realIbias_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_realIbias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_realIbias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SQ_realIbias_Units.
function SQ_realIbias_Units_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_realIbias_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns SQ_realIbias_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SQ_realIbias_Units
realIbias = str2double(handles.SQ_realIbias.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        realIbias = realIbias/1e-06;
    case -1
        realIbias = realIbias/1e-03;
    case 0
        realIbias = realIbias/1;
    case 1
        realIbias = realIbias/1e03;
    case 2
        realIbias = realIbias/1e06;
end
handles.SQ_realIbias.String = num2str(realIbias);
hObject.UserData = NewValue;
contents = cellstr(get(handles.SQ_realIbias_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: Measured I bias '...
    handles.SQ_realIbias.String ' ' contents{get(handles.SQ_realIbias_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_realIbias_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_realIbias_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function SQ_PhiB_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_PhiB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
%     hObject.Value = 0;
else
    
    %         hObject.BackgroundColor = handles.Active_Color;  % Green Color
    hObject.Enable = 'off';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Action of the device (including line)
    phib = hObject.Value;
    handles.SQ_PhiBStr.String = num2str(phib);
    try
        handles.Squid.Set_Phib(phib);
        Ireal = handles.Squid.Read_PhiB;
        handles.SQ_PhiBStr.String = num2str(Ireal.Value);
        handles.SQ_PhiB.Value = Ireal.Value;
    catch me
        disp(me);
    end
    handles.Actions_Str.String = ['Electronic Magnicon: PhiB changed to ' num2str(phib) ' uA'];
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %         hObject.BackgroundColor = handles.Disable_Color;
    %         hObject.Value = 0;
    hObject.Enable = 'on';
    
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function SQ_PhiB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_PhiB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% function SQ_PhiBStr_Callback(hObject, eventdata, handles)
% % hObject    handle to SQ_PhiBStr (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of SQ_PhiBStr as text
% %        str2double(get(hObject,'String')) returns contents of SQ_PhiBStr as a double
% 
% if isempty(handles.Squid.ObjHandle)
%     handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
%     Actions_Str_Callback(handles.Actions_Str,[],handles);
% %     hObject.Value = 0;
% else
%     
%     %         hObject.BackgroundColor = handles.Active_Color;  % Green Color
%     hObject.Enable = 'off';
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Action of the device (including line)    
%     phib = str2double(hObject.String);
%     
%     if phib < -124 || phib > 125
%         warndlg('Value out of range (PhiB [-124 125])',handles.VersionStr);        
%         hObject.String = '0';
%         handles.Actions_Str.String = 'Electronic Magnicon: PhiB does not change';
%         hObject.Enable = 'on';
%     else
%         
%         handles.SQ_PhiB.Value = phib;        
%         try
%             handles.Squid.Set_Phib(phib);
%             Ireal = handles.Squid.Read_PhiB;
%             handles.SQ_PhiBStr.String = num2str(Ireal.Value);
%             handles.SQ_PhiB.Value = Ireal.Value;
%         catch me
%             disp(me);
%         end
%         handles.Actions_Str.String = ['Electronic Magnicon: PhiB changed to ' num2str(phib) ' uA'];
%         Actions_Str_Callback(handles.Actions_Str,[],handles);
%         
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%         %         hObject.BackgroundColor = handles.Disable_Color;
%         %         hObject.Value = 0;
%         hObject.Enable = 'on';
%     end
%     
% end
% guidata(hObject,handles);
% 
% % --- Executes during object creation, after setting all properties.
% function SQ_PhiBStr_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to SQ_PhiBStr (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end

function SQ_Rf_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Rf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of SQ_Rf as text
%        str2double(get(hObject,'String')) returns contents of SQ_Rf as a double
% Edit_Protect(hObject)
try
    content = cellstr(handles.SQ_Rf.String);
    newRf = str2double(content{handles.SQ_Rf.Value});
    handles.Squid.Rf.Value = newRf;
    handles.Squid = handles.Squid.Calibration;
    handles.SQ_Rf_real.String = num2str(handles.Squid.Rf.Value);
    handles.Circuit.Rf.Value = handles.Squid.Rf.Value;
    handles.Menu_Circuit.UserData = handles.Circuit;
    handles.Actions_Str.String = ['Electronic Magnicon: RF set at : ' num2str(handles.Circuit.Rf.Value) ' Ohms'];
    Actions_Str_Callback(handles.Actions_Str,[],handles);
catch
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function SQ_Rf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Rf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
hObject.String = num2str([0 0.7 0.75 0.91 1 2.14 2.31 2.73 3.0 7.0 7.5 9.1 10 23.1 30 100]'*1e3);
hObject.Value = 5;

% --- Executes on selection change in SQ_Rf_Units.
function SQ_Rf_Units_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Rf_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns SQ_Rf_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SQ_Rf_Units
Rf = str2double(handles.SQ_Rf.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Rf = Rf/1e-06;
    case -1
        Rf = Rf/1e-03;
    case 0
        Rf = Rf/1;
    case 1
        Rf = Rf/1e03;
    case 2
        Rf = Rf/1e06;
end
handles.SQ_Rf.String = num2str(Rf);
hObject.UserData = NewValue;
contents = cellstr(get(handles.SQ_Rf_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: Rf '...
    handles.SQ_Rf.String ' ' contents{get(handles.Rf_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_Rf_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Rf_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SQ_Rf_real_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Rf_real (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of SQ_Rf_real as text
%        str2double(get(hObject,'String')) returns contents of SQ_Rf_real as a double

% --- Executes during object creation, after setting all properties.
function SQ_Rf_real_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Rf_real (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SQ_Rf_real_Units.
function SQ_Rf_real_Units_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Rf_real_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns SQ_Rf_real_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SQ_Rf_real_Units
Rf_real = str2double(handles.SQ_Rf_real.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        Rf_real = Rf_real/1e-06;
    case -1
        Rf_real = Rf_real/1e-03;
    case 0
        Rf_real = Rf_real/1;
    case 1
        Rf_real = Rf_real/1e03;
    case 2
        Rf_real = Rf_real/1e06;
end
handles.SQ_Rf_real.String = num2str(Rf_real);
hObject.UserData = NewValue;
contents = cellstr(get(handles.SQ_Rf_real_Units,'String'));
handles.Actions_Str.String = ['Electronic Magnicon: Measured Rf '...
    handles.SQ_Rf_real.String ' ' contents{get(handles.SQ_Rf_real_Units,'Value')}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function SQ_Rf_real_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Rf_real_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in SQ_RangeIbias.
function SQ_RangeIbias_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_RangeIbias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Llama a un pequeño gui para dar valor inicial, final y resolucion

hObject.UserData = [];
waitfor(Conf_Setup(hObject));
if ~isempty(hObject.UserData)
    handles.IbiasRange = hObject.UserData;
    guidata(hObject,handles);
end

% --- Executes on button press in Start_IVRange.
function Start_IVRange_Callback(hObject, eventdata, handles)
% hObject    handle to Start_IVRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
else
    if hObject.Value
        hObject.BackgroundColor = handles.Active_Color;  % Green Color
        hObject.Enable = 'off';
        
        if ~isempty(handles.TestData.IVs)
            ButtonName = questdlg('Do you want to erase current I-V Curve test values?', ...
                handles.VersionStr, ...
                'Yes', 'No', 'Yes');
            switch ButtonName
                case 'Yes'
                    handles.TestData.IVs = [];
            end % switch
        end
        
        if size(handles.IbiasRange,2) > 1
            for i = 1:size(handles.IbiasRange,1)
                if isnumeric(handles.IbiasRange{i,1})
                    Ibias{i} = handles.IbiasRange{i,1}:handles.IbiasRange{i,2}:handles.IbiasRange{i,3};
                elseif ischar(handles.IbiasRange{i,1})
                    Ibias{i} = str2double(handles.IbiasRange{i,1}):str2double(handles.IbiasRange{i,2}):str2double(handles.IbiasRange{i,3});
                end
            end
        else
            Ibias{1} = cell2mat(handles.IbiasRange);
        end
        vals = Ibias;
        clear Ibias;
        if median(sign(cell2mat(vals))) == 1
            Ibias{1} = sort(unique(cell2mat(vals)),'descend');
        else
            Ibias{1} = sort(unique(cell2mat(vals)),'ascend');
        end
        
        % Poner el valor en el sitio que le corresponde
        for i = 1:length(Ibias)            
            xlim(handles.Result_Axes,[min(Ibias{i}) max(Ibias{i})]);
            for j = 1:length(Ibias{i})
                hnd = guidata(hObject);
                if hnd.Stop.UserData == 1
                    handles.Stop.UserData = 0;
                    Stop_Callback(handles.Stop,[],handles);
                    break;
                end
                handles.SQ_Ibias.String = Ibias{i}(j);
                handles.SQ_Set_I.Value = 1;
                SQ_Set_I_Callback(handles.SQ_Set_I, [], handles);
                if i == 1 && j == 1
                    pause(handles.IVDelay.FirstDelay);  % FirstDelay
                end
                pause(handles.IVDelay.StepDelay); % StepDelay
                if ~handles.LNCS_Active.Value
                    Ireal = handles.Squid.Read_Current_Value;
                else
                    Ireal = handles.Squid.Read_Current_Value_LNCS;
                end
                [handles.Multi, vout] = handles.Multi.Read;
                handles.TestData.IVs = [handles.TestData.IVs; Ireal.Value vout.Value];
                
                
                clear Data
                % Dejamos esta parte para no superponer lineas repetidas
                % aunque esté seleccionado el Hold on
                HL = findobj(handles.Result_Axes,'Type','Line');
                delete(HL);
                Data(:,2) = handles.TestData.IVs(:,1);
                Data(:,4) = handles.TestData.IVs(:,2);
                DataName = '';
                ManagingData2Plot(Data,DataName,handles,hObject);
                
            end
            
            % I-V correction by forzing zero crossing
            try
            j = size(Data,2);
            switch j
                case 2
                    IVmeasure.ibias = Data(:,2)*1e-6;
                    if Data(1,1) == 0
                        IVmeasure.vout = Data(:,4)-Data(1,4);
                    else
                        IVmeasure.vout = Data(:,4)-Data(end,4);
                    end
                case 4
                    IVmeasure.ibias = Data(:,2)*1e-6;
                    if Data(1,2) == 0
                        IVmeasure.vout = Data(:,4)-Data(1,4);
                    else
                        IVmeasure.vout = Data(:,4)-Data(end,4);
                    end
            end
            val = polyfit(IVmeasure.ibias(1:3),IVmeasure.vout(1:3),1); % First points avoided
            mN = val(1);
            val = polyfit(IVmeasure.ibias(end-2:end),IVmeasure.vout(end-2:end),1);
            mS = val(1);
            
            waitfor(msgbox(['IV curve estimated parameters: mN = '...
                num2str(mN) '; mS = ' num2str(mS) '; Rn = ' num2str(Rn) '; Rpar = ' num2str(Rpar)'],hangles.VersionStr));
            
            ButtonName = questdlg(['Do you want to update mN value extracted from IV curve: mN = ' num2str(mN)], ...
                handles.VersionStr, ...
                'Yes', 'No', 'Yes');
            switch ButtonName
                case 'Yes'
                    handles.Circuit.mN.Value = mN;
%                     handles.Circuit.Rn.Value = Rn;
            end
            ButtonName = questdlg(['Do you want to update mS value extracted from IV curve: mS = ' num2str(mS)], ...
                handles.VersionStr, ...
                'Yes', 'No', 'Yes');
            switch ButtonName
                case 'Yes'
                    handles.Circuit.mS.Value = mS;
%                     handles.Circuit.Rpar.Value = Rpar;
            end
            
            ButtonName = questdlg('Do you want to update Rn and Rpar value extracted from IV curve?', ...
                handles.VersionStr, ...
                'Yes', 'No', 'Yes');
            switch ButtonName
                case 'Yes'
                    Rpar = (handles.Circuit.Rf.Value*handles.Circuit.invMf.Value/(mS*handles.Circuit.invMin.Value)-1)*handles.Circuit.Rsh.Value;
                    Rn = (handles.Circuit.Rsh.Value*handles.Circuit.Rf.Value*handles.Circuit.invMf.Value/(mN*handles.Circuit.invMin.Value)-handles.Circuit.Rsh.Value-Rpar);
                    handles.Circuit.Rpar.Value = Rpar;
                    handles.Circuit.Rn.Value = Rn;
%                     handles.Circuit.Rpar.Value = Rpar;
            end                                              
            handles.Menu_Circuit.UserData = handles.Circuit;
            Obj_Properties(handles.Menu_Circuit);
            TESDATA.circuit = TES_Circuit;
            TESDATA.circuit = TESDATA.circuit.Update(handles.Circuit);
            IVCurveSet = TES_IVCurveSet;
            IVCurveSet = IVCurveSet.Update(IVmeasure);
            TESDATA.TESThermal.n.Value = [];
            TESDATA.TESParam.Rn.Value = Rn;
            TESDATA.TESParam.Rpar.Value = Rpar;
            
            handles.IVset = IVCurveSet.GetIVTES(TESDATA.circuit,TESDATA.TESParam,TESDATA.TESThermal);
            handles.IVset.Tbath = handles.vi_IGHFrontPanel.GetControlValue('M/C');
            
            set([handles.SQ_SetRnBias handles.SQ_Rn],'Enable','on')
            
%             ButtonName = questdlg(['Do you want to update Circuit values from the ones extracted from IV curve: mN = '...
%                 num2str(mN) '; mS = ' num2str(mS) '; Rn = ' num2str(Rn) '; Rpar = ' num2str(Rpar)], ...
%                 handles.VersionStr, ...
%                 'Yes', 'No', 'Yes');
%             switch ButtonName
%                 case 'Yes'
%                     handles.Circuit.mN.Value = mN;
%                     handles.Circuit.mS.Value = mS;
%                     handles.Circuit.Rpar.Value = Rpar;
%                     handles.Circuit.Rn.Value = Rn;
%                     handles.Menu_Circuit.UserData = handles.Circuit;
%                     Obj_Properties(handles.Menu_Circuit);
%                     TESDATA.circuit = TES_Circuit;
%                     TESDATA.circuit = TESDATA.circuit.Update(handles.Circuit);
%                     IVCurveSet = TES_IVCurveSet;
%                     IVCurveSet = IVCurveSet.Update(IVmeasure);
%                     TESDATA.TESThermal.n.Value = [];
%                     TESDATA.TESParam.Rn.Value = Rn;
%                     TESDATA.TESParam.Rpar.Value = Rpar;
%                     
%                     handles.IVset = IVCurveSet.GetIVTES(TESDATA.circuit,TESDATA.TESParam,TESDATA.TESThermal);
%                     handles.IVset.Tbath = handles.vi_IGHFrontPanel.GetControlValue('M/C');
%                     
%                     
%             end % switch                        
            
                        
            ButtonName = questdlg('Do you want to store the IV-Curve for further analysis?',handles.VersionStr,...
                'Yes','No','Yes');
            switch ButtonName
                case 'Yes'
                    TMC = num2str(str2double(handles.MCTemp.String)*1e3,'%1.1f');
                    if mode(sign(Ibias{1})) < 0
                        filename = [TMC ,'mK_Rf' num2str(handles.Circuit.Rf.Value*1e-3,'%1.0f') '_down_n_matlab'];
                    else
                        filename = [TMC ,'mK_Rf' num2str(handles.Circuit.Rf.Value*1e-3,'%1.0f') '_down_p_matlab'];
                    end
                    
                    [filename, pathname] = uiputfile( ...
                        {[filename '.txt']}, ...
                        'Save as');
                    if ~isequal(pathname,0)
                        Data(:,4) = Data(:,4)-Data(end,4);
                        save([pathname filename],'Data','-ascii')
                    end
                    
                otherwise
%                     if isempty(handles.IVset)
%                         handles.SQ_Rn.Enable = 'off';
%                     end
                    break;
            end
            
            
            end
            
            guidata(hObject,handles);

        end
        pause(0.6);
        hObject.BackgroundColor = handles.Disable_Color;
        hObject.Value = 0;
        hObject.Enable = 'on';
    else
        hObject.BackgroundColor = handles.Disable_Color;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
        Actions_Str_Callback(handles.Actions_Str,[],handles);
    end
end
guidata(hObject,handles);

% --- Executes on button press in SQ_SetRnBias.
function SQ_SetRnBias_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_SetRnBias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
else
    if hObject.Value
        hObject.BackgroundColor = handles.Active_Color;  % Green Color
        hObject.Enable = 'off';
        
        handles.SQ_TES2NormalState.Value = 1;
        SQ_TES2NormalState_Callback(handles.SQ_TES2NormalState,[],handles);
        
        handles.SQ_Closed_Loop.Value = 1;
        SQ_Reset_Closed_Loop_Callback(handles.SQ_Reset_Closed_Loop,[],handles);
        
        handles.SQ_Ibias_Units.Value = 3;
        SQ_Ibias_Units_Callback(handles.SQ_Ibias_Units,[],handles);
        SQ_Rn_Callback(handles.SQ_Rn,[],handles);
        handles.SQ_Ibias.String = handles.SQ_Rn_Ibias.String;
        Ibvalue = str2double(handles.SQ_Ibias.String);
        pause(0.3);
        
        if ~handles.LNCS_Active.Value
            handles.Squid.Set_Current_Value(Ibvalue)  % uA.
        else
            handles.Squid.Set_Current_Value_LNCS(Ibvalue);
        end
        
        handles.Actions_Str.String = ['Electronic Magnicon: I bias set to ' num2str(Ibvalue) ' uA'];
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        
        handles.SQ_Read_I.Value = 1;
        SQ_Read_I_Callback(handles.SQ_Read_I,[],handles);
        
        handles.Multi_Read.Value = 1;
        Multi_Read_Callback(handles.Multi_Read,[],handles);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        hObject.BackgroundColor = handles.Disable_Color;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end


function SQ_Rn_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Rn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SQ_Rn as text
%        str2double(get(hObject,'String')) returns contents of SQ_Rn as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if (value < 0|| value > 1)
        set(hObject,'String','0.5');
    end
else
    set(hObject,'String','0.5');
end

if ~isempty(handles.IVset)
    if abs(handles.IVset.Tbath-str2double(handles.MCTemp.String)) < 0.002        
        
        Ibias = BuildIbiasFromRp(handles.IVset,str2double(handles.SQ_Rn.String));  %%%%%%
        handles.SQ_Rn_Ibias.String = num2str(Ibias);
        handles.SQ_SetRnBias.Enable = 'on';
        
    else
        handles.SQ_SetRnBias.Enable = 'off';
        warndlg('Not available for the current Mixing Chamber Temperature. To enable please acquire an IV curve.',handles.VersionStr);        
    end    
else
    handles.SQ_SetRnBias.Enable = 'off';
end

% --- Executes during object creation, after setting all properties.
function SQ_Rn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Rn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SQ_Rn_Ibias_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_Rn_Ibias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes during object creation, after setting all properties.

function SQ_Rn_Ibias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_Rn_Ibias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Squid_Pulse_Input.
function Squid_Pulse_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Squid_Pulse_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Squid_Pulse_Input
if isempty(handles.Squid.ObjHandle)
    handles.Actions_Str.String = 'Electronic Magnicon Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
else
    if hObject.Value
        hObject.BackgroundColor = handles.Active_Color;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        % Pulse Configuration Mode
        % Pulse On
        
        status = handles.Squid.Cal_Pulse_ON;
        if strcmp(status,'OK')
            handles.Actions_Str.String = 'Electronic Magnicon: PULSE MODE ON';
            Actions_Str_Callback(handles.Actions_Str,[],handles);
        else
            hObject.BackgroundColor = handles.Disable_Color;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            handles.Actions_Str.String = 'Electronic Magnicon: Unsuccessful read: A timeout occurred before the Terminator was reached.';
            Actions_Str_Callback(handles.Actions_Str,[],handles);
        end
    else
        hObject.BackgroundColor = handles.Disable_Color;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        % Pulse Off
        status = handles.Squid.Cal_Pulse_OFF;
        if strcmp(status,'OK')
            handles.Actions_Str.String = 'Electronic Magnicon: PULSE MODE OFF';
            Actions_Str_Callback(handles.Actions_Str,[],handles);
        else
            hObject.BackgroundColor = handles.Disable_Color;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            handles.Actions_Str.String = 'Electronic Magnicon: Unsuccessful read: A timeout occurred before the Terminator was reached.';
            Actions_Str_Callback(handles.Actions_Str,[],handles);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

% --- Executes on button press in Squid_Pulse_Input_Conf.
function Squid_Pulse_Input_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to Squid_Pulse_Input_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject.UserData = [];
waitfor(Conf_Setup(hObject,[],handles));
if ~isempty(hObject.UserData)
    handles.Squid.PulseAmp.Value = hObject.UserData{1,2};
    handles.Squid.PulseDT.Value = hObject.UserData{2,2};
    handles.Squid.PulseDuration.Value = hObject.UserData{3,2};
    handles.Squid.RL.Value = hObject.UserData{4,2};
    handles.Actions_Str.String = 'Electronic Magnicon: Configuration Pulse Input Mode changed';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    guidata(hObject,handles);
end

%%%%%%%%%%%%%%%%%%  FIELD SETUP FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in CurSource_OnOff.
function CurSource_OnOff_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_OnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of CurSource_OnOff
if isempty(handles.CurSour.ObjHandle)
    handles.Actions_Str.String = 'Current Source Connection for Field Setup is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
else
    if hObject.Value
        hObject.BackgroundColor = handles.Active_Color;
        %         handles.CurSource_OnOff.String = 'ON';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        handles.CurSour.CurrentSource_Start;
        handles.Actions_Str.String = 'Current Source: Output ON';
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    else
        hObject.BackgroundColor = handles.Disable_Color;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        handles.CurSour.CurrentSource_Stop;
        handles.Actions_Str.String = 'Current Source: Output OFF';
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
end

% --- Executes on button press in CurSource_Set_I.
function CurSource_Set_I_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_Set_I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of CurSource_Set_I
if isempty(handles.CurSour.ObjHandle)
    handles.Actions_Str.String = 'Current Source Connection for Field Setup is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
else
    if hObject.Value
        hObject.BackgroundColor = handles.Active_Color;  % Green Color
        hObject.Enable = 'off';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        handles.CurSource_I_Units.Value = 1;  % Data is given in Amp
        CurSource_I_Units_Callback(handles.CurSource_I_Units,[],handles);
        I.Value = str2double(handles.CurSource_I.String);
        I.Units = 'A';
        if abs(I.Value) > 0.007 % handles.CurSource.Imax.Value % 5 mA
            h = msgbox('Current value exceeds security range of 5mA', ...
                handles.VersionStr);
            tic;
            t = toc;
            while 10-t > 0
                t = toc;
            end
            if ishandle(h)
                close(h);
            end
            handles.CurSour = handles.CurSour.SetIntensity(I);
        else
            handles.CurSour = handles.CurSour.SetIntensity(I);
        end
        handles.Actions_Str.String = ['Current Source: I value set to ' num2str(I.Value) ' A'];
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        hObject.BackgroundColor = handles.Disable_Color;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end


function CurSource_I_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of CurSource_I as text
%        str2double(get(hObject,'String')) returns contents of CurSource_I as a double
value = str2double(get(hObject,'String'));
Units = handles.CurSource_I_Units.Value;

if ~isempty(value)&&~isnan(value)
    if ((value > 0.005)&&(Units == 1))||((value > 5)&&(Units == 2))||((value > 5000)&&(Units == 3))
        hObject.String = '0';
        handles.CurSource_I_Units.Value = 2;
        CurSource_I_Callback(hObject, [], handles)
    end
else
    hObject.String = '0';
    handles.CurSource_I_Units.Value = 2;
    CurSource_I_Callback(hObject, [], handles)
end
contents = cellstr(handles.CurSource_I_Units.String);
handles.Actions_Str.String = ['Current Source: ' num2str(handles.CurSource_I.String) ' ' contents{handles.CurSource_I_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function CurSource_I_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurSource_I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in CurSource_I_Units.
function CurSource_I_Units_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_I_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns CurSource_I_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CurSource_I_Units
I_value = str2double(handles.CurSource_I.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        I_value = I_value/1e-06;
    case -1
        I_value = I_value/1e-03;
    case 0
        I_value = I_value/1;
    case 1
        I_value = I_value/1e03;
    case 2
        I_value = I_value/1e06;
end
handles.CurSource_I.String = num2str(I_value);
hObject.UserData = NewValue;
contents = cellstr(handles.CurSource_I_Units.String);
handles.Actions_Str.String = ['Current Source: I value ' num2str(handles.CurSource_I.String) ' ' contents{handles.CurSource_I_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function CurSource_I_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurSource_I_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in CurSource_Cal.
function CurSource_Cal_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_Cal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of CurSource_Cal
if isempty(handles.CurSour.ObjHandle)
    handles.Actions_Str.String = 'Current Source Connection for Field Setup is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
else
    if hObject.Value
        hObject.BackgroundColor = handles.Active_Color;  % Green Color
        hObject.Enable = 'off';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        handles.CurSource_Vmax_Units.Value = 1;
        CurSource_Vmax_Units_Callback(handles.CurSource_Vmax_Units,[],handles);
        handles.CurSour.Vmax.Value = str2double(handles.CurSource_Vmax.String);
        handles.CurSour.Vmax.Units = 'V';
        
        handles.CurSour.Calibration;
        handles.Actions_Str.String = ['Current Source: Vmax ' num2str(handles.CurSour.Vmax.Value) ' V'];
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        hObject.BackgroundColor = handles.Disable_Color;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end


function CurSource_Vmax_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_Vmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of CurSource_Vmax as text
%        str2double(get(hObject,'String')) returns contents of CurSource_Vmax as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','50');
        handles.CurSource_Vmax_Units.Value = 1;
        CurSource_Vmax_Callback(hObject, [], handles)
    end
else
    set(hObject,'String','50');
    handles.CurSource_Vmax_Units.Value = 1;
    CurSource_Vmax_Callback(hObject, [], handles)
end
contents = cellstr(handles.CurSource_Vmax_Units.String);
handles.Actions_Str.String = ['Current Source: Vmax ' num2str(handles.CurSource_Vmax.String) ' ' contents{handles.CurSource_Vmax_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function CurSource_Vmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurSource_Vmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in CurSource_Vmax_Units.
function CurSource_Vmax_Units_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_Vmax_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns CurSource_Vmax_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CurSource_Vmax_Units
V_max = str2double(handles.CurSource_Vmax.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        V_max = V_max/1e-06;
    case -1
        V_max = V_max/1e-03;
    case 0
        V_max = V_max/1;
    case 1
        V_max = V_max/1e03;
    case 2
        V_max = V_max/1e06;
end
handles.CurSource_Vmax.String = num2str(V_max);
hObject.UserData = NewValue;
contents = cellstr(handles.CurSource_Vmax_Units.String);
handles.Actions_Str.String = ['Current Source: Vmax ' num2str(handles.CurSource_Vmax.String) ' ' contents{handles.CurSource_Vmax_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes during object creation, after setting all properties.
function CurSource_Vmax_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurSource_Vmax_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in CurSource_Range.
function CurSource_Range_Callback(hObject, eventdata, handles)
% hObject    handle to CurSource_Range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject.UserData = [];
waitfor(Conf_Setup(hObject));
if ~isempty(hObject.UserData)
    handles.FieldRange = hObject.UserData;
    guidata(hObject,handles);
end

% --- Executes on button press in Start_FieldRange.
function Start_FieldRange_Callback(hObject, eventdata, handles)
% hObject    handle to Start_FieldRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.CurSour.ObjHandle)
    handles.Actions_Str.String = 'Current Source K220 Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
else
    if hObject.Value
        hObject.BackgroundColor = handles.Active_Color;  % Green Color
        hObject.Enable = 'off';
        
        handles.SQ_Reset_Closed_Loop.Value = 1;
        SQ_Reset_Closed_Loop_Callback(handles.SQ_Reset_Closed_Loop,[],handles);
                
        if size(handles.FieldRange,2) > 1
            for i = 1:size(handles.FieldRange,1)
                if isnumeric(handles.FieldRange{i,1})
                    FieldValues{i} = handles.FieldRange{i,1}:handles.FieldRange{i,2}:handles.FieldRange{i,3};
                elseif ischar(handles.FieldRange{i,1})
                    FieldValues{i} = str2double(handles.FieldRange{i,1}):str2double(handles.FieldRange{i,2}):str2double(handles.FieldRange{i,3});
                end
            end
        else
            FieldValues{1} = cell2mat(handles.FieldRange);
        end
%         vals = FieldValues;
%         clear FieldValues;
%         FieldValues{1} = sort(unique(cell2mat(vals)),'ascend');
        
        if ~isempty(handles.TestData.VField)
            ButtonName = questdlg('Do you want to erase current Field Scan?', ...
                handles.VersionStr, ...
                'Yes', 'No', 'Yes');
            switch ButtonName
                case 'Yes'
                    handles.TestData.VField = [];
                    cla(handles.Result_Axes);
            end % switch
        end
        
        % Poner el valor en el sitio que le corresponde
        % Se activa la salida de la fuente de intensidad
        handles.CurSource_OnOff.Value = 1;
        CurSource_OnOff_Callback(handles.CurSource_OnOff,[],handles);
        
        set([handles.Result_Axes1 handles.Result_Axes2 handles.Result_Axes3],'Visible','off');
        
        for i = 1:length(FieldValues)
            hnd = guidata(handles.Stop);
            if hnd.Stop.UserData == 1
                handles.Stop.UserData = 0;
                Stop_Callback(handles.Stop,[],handles);
                break;
            end
            xlim(handles.Result_Axes,[min(FieldValues{i}) max(FieldValues{i})]);
            for j = 1:length(FieldValues{i})
                
                handles.CurSource_I.String = FieldValues{i}(j)*1e-6;
                handles.CurSource_I_Units.Value = 1;
                CurSource_I_Units_Callback(handles.CurSource_I_Units,[],handles);
                
                handles.CurSource_Set_I.Value = 1;
                CurSource_Set_I_Callback(handles.CurSource_Set_I, [], handles);
                if i == 1 && j == 1
                    pause(handles.BoptDelay.FirstDelay);
                end
                pause(handles.BoptDelay.StepDelay)
                averages = 1;
                for i_av = 1:averages
                    handles.Multi_Read.Value = 1;
                    Multi_Read_Callback(handles.Multi_Read,[],handles);
                    aux1{i_av} = str2double(handles.Multi_Value.String);
                    if i_av == averages
                        vout = mean(cell2mat(aux1));
                    end
                end
                handles.TestData.VField = [handles.TestData.VField; FieldValues{i}(j) vout];
                
                clear Data
                HL = findobj(handles.Result_Axes,'Type','Line');
                delete(HL);
                Data(:,2) = handles.TestData.VField(:,1);
                Data(:,5) = handles.TestData.VField(:,2);
                DataName = '';
                ManagingData2Plot(Data,DataName,handles,hObject)
                % Tendríamos que pintar los valores cada vez que se están
                % registrando.
                
            end
        end        
        
        handles.CurSource_OnOff.Value = 0;
        CurSource_OnOff_Callback(handles.CurSource_OnOff,[],handles);
        
        try
            ButtonName = questdlg('Do you want to save the current Field Scan?',handles.VersionStr,...
                'Yes','No','Yes');
            switch ButtonName
                case 'Yes'
                    TMC = num2str(str2double(handles.MCTemp.String)*1e3,'%1.1f');
                    Ibias = handles.SQ_realIbias.String;
                    
                    filename = ['BVScan_' TMC ,'mK_Ibias' Ibias ];
                    
                    [filename, pathname] = uiputfile( ...
                        {[filename '.txt']}, ...
                        'Save as');
                    if ~isequal(pathname,0)
                        save([pathname filename],'Data','-ascii')
                    end
                    
                otherwise
            end
        end
        
        pause(0.6);
        hObject.BackgroundColor = handles.Disable_Color;
        hObject.Value = 0;
        hObject.Enable = 'on';
    else
        hObject.BackgroundColor = handles.Disable_Color;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        handles.Actions_Str.String = 'Current Source K220 Connection is missed. Check connection and initialize it from the MENU.';
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        
    end
end
guidata(hObject,handles);

% --- Executes on button press in IC_Range.
function IC_Range_Callback(hObject, eventdata, handles)
% hObject    handle to IC_Range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.Result_Axes);
hold(handles.Result_Axes,'on');
xlabel(handles.Result_Axes,'Bfield(\muA)');
ylabel(handles.Result_Axes,'Ibias(\muA)');
set(handles.Result_Axes,'LineWidth',2,'FontSize',12,'FontWeight','bold','XScale','linear','YScale','linear',...
                'XTickLabelMode','auto','XTickMode','auto');
if size(handles.FieldRange,2) > 1
    for i = 1:size(handles.FieldRange,1)
        if isnumeric(handles.FieldRange{i,1})
            FieldValues{i} = handles.FieldRange{i,1}:handles.FieldRange{i,2}:handles.FieldRange{i,3};
        elseif ischar(handles.FieldRange{i,1})
            FieldValues{i} = str2double(handles.FieldRange{i,1}):str2double(handles.FieldRange{i,2}):str2double(handles.FieldRange{i,3});
        end
    end
else
    FieldValues{1} = cell2mat(handles.FieldRange);
end
vals = FieldValues;
clear FieldValues;
FieldValues{1} = sort(unique(cell2mat(vals)),'ascend');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% (Codigo Carlos) %%%%%%%%%%%%%%%%%%

% Ponemos el valor de corriente en la fuente
handles.CurSource_I_Units.Value = 1;
handles.CurSource_I.String = num2str(FieldValues{1}(1)*1e-6);  % Se pasan las corrientes en amperios
handles.CurSource_Set_I.Value = 1;
CurSource_Set_I_Callback(handles.CurSource_Set_I,[],handles);
handles.CurSource_OnOff.Value = 1;
CurSource_OnOff_Callback(handles.CurSource_OnOff,[],handles);

pause(handles.ICDelay.FirstDelay);

handles.SQ_Reset_Closed_Loop.Value = 1;
SQ_Reset_Closed_Loop_Callback(handles.SQ_Reset_Closed_Loop,[],handles);

step_ini = 10;
step = step_ini;

for i = 1:length(FieldValues{1})
    
    hnd = guidata(handles.SetupTES);
    if hnd.Stop.UserData == 1
        handles.Stop.UserData = 0;
        Stop_Callback(handles.Stop,[],handles);
        break;
    end
    
    handles.CurSource_I_Units.Value = 1;
    handles.CurSource_I.String = num2str(FieldValues{1}(i)*1e-6);  % Se pasan las corrientes en amperios
    handles.CurSource_Set_I.Value = 1;
    CurSource_Set_I_Callback(handles.CurSource_Set_I,[],handles);
    pause(handles.ICDelay.StepDelay);
    
    if i < 4
        i0 = [1 1];
    else
        mmp = (ICpairs(i-1).p-ICpairs(i-3).p)/(FieldValues{1}(i-1)-FieldValues{1}(i-3));
        mmn = (ICpairs(i-1).n-ICpairs(i-3).n)/(FieldValues{1}(i-1)-FieldValues{1}(i-3));
        icnext_p = ICpairs(i-1).p + mmp*(FieldValues{1}(i)-FieldValues{1}(i-1));
        icnext_n = ICpairs(i-1).n + mmn*(FieldValues{1}(i)-FieldValues{1}(i-1));
        ic0_p = 0.9*icnext_p;
        ic0_n = 0.9*icnext_n;
        tempvalues = 0:step:500;%%%array de barrido en corriente
        ind_p = find(tempvalues <= abs(ic0_p));
        ind_n = find(tempvalues <= abs(ic0_n));
        try
            i0 = [ind_p(end) ind_n(end)];%%%Calculamos el índice que corresponde a la corriente para empezar el barrido
        catch
            i0 = [1 1];
        end
    end
    try
        aux = measure_IC_Pair_autom(step,i0,FieldValues{1}(i),handles);
        ICpairs(i).p = aux.p;
        ICpairs(i).n = aux.n;
        ICpairs(i).B = FieldValues{1}(i);
        step = max(step_ini,aux.p/20);%por si es cero.
    catch
%         pause(1);
        ICpairs(i).p = nan;
        ICpairs(i).n = nan;
        ICpairs(i).B = FieldValues{1}(i);
        %continue;
    end
    hf = findobj(handles.Result_Axes,'DisplayName','Final_Temporal');
    delete(hf);
    plot(handles.Result_Axes,FieldValues{1}(1:i),[ICpairs.p],'ro-',FieldValues{1}(1:i),[ICpairs.n],'ro-','DisplayName','Final');
    
end

handles.CurSource_I_Units.Value = 1;
handles.CurSource_I.String = num2str(0*1e-6);  % Se pasan las corrientes en amperios
handles.CurSource_Set_I.Value = 1;
CurSource_Set_I_Callback(handles.CurSource_Set_I,[],handles);
handles.CurSource_OnOff.Value = 0;
CurSource_OnOff_Callback(handles.CurSource_OnOff,[],handles);

try
    Temp = str2double(handles.MCTemp.String);
    button = questdlg('Do you want to store this Critical Current plot?',handles.VersionStr,'Yes','No','Yes');
    switch button
        case 'Yes'
            FileStr = ['ICpairs' num2str(Temp*1e3,'%1.1f'), 'mK'];
            [FileStr, pathname] = uiputfile( ...
                {[FileStr '.txt']}, ...
                'Save as');
            if ~isequal(pathname,0)
                Data(:,1) = [ICpairs.B];
                Data(:,2) = [ICpairs.p];
                Data(:,3) = [ICpairs.n];
                save([pathname FileStr],'Data','-ascii')
                uisave('ICpairs',[pathname filesep FileStr(1:end-4)]);
            end
            if ~isequal(folder_name,0)
                
                msgbox(['File named ' FileStr 'was saved'],handles.VersionStr);
            else
                warndlg('No path was selected',handles.VersionStr);
            end
        otherwise
    end
end
guidata(hObject,handles);


function ICpair = measure_IC_Pair_autom(step,i0,B,handles)

Ivalues = 0:step:500;
Rf = handles.Circuit.Rf.Value;
THR = 1;

for jj = 1:2 % barrido positivo y negativo
    
    if jj == 2
        Ivalues = -Ivalues;
        IV = [];
    end
    
    handles.SQ_Reset_Closed_Loop.Value = 1;
    SQ_Reset_Closed_Loop_Callback(handles.SQ_Reset_Closed_Loop,[],handles);
    
    % Set Ibias to zero value in order to impose TES's Superconductor State
    handles.SQ_Ibias_Units.Value = 3;
    handles.SQ_Ibias.String = num2str(Ivalues(1));
    handles.SQ_Set_I.Value = 1;
    SQ_Set_I_Callback(handles.SQ_Set_I, [],handles);
    
    a = handles.Squid.Read_Current_Value;
    IV.ic(1) = a.Value;
    pause(1);
    [~, v] = handles.Multi.Read;
    IV.vc(1) = v.Value;
    vout1 = IV.vc(1);
           
    DataName = 'Temporal';
    plot(handles.Result_Axes,B,IV.ic(1),'bo-','DisplayName',DataName);
    
    for i = i0(jj)+1:length(Ivalues)
        % Set Ibias to zero value in order to impose TES's Superconductor State
        handles.SQ_Ibias_Units.Value = 3;
        handles.SQ_Ibias.String = num2str(Ivalues(i));
        handles.SQ_Set_I.Value = 1;
        SQ_Set_I_Callback(handles.SQ_Set_I, [], handles);
        pause(0.5);
        a = handles.Squid.Read_Current_Value;
        IV.ic(i) = a.Value;
        [~, v] = handles.Multi.Read;
        IV.vc(i) = v.Value;
        vout2 = IV.vc(i);
        
        DataName = 'Temporal';
        plot(handles.Result_Axes,B,IV.ic(i),'bo-','DisplayName',DataName);
        
        slope = (vout2 -vout1)/((Ivalues(i)-Ivalues(i-1))*1e-6)/Rf;
        if slope < THR
            break;
        end
        vout1 = vout2;
    end
    % Set Ibias to zero value in order to impose TES's Superconductor State
    handles.SQ_Ibias_Units.Value = 3;
    handles.SQ_Ibias.String = num2str(0);
    handles.SQ_Set_I.Value = 1;
    SQ_Set_I_Callback(handles.SQ_Set_I, [], handles);
    
    if jj == 1
        ICpair.p = IV.ic(end-1);
        
    elseif jj == 2
        ICpair.n = IV.ic(end-1);            
    end
    HL = findobj(handles.Result_Axes,'DisplayName','Temporal');
    delete(HL);
    plot(handles.Result_Axes,B,IV.ic(end-1),'ro-','DisplayName','Final_Temporal');
end



%%%%%%%%%%%%%%%%%%  MULTIMETER FUNCTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in Multi_Read.
function Multi_Read_Callback(hObject, eventdata, handles)
% hObject    handle to Multi_Read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Multi_Read
if ~isvalid(handles.Multi.ObjHandle)
    handles.Actions_Str.String = 'Multimeter Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
else
    if hObject.Value
        hObject.BackgroundColor = handles.Active_Color;  % Green Color
        hObject.Enable = 'off';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        [handles.Multi, Vdc] = handles.Multi.Read;  % The output is in Volts.
        handles.Multi_Value.String = num2str(Vdc.Value);
        handles.Actions_Str.String = ['Multimeter: Voltage ' num2str(Vdc.Value) ' V'];
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        hObject.BackgroundColor = handles.Disable_Color;
        hObject.Value = 0;
        hObject.Enable = 'on';
    end
end
guidata(hObject,handles);


function Multi_Value_Callback(hObject, eventdata, handles)
% hObject    handle to Multi_Value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of Multi_Value as text
%        str2double(get(hObject,'String')) returns contents of Multi_Value as a double

% --- Executes during object creation, after setting all properties.
function Multi_Value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Multi_Value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%%%%%%%%%%%%%%%%%%  DIGITAL SIGNAL ANALYZER FUNCTIONS  %%%%%%%%%%%%%%%%%%%%

function DSA_Input_Amp_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_Input_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of DSA_Input_Amp as text
%        str2double(get(hObject,'String')) returns contents of DSA_Input_Amp as a double
value = str2double(get(hObject,'String'));
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

contents1 = cellstr(handles.DSA_Input_Amp_Units.String);
contents2 = cellstr(handles.DSA_Input_Freq_Units.String);
handles.Actions_Str.String = ['Digital Signal Analyzer HP3562A: TF Mode Sine  Amp '...
    handles.DSA_Input_Amp.String ' ' contents1{handles.DSA_Input_Amp_Units.Value} ' Freq ' ...
    handles.DSA_Input_Freq.String ' ' contents2{handles.DSA_Input_Freq_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

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
    Amp = 5;
end
handles.DSA_Input_Amp.String = num2str(Amp);
hObject.UserData = NewValue;
contents1 = cellstr(handles.DSA_Input_Amp_Units.String);
contents2 = cellstr(handles.DSA_Input_Freq_Units.String);
handles.Actions_Str.String = ['Digital Signal Analyzer HP3562A: TF Mode Sine  Amp '...
    handles.DSA_Input_Amp.String ' ' contents1{handles.DSA_Input_Amp_Units.Value} ' Freq ' ...
    handles.DSA_Input_Freq.String ' ' contents2{handles.DSA_Input_Freq_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

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
contents1 = cellstr(handles.DSA_Input_Amp_Units.String);
contents2 = cellstr(handles.DSA_Input_Freq_Units.String);
handles.Actions_Str.String = ['Digital Signal Analyzer HP3562A: TF Mode Sine  Amp '...
    handles.DSA_Input_Amp.String ' ' contents1{handles.DSA_Input_Amp_Units.Value} ' Freq ' ...
    handles.DSA_Input_Freq.String ' ' contents2{handles.DSA_Input_Freq_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

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
contents1 = cellstr(handles.DSA_Input_Amp_Units.String);
contents2 = cellstr(handles.DSA_Input_Freq_Units.String);
handles.Actions_Str.String = ['Digital Signal Analyzer HP3562A: TF Mode Sine  Amp '...
    handles.DSA_Input_Amp.String ' ' contents1{handles.DSA_Input_Amp_Units.Value} ' Freq ' ...
    handles.DSA_Input_Freq.String ' ' contents2{handles.DSA_Input_Freq_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

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

% --- Executes on button press in DSA_TF_Zw_Conf.
function DSA_TF_Zw_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_TF_Zw_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

waitfor(Conf_Setup(hObject,handles.DSA_TF_Zw_Menu.Value,handles));
handles.Actions_Str.String = 'Digital Signal Analyzer: Configuration changes in TF Mode';
Actions_Str_Callback(handles.Actions_Str,[],handles);
DSA_TF_Zw_Menu_Callback(handles.DSA_TF_Zw_Menu,[],handles);

% --- Executes on selection change in DSA_TF_Zw_Menu.
function DSA_TF_Zw_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_TF_Zw_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns DSA_TF_Zw_Menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DSA_TF_Zw_Menu
switch hObject.Value
    case 1
        Srch = strfind(handles.DSA.Config.SSine,'SRLV ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        handles.DSA_Input_Amp_Units.Value = 2;
        Str = handles.DSA.Config.SSine{Srch == 1};
        handles.DSA_Input_Amp.String = Str(strfind(Str,'SRLV ')+5:end-2);
        
        set([handles.DSA_Input_Freq handles.DSA_Input_Freq_Units],'Enable','off');
        
    case 2
        Srch = strfind(handles.DSA.Config.FSine,'SRLV ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        handles.DSA_Input_Amp_Units.Value = 2;
        Str = handles.DSA.Config.FSine{Srch == 1};
        handles.DSA_Input_Amp.String = Str(strfind(Str,'SRLV ')+5:end-2);
        
        Srch = strfind(handles.DSA.Config.FSine,'FSIN ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        handles.DSA_Input_Freq_Units.Value = 1;
        Str = handles.DSA.Config.FSine{Srch == 1};
        handles.DSA_Input_Freq.String = Str(strfind(Str,'FSIN ')+5:end-2);
        
        set([handles.DSA_Input_Amp handles.DSA_Input_Amp_Units ...
            handles.DSA_Input_Freq handles.DSA_Input_Freq_Units],'Enable','on');
    case 3
        Srch = strfind(handles.DSA.Config.WNoise,'SRLV ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        handles.DSA_Input_Amp_Units.Value = 2;
        Str = handles.DSA.Config.WNoise{Srch == 1};
        handles.DSA_Input_Amp.String = Str(strfind(Str,'SRLV ')+5:end-2);
        set([handles.DSA_Input_Freq handles.DSA_Input_Freq_Units],'Enable','off');
end

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

% --- Executes on button press in DSA_TF_Noise_Conf.
function DSA_TF_Noise_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_TF_Noise_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
waitfor(Conf_Setup(hObject,[],handles));
if ~isempty(hObject.UserData)
    handles.Actions_Str.String = 'Digital Signal Analyzer: Configuration changes in TF Mode';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    guidata(hObject,handles);
end

% --- Executes on button press in DSA_TF_Noise_Read.
function DSA_TF_Noise_Read_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_TF_Noise_Read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (isempty(handles.DSA.ObjHandle))
    handles.Actions_Str.String = 'Digital Signal Analyzer HP3562A Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
end

if hObject.Value
    hObject.BackgroundColor = handles.Active_Color;  % Green Color
    hObject.Enable = 'off';
    pause(0.1);
    if isempty(handles.Circuit.Rf.Value)
        SQ_Rf_Callback(handles.SQ_Rf,[],handles);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Action of the device (including line)
    
    handles.DSA = handles.DSA.NoiseMode;
    [handles.DSA, datos] = handles.DSA.Read;
    handles.DSA_Noise_Data = datos;
    
    if ~isempty(handles.DSA_Noise_Data)
        if isempty(handles.TestData.Noise.DSA{1})
            handles.TestData.Noise.DSA{1} = handles.DSA_Noise_Data;
        else
            if ~isnumeric(eventdata)
                ButtonName = questdlg('Do you want to erase current Noise (DSA) test values?', ...
                    handles.VersionStr, ...
                    'Yes', 'No', 'Yes');
                switch ButtonName
                    case 'Yes'
                        handles.TestData.Noise.DSA = {[]};
                end % switch
            end
            handles.TestData.Noise.DSA{length(handles.TestData.Noise.DSA)+1} = handles.DSA_Noise_Data;
        end
    end
    
    clear Data;
    
    DataName = ' ';
    Data(:,1) = handles.TestData.Noise.DSA{end}(:,1);
    Data(:,2) = handles.TestData.Noise.DSA{end}(:,2);
    ManagingData2Plot(Data,DataName,handles,hObject);
    
    ButtonName = questdlg('Do you want to save current Noise (DSA) test values?', ...
        handles.VersionStr, ...
        'Yes', 'No', 'Yes');
    switch ButtonName
        case 'Yes'
            Itxt = handles.SQ_realIbias.String;
            filename = strcat('HP_noise_',Itxt,'uA','.txt');            
            [filename, pathname] = uiputfile('*.txt','Save current noise acquisition',filename);
            if isequal(filename,0) || isequal(pathname,0)
                waitfor(warndlg('User pressed cancel',handles.VersionStr));
            else
                save([pathname filename],'datos','-ascii');%salva los datos a fichero.
            end
    end % swit
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hObject.BackgroundColor = handles.Disable_Color;
    hObject.Value = 0;
    hObject.Enable = 'on';
end

% --- Executes on button press in DSA_TF_Zw_Read.
function DSA_TF_Zw_Read_Callback(hObject, eventdata, handles)
% hObject    handle to DSA_TF_Zw_Read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (isempty(handles.DSA.ObjHandle))
    handles.Actions_Str.String = 'Digital Signal Analyzer HP3562A Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
end

if hObject.Value
    hObject.BackgroundColor = handles.Active_Color;  % Green Color
    hObject.Enable = 'off';
    pause(0.1);
    if isempty(handles.Circuit.Rf.Value)
        SQ_Rf_Callback(handles.SQ_Rf,[],handles);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Action of the device (including line)
    
    switch handles.DSA_TF_Zw_Menu.Value
        case 1 % Sweept sine
            if handles.DSA_Input_Amp_Units.Value ~= 4
                handles.DSA_Input_Amp_Units.Value = 2;  % mV
                DSA_Input_Amp_Callback(handles.DSA_Input_Amp,[],handles);
                Amp = str2double(handles.DSA_Input_Amp.String);
            else
                Amp = (1/100)*str2double(handles.DSA_Input_Amp.String)*1e1*str2double(handles.SQ_realIbias.String);
            end
            handles.DSA = handles.DSA.SineSweeptMode(Amp);
        case 2 % Fixed sine
            handles.DSA_Input_Freq_Units.Value = 1;  % Hz
            DSA_Input_Freq_Callback(handles.DSA_Input_Freq,[],handles);
            Freq = str2double(handles.DSA_Input_Freq.String);
            handles.DSA_Input_Amp_Units.Value = 2;  % mV
            DSA_Input_Amp_Callback(handles.DSA_Input_Amp,[],handles);
            Amp = str2double(handles.DSA_Input_Amp.String);
            handles.DSA = handles.DSA.FixedSine(Amp,Freq);
            %         case 3 % White noise
            %             if handles.DSA_Input_Amp_Units.Value ~= 4
            %                 handles.DSA_Input_Amp_Units.Value = 2;  % mV
            %                 DSA_Input_Amp_Callback(handles.DSA_Input_Amp,[],handles);
            %                 Amp = str2double(handles.DSA_Input_Amp.String);
            %             else
            %                 Amp = str2double(handles.DSA_Input_Amp.String)*1e1*str2double(handles.SQ_realIbias.String);
            %             end
            %             handles.DSA = handles.DSA.WhiteNoise(Amp);
            
    end
    handles.Actions_Str.String = 'Digital Signal Analyzer HP3562A: TF Mode ON';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    
    [handles.DSA, datos] = handles.DSA.Read;
    handles.DSA_TF_Data = datos;
    
    if ~isempty(handles.DSA_TF_Data)
        if isempty(handles.TestData.TF.DSA{1})
            handles.TestData.TF.DSA{1} = handles.DSA_TF_Data;
        else
            if ~isnumeric(eventdata)
                ButtonName = questdlg('Do you want to erase current TF (DSA) test values?', ...
                    handles.VersionStr, ...
                    'Yes', 'No', 'Yes');
                switch ButtonName
                    case 'Yes'
                        handles.TestData.TF.DSA = {[]};
                end % switch
            end
            handles.TestData.TF.DSA{length(handles.TestData.TF.DSA)+1} = handles.DSA_TF_Data;
        end
    end
    
    DataName = ' ';
    Data(:,1) = handles.TestData.TF.DSA{end}(:,1);
    Data(:,2) = handles.TestData.TF.DSA{end}(:,2);
    Data(:,3) = handles.TestData.TF.DSA{end}(:,3);
    ManagingData2Plot(Data,DataName,handles,hObject)
    
    ButtonName = questdlg('Do you want to save current TF (DSA) test values?', ...
        handles.VersionStr, ...
        'Yes', 'No', 'Yes');
    switch ButtonName
        case 'Yes'
            Itxt = handles.SQ_realIbias.String;
            filename = strcat('TF_',Itxt,'uA','.txt');            
            [filename, pathname] = uiputfile('*.txt','Save current TF acquisition',filename);
            if isequal(filename,0) || isequal(pathname,0)
                waitfor(warndlg('User pressed cancel',handles.VersionStr));
            else
                save([pathname filename],'datos','-ascii');%salva los datos a fichero.
            end
    end % swit
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hObject.BackgroundColor = handles.Disable_Color;
    hObject.Value = 0;
    hObject.Enable = 'on';
end




%%%%%%%%%%%%%%%%%%  PXI ACQUISITION CARD FUNCTIONS  %%%%%%%%%%%%%%%%%%%%%%%


function PXI_Input_Amp_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Input_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of PXI_Input_Amp as text
%        str2double(get(hObject,'String')) returns contents of PXI_Input_Amp as a double
value = str2double(get(hObject,'String'));
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
contents = cellstr(handles.PXI_Input_Amp_Units.String);
handles.Actions_Str.String = ['Digital Signal Analyzer HP3562A: Noise Mode  Amp '...
    handles.PXI_Input_Amp.String ' ' contents{handles.PXI_Input_Amp_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

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
    Amp = 5;
end
handles.PXI_Input_Amp.String = num2str(Amp);
hObject.UserData = NewValue;
contents = cellstr(handles.PXI_Input_Amp_Units.String);
handles.Actions_Str.String = ['PXI: TF Z(w) - Mode  Amp '...
    handles.PXI_Input_Amp.String ' ' contents{handles.PXI_Input_Amp_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

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
contents1 = cellstr(handles.PXI_Input_Amp_Units.String);
contents2 = cellstr(handles.PXI_Input_Freq_Units.String);
handles.Actions_Str.String = ['PXI: TF - Z(w): Mode Sine  Amp '...
    handles.PXI_Input_Amp.String ' ' contents1{handles.PXI_Input_Amp_Units.Value} ' Freq ' ...
    handles.PXI_Input_Freq.String ' ' contents2{handles.PXI_Input_Freq_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

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
contents1 = cellstr(handles.PXI_Input_Amp_Units.String);
contents2 = cellstr(handles.PXI_Input_Freq_Units.String);
handles.Actions_Str.String = ['PXI: TF Mode Sine  Amp '...
    handles.PXI_Input_Amp.String ' ' contents1{handles.PXI_Input_Amp_Units.Value} ' Freq ' ...
    handles.PXI_Input_Freq.String ' ' contents2{handles.PXI_Input_Freq_Units.Value}];
Actions_Str_Callback(handles.Actions_Str,[],handles);

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

% --- Executes on button press in PXI_TF_Zw_Conf.
function PXI_TF_Zw_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_TF_Zw_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hObject.UserData = [];
waitfor(Conf_Setup_PXI(hObject,handles.PXI_TF_Zw_Menu.Value,handles));
if ~isempty(hObject.UserData)
    handles.PXI.ConfStructs = hObject.UserData;    
    guidata(hObject,handles);
end
handles.Actions_Str.String = 'PXI: Configuration changes in Noise Mode';
Actions_Str_Callback(handles.Actions_Str,[],handles);

% --- Executes on selection change in PXI_TF_Zw_Menu.
function PXI_TF_Zw_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_TF_Zw_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns PXI_TF_Zw_Menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PXI_TF_Zw_Menu
if hObject.Value == 1
    set([handles.PXI_Input_Amp handles.PXI_Input_Amp_Units],'Enable','on');
else
    set([handles.PXI_Input_Amp handles.PXI_Input_Amp_Units],'Enable','on');
end

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

% --- Executes on button press in PXI_TF_Zw_Read.
function PXI_TF_Zw_Read_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_TF_Zw_Read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (isempty(handles.PXI.ObjHandle))
    handles.Actions_Str.String = 'PXI Acquisition Card Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
end

if hObject.Value
    hObject.BackgroundColor = handles.Active_Color;  % Green Color
    hObject.Enable = 'off';
    pause(0.1);
    if isempty(handles.Circuit.Rf.Value)
        SQ_Rf_Callback(handles.SQ_Rf,[],handles);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Action of the device (including line)
    handles.PXI.AbortAcquisition;
    handles.PXI=handles.PXI.TF_Configuration;
    
    handles.Actions_Str.String = 'PXI Acquisition Card: TF Mode ON';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    
    if handles.PXI_Input_Amp_Units.Value == 4 % Porcentaje de Ibias
        % Devuelve el valor siempre en uA
        excitacion = str2double(handles.SQ_realIbias.String)*1e1*str2double(handles.PXI_Input_Amp.String)/100;
    else
        handles.PXI_Input_Amp_Units.Value = 2;
        excitacion = str2double(handles.PXI_Input_Amp.String);
    end
    try
%         
        handles.DSA.WhiteNoise(excitacion);
%         pause(0.4);
        handles.DSA.SourceOn;
%         pause(1);
    catch
        warndlg('External Source is not connected',handles.VersionStr);
        hObject.BackgroundColor = handles.Disable_Color;
        hObject.Value = 0;
        hObject.Enable = 'on';
        return;
    end
    
    [data, ~] = handles.PXI.Get_Wave_Form;
    
    sk = skewness(data);
    while abs(sk(3)) > handles.PXI.Options.Skewness
        [data,~] = handles.PXI.Get_Wave_Form;
        sk = skewness(data);
    end
    [txy, freqs] = tfestimate(data(:,2),data(:,3),[],[],2^14,handles.PXI.ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR
    n_avg = handles.PXI.Options.NAvg;
    for i = 1:n_avg-1
        [data,~] = handles.PXI.Get_Wave_Form;
        sk = skewness(data);
        while abs(sk(3)) > handles.PXI.Options.Skewness
            [data,~] = handles.PXI.Get_Wave_Form;
            sk = skewness(data);
        end
        aux = tfestimate(data(:,2),data(:,3),[],[],2^14,handles.PXI.ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR);%%%,[],[],128,ConfStructs.Horizontal.SR
        txy = txy+aux;
    end
    txy = txy/n_avg;
    txy = medfilt1(txy,40);
    
    handles.PXI_TF_Data = data;
    handles.PXI_TF_DataXY = [freqs real(txy) imag(txy)];
    handles.DSA.SourceOff;
    
    
    if ~isempty(handles.PXI_TF_Data)
        if isempty(handles.TestData.TF.PXI{1})
            handles.TestData.TF.PXI{1} = handles.PXI_TF_Data;
        else
            if ~isnumeric(eventdata)
                ButtonName = questdlg('Do you want to erase current TF (PXI) test values?', ...
                    handles.VersionStr, ...
                    'Yes', 'No', 'Yes');
                switch ButtonName
                    case 'Yes'
                        handles.TestData.TF.PXI = {[]};
                end % switch
            end
            handles.TestData.TF.PXI{length(handles.TestData.TF.PXI)+1} = handles.PXI_TF_Data;
        end
        
        
        DataName = ' ';
        Data{1} = handles.TestData.TF.PXI{end}(:,1);
        Data{2} = handles.TestData.TF.PXI{end}(:,2);
        Data{3} = handles.TestData.TF.PXI{end}(:,3);
        Data{4} = handles.PXI_TF_DataXY(:,1);
        Data{5} = handles.PXI_TF_DataXY(:,2);
        Data{6} = handles.PXI_TF_DataXY(:,3);
        ManagingData2Plot(Data,DataName,handles,hObject)
        
        ButtonName = questdlg('Do you want to save current TF (PXI) test values?', ...
            handles.VersionStr, ...
            'Yes', 'No', 'Yes');
        switch ButtonName
            case 'Yes'
                Itxt = handles.SQ_realIbias.String;
                filename = strcat('PXI_TF_',Itxt,'uA','.txt');
                [filename, pathname] = uiputfile('*.txt','Save current TF acquisition',filename);
                if isequal(filename,0) || isequal(pathname,0)
                    waitfor(warndlg('User pressed cancel',handles.VersionStr));
                else
                    datos = handles.PXI_TF_DataXY;
                    save([pathname filename],'datos','-ascii');%salva los datos a fichero.
                end
        end % swit
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hObject.BackgroundColor = handles.Disable_Color;
    hObject.Value = 0;
    hObject.Enable = 'on';
end

% --- Executes on button press in PXI_TF_Noise_Conf.
function PXI_TF_Noise_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_TF_Noise_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
waitfor(Conf_Setup_PXI(hObject,[],handles));
if ~isempty(hObject.UserData)
    handles.PXI.ConfStructs = hObject.UserData;
    handles.Actions_Str.String = 'PXI Acquisition Card: Configuration changes';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    guidata(hObject,handles);
end

% --- Executes on button press in PXI_TF_Noise_Read.
function PXI_TF_Noise_Read_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_TF_Noise_Read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (isempty(handles.PXI.ObjHandle))
    handles.Actions_Str.String = 'PXI Acquisition Card Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
end

if hObject.Value
    hObject.BackgroundColor = handles.Active_Color;  % Green Color
    hObject.Enable = 'off';
    pause(0.1);
    if isempty(handles.Circuit.Rf.Value)
        SQ_Rf_Callback(handles.SQ_Rf,[],handles);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Action of the device (including line)
    handles.PXI.AbortAcquisition;
    handles.PXI = handles.PXI.Noise_Configuration;
    handles.Actions_Str.String = 'PXI Acquisition Card: Noise Mode ON';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    
    [data, WfmI] = handles.PXI.Get_Wave_Form;
    [psd,freq] = PSD(data);
    clear datos;
    datos(:,1) = freq;
    datos(:,2) = sqrt(psd);
    n_avg = handles.PXI.Options.NAvg;
    for jj = 1:n_avg-1%%%Ya hemos adquirido una.
        [data, WfmI] = handles.PXI.Get_Wave_Form;
        [psd,freq] = PSD(data);
        aux(:,1) = freq;
        aux(:,2) = sqrt(psd);
        datos(:,2) = datos(:,2)+aux(:,2);
    end
    datos(:,2) = datos(:,2)/n_avg;
    handles.PXI_Noise_Data = datos;
    
    if ~isempty(handles.PXI_Noise_Data)
        if isempty(handles.TestData.Noise.PXI{1})
            handles.TestData.Noise.PXI{1} = handles.PXI_Noise_Data;
        else
            if ~isnumeric(eventdata)
                ButtonName = questdlg('Do you want to erase current Noise (PXI) test values?', ...
                    handles.VersionStr, ...
                    'Yes', 'No', 'Yes');
                switch ButtonName
                    case 'Yes'
                        handles.TestData.Noise.PXI = {[]};
                end % switch
            end
            handles.TestData.Noise.PXI{length(handles.TestData.Noise.PXI)+1} = handles.PXI_Noise_Data;
        end
        
        clear Data;
        DataName = ' ';
        Data(:,1) = handles.TestData.Noise.PXI{end}(:,1);
        Data(:,2) = handles.TestData.Noise.PXI{end}(:,2);
        
        ManagingData2Plot(Data,DataName,handles,hObject)
        
        ButtonName = questdlg('Do you want to save current Noise (PXI) test values?', ...
            handles.VersionStr, ...
            'Yes', 'No', 'Yes');
        switch ButtonName
            case 'Yes'
                Itxt = handles.SQ_realIbias.String;
                filename = strcat('PXI_noise_',Itxt,'uA','.txt');
                [filename, pathname] = uiputfile('*.txt','Save current Noise acquisition',filename);
                if isequal(filename,0) || isequal(pathname,0)
                    waitfor(warndlg('User pressed cancel',handles.VersionStr));
                else                    
                    save([pathname filename],'datos','-ascii');%salva los datos a fichero.
                end
        end % swit
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hObject.BackgroundColor = handles.Disable_Color;
    hObject.Value = 0;
    hObject.Enable = 'on';
end

% --- Executes on button press in PXI_Pulse_Read.
function PXI_Pulse_Read_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Pulse_Read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.PXI.ObjHandle)
    handles.Actions_Str.String = 'PXI Acquisition Card Connection is missed. Check connection and initialize it from the MENU.';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    hObject.Value = 0;
else
    if hObject.Value
        hObject.BackgroundColor = handles.Active_Color;  % Green Color
        hObject.Enable = 'off';
        pause(0.05);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Action of the device (including line)
        
        handles.PXI.AbortAcquisition;
        handles.PXI = handles.PXI.Pulses_Configuration;
        warning off;
        set(get(handles.PXI.ObjHandle,'triggering'),'trigger_source','NISCOPE_VAL_EXTERNAL');
        [data, WfmI, TimeLapsed] = handles.PXI.Get_Wave_Form;   % Las adquisiciones se guardan en una variable TestData.Pulses
        
        %         actualSR = get(get(handles.PXI.ObjHandle,'horizontal'),'Actual_Sample_Rate');
        
        if ~TimeLapsed
            
            ManagingData2Plot(data,'',handles,hObject);
            
            handles.Actions_Str.String = 'PXI Acquisition Card: Acquisition of pulse system response';
            Actions_Str_Callback(handles.Actions_Str,[],handles);
            
            % Updated TestData.Pulses
            if isempty(handles.TestData.Pulses{1})
                handles.TestData.Pulses{1} = data;
            else
                handles.TestData.Pulses{length(handles.TestData.Pulses)} = data;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            pause(0.5);
        else
            warndlg('No Data for Acquisition was found, change Trigger Settings',handles.VersionStr);
        end
        hObject.BackgroundColor = handles.Disable_Color;
        hObject.Value = 0;
        hObject.Enable = 'on';
        
    end
end

% --- Executes on button press in PXI_Pulse_Conf.
function PXI_Pulse_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to PXI_Pulse_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
waitfor(Conf_Setup_PXI(hObject,handles.PXI_TF_Zw_Menu.Value,handles));
if ~isempty(hObject.UserData)
    handles.PXI.ConfStructs = hObject.UserData;
    handles.Actions_Str.String = 'PXI Acquisition Card: Configuration changes';
    Actions_Str_Callback(handles.Actions_Str,[],handles);
    guidata(hObject,handles);
end

% --- Executes on button press in Pulse_Cont.
function Pulse_Cont_Callback(hObject, eventdata, handles)
% hObject    handle to Pulse_Cont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Pulse_Cont

hObject.UserData = hObject.Value;
hObject.BackgroundColor = handles.Active_Color;
while hObject.UserData
    pause(0.2)
    handles.PXI_Pulse_Read.Value = 1;
    PXI_Pulse_Read_Callback(handles.PXI_Pulse_Read,[],handles);
end
hObject.BackgroundColor = handles.Disable_Color;

% --- Executes on button press in SavePulses.
function SavePulses_Callback(hObject, eventdata, handles)
% hObject    handle to SavePulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warning off;
AQ_dir = uigetdir(pwd, 'Select a path for storing acquisition data');
if ~ischar(AQ_dir)
    return;
end

Ncounts = str2double(handles.NPulses.String);

for i = 1:Ncounts
    pause(0.2)
    handles.Pulse_Counter.String = ['# ' num2str(i)];
    Itxt = handles.SQ_realIbias.String;
    handles.PXI.AbortAcquisition;
    handles.PXI = handles.PXI.Pulses_Configuration;
    
    set(get(handles.PXI.ObjHandle,'triggering'),'trigger_source','NISCOPE_VAL_EXTERNAL');
    [datos, WfmI, TimeLapsed] = handles.PXI.Get_Wave_Form;
    
    if ~TimeLapsed
        ManagingData2Plot(datos,'',handles,hObject);
    end
    
    % Guardamos los datos en un fichero
    file = strcat('PXI_Pulso_',num2str(i),'_',Itxt,'uA','.txt');
    save([AQ_dir file],'datos','-ascii');%salva los datos a fichero.
    
end


function NPulses_Callback(hObject, eventdata, handles)
% hObject    handle to NPulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NPulses as text
%        str2double(get(hObject,'String')) returns contents of NPulses as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0
        set(hObject,'String','1');
    end
else
    set(hObject,'String','1');
end

% --- Executes during object creation, after setting all properties.
function NPulses_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NPulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





%%%%%%%%%%%%%%%%%%  GRAPHS FUNCTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ManagingData2Plot(Data,DataName,handles,hObject)
handles = guidata(handles.SetupTES);
if isempty(handles.Circuit.Rf.Value)
    waitfor(msgbox('Circuit Rf value is empty, set the correct value',handles.VersionStr));
    waitfor(handles.Menu_Circuit.Callback(handles.Menu_Circuit,[],handles));
    handles = guidata(handles.SetupTES);
    if isempty(handles.Circuit.Rf.Value)
        return;
    else
        guidata(hObject,handles);
    end
end
delete(findobj(handles.Result_Axes,'Type','Image'));
if nargin == 4
    switch hObject.Tag
        
        case 'Start_IVRange'
            
            set([findobj(handles.Result_Axes1); findobj(handles.Result_Axes2); findobj(handles.Result_Axes3)],'Visible','off');
            set(findobj(handles.Result_Axes),'Visible','on');
            
            plot(handles.Result_Axes,Data(:,2),Data(:,4),'Visible','on','Marker','o','Color',[0 0.447 0.741]);
            xlabel(handles.Result_Axes,'Ibias(\muA)','FontSize',12,'FontWeight','bold');
            ylabel(handles.Result_Axes,'Vdc(V)','LineWidth',2,'FontSize',12,'FontWeight','bold');
            set(handles.Result_Axes,'LineWidth',2,'FontSize',12,'FontWeight','bold','XScale','linear','YScale','linear',...
                'XTickLabelMode','auto','XTickMode','auto');
            
        case 'IC_Range'
                        
            set([findobj(handles.Result_Axes1); findobj(handles.Result_Axes2); findobj(handles.Result_Axes3)],'Visible','off');
            set(findobj(handles.Result_Axes),'Visible','on');
            
            plot(handles.Result_Axes,Data(:,2),Data(:,4),'Visible','on','Marker','o','Color',[0 0.447 0.741],'DisplayName',DataName);
            xlabel(handles.Result_Axes,'Bfield(\muA)','FontSize',12,'FontWeight','bold');
            ylabel(handles.Result_Axes,'Icritical(\muA)','LineWidth',2,'FontSize',12,'FontWeight','bold');
            set(handles.Result_Axes,'LineWidth',2,'FontSize',12,'FontWeight','bold','XScale','linear','YScale','linear',...
                'XTickLabelMode','auto','XTickMode','auto');
            
        case 'Start_FieldRange'
            
            set([findobj(handles.Result_Axes1); findobj(handles.Result_Axes2); findobj(handles.Result_Axes3)],'Visible','off');
            set(findobj(handles.Result_Axes),'Visible','on');
            
            plot(handles.Result_Axes,Data(:,2),Data(:,5),'Visible','on','Marker','o','Color',[0 0.447 0.741]);
            xlabel(handles.Result_Axes,'I_{Field}(\muA)','FontSize',12,'FontWeight','bold');
            ylabel(handles.Result_Axes,'Vdc(V)','FontSize',12,'FontWeight','bold');
            set(handles.Result_Axes,'LineWidth',2,'FontSize',12,'FontWeight','bold','XScale','linear','YScale','linear',...
                'XTickLabelMode','auto','XTickMode','auto');
            
        case 'DSA_TF_Zw_Read'
            
            set([findobj(handles.Result_Axes1); findobj(handles.Result_Axes2); findobj(handles.Result_Axes3)],'Visible','off');
            set(findobj(handles.Result_Axes),'Visible','on');
            
            plot(handles.Result_Axes,Data(:,2)+1i*Data(:,3),'Visible','on','Marker','o',...
                'LineStyle','-');
            xlabel(handles.Result_Axes,'Re(mZ)','FontSize',12,'FontWeight','bold');
            ylabel(handles.Result_Axes,'Im(mZ)','FontSize',12,'FontWeight','bold');
            axis(handles.Result_Axes,'tight');
            set(handles.Result_Axes,'LineWidth',2,'FontSize',12,'FontWeight','bold','XScale','linear','YScale','linear',...
                'XTickLabelMode','auto','XTickMode','auto');
            
        case 'PXI_TF_Zw_Read'
            
            set(findobj(handles.Result_Axes),'Visible','off');
            set(handles.Result_Axes1,'Position',[0.65 0.58 0.15 0.35]);
            set(handles.Result_Axes2,'Position',[0.65 0.09 0.15 0.35]);
            set([findobj(handles.Result_Axes1); findobj(handles.Result_Axes2); findobj(handles.Result_Axes3)],'Visible','on');
            try
            plot(handles.Result_Axes1,Data{1},Data{2});
            catch
                plot(handles.Result_Axes1,Data(:,1),Data(:,2));
            end
            xlabel(handles.Result_Axes1,'Time(s)','FontSize',12,'FontWeight','bold');
            ylabel(handles.Result_Axes1,'V_{in}(mV)','FontSize',12,'FontWeight','bold');
            set(handles.Result_Axes1,'LineWidth',2,'FontSize',12,'FontWeight','bold','XScale','linear','YScale','linear',...
                'XTickLabelMode','auto','XTickMode','auto');
            
            try
            plot(handles.Result_Axes2,Data{1},Data{3});
            catch
                plot(handles.Result_Axes2,Data(:,1),Data(:,3));
            end
            xlabel(handles.Result_Axes2,'Time(s)','FontSize',12,'FontWeight','bold');
            ylabel(handles.Result_Axes2,'V_{out}(mV)','FontSize',12,'FontWeight','bold');
            set(handles.Result_Axes2,'LineWidth',2,'FontSize',12,'FontWeight','bold','XScale','linear','YScale','linear',...
                'XTickLabelMode','auto','XTickMode','auto');
            
            try
                plot(handles.Result_Axes3,Data{5},Data{6},'o-');
%                 plot(handles.Result_Axes3,Data(:,4)+1i*Data(:,5),'o-');
            catch
                try
                    plot(handles.Result_Axes3,Data(:,4)+1i*Data(:,5),'o-');
                catch
                    plot(handles.Result_Axes3,Data(:,2)+1i*Data(:,3),'o-');
                end
            end
            xlabel(handles.Result_Axes3,'Re(mZ)','FontSize',12,'FontWeight','bold');
            ylabel(handles.Result_Axes3,'Im(mZ)','FontSize',12,'FontWeight','bold');
            set(handles.Result_Axes3,'LineWidth',2,'FontSize',12,'FontWeight','bold','XScale','linear','YScale','linear',...
                'XTickLabelMode','auto','XTickMode','auto');
            axis(handles.Result_Axes3,'tight');
            
        case 'DSA_TF_Noise_Read'
            
            set([findobj(handles.Result_Axes); findobj(handles.Result_Axes3)],'Visible','off');
            set(handles.Result_Axes1,'Position',[0.65 0.58 0.30 0.35]);
            set(handles.Result_Axes2,'Position',[0.65 0.09 0.30 0.35]);
            set([findobj(handles.Result_Axes1); findobj(handles.Result_Axes2)],'Visible','on');
            
            loglog(handles.Result_Axes1,Data(:,1),Data(:,2));
            xlabel(handles.Result_Axes1,'\nu(Hz)','FontSize',12,'FontWeight','bold');
            ylabel(handles.Result_Axes1,'V_{out}','FontSize',12,'FontWeight','bold');
            set(handles.Result_Axes1,'XScale','log','YScale','log','LineWidth',2,'FontSize',11,...
                'FontWeight','bold','XTickLabelMode','auto','XTickMode','auto');
            
            loglog(handles.Result_Axes2,Data(:,1),V2I(Data(:,2)*1e12,handles.Circuit),'.-r',...
                Data(:,1),medfilt1(V2I(Data(:,2)*1e12,handles.Circuit),20),'.-k');
            ylabel(handles.Result_Axes2,'pA/Hz^{0.5}','FontSize',12,'FontWeight','bold');
            xlabel(handles.Result_Axes2,'\nu(Hz)','FontSize',12,'fontweight','bold');
            set(handles.Result_Axes2,'XScale','log','YScale','log','LineWidth',2,'FontSize',11,'FontWeight',...
                'bold','XTick',[10 100 1000 1e4 1e5],'XTickLabel',{'10' '10^2' '10^3' '10^4' '10^5'});
            axis(handles.Result_Axes2,'tight');
            
        case 'PXI_TF_Noise_Read'
            
            set([findobj(handles.Result_Axes); findobj(handles.Result_Axes3)],'Visible','off');
            set(handles.Result_Axes1,'Position',[0.65 0.58 0.30 0.35]);
            set(handles.Result_Axes2,'Position',[0.65 0.09 0.30 0.35]);
            set([findobj(handles.Result_Axes1); findobj(handles.Result_Axes2)],'Visible','on');
            
            loglog(handles.Result_Axes1,Data(:,1),Data(:,2));
            xlabel(handles.Result_Axes1,'Time(s)','FontSize',12,'FontWeight','bold');
            ylabel(handles.Result_Axes1,'V_{out}','FontSize',12,'FontWeight','bold');
            set(handles.Result_Axes1,'LineWidth',2,'FontSize',11,'FontWeight','bold','XScale','log','YScale','log',...
                'XTickLabelMode','auto','XTickMode','auto');
            
            loglog(handles.Result_Axes2,Data(:,1),V2I(Data(:,2)*1e12,handles.Circuit),'.-r',...
                Data(:,1),medfilt1(V2I(Data(:,2)*1e12,handles.Circuit),20),'.-k');
            ylabel(handles.Result_Axes2,'pA/Hz^{0.5}','FontSize',12,'FontWeight','bold');
            xlabel(handles.Result_Axes2,'\nu(Hz)','FontSize',12,'FontWeight','bold');
            set(handles.Result_Axes2,'XScale','log','YScale','log','LineWidth',2,'FontSize',11,'FontWeight',...
                'bold','XTick',[10 100 1000 1e4 1e5],'XTickLabel',{'10' '10^2' '10^3' '10^4' '10^5'});
            axis(handles.Result_Axes2,'tight');
            
        case 'PXI_Pulse_Read'
            
            set([findobj(handles.Result_Axes); findobj(handles.Result_Axes3)],'Visible','off');
            set(handles.Result_Axes1,'Position',[0.65 0.58 0.30 0.35]);
            set(handles.Result_Axes2,'Position',[0.65 0.09 0.30 0.35]);
            set([findobj(handles.Result_Axes1); findobj(handles.Result_Axes2)],'Visible','on');
            
            plot(handles.Result_Axes1,Data(:,1),Data(:,2));
            xlabel(handles.Result_Axes1,'Time(s)','FontSize',12,'FontWeight','bold');
            ylabel(handles.Result_Axes1,'Amplitude(a.u.)','FontSize',12,'FontWeight','bold');
            set(handles.Result_Axes1,'LineWidth',2,'FontSize',11,'FontWeight','bold','XScale','linear','YScale','linear',...
                'XTickLabelMode','auto','XTickMode','auto');
            axis(handles.Result_Axes1,'tight');
            
            [psd,freq] = PSD(Data);
            loglog(handles.Result_Axes2,freq,10*log10(psd));
            xlabel(handles.Result_Axes2,'\nu(Hz)','FontSize',12,'FontWeight','bold');
            ylabel(handles.Result_Axes2,'PDS','FontSize',12,'FontWeight','bold');
            set(handles.Result_Axes2,'LineWidth',2,'FontSize',11,'FontWeight','bold','XScale','log','YScale','log',...
                'XTickLabelMode','auto','XTickMode','auto');
            axis(handles.Result_Axes2,'tight');
            
        case 'Pulse_Cont'
            
            set([findobj(handles.Result_Axes); findobj(handles.Result_Axes3)],'Visible','off');
            set(handles.Result_Axes1,'Position',[0.65 0.58 0.30 0.35]);
            set(handles.Result_Axes2,'Position',[0.65 0.09 0.30 0.35]);
            set([findobj(handles.Result_Axes1); findobj(handles.Result_Axes2)],'Visible','on');
            
            plot(handles.Result_Axes1,Data(:,1),Data(:,2));
            xlabel(handles.Result_Axes1,'Time(s)','FontSize',12,'FontWeight','bold');
            ylabel(handles.Result_Axes1,'Amplitude(a.u.)','FontSize',12,'FontWeight','bold');
            set(handles.Result_Axes1,'LineWidth',2,'FontSize',11,'FontWeight','bold','XScale','linear','YScale','linear',...
                'XTickLabelMode','auto','XTickMode','auto');
            axis(handles.Result_Axes1,'tight');
            
            [psd,freq] = PSD(Data);
            loglog(handles.Result_Axes2,freq,10*log10(psd));
            xlabel(handles.Result_Axes2,'\nu(Hz)','FontSize',12,'FontWeight','bold');
            ylabel(handles.Result_Axes2,'PDS','FontSize',12,'FontWeight','bold');
            set(handles.Result_Axes2,'LineWidth',2,'FontSize',11,'FontWeight','bold','XScale','log','YScale','log',...
                'XTickLabelMode','auto','XTickMode','auto');
            axis(handles.Result_Axes2,'tight');
            
    end
    Grid_Plot_Callback(handles.Grid_Plot,[],handles);
else
    
    DataName(DataName == '_') = ' ';
    switch size(Data,2)
        case 2  % Noise
            set([handles.Result_Axes handles.Result_Axes3],'Visible','off');
            
            loglog(handles.Result_Axes1,Data(:,1),Data(:,2));
            xlabel(handles.Result_Axes1,'Time(s)');
            ylabel(handles.Result_Axes1,'V_{out}');
            set(handles.Result_Axes1,'linewidth',2,'fontsize',12,'fontweight','bold');
            
            
            try
                loglog(handles.Result_Axes2,Data(:,1),V2I(Data(:,2)*1e12,handles.Circuit),'.-r','Visible','on','DisplayName',DataName);
                hold(handles.Result_Axes2,'on');
                grid(handles.Result_Axes2,'on');
                loglog(handles.Result_Axes2,Data(:,1),medfilt1(V2I(Data(:,2)*1e12,handles.Circuit),20),'.-k','Visible','off','DisplayName',DataName)
                ylabel(handles.Result_Axes2,'pA/Hz^{0.5}','fontsize',12,'fontweight','bold')
                xlabel(handles.Result_Axes2,'\nu (Hz)','fontsize',12,'fontweight','bold')
                set(handles.Result_Axes2,'XScale','log','YScale','log')
                axis(handles.Result_Axes2,'tight')
                set(handles.Result_Axes2,'linewidth',2,'fontsize',11,'fontweight',...
                    'bold','XMinorGrid','off','YMinorGrid','off','GridLineStyle','-',...
                    'xtick',[10 100 1000 1e4 1e5],'xticklabel',{'10' '10^2' '10^3' '10^4' '10^5'});
            catch
            end
            
            set([handles.Result_Axes1 handles.Result_Axes2],'Visible','on');
            
        case 6  % TF (PXI)
            
            set(handles.Result_Axes,'Visible','off');
            plot(handles.Result_Axes1,Data(:,1),Data(:,2))
            xlabel(handles.Result_Axes1,'Time(s)');
            ylabel(handles.Result_Axes1,'V_{in}(mV)');
            set(handles.Result_Axes1,'linewidth',2,'XScale','linear','YScale','linear')
            
            plot(handles.Result_Axes2,Data(:,1),Data(:,3))
            xlabel(handles.Result_Axes2,'Time(s)');
            ylabel(handles.Result_Axes2,'V_{out}(mV)');
            set(handles.Result_Axes2,'linewidth',2,'XScale','linear','YScale','linear')
            
            set(handles.Result_Axes3,'linewidth',2,'fontsize',12,'fontweight','bold',...
                'XTickMode','auto','XTickLabelMode','auto',...
                'XMinorGrid','on','YMinorGrid','on');
            set(handles.Result_Axes3,'XScale','linear','YScale','linear')
            plot(handles.Result_Axes3,Data(:,4)+1i*Data(:,5),'Visible','on','DisplayName',DataName,'o-');
            xlabel(handles.Result_Axes3,'Re(mZ)','fontsize',12,'fontweight','bold');
            ylabel(handles.Result_Axes3,'Im(mZ)','fontsize',12,'fontweight','bold');
            axis(handles.Result_Axes3,'tight')
            set([handles.Result_Axes1 handles.Result_Axes2 handles.Result_Axes3],'Visible','on');
            
        case 3 % TF (HP)
            
            set([handles.Result_Axes1 handles.Result_Axes2 handles.Result_Axes3],'Visible','off');
            set(handles.Result_Axes,'linewidth',2,'fontsize',12,'fontweight','bold',...
                'XTickMode','auto','XTickLabelMode','auto',...
                'XMinorGrid','on','YMinorGrid','on');
            set(handles.Result_Axes,'linewidth',2,'XScale','linear','YScale','linear')
            plot(handles.Result_Axes,Data(:,2)+1i*Data(:,3),'Visible','on','DisplayName',DataName,'Marker','o',...
                'LineStyle','-');
            xlabel(handles.Result_Axes,'Re(mZ)','fontsize',12,'fontweight','bold');
            ylabel(handles.Result_Axes,'Im(mZ)','fontsize',12,'fontweight','bold');
            axis(handles.Result_Axes,'tight')
            set(handles.Result_Axes,'Visible','on','fontsize',11);
            
        case 4  % I-Vs
            
            set([handles.Result_Axes1 handles.Result_Axes2 handles.Result_Axes3],'Visible','off');
            set(handles.Result_Axes,'linewidth',2,'fontsize',12,'fontweight','bold',...
                'XTickMode','auto','XTickLabelMode','auto',...
                'XMinorGrid','off','YMinorGrid','on');
            handles.Result_Axes.XScale = 'linear';
            handles.Result_Axes.YScale = 'linear';
            plot(handles.Result_Axes,Data(:,2),Data(:,4),'Visible','on','DisplayName',DataName,'Marker','o','Color',[0 0.447 0.741]);
            xlabel(handles.Result_Axes,'Ibias (\muA)','fontsize',12,'fontweight','bold');
            ylabel(handles.Result_Axes,'Vdc(V)','linewidth',2,'fontsize',12,'fontweight','bold');
            
        case 5 % Field Opt
            
            set([handles.Result_Axes1 handles.Result_Axes2 handles.Result_Axes3],'Visible','off');
            set(handles.Result_Axes,'linewidth',2,'fontsize',12,'fontweight','bold',...
                'XTickMode','auto','XTickLabelMode','auto',...
                'XMinorGrid','off','YMinorGrid','on');
            handles.Result_Axes.XScale = 'linear';
            handles.Result_Axes.YScale = 'linear';
            plot(handles.Result_Axes,Data(:,2),Data(:,5),'Visible','on','DisplayName',DataName,'Marker','o','Color',[0 0.447 0.741]);
            xlabel(handles.Result_Axes,'I_{Field} (\muA)','fontsize',12,'fontweight','bold');
            ylabel(handles.Result_Axes,'Vdc(V)','fontsize',12,'fontweight','bold');
            
        case 1 % Empty
            
        otherwise % R(T)
            for i = 2:2:size(Data.data,2)-1
                plot(handles.Result_Axes,Data.data(:,i),Data.data(:,i+1),'Visible','on','DisplayName',Data.textdata{i+1});
            end
            xlabel(handles.Result_Axes,Data.textdata{2})
            ylabel(handles.Result_Axes,'??');
            handles.Result_Axes.XScale = 'linear';
            handles.Result_Axes.YScale = 'linear';
    end
end

% --- Executes on button press in Check_Plot.
function Check_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Check_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Check_Plot
if ~isempty(handles.FileName)
    handles.Draw_Select.Visible = 'on';
else % Test Values
    if handles.TestPlot.Value
        handles.Draw_Select.Visible = 'off';
    end
end
guidata(hObject,handles);

% --- Executes on selection change in Draw_Select.
function Draw_Select_Callback(hObject, eventdata, handles)
% hObject    handle to Draw_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Draw_Select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Draw_Select


if handles.Draw_Select.Value == 1
    handles.Area_Plot.Enable = 'on';
else
    handles.Area_Plot.Enable = 'off';
end


DataStr = {'IVs';'TF';'Noise';'Pulse';'RTs'};
if handles.TestPlot.Value
    eval(['Data = handles.TestData.' DataStr{handles.Draw_Select.Value}]);
elseif handles.FilePlot.Value
    LoadedFileList = handles.List_Files.String;
    if iscell(handles.FileName)
        if strcmp(LoadedFileList{handles.List_Files.Value},'All')
            handles.Hold_Plot.Value = 1;
            Hold_Plot_Callback(handles.Hold_Plot,[],handles);
            for i = 1:length(handles.FileName)
                Data = [];
                DataName = handles.FileName{i};
                try
                    eval(['Data = handles.LoadData.' DataStr{handles.Draw_Select.Value} '{' num2str(i) '};']);
                catch
                    if i == 1
                        warndlg('Data representation does not correspond to loaded data',handles.VersionStr);
                        return;
                    end
                end
                if isempty(Data)&&length(eval(['handles.LoadData.' DataStr{handles.Draw_Select.Value}]))==1
                    warndlg('Data representation does not correspond to loaded data',handles.VersionStr);
                    return;
                elseif ~isempty(Data)
                    switch handles.Draw_Select.Value
                        case 1 % IV
                            ManagingData2Plot(Data,DataName,handles,handles.Start_IVRange);
                        case 2 % Zw
%                             if ~isempty(strfind(upper(DataName),'PXI'))
%                                 ManagingData2Plot(Data,DataName,handles,handles.PXI_TF_Zw_Read);
%                             else
                                ManagingData2Plot(Data,DataName,handles,handles.DSA_TF_Zw_Read);
%                             end
                        case 3 % Noise
                            if ~isempty(strfind(upper(DataName),'PXI'))
                                ManagingData2Plot(Data,DataName,handles,handles.PXI_TF_Noise_Read);
                            else
                                ManagingData2Plot(Data,DataName,handles,handles.DSA_TF_Noise_Read);
                            end
                        case 4 % Pulse
                            ManagingData2Plot(Data,DataName,handles,handles.PXI_Pulse_Read);
                        case 5 % RTs
                            
                    end
                end
            end
        else
            Data = [];
            DataName = handles.FileName{handles.List_Files.Value-1};
            if ~isempty(strfind(DataName,'mK_Rf'))
                handles.Draw_Select.Value = 1;
            elseif ~isempty(strfind(DataName,'TF_'))
                handles.Draw_Select.Value = 2;
            elseif ~isempty(strfind(upper(DataName),'NOISE'))
                handles.Draw_Select.Value = 3;
            elseif ~isempty(strfind(upper(DataName),'PULSO'))
                handles.Draw_Select.Value = 4;
            else
                handles.Draw_Select.Value = 5;
            end
            
            try
                eval(['Data = handles.LoadData.' DataStr{handles.Draw_Select.Value} '{' num2str(handles.List_Files.Value-1) '};']);
            catch
                warndlg('Data representation does not correspond to loaded data',handles.VersionStr);
                return;
            end
            if isempty(Data)
                warndlg('Data representation does not correspond to loaded data',handles.VersionStr);
                return;
            elseif iscell(Data) && length(Data) == 1 && isempty(Data{1})
                warndlg('Data representation does not correspond to loaded data',handles.VersionStr);
                return;
            end
            switch handles.Draw_Select.Value
                case 1 % IV
                    ManagingData2Plot(Data,DataName,handles,handles.Start_IVRange);
                case 2 % Zw
%                     if ~isempty(strfind(upper(DataName),'PXI'))
%                         ManagingData2Plot(Data,DataName,handles,handles.PXI_TF_Zw_Read);
%                     else
                        ManagingData2Plot(Data,DataName,handles,handles.DSA_TF_Zw_Read);
%                     end
                case 3 % Noise
                    if ~isempty(strfind(upper(DataName),'PXI'))
                        ManagingData2Plot(Data,DataName,handles,handles.PXI_TF_Noise_Read);
                    else
                        ManagingData2Plot(Data,DataName,handles,handles.DSA_TF_Noise_Read);
                    end
                case 4 % Pulse
                    ManagingData2Plot(Data,DataName,handles,handles.PXI_Pulse_Read);
                case 5 % RTs
                    
            end
        end
    else
        Data = [];
        try
            eval(['Data = handles.LoadData.' DataStr{handles.Draw_Select.Value} ';']);
        catch
            warndlg(['No data of ' DataStr{handles.Draw_Select.Value} ' were loaded'],handles.VersionStr);
            return;
        end
        if isempty(Data)
            warndlg('Data representation does not correspond to loaded data',handles.VersionStr);
            return;
        elseif iscell(Data) && length(Data) == 1 && isempty(Data{1})
            warndlg('Data representation does not correspond to loaded data',handles.VersionStr);
            return;
        end
        switch handles.Draw_Select.Value
            case 1 % IV
                ManagingData2Plot(Data,handles.FileName,handles,handles.Start_IVRange);
            case 2 % Zw
%                 if ~isempty(strfind(upper(handles.FileName),'PXI'))
%                     ManagingData2Plot(Data,handles.FileName,handles,handles.PXI_TF_Zw_Read);
%                 else
                    ManagingData2Plot(Data,handles.FileName,handles,handles.DSA_TF_Zw_Read);
%                 end
            case 3 % Noise
                if ~isempty(strfind(upper(handles.FileName),'PXI'))
                    ManagingData2Plot(Data,handles.FileName,handles,handles.PXI_TF_Noise_Read);
                else
                    ManagingData2Plot(Data,handles.FileName,handles,handles.DSA_TF_Noise_Read);
                end
            case 4 % Pulse
                ManagingData2Plot(Data,handles.FileName,handles,handles.PXI_Pulse_Read);
            case 5 % RTs
                
        end
    end
    
end
Check_Plot_Callback(handles.Check_Plot,[],handles);

% --- Executes during object creation, after setting all properties.
function Draw_Select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Draw_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in FilePlot.
function FilePlot_Callback(hObject, eventdata, handles)
% hObject    handle to FilePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FilePlot
if (hObject.Value||handles.GraphPlot.Value)
    handles.Browse_File.Enable = 'on';
else
    handles.Browse_File.Enable = 'off';
end
guidata(hObject,handles);

% --- Executes on button press in GraphPlot.
function GraphPlot_Callback(hObject, eventdata, handles)
% hObject    handle to GraphPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GraphPlot
if (hObject.Value||handles.FilePlot.Value)
    handles.Browse_File.Enable = 'on';
else
    handles.Browse_File.Enable = 'off';
end
guidata(hObject,handles);

% --- Executes on button press in Hold_Plot.
function Hold_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Hold_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Hold_Plot
Str = {'';'1';'2';'3'};
if hObject.Value
    for i = 1:4
        eval(['hold(handles.Result_Axes' Str{i} ',''on'');']);
    end
else
    for i = 1:4
        eval(['hold(handles.Result_Axes' Str{i} ',''off'');']);
    end
end
guidata(hObject,handles);

% --- Executes on button press in Zoom_Plot.
function Zoom_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Zoom_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Zoom_Plot
Str = {'';'1';'2';'3'};
if hObject.Value
    for i = 1:4
        eval(['zoom(handles.Result_Axes' Str{i} ',''on'');']);
    end
else
    for i = 1:4
        eval(['zoom(handles.Result_Axes' Str{i} ',''off'');']);
    end
end
guidata(hObject,handles);

% --- Executes on button press in Grid_Plot.
function Grid_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Grid_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Grid_Plot
Str = {'';'1';'2';'3'};
if hObject.Value
    for i = 1:4
        eval(['grid(handles.Result_Axes' Str{i} ',''on'');']);
    end
else
    for i = 1:4
        eval(['grid(handles.Result_Axes' Str{i} ',''off'');']);
    end
end
guidata(hObject,handles);

% --- Executes on button press in Clear_Plot.
function Clear_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Clear_Plot
hObject.Enable = 'off';
CH = findobj(handles.Result_Axes,'Type','Line');
delete(CH);
CH = findobj(handles.Result_Axes1,'Type','Line');
delete(CH);
CH = findobj(handles.Result_Axes2,'Type','Line');
delete(CH);
CH = findobj(handles.Result_Axes3,'Type','Line');
delete(CH);
handles.Check_Plot.Value = 0;
Check_Plot_Callback(handles.Check_Plot,[],handles);
hObject.Enable = 'on';
guidata(hObject,handles);

% --- Executes on button press in Browse_File.
function Browse_File_Callback(hObject, eventdata, handles)
% hObject    handle to Browse_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.FilePlot.Value
    [FileName, FileDir] = uigetfile({'*.txt','Example file (*.txt)';...
        '*.dat','Example file (*.dat)'},...
        'MultiSelect','on','Select File(s)',handles.FileDir);
    if ~isempty(FileName)&&~isequal(FileName,0)
        handles.FileDir = FileDir;
        handles.FileName = FileName;
        handles.Datos = {[]};
        handles.LoadData.IVs = [];
        handles.LoadData.Noise = {[]};
        handles.LoadData.TF = {[]};
        handles.LoadData.Pulse = {[]};
        handles.LoadData.RTs = [];
        if iscell(FileName)
            handles.Actions_Str.String = 'Graphical Representation: MultiSelection';
            handles.List_Files.String = [{'All'} FileName]';
            handles.List_Files.Value = 1;
            set([handles.LoadFiles_Str handles.List_Files],'Visible','on');
        else
            handles.Actions_Str.String = ['Graphical Representation: ' FileDir FileName ];
            Actions_Str_Callback(handles.Actions_Str,[],handles);
            handles.List_Files.String = FileName;
            handles.List_Files.Value = 1;
            set([handles.LoadFiles_Str handles.List_Files],'Visible','on');
        end
        
        if handles.FilePlot.Value
            if iscell(handles.FileName)
                handles.Hold_Plot.Value = 1;
                Hold_Plot_Callback(handles.Hold_Plot,[],handles);
                h = waitbar(0,'Please wait... loading Files');
                for i = 1:length(handles.FileName)
                    fid = fopen([handles.FileDir handles.FileName{i}]);
                    Data = importdata([handles.FileDir handles.FileName{i}]);
                    fclose(fid);
                    
                    if ~isempty(strfind(handles.FileName{i},'mK_Rf'))
                        handles.LoadData.IVs{i} = Data;
                        handles.Draw_Select.Value = 1;
                    elseif ~isempty(strfind(handles.FileName{i},'TF_'))
                        handles.LoadData.TF{i} = Data;
                        handles.Draw_Select.Value = 2;
                    elseif ~isempty(strfind(upper(handles.FileName{i}),'_NOISE'))
                        handles.LoadData.Noise{i} = Data;
                        handles.Draw_Select.Value = 3;
                    elseif ~isempty(strfind(upper(handles.FileName{i}),'_PULSO'))
                        handles.LoadData.Pulse{i} = Data;
                        handles.Draw_Select.Value = 4;
                    end
                    handles.Datos{i} = Data;
                    waitbar(i/length(handles.FileName),h)
                end
                close(h);
            else
                fid = fopen([handles.FileDir handles.FileName]);
                Data = importdata([handles.FileDir handles.FileName]);
                fclose(fid);
                if ~isempty(strfind(handles.FileName,'mK_Rf'))
                    handles.LoadData.IVs = Data;
                    handles.Draw_Select.Value = 1;
                elseif ~isempty(strfind(handles.FileName,'TF_'))
                    handles.LoadData.TF = Data;
                    handles.Draw_Select.Value = 2;
                elseif ~isempty(strfind(upper(handles.FileName),'_NOISE'))
                    handles.LoadData.Noise = Data;
                    handles.Draw_Select.Value = 3;
                elseif ~isempty(strfind(upper(handles.FileName),'_PULSO'))
                    handles.LoadData.Pulse = Data;
                    handles.Draw_Select.Value = 4;
                end
                handles.Datos = Data;
            end
            set(handles.Draw_Select,'Visible','on');
            Draw_Select_Callback(handles.Draw_Select,[],handles);
            
        end
        if handles.Check_Plot.Value
            Check_Plot_Callback(handles.Check_Plot,[],handles);
        end
    else
        handles.FileDir = [];
        handles.FileName = [];
        handles.Actions_Str.String = 'Graphical Representation: No file selected';
        Actions_Str_Callback(handles.Actions_Str,[],handles);
        set([handles.LoadFiles_Str handles.List_Files],'Visible','off');
    end
    
    
end

guidata(hObject, handles);

% --- Executes on button press in TestPlot.
function TestPlot_Callback(hObject, eventdata, handles)
% hObject    handle to TestPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TestPlot
% if (handles.FilePlot.Value||handles.GraphPlot.Value)
if handles.FilePlot.Value
    handles.Browse_File.Enable = 'on';
else
    handles.Browse_File.Enable = 'off';
end

if hObject.Value  % Current values acquired
    
    switch size(handles.TestData,2)
        case 2 % Noise
            handles.TestData.Noise = Data;
        case 3 % TF
            handles.TestData.TF = Data;
        case 4 % I-Vs
            handles.TestData.IVs = Data;
        otherwise
    end
    ManagingData2Plot(handles.TestData,[],handles);
end

guidata(hObject,handles);

% --- Executes on selection change in List_Files.
function List_Files_Callback(hObject, eventdata, handles)
% hObject    handle to List_Files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns List_Files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from List_Files
%
Draw_Select_Callback(handles.Draw_Select,[],handles);
Check_Plot_Callback(handles.Check_Plot,[],handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function List_Files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to List_Files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





%%%%%%%%%%%%%%%%%%  MIXING CHAMBER TEMP FUNCTIONS  %%%%%%%%%%%%%%%%%%%%%%%%


function update_Temp_display(src,evnt)

handles = src.UserData;
T_MC = handles.vi_IGHFrontPanel.GetControlValue('M/C');
handles.MCTemp.String = num2str(T_MC);


function update_Temp_Color(src,evnt)

handles = src.UserData;
T_MC = handles.vi_IGHFrontPanel.GetControlValue('M/C');
Set_Pt = str2double(handles.SetPt.String);

Error = abs(T_MC-Set_Pt)/T_MC*100;
handles.Error_Measured.String = Error;

RGB = [linspace(120,255,100)' sort(linspace(50,170,100),'descend')' 50*ones(100,1)]./255;
try
    handles.Temp_Color.BackgroundColor = RGB(round(min(ceil(Error),100)),:);
catch
    handles.Temp_Color.BackgroundColor = RGB(1,:);
end


function SetPt_Callback(hObject, eventdata, handles)
% hObject    handle to SetPt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SetPt as text
%        str2double(get(hObject,'String')) returns contents of SetPt as a double

SetPt = str2double(hObject.String);

if isnan(SetPt)||isinf(SetPt)
    warndlg('Invalid Set Pt value',handles.VersionStr);
    hObject.String = '---';
    return;
else
    if SetPt > 500*1e-3 % Por encima de 120mK
        ButtonName = questdlg('Set Pt above 120 mK, are you sure to continue?',handles.VersionStr,'Yes','No','No');
        switch ButtonName
            case 'No'
                return;
        end
    end
end

handles.vi_IGHFrontPanel.FPState = 4;
pause(0.1)
handles.vi_IGHFrontPanel.FPState = 1;
pause(0.1)
handles.vi_IGHFrontPanel.SetControlValue('Settings',1);
pause(1.5)
handles.vi_IGHChangeSettings.SetControlValue('Set Point Dialog',1);
pause(0.1)
while strcmp(handles.vi_PromptForT.FPState,'eClosed')
    pause(0.1);
end
handles.vi_PromptForT.SetControlValue('Set T',SetPt)%
pause(0.4)
handles.vi_PromptForT.SetControlValue('Set T',SetPt)%
pause(0.1)
handles.vi_PromptForT.SetControlValue('OK',1)
pause(0.1)
while strcmp(handles.vi_PromptForT.FPState,'eClosed')
    pause(0.1);
end
stop(handles.timer_T);
start(handles.timer_T);
waitfor(msgbox('Temperature was sucessfully set',handles.VersionStr));

guidata(hObject,handles);

% --- Executes on button press in Temp_Color.
function Temp_Color_Callback(hObject, eventdata, handles)
% hObject    handle to Temp_Color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function Temp_Error_Callback(hObject, eventdata, handles)
% hObject    handle to Temp_Error (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Temp_Error as text
%        str2double(get(hObject,'String')) returns contents of Temp_Error as a double
value = str2double(get(hObject,'String'));
if ~isempty(value)&&~isnan(value)
    if value <= 0||value > 100
        set(hObject,'String','5');
    end
else
    set(hObject,'String','5');
end

% --- Executes during object creation, after setting all properties.
function Temp_Error_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Temp_Error (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Error_Measured_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Temp_Error (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function SQ_PhiBStr_Callback(hObject, eventdata, handles)
% hObject    handle to SQ_PhiBStr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SQ_PhiBStr as text
%        str2double(get(hObject,'String')) returns contents of SQ_PhiBStr as a double


% --- Executes during object creation, after setting all properties.
function SQ_PhiBStr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SQ_PhiBStr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
