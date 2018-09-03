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

% Last Modified by GUIDE v2.5 31-Aug-2018 12:18:48

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
catch
end

handles.TempDir = [];
handles.TempName = [];

handles.IbiasDir = [];
handles.IbiasName = [];


position = get(handles.figure1,'Position');
set(handles.figure1,'Color',[0 100 160]/255,'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');

handles.menu(1) = uimenu('Parent',handles.figure1,'Label',...
    'Configuration File');
handles.Menu_Conf = uimenu('Parent',handles.menu(1),'Label',...
    'Open','Callback',{@OpenConfFile});


% Initializing Table values
handles.Ibias_Table.Data = num2cell([500 -10 0]);
Ibias_Panel_SelectionChangedFcn(handles.Manual,[],handles);

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

function OpenConfFile(src,evnt)
handles = guidata(src);
[Name, Dir] = uigetfile({'*.xml','Example file (*.xml)'},...
    'Select file','tmp\*.xml');
if ~isempty(Name)&&~isequal(Name,0)
    handles.ConfDir = Dir;
    handles.ConfName = Name;
else
    warndlg('No Configuration File Selected!','ZarTES v1.0')
    return;
end

S = xml2struct([handles.ConfDir handles.ConfName]);

Conf.Temps.Values = str2double(split(S.Conf.Temps.Values.Text,' '));
Conf.Temps.File = S.Conf.Temps.File.Text;
Conf.Ibvalues.Mode = str2double(S.Conf.Ibvalues.Mode.Text);
Conf.Ibvalues.Values = str2double(split(S.Conf.Ibvalues.Values.Text,' '));
Conf.Field.Mode = str2double(S.Conf.Field.Mode.Text);
Conf.Field.Values = str2double(split(S.Conf.Field.Values.Text,' '));
Conf.ZwNoise.Mode = str2double(S.Conf.ZwNoise.Mode.Text);
Conf.ZwNoise.Parameters = [];
Conf.Pulses.Mode = str2double(S.Conf.Pulses.Mode.Text);
Conf.Pulses.Parameters = [];

Update_Setup(Conf,handles);


function Update_Setup(Conf,handles)

if isempty(Conf.Temps.File)
    handles.Temp_Manual.Value = 1;
    Temp_Panel_SelectionChangedFcn(handles.Temp_Panel, [], handles)
else
    handles.Temp_FromFile.Value = 1;
    Temp_Panel_SelectionChangedFcn(handles.Temp_Panel, [], handles)
    handles.Temp_Save_Str.String = Conf.Temps.File;
    
    handles.TempName = Conf.Temps.File(max(strfind(Conf.Temps.File,filesep))+1:end);
    handles.TempDir = Conf.Temps.File(1:max(strfind(Conf.Temps.File,filesep)));
end
handles.Temp_Table.Data = [];
handles.Temp_Table.Data{size(Conf.Temps.Values,1),3} = []; 
handles.Temp_Table.Data(1:size(Conf.Temps.Values,1),size(Conf.Temps.Values,2)) = cellstr(num2str(Conf.Temps.Values));
   
handles.AQ_IVs.Value = Conf.Ibvalues.Mode;
AQ_IVs_Callback(handles.AQ_IVs, [], handles);
if handles.AQ_IVs.Value
    handles.Ibias_Table.Data = [];
    handles.Ibias_Table.Data{size(Conf.Ibvalues.Values,1),3} = [];
    handles.Ibias_Table.Data(1:size(Conf.Ibvalues.Values,1),size(Conf.Ibvalues.Values,2)) = cellstr(num2str(Conf.Ibvalues.Values));
end

handles.BField_Mode.Value = Conf.Field.Mode;
BField_Mode_Callback(handles.BField_Mode, [], handles);
if handles.BField_Mode.Value
    handles.Field_Table.Data = [];
    handles.Field_Table.Data{size(Conf.Field.Values,1),3} = [];
    handles.Field_Table.Data(1:size(Conf.Field.Values,1),size(Conf.Field.Values,2)) = cellstr(num2str(Conf.Field.Values));
end

handles.AQ_mode.Value = Conf.ZwNoise.Mode;
AQ_mode_Callback(handles.AQ_mode, [], handles);

handles.AQ_Pulse.Value = Conf.Pulses.Mode;
AQ_Pulse_Callback(handles.AQ_Pulse, [], handles);
guidata(handles.figure1,handles);


% --- Executes on button press in Start_AQ.
function Start_AQ_Callback(hObject, eventdata, handles)
% hObject    handle to Start_AQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%% Bath Temperature Range Setting
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
        elseif ~isempty(handles.Ibias_Table.Data{i,3})
            Data = [Data eval([num2str(handles.Ibias_Table.Data{i,1}) ':' ...
                num2str(handles.Ibias_Table.Data{i,2}) ':' ...
                num2str(handles.Ibias_Table.Data{i,3}) ])];
        end
    end
end
Ibvalues = eval(['repmat(Data,1,' handles.Ibias_NRepeat.String ');']);

