function IVSquidStep(src,evnt)
% Auxiliary function to handle right-click mouse options of I-V curves
% representation to erase
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
        c1 = uimenu(cmenu,'Label',src.Tag,'ForegroundColor',src.Color);
        try
            
            data.NumFile = NumFile;
            data.fig.hObject = src.Parent.Parent;
            data.IVset = IVset;            
            data.src = src;
            data.color = distinguishable_colors(length(data.IVset));
            
            uimenu(c1,'Label','IV Vertical Shift','Callback',...
                {@ActionFcn},'UserData',data);
            uimenu(c1,'Label','Superconductor stage correction','Callback',...
                {@ActionFcn},'UserData',data);
            uimenu(c1,'Label','Transition stage correction','Callback',...
                {@ActionFcn},'UserData',data);
            
        catch
        end
        
        
        set(src,'uicontextmenu',cmenu);
    otherwise
end

function ActionFcn(src,evnt)

hfig = findobj('Tag','Raw IV Curves');
hax = findobj('Tag','Raw IV axes');
UserData = get(src,'UserData');
% UserData.fig.hObject.UserData = UserData.IVset;
str = get(src,'Label');

% Pintar los tramos de pendiente superconductora y la transición
x = UserData.IVset(UserData.NumFile).ibias;
y = UserData.IVset(UserData.NumFile).vout;

diffy = diff(y);
thresholdy = prctile(abs(diffy),100);
Ind = find(round(abs(diffy)*1e5) == round(thresholdy*1e5))+1;
Trans.ibias = x(1:Ind);
Trans.vout = y(1:Ind);
Supercond.ibias = x(Ind+1:end);
Supercond.vout = y(Ind+1:end);


% Corrección para un salto de Squid que puede afectar a toda la IV o únicamente a la parte superconductora 
% El valor final (cercano a 0 de corriente) se obtiene de todas las curvas
% de forma que el valor mediano (el más estable) se resta de: toda la IV en caso de estar afectada toda la curva o; de la parte
% superconductora

for i = 1:length(UserData.IVset)
    a(i) = UserData.IVset(i).vout(end);
    b(i) = UserData.IVset(i).vout(1);
end

Squid_shift = Supercond.vout(end)-nanmedian(a);

% Corrección para un salto de Squid que únicamente afecta a la parte de la
% transición



switch str
    case 'IV Vertical Shift'
        UserData.IVset(UserData.NumFile).vout = [Trans.vout; Supercond.vout]-Squid_shift;

    case 'Superconductor stage correction'                
        UserData.IVset(UserData.NumFile).vout = [Trans.vout; Supercond.vout-Squid_shift];
        
    case 'Transition stage correction'
        bM = nanmedian(diff(b));
        if UserData.NumFile == length(UserData.IVset)
            Normal_shift = UserData.IVset(UserData.NumFile-1).vout(1)+bM; 
            UserData.IVset(UserData.NumFile).vout = [Trans.vout-Trans.vout(1)-Normal_shift; Supercond.vout];
        else
            Normal_shift = UserData.IVset(UserData.NumFile+1).vout(1)+bM; 
            UserData.IVset(UserData.NumFile).vout = [Trans.vout-Trans.vout(1)+Normal_shift; Supercond.vout];
        end

    otherwise

end
% Cambiamos de color la curva IV que va a ser modificada

IVchange = findobj('Tag',src.Parent.Text);  % Problemas de identificación si hay otras figuras abiertas!!!!! 'Tag','Raw IV axes'
color = IVchange.Color;
IVchange.Color = [0.8 0.8 0.8];
IVchange.Tag = '';
IVchange.ButtonDownFcn = [];
guidata(IVchange,IVchange)
% Volvemos a pintar la curva IV corregida
plot(hax,UserData.IVset(UserData.NumFile).ibias*1e6,UserData.IVset(UserData.NumFile).vout,...
    'DisplayName',[num2str(UserData.IVset(UserData.NumFile).Tbath*1e3) ' ' UserData.IVset(UserData.NumFile).range],...
                    'ButtonDownFcn',{@IVSquidStep},'Tag',UserData.IVset(UserData.NumFile).file,'Color',color,'UserData',UserData.IVset);

IVlines = findobj('Type','Line');
for i = 1:length(IVlines)
    IVlines(i).UserData = UserData.IVset;
end

set(hfig,'UserData',UserData.IVset);


