function varargout = DBInterface(varargin)
% DBINTERFACE MATLAB code for DBInterface.fig
%      DBINTERFACE, by itself, creates a new DBINTERFACE or raises the existing
%      singleton*.
%
%      H = DBINTERFACE returns the handle to a new DBINTERFACE or the handle to
%      the existing singleton*.
%
%      DBINTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DBINTERFACE.M with the given input arguments.
%
%      DBINTERFACE('Property','Value',...) creates a new DBINTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DBInterface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DBInterface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DBInterface

% Last Modified by GUIDE v2.5 18-Mar-2019 14:13:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DBInterface_OpeningFcn, ...
                   'gui_OutputFcn',  @DBInterface_OutputFcn, ...
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


% --- Executes just before DBInterface is made visible.
function DBInterface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DBInterface (see VARARGIN)

% Choose default command line output for DBInterface
handles.output = hObject;
% handles.DataBasePath = 'C:\Users\itinerante.CUD\Documents\GitHub\Zartes\';
% handles.DataBaseName = 'ZarTESDB';

handles.DataBasePath = 'G:\Unidades compartidas\X-IFU\Software\ZarTES_DataBase\';
if ~exist(handles.DataBasePath,'dir')
    handles.DataBasePath = 'G:\Shared drives\X-IFU\Software\ZarTES_DataBase\';
end
    
handles.DataBaseName = 'ZarTESDB';
handles.VersionStr = 'ZarTES DataBase v1.0';

prompt = {'Enter the UserName:','Enter the Password:'};
name = 'ZarTESDB Connection';
numlines = 1;
defaultanswer = {'',''};

answer = inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
%     return;
else
    
    handles.conn = database(handles.DataBaseName,answer{1},answer{2});
%     if ~strcmp(handles.conn.UserName,'jbolea')
%         handles.conn.ReadOnly = 'on';
%     end
end
t = tables(handles.conn,[handles.DataBasePath handles.DataBaseName '.mdb']);
% t = tables(handles.conn,[handles.DataBasePath 'ZarTESDB.mdb']);

handles.usuarios = {'jbolea';'acamon';'cpobes';'stricho'};
handles.jbolea_tablas = t;
handles.acamon_tablas = {'BULK_RT';'Data_Acquisition';'SQUID';'TES_RT'};
handles.cpobes_tablas = {'TES_Analysis'};
handles.stricho_tablas = {'Absorbent';'Masks';'Sputtering_params';'Sputtering_Tech';'Wafers'};


set(handles.figure1,'Name',handles.VersionStr);

TableListStr = {[]};
j = 1;
for i = 1:size(t,1)
    if isequal(t{i,2},'TABLE')
        TableListStr{i,1} = t{i,1};
        j = j+1;
    end
end
handles.TableListStr = TableListStr;
handles.TableList.String = handles.TableListStr;
handles.TableList.Value = 1;

% Update handles structure
guidata(hObject, handles);
refreshTable(hObject);

% UIWAIT makes DBInterface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DBInterface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function refreshTable(src,evnt)
handles = guidata(src);
sqlquery = ['SELECT * FROM '  handles.TableListStr{handles.TableList.Value}];
curs = exec(handles.conn,sqlquery);
curs = fetch(curs);
colnames = columnnames(curs,1);
atr = attr(curs);
handles.Table1.ColumnName = colnames;
for i = 1:length(atr)
    switch atr(i).typeName
        case 'VARCHAR'
            handles.Table1.ColumnFormat{i} = 'char';
        case 'INTEGER'
            handles.Table1.ColumnFormat{i} = 'numeric';
        case 'DOUBLE'
            handles.Table1.ColumnFormat{i} = 'numeric';
    end
    switch handles.TableListStr{handles.TableList.Value}
        
        otherwise
            if (~isequal(colnames{i},'Id'))
                handles.Table1.ColumnEditable(i) = true;
            else
                handles.Table1.ColumnEditable(i) = false;
            end                        
    end
end                
handles.Table1.Data = curs.Data;
guidata(src,handles);

% --- Executes on selection change in TableList.
function TableList_Callback(hObject, eventdata, handles)
% hObject    handle to TableList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TableList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TableList
refreshTable(hObject);

% --- Executes during object creation, after setting all properties.
function TableList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TableList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in InsertData.
function InsertData_Callback(hObject, eventdata, handles)
% hObject    handle to InsertData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tablename = handles.TableListStr{handles.TableList.Value};
if eval(['~isempty(find(ismember(handles.' handles.conn.UserName '_tablas, tablename), 1))'])
    handles.conn.ReadOnly = 'off';
else
    handles.conn.ReadOnly = 'on';
end

switch handles.conn.ReadOnly
    case 'off'
