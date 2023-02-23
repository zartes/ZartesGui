function varargout = TF_Noise_Viewer(varargin)
% TF_NOISE_VIEWER MATLAB code for TF_Noise_Viewer.fig
%      TF_NOISE_VIEWER, by itself, creates a new TF_NOISE_VIEWER or raises the existing
%      singleton*.
%
%      H = TF_NOISE_VIEWER returns the handle to a new TF_NOISE_VIEWER or the handle to
%      the existing singleton*.
%
%      TF_NOISE_VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TF_NOISE_VIEWER.M with the given input arguments.
%
%      TF_NOISE_VIEWER('Property','Value',...) creates a new TF_NOISE_VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TF_Noise_Viewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TF_Noise_Viewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TF_Noise_Viewer

% Last Modified by GUIDE v2.5 20-May-2019 14:27:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TF_Noise_Viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @TF_Noise_Viewer_OutputFcn, ...
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


% --- Executes just before TF_Noise_Viewer is made visible.
function TF_Noise_Viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TF_Noise_Viewer (see VARARGIN)

% Choose default command line output for TF_Noise_Viewer

handles.output = hObject;
handles.varargin = varargin;
position = get(handles.figure1,'Position');
set(handles.figure1,'Color',[200 200 200]/255,'Position',...
    [0.5-position(3)/2 0.5-position(4)/2 position(3) position(4)],...
    'Units','Normalized');

handles.VersionStr = handles.varargin{1}.version; %'ZarTES v4.1';
set(handles.figure1,'Name',['Z(w) and Noise Viewer    ---   ' handles.VersionStr]);
% Updating the popup menu


Extnd = {[]};
try
    Tbaths{1} = [handles.varargin{1}.PP.Tbath]*1e3;
    Extnd(1:length(Tbaths{1}),1) = {'mK Positive Ibias'};
catch
    Tbaths{1} = [];
end
try
    Tbaths{2} = [handles.varargin{1}.PN.Tbath]*1e3;
    Extnd(length(Tbaths{1})+1:length(Tbaths{2})+length(Tbaths{1}),1) = {'mK Negative Ibias'};
catch
    Tbaths{2} = [];
end
if ~isempty(Tbaths{1})||~isempty(Tbaths{2})
    TbathPopStr = [num2cell(Tbaths{1}') Extnd(1:length(Tbaths{1}),1); num2cell(Tbaths{2}') Extnd(length(Tbaths{1})+1:length(Tbaths{2})+length(Tbaths{1}),1)];
    Str = {[]};
    for j = 1:size(TbathPopStr)
        Str{j,1} = [num2str(TbathPopStr{j,1}) TbathPopStr{j,2}];
    end
    handles.TBath_ind = 1;
    set(handles.TBath_popup,'String',char(Str),'Value',handles.TBath_ind);
else
    warndlg('First use FitZset method!',handles.VersionStr);
    delete(handles.figure1);
    return;
end

handles.Files_Ind = 1;
try
    PlotTF_Noise(hObject,[],handles);
    Ok = 1;
catch
    Ok = 0;
end
if ~Ok
    warndlg('First use FitZset method!',handles.VersionStr);
    delete(handles.figure1);
    return;
