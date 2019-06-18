function [IuA, out] = mag_readPhib_CH(s)
% Function to read Phi_b values of the electronic magnicon in uA
%
% Input:
% - s: communication object referring to electronic magnicon
%
% Output:
% - IuA: Current values in microamperes
% - out: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Last update: 11/06/2019

if s.SourceCH == 1
    ch = '1';
elseif s.SourceCH == 2
    ch = '2';
else
    error('wrong Channel number');
end

str = sprintf('%s%s%s','<0',ch,'j8');%%%
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');

if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end

%str=sprintf('%s\r','<01q846');
%out=query(s,str,'%s','%s');

dac = hex2dec(out(2:4));

IuA = 5*(dac-2048)*1e6/(4096*20071);%%%ojo, está mal el manual!!!