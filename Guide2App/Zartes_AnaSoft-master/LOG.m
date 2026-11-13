function varargout = LOG(varargin)
% LOG MATLAB code for LOG.fig
%      LOG, by itself, creates a new LOG or raises the existing
%      singleton*.
%
%      H = LOG returns the handle to a new LOG or the handle to
%      the existing singleton*.
%
%      LOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOG.M with the given input arguments.
%
%      LOG('Property','Value',...) creates a new LOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LOG_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LOG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LOG

% Last Modified by GUIDE v2.5 21-Oct-2015 15:23:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @LOG_OpeningFcn, ...
    'gui_OutputFcn',  @LOG_OutputFcn, ...
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


% --- Executes just before LOG is made visible.
function LOG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LOG (see VARARGIN)

% Choose default command line output for LOG

handles.output = hObject;

% START USER CODE
% Create a timer object to fire at 1/10 sec intervals
% Specify function handles for its start and run callbacks
Period = 30;
handles.timer = timer(...
    'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly
    'Period', Period, ...                        % Initial period is 1 sec.
    'TimerFcn', {@update_display,hObject}); % Specify callback function
% Initialize slider and its readout text field
dataPlot = 0;
timeAxis = 0;
handles.plot = plot(handles.graph1,timeAxis,dataPlot,'r','LineWidth',1);

close_visible(hObject, eventdata, handles);

% grid minor;
% END USER CODE


% Update handles structure
guidata(hObject,handles);

% UIWAIT makes LOG wait for user response (see UIRESUME)
% uiwait(handles.LOG);


% --- Outputs from this function are returned to the command line.
function varargout = LOG_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%-----------------------------------------------------------------------------------------% Push & Toggle Buttons

function clearTicks()
% AxesHandle=findobj(gcf,'Type','axes');
% pt1 = get(AxesHandle,'Position');
%
% ax1 = axes('Position',pt1,...
%     'XAxisLocation','bottom',...
%     'YAxisLocation','left',...
%     'Color','none');
% set(gca,'XTick',[]);
% set(gca,'YTick',[]);
% ax2 = axes('Position',pt1,...
%     'XAxisLocation','top',...
%     'YAxisLocation','right',...
%     'Color','none');
% set(gca,'XTick',[]);
% set(gca,'YTick',[]);
% set(gca,ax2);

% not working
%%

% --- Executes on button press in multiplot.
function multiplot_Callback(hObject, eventdata, handles)
% hObject    handle to multiplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = hObject;
%
% parameterSelect = get(handles.parameterlist,'Value');
% parameterNames = evalin('base','parameterNames');
% data = evalin('base','dataTemp');
% timeAxis = evalin('base','timeAxis');
% dataPlot1 = cell2mat(data(:,parameterSelect+2));
% dataPlot2 = cell2mat(data(:,parameterSelect+6));
%
% % figure(1);
% line(timeAxis,dataPlot1,'Color','r');
% hold on;
% AxesHandle=findobj(gcf,'Type','axes');
%
% pt1 = get(AxesHandle,'Position');
%
% ax2 = axes('Position',pt1,...
%     'XAxisLocation','top',...
%     'YAxisLocation','right',...
%     'Color','none');
% line(timeAxis,dataPlot2,'Parent',ax2,'Color','k');
% set(gca,'XTick',[]);
%
% pt2 = get(AxesHandle,'Position');
%
% ax2 = axes('Position',pt2,...
%     'XAxisLocation','bottom',...
%     'YAxisLocation','left',...
%     'Color','none');
% hold off;

% not working properly

% Update handles structure
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of multiplot

% --- Executes on button press in infobutton.
function infobutton_Callback(hObject, eventdata, handles)
% hObject    handle to infobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ver100 = {'Version 1.0.0' '-New: Interface works with specific data format.' ...
    '-New: Browsing a file supported with file name and directory information.' ...
    '-New: Auto data update is available.' ...
    '-New: Last data update information is available.' ...
    '-New: Magnify and Zoom features are available.' ...
    '-New: Only one parameter selection is supported.' ...
    '-New: User interface resize behaviour is proportional.' ...
    '-New: Precautions are taken into account for possible errors.' ...
    '-Unresolved: More than one parameter selection does not work.' ...
    '-Unresolved: Errors occur while using Pan. Pan is disabled.' ...
    '-Unresolved: Cursor clean function is required, Data Cursor is disabled. ' ...
    };

