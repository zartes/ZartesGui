function hp_auto_acq_POS_NEG_updated(IZvaluesP, varargin)
%%%%Pasar los IZvalues positivos y negativos
hp_auto_acq_updated(IZvaluesP);

if nargin == 1 
    IZvaluesN = -IZvaluesP; 
else
    IZvaluesN = varargin{1};
end

d = pwd;
%temp=regexp(d,'\d*mK','match');
temp = regexp(d,'\d*.?\d*mK','match');%%%Regexp correcta para reconocer tanto 50mK como 50.0mK
mkdir(strcat('../Negative Bias/',temp{1}));%%%Crea el directorio para las Z(w) con Ibias negativa.
cd(strcat('../Negative Bias/',temp{1}));
hp_auto_acq(IZvaluesN);
cd('../..')