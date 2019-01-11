function [IuA, out] = mag_readLNCSImag(s)
% Funcion para leer la Ibias de la LNCS!
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
str = sprintf('%s\r','<03q848');
out = query(s.ObjHandle,str,'%s','%s');

dac = hex2dec(out(2:5));
if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end

% R=218.679249;%%%Para rango 25mA! MAL
% IuA=(10.934*(dac-8192)*1e6)/(16384*R);

R = 600;
IuA = (30.005*(dac-8192)*1e6)/(16385*R);