ver104 = {'' 'Version 1.0.4' '-Changed: Security fixes for browsing a file.'...
    '-Changed: Parameter selection performance improved.' ...
    '-Changed: User Interface style is upgraded.' ...
    '-Fixed: Initial data plot works properly.' ...
    };

verTotal = [ver100 ver104];

myicon = imread('ICMA2.jpg');
% h=msgbox('Operation Completed','Success','custom',myicon);

uiwait(msgbox(verTotal,'Version Release History','custom',myicon));

% --- Executes on button press in browsefile.
function browsefile_Callback(hObject, eventdata, handles)
% hObject    handle to browsefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% Choose default command line output for LOG
handles.output = hObject;
clc;

set(handles.magnify,'Value',0);
set(handles.zoomx,'Value',0);
set(handles.zoomxy,'Value',0);

f1 = gcf;

set(f1, ...
    'WindowButtonDownFcn',@emptyF, ...
    'WindowButtonUpFcn', @emptyF, ...
    'WindowButtonMotionFcn', @emptyF, ...
    'KeyPressFcn', @emptyF);
zoom off;

set(handles.magnify,'backg',[0.941 0.941 0.941])  % Now reset the button features.
set(handles.zoomxy,'backg',[0.941 0.941 0.941])  % Now reset the button features.
set(handles.zoomx,'backg',[0.941 0.941 0.941])  % Now reset the button features.

try
    [FileName,PathName] = uigetfile('*.*','Select the LOG data file');
    if FileName == 0
        FileName = 'File is not selected.';
        PathName = 'File is not selected.';
        set(handles.filename,'String',FileName);
        set(handles.filedirectory,'String',PathName);
        errordlg('File not found','File Error');
        
        close_visible(hObject, eventdata, handles);
        
        %         uiresume(gcbf);
    else
        set(handles.filename,'String',FileName);
        set(handles.filedirectory,'String',PathName);
        assignin('base','FileName',FileName);
        assignin('base','PathName',PathName);
        getLOG(FileName);
        parameterNames = evalin('base','parameterNames');
        set(handles.parameterlist,'String',transpose(parameterNames(3:length(parameterNames))));
        
        open_visible(hObject, eventdata, handles);
        
        parameterSelect = get(handles.parameterlist,'Value');
        % parameterNames = evalin('base','parameterNames');
        data = evalin('base','dataTemp');
        timeAxis = evalin('base','timeAxis');
        dataPlot = cell2mat(data(:,parameterSelect+2));
        set(handles.plot,'XData',timeAxis,'YData',dataPlot);
        
        setGraphTicks();
    end
catch err
    FileName = 'File is not selected.';
    PathName = 'File is not selected.';
    set(handles.filename,'String',FileName);
    set(handles.filedirectory,'String',PathName);
    errordlg('File not found','File Error');
    
    close_visible(hObject, eventdata, handles);
    
end

% ExPath = [FilePath FileName];
% set(handles.answer_edit,'String',ExPath);

% Update handles structure
guidata(hObject, handles);
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of browsefile

% --- Executes on button press in zoomreset.
function zoomreset_Callback(hObject, eventdata, handles)
% hObject    handle to zoomreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = hObject;
zoom out;

% parameterSelect = get(handles.parameterlist,'Value');
% parameterNames = evalin('base','parameterNames');
% data = evalin('base','dataTemp');
% % parameterNames = transpose(parameterNames(3:length(parameterNames)));
% dataPlot = cell2mat(data(:,parameterSelect+2));
% plot(dataPlot);


% Update handles structure
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of zoomreset

