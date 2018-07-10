function Rf = mag_readRf_FLL_CH_updated(s)
% Function to measure the value of impedance Rf in closed loop
%
% Input:
% - s: communication object referring to electronic magnicon
% - nch: source channel of the electronic magnicon
%
% Output:
% - Rf: Resistance (ohms)
% 
% Example of usage:
% Rf = mag_readRf_FLL_CH(s, 2)
%
% Last update: 26/06/2018

if ~isnumeric(s.SourceCH)
    disp('nch parameter must be a number, 1 or 2');
    return;
elseif ~any([1 2]-s.SourceCH == 0) % Only channels 1 and 2 are available
    error('wrong Channel number');
end

str = sprintf('%s%s%s','<0',num2str(s.SourceCH),'n9');
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');

table = [0 0.7 0.75 0.91 1 2.14 2.31 2.73 3.0 7.0 7.5 9.1 10 23.1 30 100]*1e3;
ind = hex2dec(out(2))+1;
Rf = table(ind);