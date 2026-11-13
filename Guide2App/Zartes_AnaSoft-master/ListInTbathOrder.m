function [files,ind]=ListInTbathOrder(pattern)
%%%función para listar en orden de Tbath creciente.

files=ls(pattern);

ind=[];%%%init
for i=1:length(files(:,1)) 
    %ind(i)=sscanf(files(i,:),'%fmK*');
    x=regexp(files(i,:),'^(?<temp>\d+(.\d+)?)mK','names');%%%%% Patron: cadena que empieza con {temp}mK... (no vale si la cadena empieza con otra cosa.
    if ~isempty(x) ind(end+1)=str2num(x.temp);end
end
[ind,ii]=sort(ind);
files=files(ii,:);