%         tablename = handles.TableListStr{handles.TableList.Value};
        PrimaryKeyStr = {'Id'};
        sqlquery = ['SELECT ' PrimaryKeyStr{1} ' FROM ' tablename];
        curs = exec(handles.conn,sqlquery);
        curs = fetch(curs);
        data{1} = length(curs.Data)+1;
        
        sqlquery = ['SELECT * FROM ' tablename];
        curs = exec(handles.conn,sqlquery);
        curs = fetch(curs);
        colnames = columnnames(curs,1);
        atr = attr(curs);
        
        IDStr = {'Id'};
        ID_Table = {tablename};
        
        
        for i = 2:length(colnames)
            ind = find(cellfun('isempty',strfind(IDStr,colnames{i}))==0);
            try
                if ~isequal(IDStr{ind},colnames{i})
                    ind = [];
                end
            end
            if ~isempty(ind)
                
                if ~(length(curs.Data) == 1 && isequal(curs.Data{1},'No Data'))
                    sqlquery = ['SELECT ' IDStr{ind} ' FROM ' ID_Table{ind}];
                    curs1 = exec(handles.conn,sqlquery);
                    curs1 = fetch(curs1);
                    if ischar(curs1.Data{1})
                        ListStr = curs1.Data;
                    else
                        ListStr = num2str(cell2mat(curs1.Data));
                    end
                    [s,v] = listdlg('PromptString',['Select an ' IDStr{ind} ':'],...
                        'SelectionMode','single',...
                        'ListString',ListStr);
                    if v
                        switch atr(i).typeName
                            case 'VARCHAR'
                                if ischar(curs1.Data{s})
                                    data{i} = curs1.Data{s};
                                else
                                    data{i} = num2str(curs1.Data{s});
                                end
                            case 'DOUBLE'
                                if isnumeric(curs1.Data{s})
                                    data{i} = curs1.Data{s};
                                else
                                    data{i} = str2double(curs1.Data{s});
                                end
                            case 'INTEGER'
                                if isnumeric(curs1.Data{s})
                                    data{i} = curs1.Data{s};
                                else
                                    data{i} = str2double(curs1.Data{s});
                                end
                        end
                        continue;
                    elseif ~isequal(tablename,ID_Table{ind})
                        warndlg(['No ' IDStr{ind} ' selected. To add a new one, use the ' ID_Table{ind} ' Table.'],'ZarTES DB 1.0');
                        return;
                    end
                elseif length(curs.Data) == 1 && isequal(curs.Data{1},'No Data')
                    sqlquery = ['SELECT ' IDStr{ind} ' FROM ' ID_Table{ind}];
                    curs1 = exec(handles.conn,sqlquery);
                    curs1 = fetch(curs1);
                    if ischar(curs1.Data{1})
                        ListStr = curs1.Data;
                    else
                        ListStr = num2str(cell2mat(curs1.Data));
                    end
                    [s,v] = listdlg('PromptString',['Select an ' IDStr{ind} ':'],...
                        'SelectionMode','single',...
                        'ListString',ListStr);
                    if v
                        switch atr(i).typeName
                            case 'VARCHAR'
                                if ischar(curs1.Data{s})
                                    data{i} = curs1.Data{s};
                                else
                                    data{i} = num2str(curs1.Data{s});
                                end
                            case 'DOUBLE'
                                if isnumeric(curs1.Data{s})
                                    data{i} = curs1.Data{s};
                                else
                                    data{i} = str2double(curs1.Data{s});
                                end
                            case 'INTEGER'
                                if isnumeric(curs1.Data{s})
                                    data{i} = curs1.Data{s};
                                else
                                    data{i} = str2double(curs1.Data{s});
                                end
                        end
                        continue;
                    elseif ~isequal(tablename,ID_Table{ind})
                        warndlg(['No ' IDStr{ind} ' selected. To add a new one, use the ' ID_Table{ind} ' Table.'],handles.VersionStr);
                        return;
                    end
                end
            end
            
            
            prompt ={['Enter the ' colnames{i}]};
            name = ['Input for ' tablename];
            numlines = [1 50];
            defaultanswer = {''};
            answer = inputdlg(prompt,name,numlines,defaultanswer);
            if ~isempty(answer)
                switch atr(i).typeName
                    case 'VARCHAR'
                        data{i} = answer{1};
                    case 'DOUBLE'
                        data{i} = str2double(answer{1});
                    case 'INTEGER'
                        data{i} = str2double(answer{1});
                end
            else
                return;
            end
            
            
        end
        
        
        datainsert(handles.conn,tablename,colnames,data)
        refreshTable(hObject)
    case 'on'
        waitfor(warndlg('Only permission to read',handles.VersionStr));
end

% --- Executes on button press in UpdateTable.
function UpdateTable_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tablename = handles.TableListStr{handles.TableList.Value};
if eval(['~isempty(find(ismember(handles.' handles.conn.UserName '_tablas, tablename), 1))'])
    handles.conn.ReadOnly = 'off';
else
    handles.conn.ReadOnly = 'on';
end

% tablename = handles.TableListStr{handles.TableList.Value};
ColumnName = handles.Table1.ColumnName{eventdata.Indices(2)};

