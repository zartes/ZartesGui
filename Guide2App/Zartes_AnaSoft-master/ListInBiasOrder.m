function [files,varargout]=ListInBiasOrder(D,varargin)
%%%Listar ficheros en orden de corriente de bias.
%%%D es un string tipo 'HP*' 'TF*' ec.

if nargin==2
    order=varargin{1};
else
    order='descend';
end

f=dir(D);
f=f(~[f.isdir]);
%length(f)
%f.name;
Ibs=[];
for i=1:length(f)
    str=regexp(f(i).name,'-?\d+.?\d*uA','match');
    Ibs(i)=sscanf(char(str),'%fuA');
end

%[ii,jj]=sort(abs(Ibs),order);
[~,jj]=sort(Ibs,order);
f=f(jj);
files={f(:).name};
if nargout==2
    varargout{1}=Ibs;
end