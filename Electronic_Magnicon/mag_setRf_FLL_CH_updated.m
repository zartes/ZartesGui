function out = mag_setRf_FLL_CH_updated(s)
% Function that sets a fixed Rf value in FLL (Frequency-locked loop). The value finally taken is
% rounded to the closest one on the following table:
% table=[0 0.7 0.75 0.91 1 2.14 2.31 2.73 3.0 7.0 7.5 9.1 10 23.1 30 100]*1e3;
%
% Input:
% - s: communication object referring to electronic magnicon
% - Rf: Resistance (ohms)
% - nch: source channel of the electronic magnicon
%
% Output:
% - out: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Example of usage:
% out = mag_setRf_FLL_CH(s, 2e3, 2)
%
% Last update: 26/06/2018

if ~isnumeric(s.SourceCH)
    disp('SourceCH parameter must be a number, 1 or 2');
    return;
elseif ~any([1 2]-s.SourceCH == 0) % Only channels 1 and 2 are available
    error('wrong Channel number');
end

% Values of Rf are rounded according to the closest one in the table
table = [0 0.7 0.75 0.91 1 2.14 2.31 2.73 3.0 7.0 7.5 9.1 10 23.1 30 100]*1e3;
[s.Rf.Value, ind] = min(abs(table-s.Rf.Value)); 


str = sprintf('%s%s%s%X','<0',num2str(s.SourceCH),'n1',ind(1)-1);
chk = mod(sum(double(str)),256);
str = sprintf('%s%X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');
if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end
RF = mag_readRf_FLL_CH_updated(s);
sprintf('Rf set to: %d Ohm',RF)  % Should it be recorded somewhere?? a Log file for example?
