function out = mag_setIrange_CH_updated(s,rango)
% Function to set the range of Ibias values
%
% Input:
% - s: communication object referring to electronic magnicon
% - rango: Current values in microamperes
% - nch: source channel
%
% Output:
% - out: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Last update: 26/06/2018

%Función para fijar valor de Ibias. Pasar Ibias en uA.
%Funcion para poner el rango de corriente.

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

if contains(rango,'125')
    out(6) = '0';
elseif contains(rango,'500')
    out(6) = '1';
end

str = ['<0' num2str(s.SourceCH) 'q0' out(2:6)];
chk = mod(sum(double(str)),256);
str = sprintf('%s%X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');

if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end