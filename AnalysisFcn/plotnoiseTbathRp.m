function plotnoiseTbathRp(ZTESDATA,Tbathstring,Rps,varargin)
%%%%Función para pintar ruidos a una Tbath determinada y unos %Rp dados

IVset = ZTESDATA.IVsetP;
P = ZTESDATA.PP;
circuit = ZTESDATA.circuit;
TES = ZTESDATA.TES;

if nargin == 3
    option = BuildNoiseOptions;
else
    option = varargin{1};
end

Tbath = sscanf(Tbathstring,'%f');
[files, filesPath] = GetFilesFromRp(IVset(GetTbathIndex(Tbath,IVset,P)),Tbath,Rps,option.NoiseBaseName,ZTESDATA.IVsetP.IVsetPath);
plotnoiseFile(IVset,P,ZTESDATA,filesPath,files,option);