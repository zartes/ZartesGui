function [data, WfmI] = pxi_GetWaveForm_updated(pxi)
% Function to donwload one screen capture and the related information to this vector; of PXI Acq. Card
%
% Output:
% - pxi: Object communication with the PXI card
%
% Example:
% pxi_GetWaveForm_updated(pxi)
%
% Last update: 06/07/2018

%% Función para descargar una captura y la informacion asociada a un vector

numSamples = get(get(pxi.ObjHandle,'horizontal'),'min_number_of_points');
ChL = length(channelList);
if ChL == 1
    numChannels = 1;
else
    numChannels = 2;
end
waveformArray = zeros(1,numSamples*numChannels);%%%Prealojamos espacio.

% Este bloque de código ya está incluido en pxi.

% TimeOut=Options.TimeOut;
% channelList=Options.channelList;
% 
% 
% for i = 1:numChannels %%%Inicializamos la Info.
%     waveformInfo(i).absoluteInitialX = 0;
%     waveformInfo(i).relativeInitialX = 0;
%     waveformInfo(i).xIncrement = 0;
%     waveformInfo(i).actualSamples = 0;
%     waveformInfo(i).offset = 0;
%     waveformInfo(i).gain = 0;
%     waveformInfo(i).reserved1 = 0;
%     waveformInfo(i).reserved2 = 0;
% end 

invoke(pxi.ObjHandle.Acquisition, 'initiateacquisition'); %%%Puede ir aquí o fuera.
[Wfm, WfmI] = invoke(pxi.ObjHandle.Acquisition, 'fetch',...
    Options.channelList,...
    Options.TimeOut,...
    numSamples,...
    waveformArray,... 
    pxi.WaveFormInfo); %%

DT = WfmI.xIncrement;
L = WfmI.actualSamples;
data(:,1) = (0:L-1)*DT;
data(:,2) = Wfm(1:L);
if numChannels == 2 
    data(:,3) = Wfm(L+1:end);
end