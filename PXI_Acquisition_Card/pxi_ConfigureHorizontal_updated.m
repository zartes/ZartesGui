function pxi_ConfigureHorizontal_updated(pxi)
% Function to set configuration of the horizontal axes of PXI Acq. Card
%
% Output:
% - pxi: Object communication with the PXI card
%
% Example:
% pxi_ConfigureHorizontal_updated(pxi)
%
% Last update: 06/07/2018

%% %%Función para configurar de golpe toda la escala horizontal.
%%%SR: Sampling Rate en S/Seg, RL: Record Length, nº samples, RefPos: Reference Position for trigger en % (div 2=20.). 

RefPos = pxi.ConfStructs.Horizontal.RefPos;

pxi_SetSamplingRate_updated(pxi); % SR
pxi_SetRecordLength_updated(pxi); % RL

set(get(pxi.ObjHandle,'horizontal'),'Reference_Position',RefPos);