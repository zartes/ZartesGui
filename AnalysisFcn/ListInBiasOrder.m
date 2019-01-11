function files = ListInBiasOrder(D,varargin)
% Function to list files in current value order
%
% Input:
% - D es un string tipo 'HP*' 'TF*' ec.
% - order: in absence order is descend by default
%
% Output:
% - files
%
% Example of usage:
% files = ListInBiasOrder('TF*')
%
% Last update: 14/11/2018

if nargin == 2
    order = varargin{1};
else
    order = 'descend';
end

f = dir(D);
if ~isempty(f)
    f = f(~[f.isdir]);
    f.name;
    for i = 1:length(f)
        str = regexp(f(i).name,'-?\d+.?\d*uA','match');
        Ibs(i) = sscanf(char(str),'%fuA');
    end
    
    [ii,jj] = sort(abs(Ibs),order);
    f = f(jj);
    files = {f(:).name};
else
    files = [];
end