function [dsa, datos] = hp_measure_noise_updated(dsa)
% Function to measure the Noise response by DSA HP3562A device
%
% Input:
% - dsa: Object class DSA
%
% Output:
% - dsa: Object added Noise Configuration
% - datos: [freq' data'] related to the spectrum.
%
% Example:
% [dsa, datos] = hp_measure_noise_updated(dsa)
%
% Last update: 05/07/2018

%% funcion para medir la respuesta al ruido.
dsa = hp_noise_config_updated(dsa);

%fprintf(dsa,'SNGC');
%pause(20);%%%Si lanzamos CAL(SNGC) hay que esperar un poco.

fprintf(dsa.ObjHandle,'STRT');             %Lanza la medida
fprintf(dsa.ObjHandle,'SMSD');             %query measure finish?
ready = str2double(fscanf(dsa.ObjHandle));
                                 %bucle de espera de la medida.
while(~ready)
    pause(10);
    fprintf(dsa.ObjHandle,'SMSD');
    ready = str2double(fscanf(dsa.ObjHandle));
    second(now)
end

[freq, data, header] = hp_read_updated(dsa);      %lee la TF.
datos = [freq' data'];
dsa.Noise.Header = header;