function hp_sin_config(dsa,freq,Amp)
% Function to initialize the multimeter HP3458A device in Sine Sweept mode
% output
%
% Input:
% - dsa: Object class Digital Signal Analyzer
% - freq: frequency value in Hz
%
% Example:
% hp_sin_config(dsa,freq)
%
% Last update: 06/07/2018
%%%función para configurar la source del HP.

%fprintf(dsa,'MNSW');
% fprintf(dsa.ObjHandle,'LGRS'); %%%%Para poder usar Fixed Sine hay que estar en modo Log
% str = ['FSIN ' num2str(freq) 'HZ'];
% fprintf(dsa.ObjHandle,str);
% fprintf(dsa.ObjHandle,'SRLV 50mV');  %%amplitud de excitación*10

ConfInstrs = {'LGRS';'FSIN ' num2str(freq) 'Hz';'SRLV ' num2str(Amp) 'mV'};
for i = 1:length(ConfInstrs)
    fprintf(dsa.ObjHandle,ConfInstrs{i});
end
dsa.TF.Config = ConfInstrs;