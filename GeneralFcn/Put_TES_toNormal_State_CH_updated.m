function out = Put_TES_toNormal_State_CH_updated(mag,signo)

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
Ilimite = 5000; 

mag_ConnectLNCS_updated(mag);
mag_setLNCSImag_updated(mag,signo*Ilimite);
mag_setLNCSImag_updated(mag,signo*0.5e3);

% In the case of using the source in channel 1, it is mandatory to remove
% the LNCS device. 
mag_setImag_CH_updated(mag,signo*500);
mag_setLNCSImag_updated(mag,0);
mag_DisconnectLNCS_updated(mag);

% No criterion is used here in order to return 1 in all cases. %%%%%%%%%%%%
out = 1; 