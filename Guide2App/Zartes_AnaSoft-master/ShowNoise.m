function out=ShowNoise(ZTESDATA,varargin);
%%%%Función para ejecutar desde el directorio común de estructuras para
%%%%visualizar las Z(w) y ruidos.
%%%%%v1: se pueden pasar como argumentos options y Tstr en cualquier orden.
%%%%% Tstr es un string con la Tbath en mK ej: '60'.

bdir=pwd;
ZTESDATA
Wdir=ZTESDATA.datadir;
cd(Wdir);
%ssn=ZTESDATA.sesion;
%aux=load(ssn,'IVset','TFS');

if nargin>1
    for i=1:nargin-1
        if isstruct(varargin{i}) opt=varargin{i}; else Tstr=varargin{i};end
    end    
else
    opt.tipo='current';
    opt.boolcomponents=0;
    opt.Mjo=0;
    opt.Mph=0;
    opt.NoiseBaseName='\HP_noise*';
    Tstr='60';
end

str=dir('*mK');

NoiseBaseName=opt.NoiseBaseName;

for i=1:length(str)
    if strfind(str(i).name,Tstr) & str(i).isdir, break;end%%%Para pintar automáticamente los ruido a una cierta temperatura.50mK.(tiene que funcionar con 50mK y 50.0mK, pero ojo con 50.2mK p.e.)
end

Tbath=str2num(Tstr);
[~,Tind]=min(abs([ZTESDATA.IVset.Tbath]*1e3-Tbath));%%%En general Tbath de la IVsest tiene que ser exactamente la misma que la del directorio, pero en algun run he puesto el valor 'real'.(ZTES20)
    IVstr=ZTESDATA.IVset(Tind);
%rps=[0.1:0.1:0.9]; %%% array 9x9
rps=[0.5:0.05:0.9]; %%% array 4x4. 0.1:0.1:0.8.
files=GetFilesFromRp(IVstr,Tstr,rps,opt.NoiseBaseName);

if numel(files)<= length(ls(strcat(str(i).name,NoiseBaseName))) 
    out=plotnoiseFile(ZTESDATA.IVset,ZTESDATA.P,ZTESDATA.circuit,ZTESDATA.TES,str(i).name,files,opt);
else
    out=plotnoiseFile(ZTESDATA.IVset,ZTESDATA.P,ZTESDATA.circuit,ZTESDATA.TES,str(i).name,opt);
end
cd(bdir);