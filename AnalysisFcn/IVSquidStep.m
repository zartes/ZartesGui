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
            uimenu(c1,'Label','SQUID Step Manually correction','Callback',...
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

% Pintar los tramos de pendiente superconductora y la transici贸n
x = UserData.IVset(UserData.NumFile).ibias;
y = UserData.IVset(UserData.NumFile).vout;

diffy = diff(y);
thresholdy = prctile(abs(diffy),100);
Ind = find(round(abs(diffy)*1e5) == round(thresholdy*1e5));
Trans.ibias = x(1:Ind);
Trans.vout = y(1:Ind);
Supercond.ibias = x(Ind+1:end);
Supercond.vout = y(Ind+1:end);


% Correcci贸n para un salto de Squid que puede afectar a toda la IV o 煤nicamente a la parte superconductora 
% El valor final (cercano a 0 de corriente) se obtiene de todas las curvas
% de forma que el valor mediano (el m谩s estable) se resta de: toda la IV en caso de estar afectada toda la curva o; de la parte
% superconductora

for i = 1:length(UserData.IVset)
    a(i) = UserData.IVset(i).vout(end);
    b(i) = UserData.IVset(i).vout(1);
end

Squid_shift = Supercond.vout(end)-nanmedian(a);

% Correcci贸n para un salto de Squid que 煤nicamente afecta a la parte de la
% transici贸n



switch str
    case 'IV Vertical Shift'
        UserData.IVset(UserData.NumFile).vout = [Trans.vout; Supercond.vout]-Squid_shift;

    case 'Superconductor stage correction'                        
        derVout = abs(diff(UserData.IVset(UserData.NumFile).vout));       
        thSup = 10*max([mean(abs(derVout(end-4:end-1))); mean(abs(derVout(2:4)))]);%                
        indx = find(derVout > thSup)+1;
        
        if length(indx) > 1
            [~, ind_c] = max(abs(UserData.IVset(UserData.NumFile).vout(indx)));             
            UserData.IVset(UserData.NumFile).vout = [Trans.vout; Supercond.vout-Squid_shift];
            UserData.IVset(UserData.NumFile).vout(indx(ind_c)) = [];
            UserData.IVset(UserData.NumFile).ibias(indx(ind_c)) = [];
        end
        
    case 'Transition stage correction'
        bM = nanmedian(diff(b));
        if UserData.NumFile == length(UserData.IVset)
            Normal_shift = UserData.IVset(UserData.NumFile-1).vout(1)+bM; 
            UserData.IVset(UserData.NumFile).vout = [Trans.vout-Trans.vout(1)-Normal_shift; Supercond.vout];
        else
            Normal_shift = UserData.IVset(UserData.NumFile+1).vout(1)+bM; 
            UserData.IVset(UserData.NumFile).vout = [Trans.vout-Trans.vout(1)+Normal_shift; Supercond.vout];
        end
    case 'SQUID Step Manually correction'
%         waitfor(msgbox('Zoom in before close this window around SQUID step.',''));
%         [XOffset, YOffset] = ginput(1);

        
        derVout = abs(diff(UserData.IVset(UserData.NumFile).vout));       
        thSup = 1.1*max([mean(abs(derVout(end-4:end-1))); mean(abs(derVout(2:4)))]);
%         thSup = 1.05*max();
        % Busqueda de pendientes grandes
        indx = find(derVout > thSup);
        
        % Comprobaci髇 de vecinos pr髕imos
        % A馻do la protecci髇 en caso de estar ante una curva "normal"
        if indx(1)-1 == 0
            % Actualizamos el umbral con los primeros puntos
            thSup = 1.1*max(abs(derVout(1:3)));
            % Busqueda de pendientes grandes
            indx = find(derVout > thSup);
        end
        ind_ok = [];
        for i = 1:length(indx)
            
            % Comprobamos que el punto tiene mayor pendiente que las partes
            % primera y 鷏tima (normal y superconductora)
            if derVout(indx(i)) > 1.1*thSup
                if (derVout(indx(i)-1) < 1.1*thSup)&&(derVout(indx(i)+1) < 1.1*thSup) % A izquierdas
                    ind_ok = [ind_ok indx(i)-1 indx(i)+1];
                end                
            end
            % Si el anterior o el posterior tienen una pendiente menor que
            % el umbral de la pendiente superconductora son puntos que hay
            % que eliminar/corregir
            if derVout(indx(i)-1) < 0.95*thSup % A izquierdas
                ind_ok = [ind_ok indx(i)-1];                
            end        
            try
                if derVout(indx(i)+1) < 0.95*thSup  % A derechas
                    ind_ok = [ind_ok indx(i)+1];
                end
            end
        end
        
        
        % Los saltos de Squid se producen de forma r醦ida en pocas muestras
        % comprobamos por pares si la distancia entre ellos no es mucha
        for i = 1:floor(length(ind_ok)/2)
            
            chk = (ind_ok(2*(i-1)+1)-ind_ok(2*(i-1)+2))<4;
            if chk == 1
                % los que est醤 cerca deber韆n de tener variaciones peque馻s de
                % amplitud
                yy = spline(UserData.IVset(UserData.NumFile).ibias(ind_ok(1)-3:ind_ok(1)),...
                    UserData.IVset(UserData.NumFile).vout(ind_ok(1)-3:ind_ok(1)),...
                    UserData.IVset(UserData.NumFile).ibias(ind_ok(1):ind_ok(2)));
                
                offset = UserData.IVset(UserData.NumFile).vout(ind_ok(2))-yy(end);
                UserData.IVset(UserData.NumFile).vout(ind_ok(1):ind_ok(2))=yy;
                UserData.IVset(UserData.NumFile).vout(ind_ok(2)+1:end) = UserData.IVset(UserData.NumFile).vout(ind_ok(2)+1:end)-offset;
            end
            
        end
        % figure,plot(UserData.IVset(UserData.NumFile).ibias,UserData.IVset(UserData.NumFile).vout),hold on,
        % Busqueda del punto de conflicto
%         [~, c] = min(abs(UserData.IVset(UserData.NumFile).ibias-XOffset*1e-6));
%         
%         intv = (c-3:min(c+3,length(UserData.IVset(UserData.NumFile).vout))); %muestras (10 antes y 10 despues del punto cr铆tico)
% 
%         [val, c1] = max(abs(diff(UserData.IVset(UserData.NumFile).vout(intv))));
%         MedianVal = median(abs(diff(UserData.IVset(UserData.NumFile).vout(intv))));
%         val = UserData.IVset(UserData.NumFile).vout(intv(c1));
%         indxc1 = c1+intv(1);
%         % plot(UserData.IVset(UserData.NumFile).ibias(c),UserData.IVset(UserData.NumFile).vout(c),'*r')
%         % plot(UserData.IVset(UserData.NumFile).ibias(indxc1),UserData.IVset(UserData.NumFile).vout(indxc1),'*r')
%         % 
%         UserData.IVset(UserData.NumFile).vout =[UserData.IVset(UserData.NumFile).vout(1:indxc1-1); UserData.IVset(UserData.NumFile).vout(indxc1:end)-val];
        % plot(UserData.IVset(UserData.NumFile).ibias,vout,'*r')
        % UserData.IVset(UserData.NumFile).ibias =UserData.IVset(UserData.NumFile).ibias(indxc1:end)-val;
        


    otherwise

end
% Cambiamos de color la curva IV que va a ser modificada

IVchange = UserData.src;  % Problemas de identificaci贸n si hay otras figuras abiertas!!!!! 'Tag','Raw IV axes'
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


