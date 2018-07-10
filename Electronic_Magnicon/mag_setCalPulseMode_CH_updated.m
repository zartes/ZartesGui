function out = mag_setCalPulseMode_CH_updated(s,mode)
% Function that sets the configuration of pulse acquisition of the electronic magnicon
%
% Input:
% - s: communication object referring to electronic magnicon
% - mode: 'continuous' or 'single'
%
% Output:
% - out: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Example of usage:
% mag_Configure_CalPulse_updated(s)
%
% Last update: 09/07/2018

%% Funcion para fijar el rango de duración del pulso de calibracion.
% pasamos el modo en formato numérico mode=1 '<150us'; mode=2 '>=150us';

if ~isnumeric(s.SourceCH)
    disp('s.SourceCH parameter must be a number, 1 or 2');
    return;
elseif ~any([1 2]-s.SourceCH == 0) % Only channels 1 and 2 are available
    error('wrong Channel number');
end

switch mode
    case 'continuous'
        mode = 0;
    case 'single'
        mode = 1;
end
% if ischar(mode)
%     if strfind('continuous',lower(mode)); mode=0;end
%     if strfind('single',lower(mode)); mode=1;end
% end

str = sprintf('%s%s%s','<0',num2str(s.SourceCH),'P8');%%%
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');

%%%mode=0 continuo; mode=1 single shot.
out(12) = num2str(mode);

str = sprintf('%s%s%s%s','<0',num2str(s.SourceCH),'P0',out(2:end-2));%%%
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');
if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end