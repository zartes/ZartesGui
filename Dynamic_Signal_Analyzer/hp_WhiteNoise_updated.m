function hp_WhiteNoise_updated(dsa,AMP)
% Function to initialize the multimeter HP3458A device in White Noise
% output
%
% Input:
% - dsa: Object class Multimetro
% - AMP: Amplitude value in mV
%
% Example:
% hp_WhiteNoise_updated(dsa,AMP)
%
% Last update: 06/07/2018

%% Activa la fuente con ruido blanco. Pasar Amp en mV

fprintf(dsa.ObjHandle,'LGRS');
fprintf(dsa.ObjHandle,'RND');
str = ['SRLV ' num2str(AMP) 'mV'];
fprintf(dsa.ObjHandle,str);