% --- Executes on button press in zoomxy.
function zoomxy_Callback(hObject, eventdata, handles)
% hObject    handle to zoomxy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = hObject;
zoom off;
if get(handles.zoomxy,'Value') == 1
    
    set(gcf, ...
        'WindowButtonDownFcn',@emptyF, ...
        'WindowButtonUpFcn', @emptyF, ...
        'WindowButtonMotionFcn', @emptyF, ...
        'KeyPressFcn', @emptyF);
    %     zoomx_Callback(hObject, eventdata, handles);
    %     zoomxy_Callback(hObject, eventdata, handles)
    set(handles.zoomx,'Value',0);
    set(handles.magnify,'Value',0);
    zoom on;
    % Update handles structure
    
    set(handles.zoomxy,'backg',[1 .6 .6]) % Change color of button.
    set(handles.zoomx,'backg',[0.941 0.941 0.941])  % Now reset the button features.
    set(handles.magnify,'backg',[0.941 0.941 0.941])  % Now reset the button features.
else
    zoom off;
    
    set(handles.zoomxy,'backg',[0.941 0.941 0.941])  % Now reset the button features.
end
%zoom setups
% zoom xon;
% zoom on;
% Update handles structure
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of zoomxy

% --- Executes on button press in zoomx.
function zoomx_Callback(hObject, eventdata, handles)
% hObject    handle to zoomx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = hObject;
zoom off;
if get(handles.zoomx,'Value') == 1
    
    set(gcf, ...
        'WindowButtonDownFcn',@emptyF, ...
        'WindowButtonUpFcn', @emptyF, ...
        'WindowButtonMotionFcn', @emptyF, ...
        'KeyPressFcn', @emptyF);
    %     zoomx_Callback(hObject, eventdata, handles);
    %     zoomxy_Callback(hObject, eventdata, handles)
    set(handles.zoomxy,'Value',0);
    set(handles.magnify,'Value',0);
    zoom xon;
    % Update handles structure
    
    set(handles.zoomx,'backg',[1 .6 .6]) % Change color of button.
    set(handles.zoomxy,'backg',[0.941 0.941 0.941])  % Now reset the button features.
    set(handles.magnify,'backg',[0.941 0.941 0.941])  % Now reset the button features.
else
    zoom off;
    
    set(handles.zoomx,'backg',[0.941 0.941 0.941])  % Now reset the button features.
end
%zoom setups
% zoom xon;
% zoom on;
% Update handles structure
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of zoomx


% --- Executes on button press in magnify.
function magnify_Callback(hObject, eventdata, handles)
% hObject    handle to magnify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = hObject;
zoom off;
f1 = gcf;
if (nargin == 0)
    f1 = gcf;
end;

if get(handles.magnify,'Value') == 1
    set(handles.zoomx,'Value',0);
    set(handles.zoomxy,'Value',0);
    zoom off;
    set(f1, ...
        'WindowButtonDownFcn', @ButtonDownCallback, ...
        'WindowButtonUpFcn', @ButtonUpCallback, ...
        'WindowButtonMotionFcn', @ButtonMotionCallback, ...
        'KeyPressFcn', @KeyPressCallback);
    
    set(handles.magnify,'backg',[1 .6 .6]) % Change color of button.
    set(handles.zoomxy,'backg',[0.941 0.941 0.941])  % Now reset the button features.
    set(handles.zoomx,'backg',[0.941 0.941 0.941])  % Now reset the button features.
else
    set(f1, ...
        'WindowButtonDownFcn',@emptyF, ...
        'WindowButtonUpFcn', @emptyF, ...
        'WindowButtonMotionFcn', @emptyF, ...
        'KeyPressFcn', @emptyF);
    %     zoomx_Callback(hObject, eventdata, handles);
    %     zoomxy_Callback(hObject, eventdata, handles)
    % Update handles structure
    
    set(handles.magnify,'backg',[0.941 0.941 0.941])  % Now reset the button features.
end

% Update handles structure
guidata(hObject, handles);
return;

%-----------------------------------------------------------------------------------------% Sliders

