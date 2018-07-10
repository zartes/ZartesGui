function [dsa, datos] = hp_measure_TF_updated(dsa, varargin)
% Function to measure the Transfer Function by DSA HP3562A device
%
% Input:
% - dsa: Object class DSA
% - varargin: Sine Amplitude in millivolts. By default: 20mV
%
% Output:
% - dsa: Object added Sine Sweept Configuration
% - datos: [freq' data'] related to the spectrum.
%
% Example:
% [dsa, datos] = hp_measure_TF_updated(dsa, varargin)
%
% Last update: 05/07/2018

%% funcion para medir una TF.

dsa = hp_ss_config_updated(dsa); % Measurement of Sine Sweept

if nargin == 2
    V = round(varargin{1}*1e4*1e3);%%%Expresado en mV
    str = strcat('SRLV ',' ',num2str(V),'mV'); %%amplitud de excitación*10
else
    str = strcat('SRLV 20mV');
end

fprintf(dsa.ObjHandle,str);
fprintf(dsa.ObjHandle,'STRT');%Lanza la medida
fprintf(dsa.ObjHandle,'SMSD');%query measure finish?
ready = str2double(fscanf(dsa.ObjHandle));
%bucle de espera de la medida.
while(~ready)
    pause(10);
    fprintf(dsa.ObjHandle,'SMSD');
    ready = str2double(fscanf(dsa.ObjHandle));
    second(now)
end

[freq, data, header] = hp_read_updated(dsa); %lee la TF.
datos = [freq' data'];
dsa.TF.Header = header;