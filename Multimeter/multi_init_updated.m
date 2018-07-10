function [multi, status] = multi_init_updated(multi)
% Function to initialize the multimeter HP3458A device
%
% Input:
% - multi: Object class Multimetro
%
% Output:
% - multi: Object regards multimeter gpib connection
% - status: status value (0: Ok; 1: Error);
%
% Example:
% [multi, status] = multi_init_updated();
%
% Last update: 28/06/2018


%% Función para inicializar una sesión con el multimetro HP.

status = 0; % Correct


% This line searchs for any closed gpib connection before creating the one for the multimeter
aux = instrfind('type','gpib','Status','closed','Boardindex',multi.BoardIndex,'primaryaddress',multi.PrimaryAddress);
for i = 1:length(aux)
    delete(aux(i));
end

multi.ObjHandle = instrfind('type','gpib','Status','open','primaryaddress',multi.PrimaryAddress);
if isempty(multi.ObjHandle)
    multi.ObjHandle = gpib('ni',multi.BoardIndex,multi.PrimaryAddress);
    try
        fopen(multi.ObjHandle);   % Important line, it is mandatory to use fclose(multi) at the end of the session.
    catch
        status = 1; % Connection not available
        delete(multi.ObjHandle);
        rmpath('G:\Mi unidad\ICMA\zartes_ACQ-master\Multimetro_HP3458A_Matlab\');
        disp('Error connecting Multimeter HP3458A, please check connectivity');         
        return;
    end
end

% Checking the correct connection with the device
device = query(multi.ObjHandle,'ID?');
if ~strcmpi(multi.ID,device(1:7))
    status = 1; % Connection not available
    return;
end


%%%Configuración copiada del programa de test de LabView modulo hp3458a
%%%Config Vdc. Con la configuración por defecto daban error los programas
%%%de IV etc y tenia que ejecutar a mano el programa de LabView.
% command = 'RESET; END 1; FUNC DCV, 10.3e; NPLC 10'; %%% NPLC 10 -> 1.
% Posible problema de sintaxis con FUNC DCV, 10.3e.  Parece que el valor no
% es aceptado por el aparato.  Este valor hace referencia al rango de
% voltajes en el que dará la medida. Si es auto, entonces antes de medir el
% aparato comprueba la señal y elige el mejor rango, si es fijo no. 
% Por defecto, el multimetro se encuentra en modo DCV. NPLC es una variable
% que se encarga de 
% END 1: The END command enables or disables the GPIB End Or Identify (EOI)
% function; 1 means ON
% The RESET command does the following: 
% - Aborts readings in process.
% - Clears error and auxiliary error registers.
% - Clears the status register except the Power-on SRQ bit (bit 3).
% - Clears reading memory.

command = 'RESET; END 1; FUNC DCV, 10.3e; NPLC 10'; %%% NPLC 10 -> 1.

query(multi.ObjHandle,command);