% --- Executes on slider movement.
function scroll_Callback(hObject, eventdata, handles)
% hObject    handle to scroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function scroll_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%----------------------------------------% List & Check Boxes

% --- Executes on button press in autoupdate.
function autoupdate_Callback(hObject, eventdata, handles)
% hObject    handle to autoupdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = hObject;

if get(handles.autoupdate, 'Value') == 1
    start(handles.timer);
else
    stop(handles.timer);
end

% Update handles structure
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of autoupdate

% --- Executes on selection change in parameterlist.
function parameterlist_Callback(hObject, eventdata, handles)
% hObject    handle to parameterlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

parameterSelect = get(handles.parameterlist,'Value');
% parameterNames = evalin('base','parameterNames');
data = evalin('base','dataTemp');
timeAxis = evalin('base','timeAxis');
dataPlot = cell2mat(data(:,parameterSelect+2));
set(handles.plot,'XData',timeAxis,'YData',dataPlot);

% setGraphTicks();

% datetick('x', 'ddd HHPM MM','keeplimits');
%
% % ylim('auto');
% % axis 'auto y';
% dynamicDateTicks(gca, [], 'ddd/mm');
% grid on
% axis tight;

% grid minor;
% set(gca,'XGrid','on');
% set(gca,'XMinorTick', 'on');

%zoom setups
% zoom xon;
% zoom on;

% Update handles structure
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns parameterlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from parameterlist

% --- Executes during object creation, after setting all properties.
function parameterlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameterlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%-----------------------------------------------------------------------------------------% Static Texts

%-----------------------------------------------------------------------------------------% Edit Texts

%-----------------------------------------------------------------------------------------% Axes

%-----------------------------------------------------------------------------------------% Others

function emptyF(~,~,~,~)
return;

function open_visible(hObject, eventdata, handles)

handles.output = hObject;

set(handles.dateHeader,'Visible','on');
set(handles.updatetext,'Visible','on');
set(handles.zoomx,'Visible','on');
set(handles.zoomxy,'Visible','on');
set(handles.zoomreset,'Visible','on');
set(handles.parameterlist,'Visible','on');
set(handles.scroll,'Visible','off');
set(handles.magnify,'Visible','on');
set(handles.autoupdate,'Visible','on');
set(handles.graph1,'Visible','on');
set(handles.multiplot,'Visible','on');
% Update handles structure
guidata(hObject, handles);

function close_visible(hObject, eventdata, handles)

handles.output = hObject;

FileName = 'File is not selected.';
PathName = 'File is not selected.';
set(handles.filename,'String',FileName);
set(handles.filedirectory,'String',PathName);

% set(handles.autoupdate,'Value',0);
% set(handles.magnify,'Value',0);
% set(handles.zoomx,'Value',0);
% set(handles.zoomxy,'Value',0);

set(handles.multiplot,'Visible','off');
set(handles.dateHeader,'Visible','off');
set(handles.updatetext,'Visible','off');
set(handles.plot,'XData',0,'YData',0);
set(handles.zoomx,'Visible','off');
set(handles.zoomxy,'Visible','off');
set(handles.zoomreset,'Visible','off');
set(handles.parameterlist,'Visible','off');
set(handles.scroll,'Visible','off');
set(handles.magnify,'Visible','off');
set(handles.autoupdate,'Visible','off');
set(handles.graph1,'Visible','off');
% Update handles structure
guidata(hObject, handles);

function getLOG(FileName)
LOGfile = importdata(FileName);
data = LOGfile.data;
textdata = LOGfile.textdata;
parameterNames = textdata(1,:);
Fecha = textdata(2:length(textdata(:,1)),1);
Hora = textdata(2:length(textdata(:,2)),2);
data = num2cell(data);
dataTemp = [Fecha Hora data];
formatDate = 'dd/mm/yyyy_HH:MM:SS';
convertDate = strcat(dataTemp(:,1),'_',dataTemp(:,2));
dataDate = datevec(convertDate, formatDate);
timeAxis = datenum(dataDate);
assignin('base','timeAxis',timeAxis);
assignin('base','dataTemp',dataTemp);
assignin('base','parameterNames',parameterNames);

