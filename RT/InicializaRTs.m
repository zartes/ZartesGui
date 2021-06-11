function [avs_Device] = InicializaRTs(Channel,Rango,Excitacion)
% Funcion que inicializa el instrumento AVS y la aplicación de Labview
% IGHFrontPanel.vi 
%
% Inputs: 
% - Channel: Channel to be measured
% - Rango: Output range (resistance resolution)
% - Excitacion: Excitation voltage in the bridge
% 
% Outputs:
% - avs_Device: object related to AVS47 device
% - vi: ActxServer related to LabView software for Mixing Chamber control
%
% Ejemplo de uso
% [avs_Device, vi] = InicializaRTs(4,1,1);
% 
% Last Update 21/01/2019


if nargin < 1
    msgbox('Input parameters: Channel, Rango, Excitacion must be provided','ZarTES v4.0');
    avs_Device = [];
%     vi = [];
    return;
end

warning off;
avs_Device = AVS;
avs_Device = avs_Device.Constructor;
avs_Device = avs_Device.Initialize;


avs_Device = avs_Device.ChangeRango(Rango);
avs_Device = avs_Device.ChangeExcitacion(Excitacion);
avs_Device = avs_Device.ChangeChannel(Channel);


