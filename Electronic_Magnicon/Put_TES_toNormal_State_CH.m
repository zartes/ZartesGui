function out = Put_TES_toNormal_State_CH(mag,signo)

% Function to set TES in Normal status, increasing the current with LNCS
% device. 
%
% Input:
% - mag: communication object referring to electronic magnicon
% - signo: sign of the current values (1 or -1).
%
% Output:
% - out: !!!!!! Needs to be defined  !!!!!
%
% Example: out = Put_TES_toNormal_State_CH(mag,1,2)
%
% Last update 16/04/2024

%% Old version 
%%%%Función para poner el TES en estado Normal.  
%% La fuente LNCS polariza el TES en estado Normal aplicando un campo en la bobina
%%

% Maximum value of the current to not exceed 
% LNCS_ILimit = 5000; % Esto debe ser opcional




% Conectamos la salida de la fuenta LNCS
mag_ConnectLNCS(mag);
    
% Ponemos la corriente del TES en 500 uA
mag_setImag_CH(mag,signo*500);
% Poner a cero la LNCS
mag_setLNCSImag(mag,0);
% Desconectamos la fuente LNCS
mag_DisconnectLNCS(mag);


% In the case of using the source in channel 1, it is mandatory to remove
% the LNCS device. 

% hd = findobj('Tag','LNCS_Active');
% if ~isempty(hd)
%     if ~hd.Value
%         mag_setImag_CH(mag,signo*500);
%         mag_setLNCSImag(mag,0);
%         mag_DisconnectLNCS(mag);
%     end
% % else
% mag_setImag_CH(mag,signo*500);
% mag_setLNCSImag(mag,0);
% mag_DisconnectLNCS(mag);
% end

% No criterion is used here in order to return 1 in all cases. %%%%%%%%%%%%
out = 1; 