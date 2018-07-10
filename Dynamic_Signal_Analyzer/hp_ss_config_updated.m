function dsa = hp_ss_config_updated(dsa)
% Function to initialize the mode Sine Sweept in the DSA HP3562A device
%
% Input:
% - dsa: Object class DSA
%
% Output:
% - dsa: Object added Sine Sweept Configuration
%
% Example:
% hp_ss_config_updated(dsa)
%
% Last update: 05/07/2018

%% Configuración del HP para medir una Funcion de Transferencia con Sine Sweept
ConfInstrs = {'AUTO 0';'SSIN';'LGSW';'RES 20P/DC';'SF 1Hz';'FRS 5Dec';...
    'SWUP';'SRLV 100mV';'C2AC 0';'FRQR';'VTRM';'VHZ';'NYQT'};
for i = 1:length(ConfInstrs)
    fprintf(dsa.ObjHandle,ConfInstrs{i});
end
dsa.TF.Config = ConfInstrs;

% fprintf(dsa,'AUTO 0');
% 
% fprintf(dsa,'SSIN');
% fprintf(dsa,'LGSW');
% fprintf(dsa,'RES 20P/DC');%%%He usado normalmente 5P/DC
% fprintf(dsa,'SF 1Hz');
% fprintf(dsa,'FRS 5Dec');
% fprintf(dsa,'SWUP'); %%%puede quedar en manual sweep y entonces no sube la frecuencia.
% fprintf(dsa,'SRLV 100mV');%%amplitud de excitación*10
% fprintf(dsa,'C2AC 0'); %CH2 coupling DC.
% %fprintf(dsa,'C2AC 1') %CH2 coupling AC.
% fprintf(dsa,'FRQR');
% fprintf(dsa,'VTRM');
% fprintf(dsa,'VHZ');
% fprintf(dsa,'NYQT');
