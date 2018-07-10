function hp_sin_config_updated(dsa,freq)
% Function to initialize the multimeter HP3458A device in Sine Sweept mode
% output
%
% Input:
% - dsa: Object class Multimetro
% - freq: frequency value in Hz
%
% Example:
% hp_sin_config_updated(dsa,freq)
%
% Last update: 06/07/2018
%%%función para configurar la source del HP.


%fprintf(dsa,'MNSW');
fprintf(dsa.ObjHandle,'LGRS'); %%%%Para poder usar Fixed Sine hay que estar en modo Log
str = ['FSIN ' num2str(freq) 'HZ'];
fprintf(dsa.ObjHandle,str);
fprintf(dsa.ObjHandle,'SRLV 50mV');  %%amplitud de excitación*10