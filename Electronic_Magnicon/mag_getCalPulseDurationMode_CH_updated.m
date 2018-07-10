function mode = mag_getCalPulseDurationMode_CH_updated(s)
% Function that gets the range duration time of the calibration pulse
% of the electronic magnicon
%
% Input:
% - s: communication object referring to electronic magnicon
%
% Output:
% - mode: numerical format: mode = 1 '<150us'; mode=2 '>=150us'
%
% Example of usage:
% mode = mag_getCalPulseDurationMode_CH(s)
%
% Last update: 09/07/2018

%% Funcion para leer el rango de duración del pulso de calibracion.
% usamos formato numérico: mode=1 '<150us'; mode=2 '>=150us';

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

%str=sprintf('%s\r','<01q846');
%out=query(s,str,'%s','%s');

%rango info en bit '6'.
mode = str2double(out(2));

if mode == 1
    sprintf('CAL Pulse Mode set to: %s','<150us')
elseif mode == 2
    sprintf('CAL Pulse Mode set to: %s','>=150us')
end