function ChangeGoodOptP(src,evnt)

sel_typ = get(gcbf,'SelectionType');
switch sel_typ
    case 'alt'   %Right button
        %
        Data.DataLines = src.UserData;
        P = src.Parent.Parent.UserData;
        Data.P = P.P;
        Data.fig = P.fig;
        
        Str = src.Tag;
        if ~isempty(strfind(Str,':fit'))
            Str = Str(1:strfind(Str,':fit')-1);
        end
        %         color_old = get(src_change.src_text,'Color');
        %         set(src_change.src_text,'Color',[1 0 0]);
        %         for i = 1:length(IVset)
        %             if strcmp(src.Tag,IVset(i).file)
        %                 NumFile = i;
        %                 break;
        %             end
        %         end
        for i = 1:length(Data.P)
            ind = strfind(Data.P(i).fileZ,Str);
            if ~isempty(cell2mat(ind))
                for j = 1:length(ind)
                    if ~isempty(ind{j})
                        break;
                    end
                end
                Pind = i;
                Find = j;
                break;
            end
        end
        
        Data.Pind = Pind;
        Data.Find = Find;
        
        cmenu = uicontextmenu('Visible','on');
        c1 = uimenu(cmenu,'Label',src.Tag);
        uimenu(c1,'Label','Remove from analysis','Callback',...
            {@ProvMarksActions},'UserData',Data);
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

Data = src.UserData;
str = src.Label;
switch str
    case 'Remove from analysis'
        
        %         Data.P(Data.Pind).fileZ(Data.Find);
        fieldNames = fieldnames(Data.P(1).p(1));
        for i = 1:length(fieldNames)
            eval(['Data.P(' num2str(Data.Pind) ').p(' num2str(Data.Find) ').' fieldNames{i} ' = nan;']);
        end
        set(Data.DataLines,'Visible','off');
        dat.P = Data.P;
        dat.fig = Data.fig;
        set(Data.fig,'UserData',dat);
    case 'Change position mark'
        
        
    case 'Change description mark'
        
        
    otherwise
        
end