function setGraphTicks()
datetick('x', 'ddd HHPM MM','keeplimits');
% ylim('auto');
% axis 'auto y';
dynamicDateTicks(gca, [], 'ddd/mm');
grid on

% cla(handles.graph1); clears the graph1
% set(gca,'LineWidth',3);

% START USER CODE
function update_display(hObject,eventdata,hfigure)
% Timer timer1 callback, called each time timer iterates.
% Gets surface Z data, adds noise, and writes it back to surface object.

% % Choose default command line output for LOG
% handles.output = hObject;

handles = guidata(hfigure);

FileName = evalin('base','FileName');
getLOG(FileName);

parameterNames = evalin('base','parameterNames');
set(handles.parameterlist,'String',transpose(parameterNames(3:length(parameterNames))));

parameterSelect = get(handles.parameterlist,'Value');
data = evalin('base','dataTemp');
timeAxis = evalin('base','timeAxis');
dataPlot = cell2mat(data(:,parameterSelect+2));
set(handles.plot,'XData',timeAxis,'YData',dataPlot);
% dateInfo = strcat('Last Update: ', datestr(now));
set(handles.updatetext,'String',datestr(now));

% setGraphTicks()
% errordlg('Update Completed','Update');

% END USER CODE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dynamicDateTicks(axH, link, mdformat)
% DYNAMICDATETICKS is a wrapper function around DATETICK which creates
% dynamic date tick labels for plots with dates on the X-axis. The date
% ticks intelligently include year/month/day information on specific ticks
% as appropriate. The ticks are dynamic with respect to zooming and
% panning. They update as the timescale changes (from years to seconds).
% Data tips on the plot also show intelligently as dates.
%
% The function may be used with linked axes as well as with multiple
% independent date and non-date axes within a plot.
%
% USAGE:
% dynamicDateTicks()
%       makes the current axes a date axes with dynamic properties
%
% dynamicDateTicks(axH)
%       makes all the axes handles in vector axH dynamic date axes
%
% dynamicDateTicks(axH, 'link')
%       additionally specifies that all the axes in axH are linked. This
%       option should be used in conjunction with LINKAXES.
%
% dynamicDateTicks(axH, 'link', 'dd/mm')
%       additionally specifies the format of all ticks that include both
%       date and month information. The default value is 'mm/dd' but any
%       valid date string format can be specified. The first two options
%       may be empty [] if only specifying format.
%
% EXAMPLES:
% load integersignal
% dates = datenum('July 1, 2008'):1/24:datenum('May 11, 2009 1:00 PM');
% subplot(2,1,1), plot(dates, Signal1);
% dynamicDateTicks
% subplot(2,1,2), plot(dates, Signal4);
% dynamicDateTicks([], [], 'dd/mm');
%
% figure
% ax1 = subplot(2,1,1); plot(dates, Signal1);
% ax2 = subplot(2,1,2); plot(dates, Signal4);
% linkaxes([ax1 ax2], 'x');
% dynamicDateTicks([ax1 ax2], 'linked')

if nargin < 1 || isempty(axH) % If no axes is specified, use the current axes
    axH = gca;
end

if nargin < 3 % Default mm/dd format
    mdformat = 'mm/dd';
end

% Apply datetick to all axes in axH, and store any linking information
axesInfo.Type = 'dateaxes'; % Information stored in axes userdata indicating that these are date axes
for i = 1:length(axH)
    datetick(axH(i), 'x');
    if nargin > 1 && ~isempty(link) % If axes are linked,
        axesInfo.Linked = axH; % Need to modify all axes at once
    else
        axesInfo.Linked = axH(i); % Need to modify only 1 axes
    end
    axesInfo.mdformat = mdformat; % Remember mm/dd format for each axes
    set(axH(i), 'UserData', axesInfo); % Store the fact that this is a date axes and its link & mm/dd information in userdata
    updateDateLabel('', struct('Axes', axH(i)), 0); % Call once to ensure proper formatting