if ischar(eventdata.PreviousData)
    if isequal(eventdata.PreviousData,'null')
        query = ['update ' tablename ' SET ' ColumnName ' = ''' eventdata.NewData ''' WHERE ' ColumnName ' IS NULL'];
    else
        query = ['update ' tablename ' SET ' ColumnName ' = ''' eventdata.NewData ''' WHERE ' ColumnName ' = ''' eventdata.PreviousData '''' ''];
    end
elseif isnumeric(eventdata.PreviousData)
    if isnan(eventdata.PreviousData)
        query = ['update ' tablename ' SET ' ColumnName ' = ' num2str(eventdata.NewData) ' WHERE ' ColumnName ' IS NULL'];
    else
        query = ['update ' tablename ' SET ' ColumnName ' = ' num2str(eventdata.NewData) ' WHERE ' ColumnName ' = ' num2str(eventdata.PreviousData)];
    end
end
curs = exec(handles.conn,query);
curs = fetch(curs);

guidata(hObject,handles);
refreshTable(hObject);


% --- Executes when entered data in editable cell(s) in Table1.
function Table1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Table1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

tablename = handles.TableListStr{handles.TableList.Value};
if eval(['~isempty(find(ismember(handles.' handles.conn.UserName '_tablas, tablename), 1))'])
    handles.conn.ReadOnly = 'off';
else
    handles.conn.ReadOnly = 'on';
end

% tablename = handles.TableListStr{handles.TableList.Value};
ColumnName = handles.Table1.ColumnName{eventdata.Indices(2)};

if ischar(eventdata.PreviousData)
    if isequal(eventdata.PreviousData,'null')
        query = ['update ' tablename ' SET ' ColumnName ' = ''' eventdata.NewData ''' WHERE ' ColumnName ' IS NULL AND ' handles.Table1.ColumnName{1} ' = ' num2str(eventdata.Source.Data{eventdata.Indices(1),1}) ''];
    else
        query = ['update ' tablename ' SET ' ColumnName ' = ''' eventdata.NewData ''' WHERE ' ColumnName ' = ''' eventdata.PreviousData ''' AND ' handles.Table1.ColumnName{1} ' = ' num2str(eventdata.Source.Data{eventdata.Indices(1),1}) ''];
    end
elseif isnumeric(eventdata.PreviousData)
    if isnan(eventdata.PreviousData)
        query = ['update ' tablename ' SET ' ColumnName ' = ' num2str(eventdata.NewData) ' WHERE ' ColumnName ' IS NULL AND ' handles.Table1.ColumnName{1} ' = ' num2str(eventdata.Source.Data{eventdata.Indices(1),1}) ''];
    else
        if isnan(eventdata.NewData)
            query = ['update ' tablename ' SET ' ColumnName ' = NULL WHERE ' ColumnName ' = ' num2str(eventdata.PreviousData) ' AND ' handles.Table1.ColumnName{1} ' = ' num2str(eventdata.Source.Data{eventdata.Indices(1),1}) ''];
        else
            %         query = ['update ' tablename ' SET ' ColumnName ' = ' num2str(eventdata.NewData) ' WHERE ' ColumnName ' = ' num2str(eventdata.PreviousData) ''];
            query = ['update ' tablename ' SET ' ColumnName ' = ' num2str(eventdata.NewData) ' WHERE ' ColumnName ' = ' num2str(eventdata.PreviousData) ' AND ' handles.Table1.ColumnName{1} ' = ' num2str(eventdata.Source.Data{eventdata.Indices(1),1}) ''];
        end
    end
end
curs = exec(handles.conn,query);
curs = fetch(curs);
pause(1);
guidata(hObject,handles);
pause(1);
refreshTable(hObject);






function QueryStr_Callback(hObject, eventdata, handles)
% hObject    handle to QueryStr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QueryStr as text
%        str2double(get(hObject,'String')) returns contents of QueryStr as a double


% --- Executes during object creation, after setting all properties.
function QueryStr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QueryStr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ExecButton.
function ExecButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExecButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

query = handles.QueryStr.String;
curs = exec(handles.conn,query);
curs = fetch(curs);

if ~isempty(strfind(upper(query),'CREATE'))||~isempty(strfind(upper(query),'DROP'))
    if isempty(curs.Message)
        t = tables(handles.conn,[handles.DataBasePath handles.DataBaseName '.mdb']);
        
        TableListStr = {[]};
        j = 1;
        for i = 1:size(t,1)
            if isequal(t{i,2},'TABLE')
                TableListStr{i,1} = t{i,1};
                j = j+1;
            end
        end
        handles.TableListStr = TableListStr;
        handles.TableList.String = handles.TableListStr;
        handles.TableList.Value = 1;
        
        % Update handles structure
        guidata(hObject, handles);
        if ~isempty(strfind(upper(query),'CREATE'))
            msgbox('Table was sucessfully created',handles.VersionStr);
        else
            msgbox('Table was sucessfully deleted ',handles.VersionStr);
        end
    end
    return;
end
atr = attr(curs);
if isequal(atr.message,'Invalid Cursor')
    warndlg('Invalid Query',handles.VersionStr);
    return;
end
refreshTable(hObject);
C = strsplit(curs.columnnames,''',''');
C{1}(1) = [];
C{end}(end) = [];
handles.Table1.ColumnName = C;
handles.Table1.Data = curs.Data;
