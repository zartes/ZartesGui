function out = mag_setLNCSImag_updated(s,IuA)
% Function to set fixed values of Ibias in LNCS device. 
%
% Input:
% - s: communication object referring to electronic magnicon
% - IuA: Current values in microamperes
%
% Output:
% - out: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Example: out = mag_setLNCSImag_updated(s,IuA)
%
% Last update 26/06/2018

%% Función para fijar valor de Ibias de la LNCS!!!

if abs(IuA) > 5000  % Protection block to ensure current below 5 milliamperes.
    error('Ibias value too high');
end

R = 600;
DAC = dec2hex(round(((16385*IuA*R)/(30.005*1e6))+8192),4);
range = '0';

str = ['<03q0' DAC range];
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');

if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end