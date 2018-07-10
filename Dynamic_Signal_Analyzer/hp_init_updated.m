function [dsa, status] = hp_init_updated(dsa)
% Function to initialize the Spectral Analyzer HP3562A device
%
% Input:
% - dsa: Class object SpectralAnalyzer
%
% Output:
% - multi: Object regards multimeter gpib connection
% - status: status value (0: Ok; 1: Error);
%
% Example:
%  [dsa, status] = hp_init_updated(dsa)
%
% Last update: 05/07/2018

%% Función para inicializar una sesión con el HP.
% 
% if nargin == 0
%     gpib_dir=1;
% else
%     gpib_dir=varargin{1};
% end

status = 0; % Correct


%%clear
aux = instrfind('type','gpib','Status','close','Boardindex',dsa.BoardIndex,'primaryaddress',dsa.PrimaryAddress);
for i = 1:length(aux)
    delete(aux(i));
end

%dsa=instrfind('Status','open');%ojo! puede haber otros devices abiertos!
dsa.ObjHandle = instrfind('type','gpib','Status','open','primaryaddress',dsa.PrimaryAddress);
if isempty(dsa.ObjHandle)    
    dsa.ObjHandle = gpib('ni',dsa.BoardIndex,dsa.PrimaryAddress);%dir:1 puede cambiar
    try
        fopen(dsa.ObjHandle);   % Important line, it is mandatory to use fclose(multi) at the end of the session.
    catch
        status = 1; % Connection not available
        delete(dsa.ObjHandle);
        rmpath('G:\Mi unidad\ICMA\zartes_ACQ-master\Analyzer_HP3562A\');
        disp('Error connecting Spectral Analyzer HP3562A, please check connectivity');         
        return;
    end
end
%instrfind; %muestra los instrumentos y su estado.

%fprintf(dsa,'ID?');
%device=fscanf(dsa)%devuelve HP3562A. Permite comprobar si estamos leyendo el 
device = query(dsa.ObjHandle,'ID?');%esta instruccion es más directa.
if ~strcmpi('HP3562A',device(1:7))
    return;
end %dispositivo correcto?