if handles.Ibias_Negative.Value
    Ibvalues = [Ibvalues -Ibvalues];
end

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
Field = Data;

%%% Configuration data is parsed to an structure

if isempty(handles.TempName)
    warndlg('Temperature values must be stored in a txt file','ZarTES v1.0');
    Temp_Save_Callback(handles.Temp_Save,[],handles);
    if isempty(handles.TempName)
       warndlg('Error generating the Configuration file!','ZarTES v1.0');  
    end
end
Conf.Temps.Values = Temps;
Conf.Temps.File = [handles.TempDir handles.TempName];

Conf.Ibvalues.Mode = handles.AQ_IVs.Value; % 0 (off), 1 (on) 
Conf.Ibvalues.Values = Ibvalues;

Conf.Field.Mode = handles.BField_Mode.Value;  % 0 (off), 1 (on)
Conf.Field.Values = Field;

Conf.ZwNoise.Mode = handles.AQ_mode.Value; % 0 (off), 1 (on)
Conf.ZwNoise.Zw.Parameters = [];
Conf.ZwNoise.Noise.Parameters = [];

Conf.Pulses.Mode = handles.AQ_Pulse.Value; % 0 (off), 1 (on)
Conf.Pulses.Parameters = [];


Start_Automatic_Acquisition(handles,handles.SetupTES,Conf);


handles.src.UserData = Conf;

guidata(hObject,handles);



% figure1_DeleteFcn(handles.figure1,eventdata,handles);   

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
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
        if strcmp(get(handles.Start_AQ,'Enable'),'on')
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
        
    case 'FromGraph'
        handles.Ibias_Table.Enable = 'off';
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




% --- Executes on button press in Ibias_Add.
function Ibias_Add_Callback(hObject, eventdata, handles)
% hObject    handle to Ibias_Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Ibias_Table.Data = [handles.Ibias_Table.Data; cell(1,3)];

% --- Executes on button press in Ibias_Remove.
function Ibias_Remove_Callback(hObject, eventdata, handles)
% hObject    handle to Ibias_Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if size(handles.Ibias_Table.Data,1) > 1
    handles.Ibias_Table.Data(end,:) = [];
end


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
            set(handles.Temp_File_Str,'String',[Dir Name],...
                'TooltipString',[Dir Name]);     
            fid = fopen([Dir Name]);
            Data = fscanf(fid,'%f');
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

% --- Executes on button press in Temp_Add.
function Temp_Add_Callback(hObject, eventdata, handles)
% hObject    handle to Temp_Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Temp_Table.Data = [handles.Temp_Table.Data; cell(1,3)];

% --- Executes on button press in Temp_Remove.
function Temp_Remove_Callback(hObject, eventdata, handles)
% hObject    handle to Temp_Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if size(handles.Temp_Table.Data,1) > 1
    handles.Temp_Table.Data(end,:) = [];
end

% --- Executes when selected object is changed in Temp_Panel.
function Temp_Panel_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Temp_Panel 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch hObject.Tag
    case 'Temp_Manual'
%         handles.Temp_Table.Enable = 'on';
        handles.Temp_Browse.Enable = 'off';
        
    otherwise
%         handles.Temp_Table.Enable = 'on';
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


function Pulse_Amp_Callback(hObject, eventdata, handles)
% hObject    handle to Pulse_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pulse_Amp as text
%        str2double(get(hObject,'String')) returns contents of Pulse_Amp as a double
Edit_Protect(hObject)

