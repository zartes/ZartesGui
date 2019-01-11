function pxi_ConfigureHorizontal(pxi)
% Function to set configuration of the horizontal axes of PXI Acq. Card
%
% Output:
% - pxi: Object communication with the PXI card
%
% Example:
% pxi_ConfigureHorizontal(pxi)
%
% Last update: 06/07/2018

%% %%Función para configurar de golpe toda la escala horizontal.
%%%SR: Sampling Rate en S/Seg, RL: Record Length, nº samples, RefPos: Reference Position for trigger en % (div 2=20.). 

RefPos = pxi.ConfStructs.Horizontal.RefPos;

pxi_SetSamplingRate(pxi); % SR
pxi_SetRecordLength(pxi); % RL

set(get(pxi.ObjHandle,'horizontal'),'Reference_Position',RefPos);