function dir=GetCloudDataDir(varargin)
%%% funcion para devolver la ruta correcta al directorio de la nube
%%%Cloud Dir movido a qmadnas en 2023.
dir='\\qmadnas\zartes\DOCUZAR\Datos'
return;
if nargin==0
    Unidad='G:\'; %%%Unidad donde esté montado el Drive.
else
    Unidad=varargin{1}; %%%Si está montado en otra unidad podemos pasarlo como argumento
end

ESP_str='Unidades compartidas'; %% directorio carpetas compartidas en castellano
ENG_str='Shared drives'; %%  directorio carpetas compartidas en ingles.
%%%before Drive discontinuation
%ruta='\X-IFU\Datos\Datos Dilución'; %%%Ruta al directorio raiz de los datos.
ruta='\ZARTES\Datos';
x_esp=ls(strcat(Unidad,ESP_str));
x_eng=ls(strcat(Unidad,ENG_str));
if ~isempty(x_esp)
    dir=strcat(Unidad,ESP_str,ruta);
elseif ~isempty(x_eng)
    dir=strcat(Unidad,ENG_str,ruta);
else
    error('Bad color directory route')
end