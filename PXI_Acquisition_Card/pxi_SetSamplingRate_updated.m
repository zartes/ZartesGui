function actualSR = pxi_SetSamplingRate_updated(pxi)
% Function to set configuration of the sampling rate of PXI Acq. Card
%
% Output:
% - pxi: Object communication with the PXI card
%
% Example:
% pxi_ConfigureHorizontal_updated(pxi)
%
% Last update: 06/07/2018

%% Función para cambiar el sampling rate

set(get(pxi.ObjHandle,'horizontal'),'min_sample_rate',pxi.ConfStructs.Horizontal.SR)
actualSR = get(get(pxi.ObjHandle,'horizontal'),'Actual_Sample_Rate');

if actualSR ~= SR
    warning(['Ojo: Sampling Rate fijado en: ' num2str(actualSR)]);
end