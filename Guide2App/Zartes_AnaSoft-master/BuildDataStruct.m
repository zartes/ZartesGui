function datastruct=BuildDataStruct()
%%%%%Función para construir la estructura global de datos de un TES. Usa
%%%%%los nombres por defecto. Luego se puede actualizar cambiando
%%%%%individualmente la que haga falta.

%%%V2: ojo, cambio base->caller pq si no puede dar error el AnalizeRun y
%%%cambio los strfind por strcmp porque strfind reconoce cualquier Pxxx como 'P'

datastruct.TES=evalin('caller','TES');
datastruct.circuit=evalin('caller','circuit');
datastruct.IVset=evalin('caller','IVset');
who=evalin('caller','who')

if sum(strcmp(who,'IVsetN'))
%if sum(~cellfun('isempty',strfind(who,'IVsetN')))
    datastruct.IVsetN=evalin('caller','IVsetN');
end

datastruct.Gset=evalin('caller','Gset');
if sum(strcmp(who,'GsetN'))
%if sum(~cellfun('isempty',strfind(who,'GsetN')))
    datastruct.GsetN=evalin('caller','GsetN');
end
if sum(strcmp(who,'P'))
%if sum(~cellfun('isempty',strfind(who,'P')))
    datastruct.P=evalin('caller','P');
end
if sum(strcmp(who,'PN'))
%if sum(~cellfun('isempty',strfind(who,'PN')))
    datastruct.PN=evalin('caller','PN');
end
if sum(strcmp(who,'TFS'))
%if sum(~cellfun('isempty',strfind(who,'TFS')))
    datastruct.TFS=evalin('caller','TFS');
end
if sum(strcmp(who,'datadir'))
%if sum(~cellfun('isempty',strfind(who,'datadir')))
    datastruct.datadir=evalin('caller','datadir');
end
if sum(strcmp(who,'session'))
%if sum(~cellfun('isempty',strfind(who,'session')))
    datastruct.session=evalin('caller','session');%%%Ojo aquí al nombre.
end