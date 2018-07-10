function out = mag_setCalPulseON_CH_updated(s)
% Function that activates the pulse source of the electronic magnicon
%
% Input:
% - s: communication object referring to electronic magnicon
%
% Output:
% - out: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Example of usage:
% out = mag_setCalPulseON_CH_updated(s)
%
% Last update: 09/07/2018

%% 
if ~isnumeric(s.SourceCH)
    disp('s.SourceCH parameter must be a number, 1 or 2');
    return;
elseif ~any([1 2]-s.SourceCH == 0) % Only channels 1 and 2 are available
    error('wrong Channel number');
end

str = sprintf('%s%s%s','<0',num2str(s.SourceCH),'P8');%%%
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');

out(13) = num2str(1);

str = sprintf('%s%s%s%s','<0',num2str(s.SourceCH),'P0',out(2:end-2));%%%
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');
if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end