% --- Executes during object creation, after setting all properties.
function Pulse_Amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pulse_Amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Pulse_Amp_Units.
function Pulse_Amp_Units_Callback(hObject, eventdata, handles)
% hObject    handle to Pulse_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Pulse_Amp_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Pulse_Amp_Units
PulseAmp = str2double(handles.Pulse_Amp.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        PulseAmp = PulseAmp/1e-06;
    case -1
        PulseAmp = PulseAmp/1e-03;
    case 0
        PulseAmp = PulseAmp/1;
    case 1
        PulseAmp = PulseAmp/1e03;
    case 2
        PulseAmp = PulseAmp/1e06;
end
handles.Pulse_Amp.String = num2str(PulseAmp);
hObject.UserData = NewValue;

% --- Executes during object creation, after setting all properties.
function Pulse_Amp_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pulse_Amp_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Pulse_Range_Callback(hObject, eventdata, handles)
% hObject    handle to Pulse_Range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pulse_Range as text
%        str2double(get(hObject,'String')) returns contents of Pulse_Range as a double
Edit_Protect(hObject)

% --- Executes during object creation, after setting all properties.
function Pulse_Range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pulse_Range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Pulse_Range_Units.
function Pulse_Range_Units_Callback(hObject, eventdata, handles)
% hObject    handle to Pulse_Range_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Pulse_Range_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Pulse_Range_Units
PulseDT = str2double(handles.Pulse_Range.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        PulseDT = PulseDT/1e-06;
    case -1
        PulseDT = PulseDT/1e-03;
    case 0
        PulseDT = PulseDT/1;
    case 1
        PulseDT = PulseDT/1e03;
    case 2
        PulseDT = PulseDT/1e06;
end
handles.Pulse_Range.String = num2str(PulseDT);
hObject.UserData = NewValue;

% --- Executes during object creation, after setting all properties.
function Pulse_Range_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pulse_Range_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Pulse_Duration_Callback(hObject, eventdata, handles)
% hObject    handle to Pulse_Duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pulse_Duration as text
%        str2double(get(hObject,'String')) returns contents of Pulse_Duration as a double
Edit_Protect(hObject)


% --- Executes during object creation, after setting all properties.
function Pulse_Duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pulse_Duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Pulse_Duration_Units.
function Pulse_Duration_Units_Callback(hObject, eventdata, handles)
% hObject    handle to Pulse_Duration_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Pulse_Duration_Units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Pulse_Duration_Units
PulseDur = str2double(handles.Pulse_Duration.String);
OldValue = hObject.UserData;
NewValue = hObject.Value;

switch OldValue-NewValue
    case -2
        PulseDur = PulseDur/1e-06;
    case -1
        PulseDur = PulseDur/1e-03;
    case 0
        PulseDur = PulseDur/1;
    case 1
        PulseDur = PulseDur/1e03;
    case 2
        PulseDur = PulseDur/1e06;
end
handles.Pulse_Duration.String = num2str(PulseDur);
hObject.UserData = NewValue;

% --- Executes during object creation, after setting all properties.
function Pulse_Duration_Units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pulse_Duration_Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Pulse_Conf.
function Pulse_Conf_Callback(hObject, eventdata, handles)
% hObject    handle to Pulse_Conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AQ_mode.
function AQ_mode_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AQ_mode

if ~hObject.Value
    set([handles.AQ_DSA handles.AQ_PXI ...
        handles.Z_Method handles.DSA_TF_Conf ...
        handles.Sine_Amp handles.Sine_Amp_Units ...
        handles.Sine_Freq handles.Sine_Freq_Units ...
        handles.Noise_Method handles.DSA_Noise_Conf ...
        handles.Noise_Amp handles.Noise_Amp_Units],'Enable','off');
else
    set([handles.AQ_DSA handles.AQ_PXI ...
        handles.Z_Method handles.DSA_TF_Conf ...
        handles.Sine_Amp handles.Sine_Amp_Units ...
        handles.Sine_Freq handles.Sine_Freq_Units ...
        handles.Noise_Method handles.DSA_Noise_Conf ...
        handles.Noise_Amp handles.Noise_Amp_Units],'Enable','on');
end


% --- Executes on button press in AQ_Pulse.
function AQ_Pulse_Callback(hObject, eventdata, handles)
% hObject    handle to AQ_Pulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AQ_Pulse

if hObject.Value
    set([handles.Pulse_Conf handles.Pulse_Amp handles.Pulse_Amp_Units ...
        handles.Pulse_Range handles.Pulse_Range_Units ...
        handles.Pulse_Duration handles.Pulse_Duration_Units],'Enable','on');
else
    set([handles.Pulse_Conf handles.Pulse_Amp handles.Pulse_Amp_Units ...
        handles.Pulse_Range handles.Pulse_Range_Units ...
        handles.Pulse_Duration handles.Pulse_Duration_Units],'Enable','off');
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

if hObject.Value
    set([handles.Ibias_Table handles.Manual handles.FromFile handles.FromGraph ...
        handles.Ibias_Browse handles.Ibias_File_Str ...
        handles.Ibias_Add handles.Ibias_Remove handles.Ibias_NRepeat_Str handles.Ibias_NRepeat ...
        handles.Ibias_Negative handles.Ibias_Table_Units],'Enable','on')
else
    set([handles.Ibias_Table handles.Manual handles.FromFile handles.FromGraph ...
        handles.Ibias_Browse handles.Ibias_File_Str ...
        handles.Ibias_Add handles.Ibias_Remove handles.Ibias_NRepeat_Str handles.Ibias_NRepeat ...
        handles.Ibias_Negative handles.Ibias_Table_Units],'Enable','off')
end
    
    
    


% --- Executes on button press in BField_Mode.
function BField_Mode_Callback(hObject, eventdata, handles)
% hObject    handle to BField_Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BField_Mode
if hObject.Value
    set([handles.Field_Table handles.Field_Table_Str],'Enable','on');
else
    set([handles.Field_Table handles.Field_Table_Str],'Enable','off');
end


% --- Executes on button press in Field_Add.
function Field_Add_Callback(hObject, eventdata, handles)
% hObject    handle to Field_Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Field_Table.Data = [handles.Field_Table.Data; cell(1,3)];

% --- Executes on button press in Field_Remove.
function Field_Remove_Callback(hObject, eventdata, handles)
% hObject    handle to Field_Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if size(handles.Field_Table.Data,1) > 1
    handles.Field_Table.Data(end,:) = [];
end
