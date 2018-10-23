function GraphicErrors(src,evnt)

Data = src.UserData;
VarVisible = Data.Visible;
if strcmp(VarVisible,'on')
    StrLabel = 'Deactivate error bars';
else
    StrLabel = 'Activate error bars';
end

cmenu = uicontextmenu('Visible','on');
c1 = uimenu(cmenu,'Label',StrLabel,'Callback',{@Handle_Errors},'UserData',Data);

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

function Handle_Errors(src,evnt)

str = get(src,'Label');
Data = src.UserData;

switch str
    case 'Deactivate error bars'
        set(Data,'Visible','off');
        
    case 'Activate error bars'
        set(Data,'Visible','on');
end

