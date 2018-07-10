function range = mag_getIrange_CH_updated(s)
% Function to get the current range of the electronic magnicon
%
% Input:
% - s: communication object referring to electronic magnicon
%
% Output:
% - range: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Example of usage:
% range = mag_getIrange_CH_updated(s)
%
% Last update: 09/07/2018


%% Funcion para leer el rango de corriente

if ~isnumeric(s.SourceCH)
    disp('s.SourceCH parameter must be a number, 1 or 2');
    return;
elseif ~any([1 2]-s.SourceCH == 0) % Only channels 1 and 2 are available
    error('wrong Channel number');
end

str = sprintf('%s%s%s','<0',num2str(s.SourceCH),'q8');%%%
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');

%str=sprintf('%s\r','<01q846');
%out=query(s,str,'%s','%s');

if strcmp(out(6),'0')
    range = '125uA';
elseif strcmp(out(6),'1')
    range = '500uA';
end