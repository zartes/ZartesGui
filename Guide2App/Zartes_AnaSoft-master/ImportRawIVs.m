function IVset=ImportRawIVs(varargin)
%%%Versión de ImportFullIV para importar los datos brutos y corregir a
%%%parte el set, por ejemplo si hay un offset.
if nargin==0
[file,path]=uigetfile('C:\Documents and Settings\Usuario\Escritorio\Datos\2016\Noviembre\IVs\*','','multiselect','on');
end

%podemos pasar los ficheros a analizar como un cellarray.
if nargin>0
    file=varargin{1};
    path=pwd;
    path=strcat(path,'\');
    if nargin==2 circuit=varargin{2};end
end

T=strcat(path,file)
if ~iscell(T)
    [ii,jj]=size(T);
    for i=1:ii, T2{i}=T(i,:);end
    T=T2;
end
if ~iscell(file)
    [ii,jj]=size(file);
    for i=1:ii, file2{i}=file(i,:);end
    file=file2;
end
j=1;
for i=1:length(T)
    T{i}
    %cargamos datos.Ojo al formato.
    %data=importdata(T{i},'\t');%%%si hay header hace falta skip.
    data=importdata(T{i});
    if isstruct(data) data=data.data;end
    auxS.ibias=data(:,2)*1e-6;%%%%raw data.
    auxS.vout=data(:,4);%%%raw data.
    auxS.Tbath=sscanf(char(regexp(file{i},'\d+.?\d+mK*','match')),'%fmK')*1e-3; %%%ojo al %d o %0.1f
    if auxS.Tbath==0, continue;end %%%No queremos importar IVs que se hayan etiquetado como tomadas a 0mK.
    IVset(j)=auxS;j=j+1;
end
if nargin==2 IVset=GetIVTES(circuit,IVset);end