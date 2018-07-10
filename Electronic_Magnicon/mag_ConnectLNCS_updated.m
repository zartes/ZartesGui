function out = mag_ConnectLNCS_updated(s)
% Function to conect LNCS source
%
% Input:
% - s.ObjHandle: communication object referring to electronic magnicon
%
% Output:
% - out: output of the query of the electronic magnicon
%
% Last update: 26/06/2018

%%%Funcion para conectar la LNCS source

str = sprintf('%s\r','<03a838'); %%command reading ch3 switch.
out = query(s.ObjHandle,str,'%s','%s');
dac = hex2dec(out(2:5));
new = dec2hex(bitand(dac,65279),4); 
%%% To unplug use the first bit of the second char

str = ['<03a0' new];
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');

if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end