function out = mag_setCalPulseAMP_CH_updated(s)
% Function that sets the pulse amplitude electronic magnicon in AMP mode
%
% Input:
% - s: communication object referring to electronic magnicon
%
% Output:
% - out: output of the query of the electronic magnicon, 'OK' or 'FAIL'
%
% Example of usage:
% out = mag_setCalPulseAMP_CH_updated(s)
%
% Last update: 28/06/2018

%% %Funcion para fijar la amplitud del pulso.


if ~isnumeric(s.SourceCH)
    disp('s.SourceCH parameter must be a number, 1 or 2');
    return;
elseif ~any([1 2]-s.SourceCH == 0) % Only channels 1 and 2 are available
    error('wrong Channel number');
end



%%Ojo, RL se pasa como parámetro. No hay forma de verificar que sea el
%%correcto.

if s.RL == 0
    %AMP=5e6*(DAC-2048)/(4096*1.0196*20000);
    DAC = s.PulseAmp.Value*4096*1.0196*20000/5e6+2048;
    if DAC < 0 || DAC > 4095
        warndlg('Amplitude out of range');
        return;
    end
else
    I = mag_readImag_CH_updated(s);
    Rp = (s.RL.Value^-1+22143^-1)^-1;
    range = mag_getIrange_CH_updated(s);
        if strcmp(range,'125uA')
            R = 43600;
        elseif strcmp(range,'500uA')
            R = 10895;
        end
    Ui = I*Rp/(Rp+R);
    K = s.RL.Value^-1+R^-1+20000^-1;
    %Upa=5e6*(DAC-2048)/4096;%%%error en manual? 1e6.
    Upa = ((s.PulseAmp.Value+I)*s.RL.Value*K-(Ui/R))*20228;
    DAC = Upa*4096/5e6+2048;
end

DAC_hex = dec2hex(round(DAC),3);

str = sprintf('%s%s%s%s','<0',num2str(s.SourceCH),'r0',DAC_hex);%%%
chk = mod(sum(double(str)),256);
str = sprintf('%s%02X\r',str,chk);
out = query(s.ObjHandle,str,'%s','%s');
if strcmp(out,'|0AC')
    out = 'OK';
else
    out = 'FAIL';
end