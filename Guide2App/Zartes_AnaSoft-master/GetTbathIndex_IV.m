function mIV=GetTbathIndex_IV(Tbath,varargin)
%%%Version Tbath index para devolver solo IV
%%%v2. se puede pasar Tbath como string y en Kelvin.
if ischar(Tbath) Tbath=sscanf(Tbath,'%d');end
if Tbath<1 Tbath=Tbath*1e3;end%%%Asumimos que si Tbath<1 la estamos pasando en Kelvin.
if nargin==2 && ~isfield(varargin{1},'Tbath') %%%Pasamos toda la estructura de datos ZTESDATA
%     IVset=getfield(varargin{1},'IVset');
%     P=getfield(varargin{1},'P');
    %varargin{1}
    IVset=varargin{1}.('IVset');
else%if nargin==3
    IVset=varargin{1};%%%%
end
    %Extraemos la IV y la P asociadas a la Tbath de interés.
    [m1,mIV]=min(abs([IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IVstr=IVset(mIV);
     thr=1;%%%umbral en 1mK de diferencia entre la Tbath pasada y la Tbath más cercana de los datos.
     if (m1>=thr) error('Tbath not in the measured data. \n Remember to pass Tbath as a number in mK');end