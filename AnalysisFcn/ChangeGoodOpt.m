function ChangeGoodOpt(src,evnt)

sel_typ = get(gcbf,'SelectionType');
switch sel_typ
    case 'alt'   %Right button
        IVset = get(src,'UserData');
        %         color_old = get(src_change.src_text,'Color');
        %         set(src_change.src_text,'Color',[1 0 0]);
        for i = 1:length(IVset)
            if strcmp(src.Tag,IVset(i).file)
                NumFile = i;
                break;
            end
        end
        
        
        
        
        cmenu = uicontextmenu('Visible','on');
        c1 = uimenu(cmenu,'Label',src.Tag);
        try
        data.NumFile = NumFile;
        data.fig.hObject = src.Parent.Parent;
        data.IVset = data.fig.hObject.UserData;
        data.src = src;
        uimenu(c1,'Label','Remove from analysis','Callback',...
            {@ProvMarksActions},'UserData',data);
        catch
        end
        %         uimenu(cmenu,'Label','Change position mark','Callback',...
        %             {@ProvMarksActions},'UserData',src_change);
        %         uimenu(cmenu,'Label','Change description mark','Callback',...
        %             {@ProvMarksActions},'UserData',src_change);
        
        
        %% Add more options about provisional marks
        
        set(src,'uicontextmenu',cmenu);
        true = 1;
        while true
            pause(0.1);
            if ishandle(cmenu)
                if strcmp(cmenu.Visible,'off')
                    true = 0;
                end
            else
                true = 0;
            end
            pause(0.1);
        end
        %         if ishandle(src_change.src_text)
        %             set(src_change.src_text,'Color',color_old);
        %         end
    otherwise
end

function ProvMarksActions(src,evnt)

UserData = get(src,'UserData');
str = get(src,'Label');
switch str
    case 'Remove from analysis'
        
        h = findobj(src.Parent.Parent.Parent.Children,'Type','Line');
        Label = src.Parent.Label;
        h1 = findobj(h,'Tag',Label);
        for i = 1:length(h1)
            h1(i).Visible = 'off';
        end
        
        UserData.IVset(UserData.NumFile).good = 0;        
        UserData.fig.hObject.UserData = UserData.IVset;
%         clf;
%         plotIVs(UserData.IVset,UserData.fig);
        
    case 'Change position mark'
        
        
    case 'Change description mark'
        
        
    otherwise
        
end