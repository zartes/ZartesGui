function GraphicErrors(src,evnt)
   
    
Data = src.UserData;
VarVisible = Data.er(1).Visible;
if strcmp(VarVisible,'on')
    StrLabel = 'Deactivate error bars';
else
    StrLabel = 'Activate error bars';
end

cmenu = uicontextmenu('Visible','on');
c1 = uimenu(cmenu,'Label',StrLabel,'Callback',{@Handle_Errors},'UserData',Data);

try
    VarVisible = Data.h_bad(1).Visible;
    if strcmp(VarVisible,'on')
        StrLabel = 'Hide Filtered Data';
    else
        StrLabel = 'Show Filtered Data';
    end
    c2 = uimenu(cmenu,'Label',StrLabel,'Callback',{@Handle_Errors},'UserData',Data);
catch
end

c3 = uimenu(cmenu,'Label','Hide Negative Ibias Data','Callback',...
        {@Handle_Errors},'UserData',Data);
c4 = uimenu(cmenu,'Label','Show Negative Ibias Data','Callback',...
        {@Handle_Errors},'UserData',Data);

set(src,'uicontextmenu',cmenu);
% true = 1;
% while true
%     pause(0.1);    
%     if ishandle(cmenu)
%         if strcmp(cmenu.Visible,'off')
%             true = 0;
%         end
%     else
%         true = 0;
%     end
%     pause(0.2);
% end

function Handle_Errors(src,evnt)

str = get(src,'Label');
Data = src.UserData;

switch str
    case 'Deactivate error bars'
        set(Data.er,'Visible','off');
        VarVisible = Data.h_bad.Visible;
        if strcmp(VarVisible,'on')            
            set(Data.erbad,'Visible','off');
        end
        
    case 'Activate error bars'
        set(Data.er,'Visible','on');
        VarVisible = Data.h_bad.Visible;
        if strcmp(VarVisible,'on')            
            set(Data.erbad,'Visible','on');
        end
        
    case 'Hide Filtered Data'
        set(Data.h_bad,'Visible','off');                 
        set(Data.erbad,'Visible','off');
        
    case 'Show Filtered Data'
        set(Data.h_bad,'Visible','on');
        VarVisible = Data.er.Visible;
        if strcmp(VarVisible,'on')            
            set(Data.erbad,'Visible','on');
        end
        
    case 'Hide Negative Ibias Data'
        hs = findobj('Type','Line');
        j = [];
        for i = 1:length(hs)
            Tag = [hs(i).DisplayName];
            if ~isempty(strfind(Tag,'NegIbias'))
               j = [j i] ;
            end
        end
        set(hs(j),'Visible','off');        
        
    case 'Show Negative Ibias Data'
        hs = findobj('Type','Line');
        j = [];
        for i = 1:length(hs)
            Tag = [hs(i).DisplayName];
            if ~isempty(strfind(Tag,'NegIbias'))
               j = [j i] ;
            end
        end
        set(hs(j),'Visible','on');   
end

