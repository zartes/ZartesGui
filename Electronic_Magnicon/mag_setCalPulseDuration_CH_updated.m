function out = mag_setCalPulseDuration_CH_updated(s)
% Function that sets the pulse duration time (us)
% of the electronic magnicon
%
% Input:
% - s: communication object referring to electronic magnicon
%
% Output:
% - out: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Example of usage:
% out = mag_setCalPulseDuration_CH_updated(s)
%
% Last update: 09/07/2018

%% Funcion para fijar la duracion del pulso.
% duration en us!!!
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
if s.PulseDuration.Value < 1.09
    s.PulseDuration.Value = 1.09;
end
if s.PulseDuration.Value > 2000
    s.PulseDuration.Value = 2000;
end
if s.PulseDuration.Value < 150
    d = 2500/9;
    out(2) = num2str(1);
elseif s.PulseDuration.Value >= 150
    d = 20000/9;
    out(2) = num2str(2);
end

%
DAC = s.PulseDuration.Value*255/d+2;
DAC_hex = dec2hex(round(DAC),2);
out(3:4) = DAC_hex;

str = sprintf('%s%s%s%s','<0',num2str(s.SourceCH),'P0',out(2:end-2));%%%El \r no se cuenta.
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');
if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end