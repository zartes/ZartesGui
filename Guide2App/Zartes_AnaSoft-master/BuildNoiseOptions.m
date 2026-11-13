function option=BuildNoiseOptions()
%%%crea estructura de opciones para plots de Ruido

option.tipo='current';
option.boolcomponents=0;
option.Mjo=0;
option.Mph=0;
option.NoiseBaseName='\HP_noise*';%%%Pattern
option.model='irwin';
option.NoiseFilterModel='default'; %%%{default, medfilt, nofilt, minfilt minfilt+medfilt}
option.FiltOpt.model='default';
option.FiltOpt.wmed=40;

who=evalin('base','who');
if sum(~cellfun('isempty',strfind(who,'datadir')))
    option.datadir=evalin('base','datadir');
end