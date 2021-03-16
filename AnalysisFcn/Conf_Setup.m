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

% Last Modified by GUIDE v2.5 14-Jan-2019 10:34:41

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
    'Units','Normalized','ButtonDownFcn',{@ExportData});

handles.versionStr = 'ZarTES v4.0';

switch varargin{1}.Tag
    case 'Squid_Pulse_Input_Conf'
        hndl = guidata(varargin{1});
        handles.figure1.Name = 'Pulse Input Configuration';
        handles.Table.ColumnEditable = [false true false];
        handles.Table.ColumnName = {'Parameter';'Value';'Units'};
        handles.Options.Visible = 'off';
        handles.Table.Data = [{'Amp'} {hndl.Squid.PulseAmp.Value} {hndl.Squid.PulseAmp.Units};...
            {'Range'} {hndl.Squid.PulseDT.Value} {hndl.Squid.PulseDT.Units};...
            {'Duration'} {hndl.Squid.PulseDuration.Value} {hndl.Squid.PulseDuration.Units};...
            {'RL'} {hndl.Squid.RL.Value} {hndl.Squid.RL.Units}];
        
    case 'DSA_TF_Zw_Conf'
        handles.figure1.Name = 'DSA Configuration';
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
        ConfInstrs{3} = DSA_Conf.WNoise;
        handles.Options.String = {'Sweept Sine';'Fixed Sine';'White Noise'};
        handles.Options.Value = varargin{2};
        
