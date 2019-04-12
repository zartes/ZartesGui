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
handles.conn = database('TESdb','','');
t = tables(handles.conn,'C:\USERS\USUARIO\DESKTOP\PRUEBADB\ZarTES.mdb');

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
        case 'INT'
            handles.Table1.ColumnFormat{i} = 'numeric';
        case 'DOUBLE'
            handles.Table1.ColumnFormat{i} = 'numeric';
    end
    if (~isequal(colnames{i},'ID_TES')||~isequal(colnames{i},'ID_Enfriada')||~isequal(colnames{i},'ID_RUN'))
        handles.Table1.ColumnEditable(i) = true;
    else
        handles.Table1.ColumnEditable(i) = false;
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
sqlquery = ['SELECT ZTESID FROM ' tablename];
curs = exec(handles.conn,sqlquery);
curs = fetch(curs);
TESID = max(cell2mat(curs.Data))+1;

sqlquery = ['SELECT * FROM ' tablename];
curs = exec(handles.conn,sqlquery);
curs = fetch(curs);
colnames = columnnames(curs,1);
atr = attr(curs);

data{1} = TESID;
for i = 2:length(colnames)
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
       end                      
   end   
end

% data = {1 'Bolea' 'Juan' 'Argel 19' 37};

datainsert(handles.conn,tablename,colnames,data)
refreshTable(hObject)

% --- Executes on button press in UpdateTable.
function UpdateTable_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% exec(handles.conn,'ALTER TABLE TesZar2 Alter Column Name varchar(30)')
% 
% tablename = handles.TableListStr{handles.TableList.Value};
% sqlquery = ['SELECT * FROM ' tablename ' WHERE ZTESID <> 0'];
% curs = exec(handles.conn,sqlquery);
% curs = fetch(curs);
% colnames = columnnames(curs,1);
% % Data = table(curs.Data);
% Data = handles.Table1.Data;
% % data = {1 'Bolea' 'Juan' 'Argel 19' 37};
% update(handles.conn,tablename,colnames',Data, ' WHERE ZTESID BETWEEN 0 AND 100')
% guidata(hObject,handles);
% 
% refreshTable(hObject)


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
colnames = columnnames(curs,1);
atr = attr(curs);
handles.Table1.ColumnName = colnames;
for i = 1:length(atr)
    switch atr(i).typeName
        case 'VARCHAR'
            handles.Table1.ColumnFormat{i} = 'char';
        case 'INT'
            handles.Table1.ColumnFormat{i} = 'numeric';
        case 'DOUBLE'
            handles.Table1.ColumnFormat{i} = 'numeric';
    end
    if (~isequal(colnames{i},'ID_TES')||~isequal(colnames{i},'ID_Enfriada')||~isequal(colnames{i},'ID_RUN'))
        handles.Table1.ColumnEditable(i) = true;
    else
        handles.Table1.ColumnEditable(i) = false;
    end
end                
handles.Table1.Data = curs.Data;
