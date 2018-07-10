function [k220, status] = k220_init_updated(k220)
% Function to initialize the current source K220
%
% Input:
% - varargin: by default is empty.
% 
% Output:
% - k220: 
%
% Example:
% k220 = k220_init_updated()
%
% Last update: 03/07/2018

%% Función para inicializar una sesión con la fuente de corriente K220.

status = 0; % Correct

k220.ObjHandle = instrfind('type','gpib','boardindex',k220.BoardIndex,'primaryaddress',k220.PrimaryAddress);

if isempty(k220.ObjHandle)    
    k220.ObjHandle = gpib('ni',k220.BoardIndex,k220.PrimaryAddress);%dir:1 puede cambiar
    try
        fopen(k220.ObjHandle);   % Important line, it is mandatory to use fclose(multi) at the end of the session.
    catch
        status = 1; % Connection not available
        delete(k220.ObjHandle);
        rmpath('G:\Mi unidad\ICMA\zartes_ACQ-master\K220\');
        disp('Error connecting Current Source K220, please check connectivity');         
        return;
    end    
elseif strcmp(k220(1).Status,'closed')
    try
        fopen(k220(1).ObjHandle);   % Important line, it is mandatory to use fclose(multi) at the end of the session.
    catch
        status = 1; % Connection not available
        delete(k220(1).ObjHandle);
        rmpath('G:\Mi unidad\ICMA\zartes_ACQ-master\K220\');
        disp('Error connecting Current Source K220, please check connectivity');         
        return;
    end    
end

device = query(k220.ObjHandle,'*IDN?');%esta instruccion es más directa.
if ~strcmpi(multi.ID,device(1:7))
    status = 1; % Connection not available
    return;
end