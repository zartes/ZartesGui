function dsa = hp_noise_config_updated(dsa)
% Function to initialize the mode Noise in the DSA HP3562A device
%
% Input:
% - dsa: Object class DSA
%
% Output:
% - dsa: Object added mode Noise Configuration
%
% Example:
% hp_ss_config_updated(dsa)
%
% Last update: 05/07/2018

%% Configuración del HP para medir ruido del CH2.
ConfInstrs = {'AUTO 0';'LGRS';'SF 10Hz';'FRS 4Dec';'PSUN';'VTRM';'VHZ';'STBL';...
    'AVG 5';'C2AC 1';'PSP2';'MGDB';'YASC'};
for i = 1:length(ConfInstrs)
    fprintf(dsa.ObjHandle,ConfInstrs{i});
end
dsa.Noise.Config = ConfInstrs;
% 
% fprintf(dsa,'AUTO 0')
% %fprintf(dsa,'FRQR')
% fprintf(dsa,'LGRS')
% fprintf(dsa,'SF 10Hz') %Start Frequency
% fprintf(dsa,'FRS 4Dec') %Frequency Span
% fprintf(dsa,'PSUN') 
% fprintf(dsa,'VTRM')
% fprintf(dsa,'VHZ')
% fprintf(dsa,'STBL') %stable mean
% fprintf(dsa,'AVG 5') %Numero de Averages
% fprintf(dsa,'C2AC 1') %CH2 coupling AC.
% %fprintf(dsa,'C2AC 0') %CH2 coupling DC.
% fprintf(dsa,'PSP2') %power spec 2
% fprintf(dsa,'MGDB'); %mag db
% fprintf(dsa,'YASC');%Y auto scale
% %fprintf(dsa,'SNGC') %Single CAL. Ojo, da timeout.