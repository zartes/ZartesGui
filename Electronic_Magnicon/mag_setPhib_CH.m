function out = mag_setPhib_CH(s,IuA,nch)
% Function to set Phi_b values of the electronic magnicon in uA
%
% Input:
% - s: communication object referring to electronic magnicon
% - IuA: Current values in microamperes
%
% Output:
% - out: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Last update: 06/06/2019

DAC=dec2hex(round(IuA*4096*20071/5e6+2048),3);%%%

if s.SourceCH == 1
    ch = '1';
elseif s.SourceCH == 2
    ch = '2';
else
    error('wrong Channel number');
end

str = sprintf('%s%s%s%s','<0',ch,'j0',DAC);%%%
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');

if strcmp(out,'|0AC')
    out='OK';
else
    out='FAIL';
end