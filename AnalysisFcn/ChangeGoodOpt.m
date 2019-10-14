function ChangeGoodOpt(src,evnt)
% Auxiliary function to handle right-click mouse options of I-V curves representation
% Last update: 14/11/2018


sel_typ = get(gcbf,'SelectionType');
switch sel_typ
    case 'alt'   %Right button
        IVset = get(src,'UserData');
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
                {@ActionFcn},'UserData',data);
        catch
        end
        
        set(src,'uicontextmenu',cmenu);
    otherwise
end

function ActionFcn(src,evnt)

UserData = get(src,'UserData');
str = get(src,'Label');
switch str
    case 'Remove from analysis'
        
        h = findobj(src.Parent.Parent.Parent.Children,'Type','Line');
        Label = src.Parent.Label;
        h1 = findobj(h,'Tag',Label);
        for i = 1:length(h1)
            h1(i).Color = [0.8 0.8 0.8];
%             h1(i).Visible = 'off';
        end
        
        UserData.IVset(UserData.NumFile).good = 0;
        UserData.fig.hObject.UserData = UserData.IVset;
        
    otherwise
        
end