%         OptStr = {'SSine';'FSine';'WNoise'};
        OptStr = {'SSine'};
        
        for j = 1:length(OptStr)
            
            eval(['Srch = strfind(DSA_Conf.' OptStr{j} ',''SRLV '');']);
            for i = 1:length(Srch)
                if isempty(Srch{i})
                    Srch{i} = 0;
                end
            end
            Srch = cell2mat(Srch);
            if hndl.DSA_Input_Amp_Units.Value == 4 % Porcentaje sobre Ibias
                Porc = str2double(hndl.DSA_Input_Amp.String)/100;
                if ~handles1.SetupTES.LNCS_Active.Value
                    Ireal = handles1.SetupTES.Squid.Read_Current_Value;
                else
                    Ireal = handles1.SetupTES.Squid.Read_Current_Value_LNCS;
                end
                SRLV_str = Ireal.Value*1e1*Porc;
            else
                Str = eval(['DSA_Conf.' OptStr{j} '{Srch == 1};']);
                SRLV_str = Str(strfind(Str,'SRLV ')+5:end-2);
            end
            eval(['DSA_Conf.' OptStr{j} '{Srch == 1} = [''SRLV ' num2str(SRLV_str) 'mV''];'])
        end
        
        Srch = strfind(DSA_Conf.FSine,'FSIN ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        DSA_Conf.FSine{Srch == 1} = ['FSIN ' varargin{3}.DSA_Input_Freq.String 'Hz'];
        
        
        ConfInstrs{1} = DSA_Conf.SSine;
        ConfInstrs{2} = DSA_Conf.FSine;
        ConfInstrs{3} = DSA_Conf.WNoise;
        % Configuration of the DSA options
        handles.handles1 = handles1;
        handles.ConfInstrs = ConfInstrs;
        handles.Table.Data = handles.ConfInstrs{varargin{2}};
        
    case 'DSA_TF_Noise_Conf'
        handles.figure1.Name = 'DSA Configuration';
        hndl = guidata(varargin{1});
        if isfield(hndl.SetupTES,'SetupTES')
            DSA_Conf = hndl.SetupTES.DSA.Config;
            handles1.SetupTES = hndl.SetupTES;
        else
            DSA_Conf = hndl.DSA.Config;
            handles1.SetupTES = hndl;
        end
        
        ConfInstrs{1} = DSA_Conf.Noise;
        handles.Options.String = {'Noise Setup'};
%         handles.Options.Value = varargin{2};
        handles.Options.Value = 1;
        
        % Noise Conf.
        Srch = strfind(DSA_Conf.Noise,'SF ');
        for i = 1:length(Srch)
            if isempty(Srch{i})
                Srch{i} = 0;
            end
        end
        Srch = cell2mat(Srch);
        DSA_Conf.Noise{Srch == 1} = ['SF ' varargin{3}.DSA_Input_Freq.String 'Hz'];
        ConfInstrs{2} = DSA_Conf.Noise;
        % Configuration of the DSA options
        handles.ConfInstrs = ConfInstrs;
        
        handles.Table.Data = handles.ConfInstrs{1};
        handles.handles1 = handles1;
        
    case 'SQ_RangeIbias'
        hndl = guidata(varargin{1});
        handles.figure1.Name = 'Ibias Range Configuration';
        handles.Table.ColumnEditable = [true true true];
        handles.Table.ColumnName = {'Initial Value';'Step';'Final Value'};
        handles.Options.Visible = 'off';
        handles.Table.Data = hndl.IbiasRange;
    case 'CurSource_Range'
        hndl = guidata(varargin{1});
        handles.figure1.Name = 'Field Range Configuration';
        handles.Table.ColumnEditable = [true true true];
        handles.Table.ColumnName = {'Initial Value';'Step';'Final Value'};
        handles.Options.Visible = 'off';
        handles.Table.Data = hndl.FieldRange;
    case 'Param_Delay'
        set(handles.figure1,'Name',handles.varargin{1}.UserData);
        set([handles.Add handles.Remove handles.Options],'Visible','off');
        handles.Table.Data = {[]};
        handles.Table.ColumnEditable = [false true false];
        TESProp = properties(handles.varargin{3});
        handles.Table.ColumnName = {'Parameter';'Value';'Units'};
        if length(TESProp) == 2
            TESUnits = {'s';'s'};
        else
            TESUnits = {'s';'s';'';''};
        end
%         handles.Table.Data(1:length(TESProp),1) = TESProp;
        for i = 1:length(TESProp)
            if ~isempty(eval(['handles.varargin{3}.' TESProp{i}]))
                handles.Table.Data{i,1} = TESProp{i};
                handles.Table.Data{i,2} = eval(['handles.varargin{3}.' TESProp{i}]);
                handles.Table.Data{i,3} = TESUnits{i};
            end
        end
    case 'TES_Struct'
        set(handles.figure1,'Name','TES Circuit Parameters');
        set([handles.Add handles.Remove handles.Options],'Visible','off');
        handles.Table.ColumnName = {'Parameter';'Value';'Units'};
        handles.Table.ColumnEditable = [false true false];
%         CircProp = properties(handles.varargin{3}.circuit);  
        CircProp = properties(handles.varargin{3});  
        ind = find(cellfun(@(s) ~isempty(strfind('CurrOffset', s)), CircProp)==1);
        inds = [1:6 ind];
%         TESUnits = {'Ohm';'Ohm';'uA/phi';'uA/phi';'H';'pA/Hz^{0.5}'};
        handles.Table.Data(1:7,1) = CircProp(inds);
        for i = 1:7
            handles.Table.Data{i,2} = eval(['handles.varargin{3}.' CircProp{inds(i)} '.Value']);
            handles.Table.Data{i,3} = eval(['handles.varargin{3}.' CircProp{inds(i)} '.Units']);
        end
    case 'TES_ThermalParam'
        set(handles.figure1,'Name',['TES Operating Point - ' handles.varargin{1}.Name]);
        set([handles.Add handles.Remove handles.Options handles.Save],'Visible','off');
        handles.Table.ColumnName = {'Parameter';'Value';'Units'};
        handles.Table.ColumnEditable = [false false false];
        TESProp = properties(handles.varargin{3});
%         TESUnits = {'adim';'adim';'W/K^n';'W/K^n';'K';'K';'W/K';'W/K';'W/K'};
        handles.Table.Data(1:length(TESProp)-1,1) = TESProp(1:end-1);
        handles.Table.Data(length(TESProp),1) = {['%' TESProp{end}]};
        for i = 1:length(TESProp)
            handles.Table.Data{i,2} = eval(['handles.varargin{3}.' TESProp{i} '.Value']);
            handles.Table.Data{i,3} = eval(['handles.varargin{3}.' TESProp{i} '.Units']);
        end
    case 'TES_Param'
        set(handles.figure1,'Name',['TES Parameters - ' handles.varargin{1}.Name]);
        set([handles.Add handles.Remove handles.Options handles.Save],'Visible','off');
        handles.Table.ColumnName = {'Parameter';'Value';'Units'};
        handles.Table.ColumnEditable = [false false false];
        TESProp = properties(handles.varargin{3});
%         TESUnits = {'Ohm';'Ohm';'V/uA';'V/uA';'K';'#'};
        handles.Table.Data(1:length(TESProp),1) = TESProp(1:length(TESProp));
        for i = 1:length(TESProp)
            handles.Table.Data{i,2} = eval(['handles.varargin{3}.' TESProp{i} '.Value']);
            handles.Table.Data{i,3} = eval(['handles.varargin{3}.' TESProp{i} '.Units']);
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
    case 'TES_ElectrThermModel'
        set(handles.figure1,'Name','Electro-Thermal Model Z(w) and Noise Fitting Options');
        set([handles.Add handles.Remove handles.Options],'Visible','off');
        handles.Table.Data = {[]};
        
        TESProp = properties(handles.varargin{3});
        j = 1;
        for i = 1:length(TESProp)            
            if strfind(TESProp{i},'Selected')
                cellList = eval(['handles.varargin{3}.' TESProp{i-1}])'; 
                handles.Table.Data{1,j} = char(cellList(eval(['handles.varargin{3}.' TESProp{i}])));
                j = j+1;
            elseif strfind(TESProp{i},'bool')
                handles.Table.ColumnEditable(j) = true;
                handles.Table.ColumnFormat{j} = 'Logical';
                handles.Table.ColumnName{j} = TESProp{i};
                if eval(['handles.varargin{3}.' TESProp{i}])
                    handles.Table.Data{1,j} = true;
                else
                    handles.Table.Data{1,j} = false;
                end
                j = j+1;                
            elseif iscell(eval(['handles.varargin{3}.' TESProp{i}]))   
                handles.Table.ColumnEditable(j) = true;
                handles.Table.ColumnFormat{j} = eval(['handles.varargin{3}.' TESProp{i}])';
                handles.Table.ColumnName{j} = TESProp{i};                                
                
            elseif isnumeric(eval(['handles.varargin{3}.' TESProp{i}]))
                handles.Table.ColumnEditable(j) = true;
                handles.Table.ColumnFormat{j} = 'numeric';
                handles.Table.ColumnName{j} = TESProp{i};
                if size(eval(['handles.varargin{3}.' TESProp{i}]),2) == 1
                    handles.Table.Data{1,j} = eval(['handles.varargin{3}.' TESProp{i}]);    
                else
                    handles.Table.Data{1,j} = num2str(eval(['handles.varargin{3}.' TESProp{i}]));
                end
                j = j+1;
            end
           
        end
        
    case 'TES_PvTModel'
        set(handles.figure1,'Name','P vs T Model Fitting Options');
        set([handles.Add handles.Remove handles.Options],'Visible','off');
        handles.Table.Data = {[]};
        
        TESProp = properties(handles.varargin{3});
        j = 1;
        for i = 1:length(TESProp)            
            if strfind(TESProp{i},'Selected')
                cellList = eval(['handles.varargin{3}.' TESProp{i-1}])'; 
                handles.Table.Data{1,j} = char(cellList(eval(['handles.varargin{3}.' TESProp{i}])));
                j = j+1;
            elseif strfind(TESProp{i},'bool')
                handles.Table.ColumnEditable(j) = true;
                handles.Table.ColumnFormat{j} = 'Logical';
                handles.Table.ColumnName{j} = TESProp{i};
                if eval(['handles.varargin{3}.' TESProp{i}])
                    handles.Table.Data{1,j} = true;
                else
                    handles.Table.Data{1,j} = false;
                end
                j = j+1; 
            elseif iscell(eval(['handles.varargin{3}.' TESProp{i}]))   
                handles.Table.ColumnEditable(j) = true;
                handles.Table.ColumnFormat{j} = eval(['handles.varargin{3}.' TESProp{i}])';
                handles.Table.ColumnName{j} = TESProp{i};                                
                
            elseif isnumeric(eval(['handles.varargin{3}.' TESProp{i}]))
                handles.Table.ColumnEditable(j) = true;
                handles.Table.ColumnFormat{j} = 'numeric';
                handles.Table.ColumnName{j} = TESProp{i};
                handles.Table.Data{1,j} = num2str(eval(['handles.varargin{3}.' TESProp{i}]));    
                j = j+1;
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
        handles.Table.ColumnFormat{7} = 'numeric';
        handles.Table.ColumnFormat{8} = 'numeric';
        handles.Table.ColumnFormat{9} = 'numeric';
        handles.Table.ColumnEditable = [true true true true true true true true true];
        
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
        set(handles.figure1,'Name','Report Options');
        set([handles.Add handles.Remove handles.Options],'Visible','off');
        handles.Table.Data = {[]};
        TESProp = properties(handles.varargin{3});
        handles.Table.ColumnName = TESProp';
        for i = 1:length(TESProp)
            handles.Table.ColumnFormat{i} = 'Logical';
            handles.Table.ColumnEditable(i) = true;
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
        
    case 'AQ_Temp_Set'
        set(handles.figure1,'Name','Set Temperatures');
        hndl = guidata(varargin{1});
        handles.Table.ColumnEditable = [true true true];
        handles.Table.ColumnName = {'Initial Value(K)';'Step(K)';'Final Value(K)'};
        handles.Table.Data = {[]};
%         handles.Table.Data = num2cell(hndl.Temp.Values);
        handles.Table.Data = cell(1,3);
        try
            handles.Table.Data(1:size(hndl.Temp.Values,1),size(hndl.Temp.Values,2)) = num2cell(hndl.Temp.Values');
        end
        handles.Options.Visible = 'off';
    case 'AQ_FieldScan_Set'
        set(handles.figure1,'Name','Set Field Value for Scan (max Vout)');
        hndl = guidata(varargin{1});
        handles.Table.ColumnEditable = [true true true];
        handles.Table.ColumnName = {'Initial Value(uA)';'Step(uA)';'Final Value(uA)'};
        handles.Table.Data = cell(1,3);
        try
            handles.Table.Data(1:size(hndl.FieldScan.BVvalues,1),size(hndl.FieldScan.BVvalues,2)) = num2cell(hndl.FieldScan.BVvalues');
        end
        handles.Options.Visible = 'off';
    case 'AQ_IC_Field_Set'
        set(handles.figure1,'Name','Set Field Values for Critical Currents');
        hndl = guidata(varargin{1});
        handles.Table.ColumnEditable = [true true true];
        handles.Table.ColumnName = {'Initial Value(uA)';'Step(uA)';'Final Value(uA)'};
        handles.Table.Data = cell(1,3);
        try
            handles.Table.Data(1:size(hndl.BFieldIC.BVvalue,1),size(hndl.BFieldIC.BVvalue,2)) = num2cell(hndl.BFieldIC.BVvalue');
        catch
        end
        handles.Options.Visible = 'off';
    case 'Ibias_Set'
        set(handles.figure1,'Name','Set Ibias Values for IV Curves');
        hndl = guidata(varargin{1});
        handles.Table.ColumnEditable = [true true true];
        handles.Table.ColumnName = {'Initial Value(uA)';'Step(uA)';'Final Value(uA)'};
        handles.Table.Data = cell(1,3);
        handles.Table.Data = [hndl.IVcurves.Manual.Values.p; hndl.IVcurves.Manual.Values.n];
        handles.Options.Visible = 'off';
    case 'BFieldIC_Ibias'
        set(handles.figure1,'Name','Set Ibias Values for Critical Currents');
        hndl = guidata(varargin{1});
        handles.Table.ColumnEditable = [true true true];
        handles.Table.ColumnName = {'Initial Value(uA)';'Step(uA)';'Final Value(uA)'};
        handles.Table.Data = cell(1,3);
        handles.Table.Data = [hndl.BFieldIC.IbiasValues.p; hndl.BFieldIC.IbiasValues.n];
        handles.Options.Visible = 'off';
    case 'AQ_TF_Rn_P_Set'
        set(handles.figure1,'Name','Set % of Rn Values for Z(w) and Noise Adquisition');
        hndl = guidata(varargin{1});
        handles.Table.ColumnEditable = [true true true];
        handles.Table.ColumnName = {'Initial Value(%)';'Step(%)';'Final Value(%)'};
        handles.Table.Data = cell(1,3);
        try
            handles.Table.Data(1:size(hndl.TF_Zw.rpp,1),size(hndl.TF_Zw.rpp,2)) = num2cell(hndl.TF_Zw.rpp);
        end
        handles.Options.Visible = 'off';
    case 'AQ_TF_Rn_N_Set'
        set(handles.figure1,'Name','Set % of Rn Values for Z(w) and Noise Adquisition');
        hndl = guidata(varargin{1});
        handles.Table.ColumnEditable = [true true true];
        handles.Table.ColumnName = {'Initial Value(%)';'Step(%)';'Final Value(%)'};
        handles.Table.Data = cell(1,3);
        try
            handles.Table.Data(1:size(hndl.TF_Zw.rpn,1),size(hndl.TF_Zw.rpn,2)) = num2cell(hndl.TF_Zw.rpn);
        end
        handles.Options.Visible = 'off';
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
if iscell(handles.Table.Data)
    handles.Table.Data = [handles.Table.Data; cell(1,size(handles.Table.Data,2))];
else
    handles.Table.Data = [handles.Table.Data; NaN];
end
guidata(hObject,handles);

% --- Executes on button press in Remove.
function Remove_Callback(hObject, eventdata, handles)
% hObject    handle to Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if size(handles.Table.Data,1) > 1
    handles.Table.Data(end,:) = [];
end
guidata(hObject,handles);

% --- Executes on selection change in Options.
function Options_Callback(hObject, eventdata, handles)
% hObject    handle to Options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Options contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Options


handles.Table.Data = handles.ConfInstrs{hObject.Value};
guidata(hObject,handles);

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
handles.varargin{1}.UserData = [];
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
    case 'Squid_Pulse_Input_Conf'
        handles.varargin{1}.UserData = handles.Table.Data;
    case 'DSA_TF_Zw_Conf'
        handles.varargin{3}.TF_Menu.Value = handles.Options.Value;
        handles.handles1.SetupTES.DSA.Config.SSine = handles.ConfInstrs{1};
        handles.handles1.SetupTES.DSA.Config.FSine = handles.ConfInstrs{2};
        handles.handles1.SetupTES.DSA.Config.WNoise = handles.ConfInstrs{3};
        guidata(handles.handles1.SetupTES.SetupTES,handles.handles1.SetupTES)
        
    case 'DSA_TF_Noise_Conf'
        handles.varargin{3}.Noise_Menu.Value = handles.Options.Value;
        handles.handles1.SetupTES.DSA.Config.Noise = handles.ConfInstrs{1};
        guidata(handles.handles1.SetupTES.SetupTES,handles.handles1.SetupTES)
        
    case 'SQ_RangeIbias'
        handles.varargin{1}.UserData = handles.Table.Data;
    case 'CurSource_Range'
        handles.varargin{1}.UserData = handles.Table.Data;
            
    case 'Param_Delay'
        NewOpt = IV_Delay;
        ParamDelay = properties(handles.varargin{3});
        for i = 1:length(ParamDelay)
            try
                eval(['NewOPT.' ParamDelay{i} ' = handles.Table.Data{i,2};']);%
            catch
            end                
        end
        handles.varargin{1}.UserData = NewOPT;
        guidata(handles.varargin{1},NewOPT);
    case 'TES_Struct'
        ButtonName = questdlg('Do you want to save these Circuit parameters?', ...
            handles.versionStr, ...
            'Save', 'Cancel', 'Save');
        switch ButtonName
            case 'Save'
                CircProp = properties(handles.varargin{3});
                for i = 1:length(CircProp)
                    try
                        if ~ischar(handles.Table.Data{i,2})
                            eval(['NewCircuit.' CircProp{i} ' = handles.Table.Data{i,2};']);
                        else
                            eval(['NewCircuit.' CircProp{i} ' = str2double(handles.Table.Data{i,2});']);
                        end
                    catch
                    end
                end
                handles.varargin{1}.UserData = NewCircuit;
                guidata(handles.varargin{1},NewCircuit);
        end % switch
        
    case 'TES_PvTModel'
        TESProp = properties(handles.varargin{3});
        j = 1;
        for i = 1:length(TESProp)            
            if strfind(TESProp{i},'Selected')
                c = strfind(eval(['handles.varargin{3}.' TESProp{i-1}]),handles.Table.Data{1,j});
                for c1 = 1:length(c)
                    if c{c1} == 1
                        break;
                    end
                end
                NewOPT = TES_PvTModel;
                eval(['NewOPT.Selected_Models = ' num2str(c1) ';']);
                NewOPT = NewOPT.Constructor;                                                
                j = j+1;               
            elseif i >= 5
                if ~isempty(handles.Table.Data{1,j})
                    s1 = double(handles.Table.Data{1,j});                    
                    sj = 1;                    
                    while ~isempty(s1)                        
                    [cs, s1] = strtok(s1,32);
                    eval(['NewOPT.' TESProp{i} '(sj) = ' char(cs) ';']);
                    sj = sj+1;
                    end
                end      
                j = j+1; 
            end
        end
        handles.varargin{1}.UserData = NewOPT;
        guidata(handles.varargin{1},NewOPT);
        
    case  'TES_ElectrThermModel'
        TES_TF = properties(handles.varargin{3});
        
        for i = 1:length(handles.Table.ColumnName)            
            if strfind(handles.Table.ColumnName{i},'bool')
                if handles.Table.Data{1,i}
                    eval(['NewOPT.' handles.Table.ColumnName{i} ' = 1;']);
                else
                    eval(['NewOPT.' handles.Table.ColumnName{i} ' = 0;']);
                end
            elseif ischar(handles.Table.Data{1,i}) 
                List = eval(['handles.varargin{3}.' handles.Table.ColumnName{i}]);
                try
                    ind = strfind(List,handles.Table.Data{1,i});
                    Index = find(not(cellfun('isempty',ind)));
                    eval(['NewOPT.Selected_' handles.Table.ColumnName{i} ' = Index;']);
                catch
                    eval(['NewOPT.' handles.Table.ColumnName{i} ' = List;']);
                end
            else
                eval(['NewOPT.' handles.Table.ColumnName{i} ' = handles.Table.Data{1,i};']);
            end
                
        end
        handles.varargin{1}.UserData = NewOPT;
        guidata(handles.varargin{1},NewOPT);
        
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
        
    case 'AQ_Temp_Set'
        Temp = ExtractFromTable(handles);
        if size(Temp{1},2) > size(Temp{1},1)
            Temp{1} = Temp{1}';
        end
        handles.varargin{1}.UserData = Temp;
        guidata(handles.varargin{1},guidata(handles.varargin{1}));
        
    case 'AQ_FieldScan_Set'
        Val = ExtractFromTable(handles);
        if size(Val{1},2) > size(Val{1},1)
            Val{1} = Val{1}';
        end
        handles.varargin{1}.UserData = Val;
        guidata(handles.varargin{1},guidata(handles.varargin{1}));
    case 'AQ_IC_Field_Set'
        Val = ExtractFromTable(handles);
        if size(Val{1},2) > size(Val{1},1)
            Val{1} = Val{1}';
        end
        handles.varargin{1}.UserData = Val;
        guidata(handles.varargin{1},guidata(handles.varargin{1}));
    case 'Ibias_Set'
        Val = ExtractFromTable(handles);
        if size(Val{1},2) > size(Val{1},1)
            Val{1} = Val{1}';
        end
        handles.varargin{1}.UserData = Val;
        guidata(handles.varargin{1},guidata(handles.varargin{1}));
    case 'BFieldIC_Ibias'
        Val = ExtractFromTable(handles);
        if size(Val{1},2) > size(Val{1},1)
            Val{1} = Val{1}';
        end
        handles.varargin{1}.UserData = Val;
        guidata(handles.varargin{1},guidata(handles.varargin{1}));
    case 'AQ_TF_Rn_P_Set'
        rpp = ExtractFromTable(handles);
        if size(rpp{1},2) > size(rpp{1},1)
            rpp{1} = rpp{1}';
        end
        handles.varargin{1}.UserData = rpp;
        guidata(handles.varargin{1},guidata(handles.varargin{1}));
        
    case 'AQ_TF_Rn_N_Set'
        rpn = ExtractFromTable(handles);
        if size(rpn{1},2) > size(rpn{1},1)
            rpn{1} = rpn{1}';
        end
        handles.varargin{1}.UserData = rpn;
        guidata(handles.varargin{1},guidata(handles.varargin{1}));
        
end



figure1_DeleteFcn(handles.figure1,eventdata,handles);


% --- Executes when entered data in editable cell(s) in Table.
function Table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

switch handles.varargin{1}.Tag
    case 'DSA_TF_Zw_Conf'
        handles.varargin{3}.DSA_TF_Zw_Menu.Value = handles.Options.Value;
        handles.ConfInstrs{handles.Options.Value} = handles.Table.Data;
        guidata(hObject,handles);
    case 'DSA_TF_Noise_Conf'
        handles.varargin{3}.DSA_TF_Zw_Menu.Value = handles.Options.Value;
        handles.ConfInstrs{handles.Options.Value} = handles.Table.Data;
        guidata(hObject,handles);
    case ''
        handles.Params = handles.Table.Data(:,2);        
        guidata(hObject,handles);
    case 'TES_ElectrThermModel'
        handles.Params = handles.Table.Data(:,2);        
        guidata(hObject,handles);
    case 'TES_PvTModel'
        if isequal(eventdata.Indices,[1,1])&& ~strcmp(eventdata.PreviousData,eventdata.NewData)
            ind = strfind(handles.varargin{3}.Models,char(eventdata.NewData));
            c = true;
            j = 1;
            while c
                if ~isempty(ind{j})
                    c = false;
                    break;
                end
                j = j+1;
            end
            handles.varargin{3}.Selected_Models = j;
            handles.varargin{3} = handles.varargin{3}.BuildPTbModel;
            TESProp = properties(handles.varargin{3});
            j = 1;
            for i = 1:length(TESProp)
                if strfind(TESProp{i},'Selected')
                    cellList = eval(['handles.varargin{3}.' TESProp{i-1}])';
                    handles.Table.Data{1,j} = char(cellList(eval(['handles.varargin{3}.' TESProp{i}])));
                    j = j+1;
                elseif strfind(TESProp{i},'bool')
                    handles.Table.ColumnEditable(j) = true;
                    handles.Table.ColumnFormat{j} = 'Logical';
                    handles.Table.ColumnName{j} = TESProp{i};
                    if eval(['handles.varargin{3}.' TESProp{i}])
                        handles.Table.Data{1,j} = true;
                    else
                        handles.Table.Data{1,j} = false;
                    end
                    j = j+1;
                elseif iscell(eval(['handles.varargin{3}.' TESProp{i}]))
                    handles.Table.ColumnEditable(j) = true;
                    handles.Table.ColumnFormat{j} = eval(['handles.varargin{3}.' TESProp{i}])';
                    handles.Table.ColumnName{j} = TESProp{i};
                    
                elseif isnumeric(eval(['handles.varargin{3}.' TESProp{i}]))
                    handles.Table.ColumnEditable(j) = true;
                    handles.Table.ColumnFormat{j} = 'numeric';
                    handles.Table.ColumnName{j} = TESProp{i};
                    handles.Table.Data{1,j} = num2str(eval(['handles.varargin{3}.' TESProp{i}]));
                    j = j+1;
                end
                
            end
        end
    otherwise
        if ischar(eventdata.Source.Data{eventdata.Indices(1),eventdata.Indices(2)})
            eventdata.Source.Data{eventdata.Indices(1),eventdata.Indices(2)} = str2double(eventdata.Source.Data{eventdata.Indices(1),eventdata.Indices(2)});         
        else
            eventdata.Source.Data{eventdata.Indices(1),eventdata.Indices(2)} = eventdata.Source.Data{eventdata.Indices(1),eventdata.Indices(2)};         
        end
        if ~isempty(strfind(handles.varargin{1}.Tag,'_Rn_'))
            if (str2double(eventdata.NewData) > 1)||(str2double(eventdata.NewData) < 0)
                msgbox('Rn(%) Values must be between 0 and 1',handles.versionStr);
            end
        end    
        
%     case 'AQ_TF_Rn_P_Set'
%         if (str2double(eventdata.NewData) > 1)||(str2double(eventdata.NewData) < 0)
%             msgbox('Rn(%) Values must be between 0 and 1','ZarTES v2.0');
%         end
%     case 'AQ_TF_Rn_N_Set'
%         if (str2double(eventdata.NewData) > 1)||(str2double(eventdata.NewData) < 0)
%             msgbox('Rn(%) Values must be between 0 and 1','ZarTES v2.0');
%         end
end



function Value = ExtractFromTable(handles)

if size(handles.Table.Data,2) > 1
    for i = 1:size(handles.Table.Data,1)
        if isnumeric(handles.Table.Data{i,1})
            try
                Value{i} = handles.Table.Data{i,1}:handles.Table.Data{i,2}:handles.Table.Data{i,3};
            catch
                Value{i} = handles.Table.Data{i,1};
            end
        elseif ischar(handles.Table.Data{i,1})
            Value{i} = str2double(handles.Table.Data{i,1}):str2double(handles.Table.Data{i,2}):str2double(handles.Table.Data{i,3});
            if isnan(Value{i})
                Value{i} = str2double(handles.Table.Data{i,1});
            end
        end
    end
else
    try
        Value{1} = cell2mat(handles.Table.Data);
    catch
        if iscell(handles.Table.Data)&&ischar(handles.Table.Data{1}(1))
            Value{1} = str2double(handles.Table.Data);
        else
            Value{1} = handles.Table.Data;
        end
    end
end
vals = Value;
clear Value;
if median(sign(cell2mat(vals))) == 1
    Value{1} = sort(unique(cell2mat(vals)),'descend');
else
    Value{1} = sort(unique(cell2mat(vals)),'ascend');
end
Value{1}(find(isnan(Value{1}))) = [];

function ExportData(src,evnt)
    

cmenu = uicontextmenu('Visible','on');
c1 = uimenu(cmenu,'Label','Export');

uimenu(c1,'Label','Data to a .txt file','Callback',...
    {@ExportDataTXT});
guidata(c1,guidata(src));
set(src,'uicontextmenu',cmenu);

function ExportDataTXT(src,evnt)   
        

handles = guidata(src);
[FileName, PathName] = uiputfile('.txt', 'Select a file name for storing data');
if isequal(FileName,0)||isempty(FileName)
    return;
end
file = strcat([PathName FileName]);
fid = fopen(file,'a+');
LabelStr = [];
data = [handles.Table.Data{:,2}];
%
%     LabelStr = handles.Table.Data(:,1);
%
%     data = handles.Table.Data(:,1:2)';
for i = 1:length(handles.Table.Data(:,1))
    LabelStr = [LabelStr handles.Table.Data{i,1} '\t'];
end
fprintf(fid,[LabelStr '\n']);
save(file,'data','-ascii','-tabs','-append');
fclose(fid);

