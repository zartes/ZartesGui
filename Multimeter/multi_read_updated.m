function Vdc = multi_read_updated(multi)
% Function to read voltage from multimeter HP3458A
%
% Input:
% - multi: object refering to gpib connection of the HP3458A multimeter
%
% Output:
% - Vdc: voltage (units).
%
% Example of usage:
% Vdc = multi_read_updated(multi);
%
% Last uptdate: 28/06/2018

out = query(multi.ObjHandle,'');
Vdc = str2num(out);  % Alternative line: Vdc = str2double(out);