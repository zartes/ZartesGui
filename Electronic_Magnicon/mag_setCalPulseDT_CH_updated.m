function out = mag_setCalPulseDT_CH_updated(s)
% Function that sets the configuration of the range of pulse calibration
% of the electronic magnicon
%
% Input:
% - s: communication object referring to electronic magnicon
%
% Output:
% - out: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Example of usage:
% out = mag_setCalPulseDT_CH_updated(s)
%
% Last update: 09/07/2018

%% Funcion para fijar el rango de duración del pulso de calibracion.
% pasamos el modo en formato numérico mode=1 '<150us'; mode=2 '>=150us';
%OJO: DT en ms!!!

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

DAC = (s.PulseDT.Value*1000-10)/95.5;
if DAC > 65535
    DAC = 65535;%%%limite 'FFFF'
end
DAC_hex = dec2hex(round(DAC),4);
out(5:8) = DAC_hex;

str = sprintf('%s%s%s%s','<0',num2str(s.SourceCH),'P0',out(2:end-2));%%%
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');
if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end
mode = mag_getCalPulseDurationMode_CH_updated(s); %#ok<NASGU>