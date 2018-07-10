function [IuA, out] = mag_readImag_CH_updated(s)
% Function to get Ibias value of the electronic magnicon
%
% Input:
% - s: communication object referring to electronic magnicon
%
% Output:
% - IuA: Current values in uA
% - out: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Last update: 28/06/2018

%% Funcion para leer la Ibias

if ~isnumeric(s.SourceCH)
    disp('s.SourceCH parameter must be a number, 1 or 2');
    return;
elseif ~any([1 2]-s.SourceCH == 0) % Only channels 1 and 2 are available
    error('wrong Channel number');
end

str = ['<0' num2str(s.SourceCH) 'q8'];
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');
if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end

dac = hex2dec(out(2:5));

if mag_getBitrange_CH_updated(s)
    R = 10895; %R para rango 500uA (bit:1)
else
    R = 43600; %R para rango 125uA (bit:0)
end

%R=218.679249;%%%Para rango 25mA!
IuA = (10.934*(dac-8192)*1e6)/(16384*R);