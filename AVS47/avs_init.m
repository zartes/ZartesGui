function [obj, status] = avs_init(obj)
% Function to initialize the AVS 47 device
%
% Input:
% - obj: Object class AVS
%
% Output:
% - obj: Object regards AVS gpib connection
% - status: status value (0: Ok; 1: Error);
%
% Example:
% [obj, status] = avs_init(obj)
%
% Last update: 10/01/2019


%% Función para inicializar una sesión con el AVS 47.

status = 0; % Correct

aux = instrfind('type','gpib','Status','closed','Boardindex',obj.BoardIndex,'primaryaddress',obj.PrimaryAddress);
for i = 1:length(aux)
    delete(aux(i));
end

obj.ObjHandle = instrfind('type','gpib','Status','open','primaryaddress',obj.PrimaryAddress);
if isempty(obj.ObjHandle)
    obj.ObjHandle = gpib('ni',obj.BoardIndex,obj.PrimaryAddress);
    try
        fopen(obj.ObjHandle);   % Important line, it is mandatory to use fclose(multi) at the end of the session.
    catch
        status = 1; % Connection not available
        delete(obj.ObjHandle);
        disp('Error connecting AVS47, please check connectivity');         
        return;
    end
end
command = 'REM1;RAN7;INP1;MUX0;EXC2;ARN0;ADC\r\n'; 


query(obj.ObjHandle,command);
fclose(obj.ObjHandle);
pause(1);
fopen(obj.ObjHandle);

% Checking the correct connection with the device
device = query(obj.ObjHandle,'*IDN?');
if ~strcmpi(obj.ID,device(6:end))
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

command = 'RESET; END 1; FUNC DCV, 10; NPLC 10'; %%% NPLC 10 -> 1.

query(obj.ObjHandle,command);