end

% Set the zoom, pan and datacursor callbacks
figH = get(axH, 'Parent');
if iscell(figH)
    figH = unique([figH{:}]);
end
if length(figH) > 1
    error('Axes should be part of the same plot (have the same figure parent)');
end

z = zoom(figH);
p = pan(figH);
d = datacursormode(figH);

set(z,'ActionPostCallback',@updateDateLabel);
set(p,'ActionPostCallback',@updateDateLabel);
set(d,'UpdateFcn',@dateTip);

% ------------ End of dynamicDateTicks-----------------------

function output_txt = dateTip(gar, ev)
pos = ev.Position;
axHandle = get(ev.Target, 'Parent'); % Which axes is the data cursor on
axesInfo = get(axHandle, 'UserData'); % Get the axes info for that axes
try % If it is a date axes, create a date-friendly data tip
    if strcmp(axesInfo.Type, 'dateaxes')
        output_txt = sprintf('X: %s\nY: %0.4g', datestr(pos(1)), pos(2));
    else
        output_txt = sprintf('X: %0.4g\nY: %0.4g', pos(1), pos(2));
    end
catch % It's not a date axes, create a generic data tip
    output_txt = sprintf('X: %0.4g\nY: %0.4g', pos(1), pos(2));
end

function updateDateLabel(obj, ev, varargin)
ax1 = ev.Axes; % On which axes has the zoom/pan occurred
axesInfo = get(ev.Axes, 'UserData');
% Check if this axes is a date axes. If not, do nothing more (return)
try
    if ~strcmp(axesInfo.Type, 'dateaxes')
        return;
    end
catch
    return;
end

% Re-apply date ticks, but keep limits (unless called the first time)
if nargin < 3
    datetick(ax1, 'x', 'keeplimits');
end


% Get the current axes ticks & labels
ticks  = get(ax1, 'XTick');
labels = get(ax1, 'XTickLabel');

% Sometimes the first tick can be outside axes limits. If so, remove it & its label
if all(ticks(1) < get(ax1,'xlim'))
    ticks(1) = [];
    labels(1,:) = [];
end

[yr, mo, da] = datevec(ticks); % Extract year & day information (necessary for ticks on the boundary)
newlabels = cell(size(labels,1), 1); % Initialize cell array of new tick label information

if regexpi(labels(1,:), '[a-z]{3}', 'once') % Tick format is mmm
    
    % Add year information to first tick & ticks where the year changes
    ind = [1 find(diff(yr))+1];
    newlabels(ind) = cellstr(datestr(ticks(ind), '/yy'));
    labels = strcat(labels, newlabels);
    
elseif regexpi(labels(1,:), '\d\d/\d\d', 'once') % Tick format is mm/dd
    
    % Change mm/dd to dd/mm if necessary
    labels = datestr(ticks, axesInfo.mdformat);
    % Add year information to first tick & ticks where the year changes
    ind = [1 find(diff(yr))+1];
    newlabels(ind) = cellstr(datestr(ticks(ind), '/yy'));
    labels = strcat(labels, newlabels);
    
elseif any(labels(1,:) == ':') % Tick format is HH:MM
    
    % Add month/day/year information to the first tick and month/day to other ticks where the day changes
    ind = find(diff(da))+1;
    newlabels{1}   = datestr(ticks(1), [axesInfo.mdformat '/yy-']); % Add month/day/year to first tick
    newlabels(ind) = cellstr(datestr(ticks(ind), [axesInfo.mdformat '-'])); % Add month/day to ticks where day changes
    labels = strcat(newlabels, labels);
    
end

set(axesInfo.Linked, 'XTick', ticks, 'XTickLabel', labels);

% ylim('auto');
axis 'auto y';
%#ok<*CTCH>
%#ok<*ASGLU>
%#ok<*INUSL>
%#ok<*INUSD>

