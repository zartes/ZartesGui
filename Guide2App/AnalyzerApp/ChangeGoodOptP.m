function ChangeGoodOptP(src,evnt)
% Auxiliary function to handle right-click mouse options of Z(w) to electro-thermal model fitting representation
% Last update: 14/11/2018

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
            {@ActionFcn},'UserData',Data);
        set(src,'uicontextmenu',cmenu);
        
    otherwise
end

function ActionFcn(src,evnt)

Data = src.UserData;
str = src.Label;
switch str
    case 'Remove from analysis'
        fieldNames = fieldnames(Data.P(1).p(1));
        for i = 1:length(fieldNames)
            eval(['Data.P(' num2str(Data.Pind) ').p(' num2str(Data.Find) ').' fieldNames{i} ' = nan;']);
        end
        set(Data.DataLines,'Visible','off');
        dat.P = Data.P;
        dat.fig = Data.fig;
        set(Data.fig,'UserData',dat);
        
    otherwise
        
end