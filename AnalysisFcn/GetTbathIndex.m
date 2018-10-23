function [mIV,mP]=GetTbathIndex(Tbath,varargin)
%%%Función para devolver los índices de las IVset y estructura P que
%%%corresponden a una Tbath determinada. La Tbath se pasa en milikelvin
%%%como un número y se busca la Tbath más cercana de cada estructura. Si no
%%%existe ninguna dentro de un margen definido por thr(=1mK) se devuelve
%%%error.
if nargin==2 && ~isfield(varargin{1},'Tbath') %%%Pasamos toda la estructura de datos ZTESDATA
%     IVset=getfield(varargin{1},'IVset');
%     P=getfield(varargin{1},'P');
    varargin{1}
    IVset=varargin{1}.('IVset');
    P=varargin{1}.('P');
elseif nargin==3
    IVset=varargin{1};%%%
    %P=varargin{2};
end
    %Extraemos la IV y la P asociadas a la Tbath de interés.
    [m1,mIV]=min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IVstr=IVset(mIV);
    mP=0;
%     [m2,mP]=min(abs([P.Tbath]*1e3-Tbath));
%     p=P(mP).p;
%     thr=1;%%%umbral en 1mK de diferencia entre la Tbath pasada y la Tbath más cercana de los datos.
%     if (m1>=thr || m2>=thr) error('Tbath not in the measured data. \n Remember to pass Tbath as a number in mK');end
