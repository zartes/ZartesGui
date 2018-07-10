function out = mag_setFLL_CH_updated(s)
% Function that sets the electronic magnicon in FLL mode
%
% Input:
% - s: communication object referring to electronic magnicon
%
% Output:
% - out: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Example of usage:
% out = mag_setFLL_CH_updated(s,nch)
%
% Last update: 28/06/2018

%% Funcion para poner modo FLL


if ~isnumeric(s.SourceCH)
    disp('s.SourceCH parameter must be a number, 1 or 2');
    return;
elseif ~any([1 2]-s.SourceCH == 0) % Only channels 1 and 2 are available
    error('wrong Channel number');
end

% str=sprintf('%s%s%s','<0',ch,'b01');
str = ['<0' num2str(s.SourceCH) 'b01'];
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');

if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end