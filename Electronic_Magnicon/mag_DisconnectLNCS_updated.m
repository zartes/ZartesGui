function out = mag_DisconnectLNCS_updated(s)
% Function to unplug LNCS source
%
% Input:
% - s: communication object referring to electronic magnicon
%
% Output:
% - out: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Last update: 26/06/2018

%%%Funcion para desconectar la LNCS source

str = sprintf('%s\r','<03a838');%%comando para leer el switch del ch3.
out = query(s.ObjHandle,str,'%s','%s');

dac = hex2dec(out(2:5));
new = dec2hex(bitor(dac,256),4); %%%El bit para desconectar es el 1º del 2º char.

str = ['<03a0' new];%%%
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');
if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end