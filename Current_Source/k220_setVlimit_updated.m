function k220 = k220_setVlimit_updated(k220)
% Function to change the maximum voltage limit value of the source device.
% By default, the maximum voltage is set at 50 V whenever no second
% argument is given.  
%
% Input:
% - k220: connection object of the current source
%
% Example:
% k220 = k220_setVlimit_updated(k220)
%
% Last update: 04/07/2018


%% Función para cambiar el límite máximo de Voltaje de la fuente.
%%%Por defecto se pone a 50V si no se pasa segundo argumento.
%%% El límite se pasa como número double en Voltios.
% if nargin == 1
%     Vmax = 50;
% else
%     Vmax = varargin{1};
% end

% Here it is needed to add a units tester

str = strcat('V',num2str(k220.Vmax.Value),'X','\n');
query(k220.ObjHandle,str)