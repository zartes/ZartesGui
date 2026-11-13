function IVset=importIVs(varargin)
%funcion para importar datos de medidas IV en estructura para analisis.

[file,path]=uigetfile('C:\Users\Carlos\Desktop\LastTESdir\*','','Multiselect','on');
T=strcat(path,file);

file
skip=7;%header=6, +1 del primer pto. Ojo, si skip=0, se devuelve data y no data.data.
if (iscell(T))
for i=1:length(T),
    data{i}=importdata(T{i},'\t',skip);
    data{i}=data{i}.data;
    IVset(i).ibias=data{i}(:,2)*1e-6;
    IVset(i).vout=data{i}(:,4)-data{i}(end,4);
    if nargin>0
        IVset(i).Tbath=varargin{1}(i);
    else
        IVset(i).Tbath=sscanf(file{i},'IV%dmK*')*1e-3;
    end
end
else
    data=importdata(T,'\t',skip);
    data=data.data;
    IVset.ibias=data(:,2)*1e-6;
    IVset.vout=data(:,4)-data(end,4);
    if nargin>0
        IVset.Tbath=varargin{1};
    else
        IVset.Tbath=sscanf(file,'IV%dmK*')*1e-3;
    end
end