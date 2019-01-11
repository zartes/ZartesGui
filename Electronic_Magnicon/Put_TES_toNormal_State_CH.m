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
% Last update 26/06/2018

%% Old version 
%%%%Función para poner el TES en estado Normal aumentando corriente con la
%%%%LNCS. La Imax es simplemente el signo para ponerlo con corrientes
%%%%positivas o negativas.
%%

% Maximum value of the current to not exceed 
% LNCS_ILimit = 5000; 

mag_ConnectLNCS(mag);
status = mag_setLNCSImag(mag,signo*Ilimite);
if strcmp(status,'FAIL')
    mag_DisconnectLNCS(mag);
    out = 0;
    return;
end
    
mag_setLNCSImag(mag,signo*500);

% In the case of using the source in channel 1, it is mandatory to remove
% the LNCS device. 
mag_setImag_CH(mag,signo*500);
mag_setLNCSImag(mag,0);
mag_DisconnectLNCS(mag);

% No criterion is used here in order to return 1 in all cases. %%%%%%%%%%%%
out = 1; 