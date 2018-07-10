function k220_setI_updated(k220,Ivalue)
% Function to activate the source output
%
% Input:
% - k220: connection object of the current source
% - Ivalue: current values (in units of A)
%
% Example:
% k220_setI_updated(k220,Ivalue)
%
% Last update: 04/07/2018

%% Función para fijar el valor de corriente de la fuente. Se pasa como
%%% double en Amperios. Se fija un Imax por precaución por si se pasa por
%%% error un valor demasiado alto.
% Imax = 0.005;
if Ivalue > k220.Imax.Value
    error('Maximum current value exceeded, select Ivalue values below 0.005 A');
end
str = strcat('I',num2str(Ivalue),'X','\n');
query(k220.ObjHandle,str)