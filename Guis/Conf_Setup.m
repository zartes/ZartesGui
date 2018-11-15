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

% Last Modified by GUIDE v2.5 23-Jul-2018 10:35:04

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
handles.varargin = varargin;
position = get(handles.figure1,'Position');
set(handles.figure1,'Color',[0 0.2 0.5],'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');


switch varargin{1}.Tag
    case 'DSA_TF_Conf'
        hndl = guidata(varargin{1});
        if isfield(hndl.SetupTES,'SetupTES')
            DSA_Conf = hndl.SetupTES.DSA.Config;
            handles1.SetupTES = hndl.SetupTES;
        else
            DSA_Conf = hndl.DSA.Config;
            handles1.SetupTES = hndl;
        end
        ConfInstrs{1} = DSA_Conf.SSine;
        ConfInstrs{2} = DSA_Conf.FSine;
        handles.Options.String = {'Sweept Sine';'Fixed Sine'};
        handles.Options.Value = varargin{2};
        
        
        Srch = strfind(DSA_Conf.SSine,'SF ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        DSA_Conf.SSine{Srch == 1} = ['SF ' varargin{3}.Sine_Freq.String 'Hz'];
        
        Srch = strfind(DSA_Conf.SSine,'SRLV ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        DSA_Conf.SSine{Srch == 1} = ['SRLV ' varargin{3}.Sine_Amp.String 'mV'];
        ConfInstrs{1} = DSA_Conf.SSine;
        
        
        Srch = strfind(DSA_Conf.FSine,'FSIN ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        DSA_Conf.FSine{Srch == 1} = ['FSIN ' varargin{3}.Sine_Freq.String 'Hz'];
        
        Srch = strfind(DSA_Conf.FSine,'SRLV ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        DSA_Conf.FSine{Srch == 1} = ['SRLV ' varargin{3}.Sine_Amp.String 'mV'];
        ConfInstrs{2} = DSA_Conf.FSine;
        handles.handles1 = handles1;
        
        
    case 'DSA_Noise_Conf'
        hndl = guidata(varargin{1});
        if isfield(hndl.SetupTES,'SetupTES')
            DSA_Conf = hndl.SetupTES.DSA.Config;
            handles1.SetupTES = hndl.SetupTES;
        else
            DSA_Conf = hndl.DSA.Config;
            handles1.SetupTES = hndl;
        end
        
        ConfInstrs{1} = DSA_Conf.Noise1;
        ConfInstrs{2} = DSA_Conf.Noise2;
        handles.Options.String = {'Noise Setup 1';'Noise Setup 2'};
        handles.Options.Value = varargin{2};
        
        
        Srch = strfind(DSA_Conf.Noise1,'SF ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        DSA_Conf.Noise1{Srch == 1} = ['SF ' varargin{3}.Noise_Amp.String 'Hz'];
        ConfInstrs{1} = DSA_Conf.Noise1;
        % Configuration of the DSA options
        handles.ConfInstrs = ConfInstrs;
        
        handles.Table.Data = handles.ConfInstrs{varargin{2}};
        % Noise Conf.
        
        
        
        Srch = strfind(DSA_Conf.Noise2,'SRLV ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        DSA_Conf.Noise2{Srch == 1} = ['SRLV ' varargin{3}.Noise_Amp.String 'mV'];
        ConfInstrs{2} = DSA_Conf.Noise2;
        % Configuration of the DSA options
        handles.ConfInstrs = ConfInstrs;
        
        handles.Table.Data = handles.ConfInstrs{varargin{2}};        
        handles.handles1 = handles1;
        
    case 'SQ_RangeIbias'
        handles.Table.ColumnEditable = [true true true];
        handles.Table.ColumnName = {'Initial Value';'Step';'Final Value'};
        handles.Options.Visible = 'off';         
        handles.Table.Data = num2cell([500 -10 0]);     
    case 'TES_Struct'
        set(handles.figure1,'Name','TES Circuit Parameters');        
        set([handles.Add handles.Remove handles.Options],'Visible','off');
        handles.Table.ColumnName = {'Parameter';'Value';'Units'};
        handles.Table.ColumnEditable = [false true false];
        CircProp = properties(handles.varargin{3}.circuit);        
        TESUnits = {'Ohm';'Ohm';'uA/phi';'uA/phi';'Ohm';'%';'Ohm';'Ohm';'H'};
        handles.Table.Data(1:length(CircProp),1) = CircProp;
        for i = 1:length(CircProp)
            handles.Table.Data{i,2} = eval(['handles.varargin{3}.circuit.' CircProp{i}]);
            handles.Table.Data{i,3} = TESUnits{i};
        end
    case 'TES_Param'
        set(handles.figure1,'Name','TES Operating Point');
        set([handles.Add handles.Remove handles.Options handles.Save],'Visible','off');
        handles.Table.ColumnName = {'Parameter';'Value';'Units'};
        handles.Table.ColumnEditable = [false false false];
        TESProp = properties(handles.varargin{3});
        TESUnits = {'adim';'pW/K^n';'mK';'pW/K';'m'};
        handles.Table.Data(1:length(TESProp),1) = TESProp;
        for i = 1:length(TESProp)
            handles.Table.Data{i,2} = eval(['handles.varargin{3}.' TESProp{i}]);
            handles.Table.Data{i,3} = TESUnits{i};
        end
    case 'TES_TF_Opt'
        set(handles.figure1,'Name','TF Visualization Options');
        set([handles.Add handles.Remove handles.Options],'Visible','off');
        handles.Table.Data = {[]};
        handles.Table.ColumnEditable = [true true true];
        TESProp = properties(handles.varargin{3});
        handles.Table.ColumnName = TESProp';        
        handles.Table.ColumnFormat{1} = 'Logical';
        handles.Table.ColumnFormat{2} = {'\TF*','\PXI_TF*'};
        handles.Table.ColumnFormat{3} = {'One Single Thermal Block','Two Thermal Blocks'};                        
        for i = 1:length(TESProp)
            if strcmp(handles.Table.ColumnFormat{i},'Logical')
                if eval(['handles.varargin{3}.' TESProp{i}])
                    handles.Table.Data{1,i} = true;
                else
                    handles.Table.Data{1,i} = false;
                end
            else
                handles.Table.Data{1,i} = eval(['handles.varargin{3}.' TESProp{i}]);
            end
        end
        
    case 'TES_Noise_Opt'
        set(handles.figure1,'Name','Noise Visualization Options');
        set([handles.Add handles.Remove handles.Options],'Visible','off');
        handles.Table.Data = {[]};        
        TESProp = properties(handles.varargin{3});                
        handles.Table.ColumnName = TESProp';
        handles.Table.ColumnFormat{1} = {'current','nep'};
        handles.Table.ColumnFormat{2} = 'Logical';
        handles.Table.ColumnFormat{3} = 'Logical';
        handles.Table.ColumnFormat{4} = 'Logical';
        handles.Table.ColumnFormat{5} = {'\HP_noise*','\PXI_noise*'};
        handles.Table.ColumnFormat{6} = {'irwin','wouter'};    
        handles.Table.ColumnEditable = [true true true true true true];
        for i = 1:length(TESProp)
            if strcmp(handles.Table.ColumnFormat{i},'Logical')
                if eval(['handles.varargin{3}.' TESProp{i}])
                    handles.Table.Data{1,i} = true;
                else
                    handles.Table.Data{1,i} = false;
                end
            else
                handles.Table.Data{1,i} = eval(['handles.varargin{3}.' TESProp{i}]);
            end
        end
    case 'TES_Report_Opt'
        set(handles.figure1,'Name','Noise Visualization Options');
        set([handles.Add handles.Remove handles.Options],'Visible','off');
        handles.Table.Data = {[]};        
        TESProp = properties(handles.varargin{3});                
        handles.Table.ColumnName = TESProp';
        handles.Table.ColumnFormat{1} = 'Logical';
        handles.Table.ColumnFormat{2} = 'Logical';
        handles.Table.ColumnFormat{3} = 'Logical';
        handles.Table.ColumnFormat{4} = 'Logical';
        handles.Table.ColumnFormat{5} = 'Logical';
        handles.Table.ColumnFormat{6} = 'Logical'; 
        handles.Table.ColumnEditable = [true true true true true true];
        for i = 1:length(TESProp)
            if strcmp(handles.Table.ColumnFormat{i},'Logical')
                if eval(['handles.varargin{3}.' TESProp{i}])
                    handles.Table.Data{1,i} = true;
                else
                    handles.Table.Data{1,i} = false;
                end
            else
                handles.Table.Data{1,i} = eval(['handles.varargin{3}.' TESProp{i}]);
            end
        end
        
end

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
handles.figure1.Visible = 'on';


% --- Executes on button press in Add.
function Add_Callback(hObject, eventdata, handles)
% hObject    handle to Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Table.Data = [handles.Table.Data; cell(1,3)];

% --- Executes on button press in Remove.
function Remove_Callback(hObject, eventdata, handles)
% hObject    handle to Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if size(handles.Table.Data,1) > 1
    handles.Table.Data(end,:) = [];
end


% --- Executes on selection change in Options.
function Options_Callback(hObject, eventdata, handles)
% hObject    handle to Options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Options contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Options


handles.Table.Data = handles.ConfInstrs{hObject.Value};


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

switch handles.varargin{1}.Tag
    case 'DSA_TF_Conf'
        handles.varargin{3}.TF_Menu.Value = handles.Options.Value;
        handles.handles1.SetupTES.DSA.Config.SSine = handles.ConfInstrs{1};
        handles.handles1.SetupTES.DSA.Config.FSine = handles.ConfInstrs{2};
        guidata(handles.handles1.SetupTES.SetupTES,handles.handles1.SetupTES)

    case 'DSA_Noise_Conf'
        handles.varargin{3}.Noise_Menu.Value = handles.Options.Value;
        handles.handles1.SetupTES.DSA.Config.Noise1 = handles.ConfInstrs{1};
        handles.handles1.SetupTES.DSA.Config.Noise2 = handles.ConfInstrs{2};
        guidata(handles.handles1.SetupTES.SetupTES,handles.handles1.SetupTES)

    case 'SQ_RangeIbias'
        handles.varargin{1}.UserData = handles.Table.Data;
    case 'TES_Struct'
        ButtonName = questdlg('Circuit parameters might be changed', ...
            'ZarTES v1.0', ...
            'Save', 'Cancel', 'Save');
        switch ButtonName
            case 'Save'
                CircProp = properties(handles.varargin{3}.circuit);                                
                for i = 1:length(CircProp)
                    eval(['NewCircuit.' CircProp{i} ' = handles.Table.Data{i,2};']);
                end
                handles.varargin{1}.UserData = NewCircuit;
                guidata(handles.varargin{1},NewCircuit);
        end % switch
    case 'TES_TF_Opt'
        TES_TF = properties(handles.varargin{3});
        for i = 1:length(TES_TF)
            if strcmp(handles.Table.ColumnFormat{i},'Logical')
                if handles.Table.Data{1,i}
                    eval(['NewOPT.' TES_TF{i} ' = 1;']);
                else
                    eval(['NewOPT.' TES_TF{i} ' = 0;']);
                end
            else
                eval(['NewOPT.' TES_TF{i} ' = handles.Table.Data{1,i};']);
            end
        end
        handles.varargin{1}.UserData = NewOPT;
        guidata(handles.varargin{1},NewOPT);
        
    case 'TES_Noise_Opt'
        TES_Noise = properties(handles.varargin{3});        
        for i = 1:length(TES_Noise)
            if strcmp(handles.Table.ColumnFormat{i},'Logical')
                if handles.Table.Data{1,i}
                    eval(['NewOPT.' TES_Noise{i} ' = 1;']);
                else
                    eval(['NewOPT.' TES_Noise{i} ' = 0;']);
                end
            else
                eval(['NewOPT.' TES_Noise{i} ' = handles.Table.Data{1,i};']);
            end
        end
        handles.varargin{1}.UserData = NewOPT;
        guidata(handles.varargin{1},NewOPT);
    case 'TES_Report_Opt'
        TES_Report = properties(handles.varargin{3});        
        for i = 1:length(TES_Report)
            if strcmp(handles.Table.ColumnFormat{i},'Logical')
                if handles.Table.Data{1,i}
                    eval(['NewOPT.' TES_Report{i} ' = 1;']);
                else
                    eval(['NewOPT.' TES_Report{i} ' = 0;']);
                end
            else
                eval(['NewOPT.' TES_Report{i} ' = handles.Table.Data{1,i};']);
            end
        end
        handles.varargin{1}.UserData = NewOPT;
        guidata(handles.varargin{1},NewOPT);
        
end



figure1_DeleteFcn(handles.figure1,eventdata,handles);
