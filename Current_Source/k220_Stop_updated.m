function k220_Stop_updated(k220)
% Function to deactivate the source output
%
% Input:
% - k220: connection object of the current source
%
% Example:
% k220_Stop_updated(k220)
%
% Last update: 04/07/2018

%% Función para desactivar el output de la fuente.
str = 'F0T4X\n'; %%% Funciona también 'F0T5X\n
query(k220.ObjHandle,str)