function ButtonDownCallback(src,eventdata)
f1 = src;
a1 = get(f1,'CurrentAxes');
a2 = copyobj(a1,f1);

set(f1, ...
    'UserData',[f1,a1,a2], ...
    'Pointer','fullcrosshair', ...
    'CurrentAxes',a2);
set(a2, ...
    'UserData',[2,0.2], ... %magnification, frame size
    'Color',get(a1,'Color'), ...
    'Box','on');
xlabel(''); ylabel(''); zlabel(''); title('');

set(a1, ...
    'Color',get(a1,'Color')*0.95);
set(f1, ...
    'CurrentAxes',a1);
ButtonMotionCallback(src);
return;

function ButtonUpCallback(src,eventdata)
H = get(src,'UserData');
f1 = H(1); a1 = H(2); a2 = H(3);
set(a1, ...
    'Color',get(a2,'Color'));
set(f1, ...
    'UserData',[], ...
    'Pointer','arrow', ...
    'CurrentAxes',a1);
if ~strcmp(get(f1,'SelectionType'),'alt'),
    delete(a2);
end;
return;

function ButtonMotionCallback(src,eventdata)
H = get(src,'UserData');
if ~isempty(H)
    f1 = H(1); a1 = H(2); a2 = H(3);
    a2_param = get(a2,'UserData');
    f_pos = get(f1,'Position');
    a1_pos = get(a1,'Position');
    
    [f_cp, a1_cp] = pointer2d(f1,a1);
    
    set(a2,'Position',[(f_cp./f_pos(3:4)) 0 0]+a2_param(2)*a1_pos(3)*[-1 -1 2 2]);
    a2_pos = get(a2,'Position');
    
    set(a2,'XLim',a1_cp(1)+(1/a2_param(1))*(a2_pos(3)/a1_pos(3))*diff(get(a1,'XLim'))*[-0.5 0.5]);
    set(a2,'YLim',a1_cp(2)+(1/a2_param(1))*(a2_pos(4)/a1_pos(4))*diff(get(a1,'YLim'))*[-0.5 0.5]);
end;
return;

function KeyPressCallback(src,eventdata)
H = get(gcf,'UserData');
if ~isempty(H)
    f1 = H(1); a1 = H(2); a2 = H(3);
    a2_param = get(a2,'UserData');
    if (strcmp(get(f1,'CurrentCharacter'),'+') | strcmp(get(f1,'CurrentCharacter'),'='))
        a2_param(1) = a2_param(1)*1.2;
    elseif (strcmp(get(f1,'CurrentCharacter'),'-') | strcmp(get(f1,'CurrentCharacter'),'_'))
        a2_param(1) = a2_param(1)/1.2;
    elseif (strcmp(get(f1,'CurrentCharacter'),'<') | strcmp(get(f1,'CurrentCharacter'),','))
        a2_param(2) = a2_param(2)/1.2;
    elseif (strcmp(get(f1,'CurrentCharacter'),'>') | strcmp(get(f1,'CurrentCharacter'),'.'))
        a2_param(2) = a2_param(2)*1.2;
    end;
    set(a2,'UserData',a2_param);
    ButtonMotionCallback(src);
end;
return;

function [fig_pointer_pos, axes_pointer_val] = pointer2d(fig_hndl,axes_hndl)

if (nargin == 0), fig_hndl = gcf; axes_hndl = gca; end;
if (nargin == 1), axes_hndl = get(fig_hndl,'CurrentAxes'); end;

set(fig_hndl,'Units','pixels');

pointer_pos = get(0,'PointerLocation');	%pixels {0,0} lower left
fig_pos = get(fig_hndl,'Position');	%pixels {l,b,w,h}

fig_pointer_pos = pointer_pos - fig_pos([1,2]);
set(fig_hndl,'CurrentPoint',fig_pointer_pos);

if (isempty(axes_hndl)),
    axes_pointer_val = [];
elseif (nargout == 2),
    axes_pointer_line = get(axes_hndl,'CurrentPoint');
    axes_pointer_val = sum(axes_pointer_line)/2;
end;
