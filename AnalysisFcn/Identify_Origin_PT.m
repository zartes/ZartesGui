function Identify_Origin_PT(src,evnt)
% Auxiliary function to handle right-click mouse options of Gset
% Representation
% Last update: 14/11/2018

if evnt.Button == 3
    
    Data = src.UserData;
    if ~isempty(Data{1})
        StrCond = {'P';'N'};
        data = eval(['Data{4}.Gset' StrCond{Data{1}} '(Data{2})' ]);
        FieldNames = fieldnames(data);
%         GsetParam{1} = src.DisplayName;        
        GsetParam{1} = [];
        for i = 1:length(FieldNames)
            GsetParam = [GsetParam; {[FieldNames{i} ': ' num2str(eval(['data.' FieldNames{i}]))]}];
        end
        GsetParam(1) = []; 
        cmenu = uicontextmenu('Visible','on');
        for i = 1:length(GsetParam)
            c1(i) = uimenu(cmenu,'Label',GsetParam{i});
        end
        set(src,'uicontextmenu',cmenu);
        waitfor(cmenu,'Visible','off')
    else
        Data{1} = src.DisplayName;
        cmenu = uicontextmenu('Visible','on');
        for i = 1:length(Data)
            c1(i) = uimenu(cmenu,'Label',Data{i});
        end
        set(src,'uicontextmenu',cmenu);
        waitfor(cmenu,'Visible','off')
    end
end

% 
% function ActionFcn(src,evnt)
% 
% File = src.Parent.Label;
% Data = get(src,'UserData');
% str = get(src,'Label');
% inds = find(File == filesep, 1, 'last' );
% wdir1 = File(1:inds);
% filesZ = File(inds+1:end);
% filesZ(filesZ == '_') = ' ';
% switch str
%     case 'Z(w)-Noise Plots'
%         
%         fig = figure('Name',['Z(w)-Noise Plots: ' wdir1],'Visible','off');
%         ax(1) = subplot(1,2,1);
%         plot(ax(1),1e3*Data{1},'.','color',[0 0.447 0.741],...
%             'markerfacecolor',[0 0.447 0.741],'markersize',15);
%         grid(ax(1),'on');
%         hold(ax(1),'on');%%% Paso marker de 'o' a '.'
%         set(ax(1),'linewidth',2,'fontsize',12,'fontweight','bold');
%         xlabel(ax(1),'Re(mZ)','fontsize',12,'fontweight','bold');
%         ylabel(ax(1),'Im(mZ)','fontsize',12,'fontweight','bold');%title('Ztes with fits (red)');
%         title(ax(1),filesZ);
%         plot(ax(1),1e3*Data{2}(:,1),1e3*Data{2}(:,2),'r','linewidth',2);
%         
%         inds = find(Data{3} == filesep, 1, 'last' );
%         filesNoise = Data{3}(inds+1:end);
%         file{1} = filesNoise;
%         ax(2) = subplot(1,2,2);
%         
%         loglog(ax(2),Data{4}(:,1),Data{5}(:,1),'.-r'),%%%for noise in Current.  Multiplico 1e12 para pA/sqrt(Hz)!Ojo, tb en plotnoise!
%         hold(ax(2),'on'),grid(ax(2),'on')
%         loglog(ax(2),Data{4}(:,1),medfilt1(Data{5}(:,1),20),'.-k'),hold(ax(2),'on'),grid(ax(2),'on')
%         set(ax(2),'linewidth',2,'fontsize',12,'fontweight','bold');
%         ylabel(ax(2),'pA/Hz^{0.5}','fontsize',12,'fontweight','bold')
%         xlabel(ax(2),'\nu (Hz)','fontsize',12,'fontweight','bold')
%         file{1}(file{1} == '_') = ' ';
%         title(ax(2),file{1});
%         fig.Visible = 'on';
%         
%     case 'Filter out'
%         handles = guidata(src.Parent.Parent.Parent);
%         P = Data{1}{1};
%         N_meas = Data{1}{2};
%         ind_orig = Data{2};
%         P(N_meas).Filtered{ind_orig} = 1;
%         PRango = Data{3};
%         if PRango == 1
%             handles.Session{handles.TES_ID}.TES.PP(N_meas) = P(N_meas);
%         else
%             handles.Session{handles.TES_ID}.TES.PN(N_meas) = P(N_meas);
%         end
%         guidata(handles.Analyzer,handles);
%         fig.hObject = handles.Analyzer;
%         indAxes = findobj(fig.hObject,'Type','Axes');
%         delete(indAxes);
%         handles.Session{handles.TES_ID}.TES.plotABCT(fig);
%         
%     case 'Unfilter'
%         handles = guidata(src.Parent.Parent.Parent);
%         P = Data{1}{1};
%         N_meas = Data{1}{2};
%         ind_orig = Data{2};
%         P(N_meas).Filtered{ind_orig} = 0;
%         PRango = Data{3};
%         if PRango == 1
%             handles.Session{handles.TES_ID}.TES.PP(N_meas) = P(N_meas);
%         else
%             handles.Session{handles.TES_ID}.TES.PN(N_meas) = P(N_meas);
%         end
%         guidata(handles.Analyzer,handles);
%         fig.hObject = handles.Analyzer;
%         indAxes = findobj(fig.hObject,'Type','Axes');
%         delete(indAxes);
%         handles.Session{handles.TES_ID}.TES.plotABCT(fig);
%         
%     otherwise
%         
% end
