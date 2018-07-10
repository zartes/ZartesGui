function pxi = pxi_ConfigureChannels_updated(pxi)
% Function to set configuration of vertical axes in channels and inputs, PXI Acq. Card
%
% Input:
% - pxi: Object class Multimetro
%
% Output:
% - pxi: Object regards multimeter gpib connection
%
% Example:
% pxi = pxi_ConfigureChannels_updated(pxi)
%
% Last update: 06/07/2018


%% Función para configurar la escala vertical de los canales y acoplos.
%%%ConfigureOptions es una estructura con todos los campos necesarios. Si
%%%ChannelList es '0,1' se aplica a los dos canales, si es '0' o '1', sólo
%%%a ese. Habilitar o deshabilitar el canal es poner Enabled=0,1. Y el
%%%coupling=0 es 'AC' y coupling=1 es 'DC'.

ChannelList = pxi.ConfStructs.Vertical.ChannelList;
Range = pxi.ConfStructs.Vertical.Range;
offset = pxi.ConfStructs.Vertical.offset;
if strcmpi(pxi.ConfStructs.Vertical.Coupling,'AC') 
    Coupling = 0;
elseif strcmpi(pxi.ConfStructs.Vertical.Coupling,'DC') 
    Coupling = 1;
end
ProbeAttenuation = pxi.ConfStructs.Vertical.ProbeAttenuation;
Enabled = pxi.ConfStructs.Vertical.Enabled;

invoke(pxi.ObjHandle.configurationfunctionsvertical,...
    'configurevertical',ChannelList,Range,offset,Coupling,ProbeAttenuation,Enabled)