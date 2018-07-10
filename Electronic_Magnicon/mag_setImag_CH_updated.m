function out = mag_setImag_CH_updated(s,IuA)
% Function to set Ibias values of the electronic magnicon
%
% Input:
% - s: communication object referring to electronic magnicon
% - IuA: Current values in microamperes
%
% Output:
% - out: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Last update: 26/06/2018

%% Función para fijar valor de Ibias. Pasar Ibias en uA.

if abs(IuA) > 500
    error('Ibias value too high');
end
if ~isnumeric(s.SourceCH)
    disp('s.SourceCH parameter must be a number, 1 or 2');
    return;
elseif ~any([1 2]-s.SourceCH == 0) % Only channels 1 and 2 are available
    error('wrong Channel number');
end

if abs(IuA) > 125
    mag_setIrange_CH_updated(s,'500');
end

if mag_getBitrange_CH_updated(s)
    R = 10895; %R para rango 500uA (bit:1)
    range = '1';
else
    R = 43600; %R para rango 125uA (bit:0)
    range = '0';
end

%R=218.679249;%%%CH3.LNCS!!!
DAC = dec2hex(round(((16384*IuA*R)/(10.934*1e6))+8192),4);%%%ch1


str = ['<0' num2str(s.SourceCH) 'q0' DAC range];
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');

if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end