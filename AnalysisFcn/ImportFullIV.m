function IVset = ImportFullIV(varargin)
%%%Nueva versión de la funcion de importacion de IVs con alguna
%%%modificacion.
%%importamos
if nargin == 0
[file,path] = uigetfile('C:\Documents and Settings\Usuario\Escritorio\Datos\2016\Noviembre\IVs\*','','multiselect','on');
end

%podemos pasar los ficheros a analizar como un cellarray.
if nargin > 0
    path = varargin{1};    
    file = varargin{2};
%     path = pwd;
%     path = strcat(path,'\');
%     if nargin == 3
%         circuit = varargin{3};
%     end
end

T = strcat(path,file);
if ~iscell(T)
    [ii,jj] = size(T);
    for i = 1:ii
        T2{i} = T(i,:);
    end
    T=T2;
end
if ~iscell(file)
    [ii,jj] = size(file);
    for i = 1:ii
        file2{i} = file(i,:);
    end
    file = file2;
end
h = waitbar(0,'Please wait...','Name','ZarTES v1.0 - Loading IV curves');
pause(0.2);
for i = 1:length(T)
    
    %cargamos datos.Ojo al formato.
    %data=importdata(T{i},'\t');%%%si hay header hace falta skip.
    data = importdata(T{i});
    if isstruct(data)
        data = data.data; 
    end
    %corregir el vout.
    %auxS=corregir4ramas(data);%%para importar ficheros con 4 ramas (sin header)
    auxS = corregir1rama(data);%% para importar ficheros con 1 rama.
    auxS.Tbath = sscanf(char(regexp(file{i},'\d+.?\d+mK*','match')),'%fmK')*1e-3; %%%ojo al %d o %0.1f
    % Añadido para identificar de donde procede la informacion
    auxS.file = file{i};
    
    IVset(i) = auxS;
    
    file_upd = file{i};
    file_upd(file_upd == '_') = ' ';
    waitbar(i/length(T),h,file_upd)
end
if ishandle(h)
    close(h);
end
% if nargin > 0
%     IVset = GetIVTES(circuit,IVset);
% end