function plotlog(tmp,str)
%funcion para mostrar el log de los parámetros del IGH. La nueva version
%del programa de LabView guarda todo en una excell que se importa en tmp
%con dos campos, el texto donde están la fecha, hora y cabecera y los datos
%La funcion se llama dando el nombre del parametro que queremos mostrar
% ej: plotlog(tmp,'1Kpot') muestra T1Kpot o plotlog(tmp,'NV') el valor de
% la niddle valve.
%import with: tmp=importdata(strcat(path,'\log.dat'));
for i=1:length(tmp.textdata(1,:)),b(i)=strcmp(tmp.textdata{1,i},str);end
try
[y,m,d,H,M,S]=datevec(strcat(strcat(tmp.textdata(2:end,1),'_'),tmp.textdata(2:end,2)),'dd/mm/yyyy_HH:MM:SS');
catch
    [y,m,d,H,M,S]=datevec(strcat(strcat(tmp.textdata(2:end,1),'_'),tmp.textdata(2:end,2)),'dd/mm/yyyy_HH:MM:SS');
end %?! weird hay que ejecutarlo 2 veces para que no de error.
xt=datenum(y,m,d,H,M,S);
plot(xt,tmp.data(:,find(b)-2))
%set(gca,'XTickMode','auto') Esto para que actualice los ticks al hacer
%zoom, pero no funciona.
datetick %para poner el ejeX en formato hora