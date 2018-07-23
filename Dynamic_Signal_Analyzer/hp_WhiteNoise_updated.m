function hp_WhiteNoise_updated(dsa,Amp)
% Function to initialize the DSA HP3562A device in White Noise
% output
%
% Input:
% - dsa: Object class DSA
% - AMP: Amplitude value in mV
%
% Example:
% hp_WhiteNoise_updated(dsa,AMP)
%
% Last update: 06/07/2018

%% Activa la fuente con ruido blanco. Pasar Amp en mV

% fprintf(dsa.ObjHandle,'LGRS');
% fprintf(dsa.ObjHandle,'RND');
% str = ['SRLV ' num2str(Amp) 'mV'];
% fprintf(dsa.ObjHandle,str);

ConfInstrs = {'LGRS';'RND';'SRLV ' num2str(Amp) 'mV'};
for i = 1:length(ConfInstrs)
    fprintf(dsa.ObjHandle,ConfInstrs{i});
end
dsa.Noise.Config = ConfInstrs;