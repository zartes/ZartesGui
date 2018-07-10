function pxi_SetRecordLength_updated(pxi)
% Function to set configuration of number of samples of acquisition of PXI Acq. Card
%
% Output:
% - pxi: Object communication with the PXI card
%
% Example:
% pxi_SetRecordLength_updated(pxi)
%
% Last update: 06/07/2018

%% función para fijar el numero de muestras en la adquisicion.

set(get(pxi.ObjHandle,'horizontal'),'min_number_of_points',pxi.ConfStructs.Horizontal.RL)
actualRL = get(get(pxi.ObjHandle,'horizontal'),'actual_record_length');

if actualRL ~= RL
    warning(['Ojo: Actual Record Length fijado en: ' num2str(actualRL)]);
    %%%Ojo, este warning parece que no funciona. Si meto RL=333333, en el
    %%%SFP aparece 300000 en rojo para el Record Length, pero al leer el
    %%%campo actual_record_length sique dando 333333. ¿Como leerlo correctamente?
end