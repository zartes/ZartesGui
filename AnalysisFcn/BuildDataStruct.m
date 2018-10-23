function datastruct=BuildDataStruct()
%%%%%Función para construir la estructura global de datos de un TES. Usa
%%%%%los nombres por defecto. Luego se puede actualizar cambiando
%%%%%individualmente la que haga falta.
datastruct.TES=evalin('base','TES');
datastruct.circuit=evalin('base','circuit');
datastruct.IVset=evalin('base','IVset');
who=evalin('base','who');
if sum(~cellfun('isempty',strfind(who,'IVsetN')))
    'IVsetN'
    datastruct.IVsetN=evalin('base','IVsetN');
end
datastruct.Gset=evalin('base','Gset');
if sum(~cellfun('isempty',strfind(who,'GsetN')))
    datastruct.GsetN=evalin('base','GsetN');
end
datastruct.P=evalin('base','P');
if sum(~cellfun('isempty',strfind(who,'PN')))
    datastruct.PN=evalin('base','PN');
end
datastruct.datadir=pwd;
if sum(~cellfun('isempty',strfind(who,'session')))
    datastruct.session=evalin('base','session');
end