function mag_Configure_CalPulse(s)
% Function that sets the configuration of pulse acquisition of the electronic magnicon
%
% Input:
% - s: communication object referring to electronic magnicon
%
% Example of usage:
% mag_Configure_CalPulse(s)
%
% Last update: 09/07/2018

%% Configura la fuente de pulsos para adquirir automaticamente
% delta T:100ms-1seg
% duracion maxima:2000us
% modo:cont
% Amplitud: 20uA?

mag_setCalPulseAMP_CH(s);%%% handle, RL,AMP(uA),CH.
mag_setCalPulseDT_CH(s);%%% handle, separacion(ms), CH.%%%%!
mag_setCalPulseDuration_CH(s); %%%handle, duracion(us), CH
mag_setCalPulseMode_CH(s,'continuous');