end
handles = guidata(hObject);
set([handles.Previous handles.Rewind],'Enable','off')
    

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TF_Noise_Viewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TF_Noise_Viewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
try
    varargout{1} = handles.output;
    set(handles.figure1,'Visible','on');
    a_str = {'New Figure';'Open File';'Link Plot';'Hide Plot Tools';'Show Plot Tools and Dock Figure'};
    for i = 1:length(a_str)
        eval(['a = findall(handles.FigureToolBar,''ToolTipString'',''' a_str{i} ''');']);
        a.Visible = 'off';
    end
    guidata(hObject,handles)
catch
end

% --- Executes on selection change in TBath_popup.
function TBath_popup_Callback(hObject, eventdata, handles)
% hObject    handle to TBath_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TBath_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TBath_popup
handles.Files_Ind = 1;
if handles.Files_Ind == 1
    set([handles.Forward handles.Next],'Enable','on');
    set([handles.Rewind handles.Previous],'Enable','off');
elseif handles.Files_Ind == handles.Nfiles
    set([handles.Forward handles.Next],'Enable','off');
    set([handles.Rewind handles.Previous],'Enable','on');
else
    set([handles.Rewind handles.Previous handles.Forward handles.Next],'Enable','on');
end
PlotTF_Noise(hObject,[],handles);
handles = guidata(hObject);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function TBath_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TBath_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Previous.
function Previous_Callback(hObject, eventdata, handles)
% hObject    handle to Previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Files_Ind = max(handles.Files_Ind - 1,1);
if hObject ~= handles.Rewind
    if handles.Files_Ind == 1
        set([handles.Previous handles.Rewind],'Enable','off')
    else
        set([handles.Previous handles.Rewind],'Enable','on')
    end
end
set([handles.TF_Name handles.Noise_Name],'Value',handles.Files_Ind);
PlotTF_Noise(hObject,[],handles);
if hObject ~= handles.Rewind
    set([handles.Next handles.Forward],'Enable','on')
end
guidata(hObject,handles)

% --- Executes on button press in Next.
function Next_Callback(hObject, eventdata, handles)
% hObject    handle to Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Files_Ind = min(handles.Files_Ind + 1,handles.Nfiles);
if hObject ~= handles.Forward
    if handles.Files_Ind == handles.Nfiles
        set([handles.Next handles.Forward],'Enable','off')
    else
        set([handles.Next handles.Forward],'Enable','on')
    end
end
set([handles.TF_Name handles.Noise_Name],'Value',handles.Files_Ind);
PlotTF_Noise(hObject,[],handles);
if hObject ~= handles.Forward
    set([handles.Previous handles.Rewind],'Enable','on')
end
guidata(hObject,handles)

% --- Executes on button press in Rewind.
function Rewind_Callback(hObject, eventdata, handles)
% hObject    handle to Rewind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.Files_Ind > 1    
    hds = findobj(hObject.Parent,'Type','Uicontrol');
    set(hds,'Enable','off');
end
while handles.Files_Ind > 1   
    Flag = get(handles.Rewind,'UserData');
    if ~isempty(Flag)
        break;
    end
    Previous_Callback(hObject,[],handles)
    handles = guidata(handles.figure1);
    pause(0.2);
end
if handles.Files_Ind == 1
    set(hds,'Enable','on');
    set([handles.Previous handles.Rewind],'Enable','off')
else
    set(hds,'Enable','on');
end
set([handles.Rewind handles.Forward],'UserData',[]);
guidata(hObject,handles)

% --- Executes on button press in Forward.
function Forward_Callback(hObject, eventdata, handles)
% hObject    handle to Forward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.Files_Ind < handles.Nfiles
    hds = findobj(hObject.Parent,'Type','Uicontrol');
    set(hds,'Enable','off');
end
while handles.Files_Ind < handles.Nfiles        
    Flag = get(handles.Forward,'UserData');
    if ~isempty(Flag)
        break;
    end
    Next_Callback(hObject,[],handles)
    handles = guidata(handles.figure1);
    pause(0.2);    
end
if handles.Files_Ind == handles.Nfiles
    set(hds,'Enable','on');
    set([handles.Next handles.Forward],'Enable','off')     
else
    set(hds,'Enable','on');
end
set([handles.Rewind handles.Forward],'UserData',[]);
guidata(hObject,handles)


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

switch eventdata.Key
    case 'rightarrow'
        if handles.Files_Ind < handles.Nfiles
            Next_Callback(handles.Next,[],handles);
        end
    case 'leftarrow'
        if handles.Files_Ind > 1
        Previous_Callback(handles.Previous,[],handles);
        end
    case 'escape'
        delete(handles.figure1);
    case 'space'        
        a = dbstack;
        if ~isempty([strfind(a(end).name,'Forward_Callback') strfind(a(end).name,'Rewind_Callback')])
            set([handles.Rewind handles.Forward],'UserData',1);            
            guidata(hObject,handles);
        end
end


function PlotTF_Noise(src,evnt,handles)

warning off;
contents = cellstr(get(handles.TBath_popup,'String'));
Str = contents{get(handles.TBath_popup,'Value')};

if ~isempty(strfind(Str,'Positive'))
    Tbaths{1} = [handles.varargin{1}.PP.Tbath]*1e3;
    T_selected = str2double(Str(1:strfind(Str,'mK')-1));
    ind = find(Tbaths{1} == T_selected);
    StrCond = 'P';    
else
    Tbaths{2} = [handles.varargin{1}.PN.Tbath]*1e3;
    T_selected = str2double(Str(1:strfind(Str,'mK')-1));
    ind = find(Tbaths{2} == T_selected);
    StrCond = 'N';
end
Tbath = str2double(Str(1:strfind(Str,'mK')-1));

if ~isempty(strfind(Str,'Negative'))
    [~,Tind] = min(abs([handles.varargin{1}.IVsetN.Tbath]*1e3-Tbath));
    IV = handles.varargin{1}.IVsetN(Tind);
else
    [~,Tind] = min(abs([handles.varargin{1}.IVsetP.Tbath]*1e3-Tbath));
    IV = handles.varargin{1}.IVsetP(Tind);
end


%% TF is drawn
ind_Tbath = ind;
eval(['files' StrCond ' = [handles.varargin{1}.P' StrCond '(ind_Tbath).fileZ]'';';]);
handles.Nfiles = length(eval(['files' StrCond ';']));
cla(handles.TF_axes);
hs = handles.TF_axes; 
set(hs,'XScale','linear','YScale','linear')
% eval(['TF{handles.Files_Ind} = importdata(files' StrCond '{handles.Files_Ind});']);
eval(['FileName = files' StrCond '{handles.Files_Ind};']);
FileName = FileName(find(FileName == filesep,1,'last')+1:end);

if ~isempty(strfind(FileName,'PXI_TF'))
    Ib = sscanf(FileName,'PXI_TF_%fuA.txt')*1e-6;
else
    Ib = sscanf(FileName,'TF_%fuA.txt')*1e-6;
end
Ib = Ib - handles.varargin{1}.circuit.CurrOffset.Value;
eval(['OP = handles.varargin{1}.setTESOPfromIb(Ib,IV,handles.varargin{1}.P' StrCond '(ind_Tbath).p,''' StrCond ''');']);

data{1} = eval(['handles.varargin{1}.P' StrCond '(ind_Tbath)']);
data{2} = handles.Files_Ind;
data{3} = FileName;

ztes = eval(['handles.varargin{1}.P' StrCond '(ind_Tbath).ztes{handles.Files_Ind};']);
fZ = eval(['handles.varargin{1}.P' StrCond '(ind_Tbath).fZ{handles.Files_Ind};']);
plot(hs,1e3*ztes,'.','Color',[0 0.447 0.741],...
    'MarkerFaceColor',[0 0.447 0.741],'MarkerSize',15,'ButtonDownFcn',{@DisplayResults},'UserData',data,'DisplayName','Experimental Data');
hold(hs,'on');grid(hs,'on');

set(hs,'LineWidth',2,'FontSize',12,'fontweight','bold');
xlabel(hs,'Re(mZ)','FontSize',12,'fontweight','bold');
ylabel(hs,'Im(mZ)','FontSize',12,'fontweight','bold');%title('Ztes with fits (red)');
ImZmin = min(imag(1e3*ztes));
% ylim(hs,[min(-15,min(ImZmin)-1) 1])

plot(hs,1e3*fZ(:,1),1e3*fZ(:,2),'r','LineWidth',2,'ButtonDownFcn',{@DisplayResults},'UserData',data,'DisplayName',...
    eval(['handles.varargin{1}.P' StrCond '(ind_Tbath).ElecThermModel{handles.Files_Ind}']));
% legend(hs,'Experimental',);

axis(hs,'tight');
r0 = data{1}.p(handles.Files_Ind).rp;
Z0 = data{1}.p(handles.Files_Ind).Z0;
Zinf = data{1}.p(handles.Files_Ind).Zinf;
title(hs,strcat(num2str(nearest(r0*100),'%3.0f'),'%Rn'),'FontSize',12);
% title(hs,strcat(num2str(nearest(OP.r0*100),'%3.2f'),'%Rn'),'FontSize',12);
if abs(Z0-Zinf) < handles.varargin{1}.ElectrThermalModel.Z0_Zinf_Thrs
    set(get(findobj(hs,'type','axes'),'title'),'Color','r');
end
hold(hs,'off');

if src == handles.figure1||src == handles.TBath_popup
    clear FilesStr;
    for k = 1:length(eval(['files' StrCond]))
        eval(['Files = files' StrCond '{k};']);
        FilesStr{k,1} = Files(find(Files == filesep,1,'last')+1:end);
    end
    set(handles.TF_Name,'String',FilesStr,'Value',1);
end
set(handles.TF_axes,'ButtonDownFcn',{@DisplayResults},'UserData',data);
axis(handles.TF_axes,'tight');

%% Noise is drawn
cla(handles.Noise_axes);
hs1 = handles.Noise_axes;
eval(['filesNoise' StrCond ' = [handles.varargin{1}.P' StrCond '(ind_Tbath).fileNoise]'';';]);
eval(['fNoise{handles.Files_Ind} = handles.varargin{1}.P' StrCond '(ind_Tbath).fNoise{handles.Files_Ind};';]);
eval(['SigNoise{handles.Files_Ind} = handles.varargin{1}.P' StrCond '(ind_Tbath).SigNoise{handles.Files_Ind};';]);
% eval(['noise{handles.Files_Ind} = importdata(filesNoise' StrCond '{handles.Files_Ind});']);

eval(['FileName = filesNoise' StrCond '{handles.Files_Ind};']);
FileName = FileName(find(FileName == filesep,1,'last')+1:end);

Ib = sscanf(FileName,strcat(handles.varargin{1}.NoiseOpt.NoiseBaseName(2:end-1),'_%fuA.txt'))*1e-6; %%%HP_noise para ZTES18.!!!
Ib = Ib - handles.varargin{1}.circuit.CurrOffset.Value;
eval(['OP = handles.varargin{1}.setTESOPfromIb(Ib,IV,handles.varargin{1}.P' StrCond '(ind_Tbath).p,''' StrCond ''');']);
if handles.varargin{1}.ElectrThermalModel.bool_Mjo == 1
%     M = OP.M;
    M = data{1}.p(handles.Files_Ind).M;
else
    M = 0;
end
f = logspace(1,5,321)';
% auxnoise = obj.noisesim(OP,M,f);
if length(fNoise{handles.Files_Ind}(:,1)) ~= length(f)
    SigNoise{handles.Files_Ind} = spline(fNoise{handles.Files_Ind}(:,1),SigNoise{handles.Files_Ind},f); % Todos los ruidos a 321 puntos
    fNoise{handles.Files_Ind} = f;
end
                                
auxnoise = handles.varargin{1}.ElectrThermalModel.noisesim(handles.varargin{1},OP,M,f,StrCond);

handles.varargin{1}.ElectrThermalModel.Plot(fNoise{handles.Files_Ind},SigNoise{handles.Files_Ind},auxnoise,OP,hs1);

% switch handles.varargin{1}.ElectrThermalModel.tipo{handles.varargin{1}.ElectrThermalModel.Selected_tipo}
%     case 'current'
%         
%         loglog(hs1,fNoise{handles.Files_Ind}(:,1),SigNoise{handles.Files_Ind},'color',[0 0.447 0.741],...
%             'markerfacecolor',[0 0.447 0.741],'DisplayName','Experimental Noise'); 
%         hold(hs1,'on');
%         grid(hs1,'on');%%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
%         loglog(hs1,fNoise{handles.Files_Ind}(:,1),handles.varargin{1}.ElectrThermalModel.NoiseFiltering(SigNoise{handles.Files_Ind}),...
%             '.-k','DisplayName','Exp Filtered Noise'); %%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
%         
%         if handles.varargin{1}.ElectrThermalModel.bool_Mph == 0
%             totnoise = sqrt(auxnoise.sum.^2+auxnoise.squidarray.^2);
%         else
%             Mexph = OP.Mph;
%             totnoise = sqrt((auxnoise.ph.^2*(1+Mexph^2))+auxnoise.jo.^2+auxnoise.sh.^2+auxnoise.squidarray.^2);
%         end
%         
%         if ~handles.varargin{1}.ElectrThermalModel.bool_components
%             loglog(hs1,auxnoise.f,totnoise*1e12,'-r','DisplayName','Total Simulation Noise','LineWidth',2);
%             h = findobj(hs1,'Color','r');
%         else
%             loglog(hs1,auxnoise.f,auxnoise.jo*1e12,'DisplayName','Johnson','LineWidth',0.5);
%             loglog(hs1,auxnoise.f,auxnoise.ph*1e12,'DisplayName','Phonon','LineWidth',0.5);
%             loglog(hs1,auxnoise.f,auxnoise.sh*1e12,'DisplayName','Shunt','LineWidth',0.5);
%             loglog(hs1,auxnoise.f,auxnoise.squidarray*1e12,'DisplayName','Squid','LineWidth',0.5);
%             loglog(hs1,auxnoise.f,totnoise*1e12,'-r','DisplayName','Total','LineWidth',2);
% %             
% %             legend(hs1,'Experimental Noise','Exp Filtered Noise','Johnson','Phonon','Shunt','Squid','Total');            
% %             h = findobj(hs1,'DisplayName','Total');
%         end
%         ylabel(hs1,'pA/Hz^{0.5}','FontSize',12,'FontWeight','bold')
%         
%     case 'nep'
%         
%         sIaux = ppval(spline(auxnoise.f,auxnoise.sI),fNoise{handles.Files_Ind}(:,1));
%         squidarray = ppval(spline(auxnoise.f,auxnoise.squidarray),fNoise{handles.Files_Ind}(:,1));
%         NEP = real(sqrt(((SigNoise{handles.Files_Ind}*1e-12).^2-squidarray.^2))./sIaux);
%         
%         loglog(hs1,fNoise{handles.Files_Ind}(:,1),(NEP*1e18),'color',[0 0.447 0.741],...
%             'markerfacecolor',[0 0.447 0.741],'DisplayName','Experimental Noise'),hold(hs1,'on'),grid(hs1,'on'),
%         loglog(hs1,fNoise{handles.Files_Ind}(:,1),handles.varargin{1}.ElectrThermalModel.NoiseFiltering(NEP*1e18),'.-k',...
%             'DisplayName','Exp Filtered Noise');
%         hold(hs1,'on');
%         grid(hs1,'on');
%         if handles.varargin{1}.ElectrThermalModel.bool_Mph == 0
%             totNEP = auxnoise.NEP;
%         else
%             totNEP = sqrt(auxnoise.max.^2+auxnoise.jo.^2+auxnoise.sh.^2)./auxnoise.sI;%%%Ojo, estamos asumiendo Mph tal que F = 1, no tiene porqué.
%         end
%         if ~handles.varargin{1}.ElectrThermalModel.bool_components
%             loglog(hs1,auxnoise.f,totNEP*1e18,'-r','DisplayName','Total Simulation Noise','LineWidth',2);hold(hs1,'on');grid(hs1,'on');
%             h = findobj(hs1,'Color','r');
%         else
%             loglog(hs1,auxnoise.f,auxnoise.jo*1e18./auxnoise.sI,'DisplayName','Johnson','LineWidth',0.5);
%             loglog(hs1,auxnoise.f,auxnoise.ph*1e18./auxnoise.sI,'DisplayName','Phonon','LineWidth',0.5);
%             loglog(hs1,auxnoise.f,auxnoise.sh*1e18./auxnoise.sI,'DisplayName','Shunt','LineWidth',0.5);
%             loglog(hs1,auxnoise.f,auxnoise.squidarray*1e18./auxnoise.sI,'DisplayName','Squid','LineWidth',0.5);
%             loglog(hs1,auxnoise.f,totNEP*1e18,'-r','DisplayName','Total','LineWidth',2);
% %             legend(hs1,'Experimental Noise','Exp Filtered Noise','Johnson','Phonon','Shunt','Squid','Total');
% %             legend(hs1,'off');
% %             h = findobj(hs1,'DisplayName','Total');
%         end
%         ylabel(hs1,'aW/Hz^{0.5}','FontSize',12,'FontWeight','bold')
% end
% xlabel(hs1,'\nu (Hz)','FontSize',12,'FontWeight','bold')
% axis(hs1,[1e1 1e5 2 1e3])%% axis([1e1 1e5 1 1e4])
% try
%     set(h(1),'LineWidth',0.5);
% catch
% end
% set(hs1,'FontSize',11,'FontWeight','bold');
% set(hs1,'LineWidth',2)
% set(hs1,'XMinorGrid','off','YMinorGrid','off','GridLineStyle','-')
% set(hs1,'XTick',[10 100 1000 1e4 1e5],'XTickLabel',{'10' '10^2' '10^3' '10^4' '10^5'})
% title(hs1,strcat(num2str(nearest(r0*100),'%3.0f'),'%Rn'),'FontSize',12);
% % title(hs1,strcat(num2str(nearest(OP.r0*100),'%3.2f'),'%Rn'),'FontSize',12);
% %         OP.Z0,OP.Zinf
% %debug
% if abs(OP.Z0-OP.Zinf) < handles.varargin{1}.ElectrThermalModel.Z0_Zinf_Thrs
%     set(get(findobj(hs1,'type','axes'),'title'),'Color','r');
% end



hold(hs1,'off');
if src == handles.figure1||src == handles.TBath_popup
    clear FilesStr;
    for k = 1:length(eval(['filesNoise' StrCond]))
        eval(['Files = filesNoise' StrCond '{k};']);
        FilesStr{k,1} = Files(find(Files == filesep,1,'last')+1:end);
    end
    set(handles.Noise_Name,'String',FilesStr,'Value',1);
end
set(handles.Noise_axes,'ButtonDownFcn',{@HandleBoolComp},'UserData',handles.varargin{1});
axis(handles.Noise_axes,'tight');
% axes(hs1);
% ax_frame = axis; %axis([XMIN XMAX YMIN YMAX])
% %                     delete(ax);
% rc = rectangle('Position', [handles.varargin{1}.ElectrThermalModel.Noise_LowFreq(1) ax_frame(3) diff(handles.varargin{1}.ElectrThermalModel.Noise_LowFreq) ax_frame(4)],'FaceColor',[253 234 23 127.5]/255);
% rc2 = rectangle('Position', [handles.varargin{1}.ElectrThermalModel.Noise_HighFreq(1) ax_frame(3) diff(handles.varargin{1}.ElectrThermalModel.Noise_HighFreq) ax_frame(4)],'FaceColor',[214 232 217 127.5]/255);

guidata(src,handles);
    



function TF_Name_Callback(hObject, eventdata, handles)
% hObject    handle to TF_Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TF_Name as text
%        str2double(get(hObject,'String')) returns contents of TF_Name as a double
handles.Files_Ind = get(hObject,'Value');
set(handles.Noise_Name,'Value',handles.Files_Ind);
if handles.Files_Ind == 1
    set([handles.Forward handles.Next],'Enable','on');
    set([handles.Rewind handles.Previous],'Enable','off');
elseif handles.Files_Ind == handles.Nfiles
    set([handles.Forward handles.Next],'Enable','off');
    set([handles.Rewind handles.Previous],'Enable','on');
else
    set([handles.Rewind handles.Previous handles.Forward handles.Next],'Enable','on');
end
PlotTF_Noise(hObject,[],handles);

guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function TF_Name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TF_Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Noise_Name_Callback(hObject, eventdata, handles)
% hObject    handle to Noise_Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Noise_Name as text
%        str2double(get(hObject,'String')) returns contents of Noise_Name as a double
handles.Files_Ind = get(hObject,'Value');
set(handles.TF_Name,'Value',handles.Files_Ind);
if handles.Files_Ind == 1
    set([handles.Forward handles.Next],'Enable','on');
    set([handles.Rewind handles.Previous],'Enable','off');
elseif handles.Files_Ind == handles.Nfiles
    set([handles.Forward handles.Next],'Enable','off');
    set([handles.Rewind handles.Previous],'Enable','on');
else
    set([handles.Rewind handles.Previous handles.Forward handles.Next],'Enable','on');
end
PlotTF_Noise(hObject,[],handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Noise_Name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Noise_Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function DisplayResults(src,evnt)

data = src.UserData;
ind_orig = data{2};
FileStrLabel = data{3};

param = fieldnames(data{1}.p);
    
    
    TFParam = {['Tbath: ' num2str(data{1}.Tbath*1e3) 'mK'];...
        ['Residuo: ' num2str(data{1}.residuo(ind_orig))];...        
        ['R2: ' num2str(data{1}.R2{ind_orig})]};
    for i = 1:length(param)-5
        TFParam = [TFParam; {[param{i} ': ' num2str(eval(['data{1}.p(ind_orig).' param{i}]))]}];
    end
    
NoiseParam = {['Noise Model: ' data{1}.NoiseModel{ind_orig}];...
    ['ExRes: ' num2str(data{1}.p(ind_orig).ExRes)];...
    ['ThRes: ' num2str(data{1}.p(ind_orig).ThRes)]; 
    ['M: ' num2str(data{1}.p(ind_orig).M)];...
    ['Mph: ' num2str(data{1}.p(ind_orig).Mph)]};


%% Añadir que se muestren todos los ruidos de la temperatura escogida

cmenu = uicontextmenu('Visible','on');
c1 = uimenu(cmenu,'Label',FileStrLabel);

c2(1) = uimenu(c1,'Label','TF parameter analysis');
for i = 1:length(TFParam)
    c3(i) = uimenu(c2(1),'Label',TFParam{i});
    if i > 2
        Str = TFParam{i}(1:strfind(TFParam{i},':')-1);        
        c3_1(i) = uimenu(c3(i),'Label',[Str ' (Histogram)'],'Callback',{@HistFcn},'UserData',{data; ind_orig});
    end
end

c2(2) = uimenu(c1,'Label','Noise parameter analysis');
for i = 1:length(NoiseParam)
    c4(i) = uimenu(c2(2),'Label',NoiseParam{i});
end
set(src,'uicontextmenu',cmenu);

function HandleBoolComp(src,evnt,handles)

data = get(src,'UserData');
cmenu = uicontextmenu('Visible','on');
c1 = uimenu(cmenu,'Label','Noise Components');
if data.ElectrThermalModel.bool_components    
    c2 = uimenu(c1,'Label','Hide','Callback',...
    {@NoiseComp},'UserData',data);
else
    c2 = uimenu(c1,'Label','Show','Callback',...
    {@NoiseComp},'UserData',data);
end
c3 = uimenu(c1,'Label','Type');
c4(1) = uimenu(c3,'Label','Current','Callback',{@NoiseComp},'UserData',data);
c4(2) = uimenu(c3,'Label','NEP','Callback',{@NoiseComp},'UserData',data);
if strcmp(data.ElectrThermalModel.tipo{data.ElectrThermalModel.Selected_tipo},'current')
    set(c4(1),'Checked','on');
    set(c4(2),'Checked','off');
else
    set(c4(1),'Checked','off');
    set(c4(2),'Checked','on');
end

set(src,'uicontextmenu',cmenu);

function NoiseComp(src,evnt)

data = get(src,'UserData');
handles = guidata(src.Parent.Parent);
switch src.Label 
    case 'Hide'        
        data.ElectrThermalModel.bool_components = 0;        
    case 'Show'
        data.ElectrThermalModel.bool_components = 1; 
    case 'Current'
        data.ElectrThermalModel.Selected_tipo = 1;
        src.Checked = 'on';
        src.Parent.Children(1).Checked = 'off';
        
    case 'NEP'
        data.ElectrThermalModel.Selected_tipo = 2;
        src.Checked = 'on';
        src.Parent.Children(2).Checked = 'off';
end
handles.varargin{1} = data;
guidata(src.Parent.Parent, handles);
PlotTF_Noise(src,[],handles)

function figure1_ButtonDownFcn(hObject,eventdata,handles)

a = dbstack;
if ~isempty([strfind(a(end).name,'Forward_Callback') strfind(a(end).name,'Rewind_Callback')])
    set([handles.Rewind handles.Forward],'UserData',1);
    guidata(hObject,handles);
end

function HistFcn(src,evnt)

Str = src.Label;
Str = Str(1:strfind(Str,'(')-2); 
if strcmp(Str,'alpha i')
    Str = 'ai';
elseif strcmp(Str,'beta i')
    Str = 'bi';
elseif strcmp(Str,'tau_eff')
    Str = 'taueff';
end
data = src.UserData;
figure;
try
    hist(eval(['cell2mat(data{1}{1}.' Str ')']),20);
catch
    hist(eval(['[data{1}{1}.p.' Str ']']),20);
end
ylabel('Counts');
xlabel(Str);
