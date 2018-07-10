function k220_Start_updated(k220)
% Function to activate the source output
%
% Input:
% - k220: connection object of the current source
%
% Example:
% k220_Start_updated(k220)
%
% Last update: 04/07/2018

%% Función para activar el output de la fuente.
str = 'F1T4X\n';
query(k220.ObjHandle,str)