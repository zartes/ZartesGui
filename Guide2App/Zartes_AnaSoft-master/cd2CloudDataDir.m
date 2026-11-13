function cd2CloudDataDir(dir)
%%%funcion para moverse a un directorio de la nube teniendo en cuenta que
%%%la ruta exacta puede cambiar por tener el string en ENG o ESP.

ESP_str='Unidades compartidas'; %% directorio carpetas compartidas en castellano
ENG_str='Shared drives'; %%  directorio carpetas compartidas en ingles.
%ruta='\X-IFU\Datos\Datos Dilución'; %%%Ruta al directorio raiz de los datos.

The_string=regexp(dir,'[A-Z]:\\(.*)\\X-IFU','tokens');

if isempty(The_string) cd(dir);return;end

Unidad=regexp(dir,'[A-Z]:\','match');
Unidad=Unidad{1};
if isempty(Unidad) Unidad='G:\'; end

x_esp=ls(strcat(Unidad,ESP_str));
x_eng=ls(strcat(Unidad,ENG_str));

if ~isempty(x_esp)
    %dir=strcat(Unidad,ESP_str,ruta);
    outdir=strrep(dir,The_string{1},ESP_str)
elseif ~isempty(x_eng)
    %dir=strcat(Unidad,ENG_str,ruta);
    outdir=strrep(dir,The_string{1},ENG_str)
else
    error('Bad color directory route')
end
cd(outdir{1})