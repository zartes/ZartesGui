function out=ShowNoise(ZTESDATA,varargin);
%%%%Función para ejecutar desde el directorio común de estructuras para
%%%%visualizar las Z(w) y ruidos.

bdir=pwd;
ZTESDATA
Wdir=ZTESDATA.datadir;
cd(Wdir);
%ssn=ZTESDATA.sesion;
%aux=load(ssn,'IVset','TFS');

if nargin==2
    opt=varargin{1};
else
    opt.tipo='current';
    opt.boolcomponents=0;
    opt.Mjo=0;
    opt.Mph=0;
end

str=dir('*mK');

Tstr='50';
for i=1:length(str)
    if strfind(str(i).name,Tstr) & str(i).isdir, break;end%%%Para pintar automáticamente los ruido a una cierta temperatura.50mK.(tiene que funcionar con 50mK y 50.0mK, pero ojo con 50.2mK p.e.)
end

Tbath=str2num(Tstr);
[~,Tind]=min(abs([ZTESDATA.IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IVstr=ZTESDATA.IVset(Tind);
%rps=[0.1:0.1:0.9]; %%% array 9x9
rps=[0.2:0.2:0.8]; %%% array 4x4
files=GetFilesFromRp(IVstr,Tstr,rps);

if numel(files)<= length(ls(strcat(str(i).name,'\HP_Noise*'))) 
    out=plotnoiseFile(ZTESDATA.IVset,ZTESDATA.P,ZTESDATA.circuit,ZTESDATA.TES,str(i).name,files,opt);
else
    out=plotnoiseFile(ZTESDATA.IVset,ZTESDATA.P,ZTESDATA.circuit,ZTESDATA.TES,str(i).name,opt);
end
cd(bdir);