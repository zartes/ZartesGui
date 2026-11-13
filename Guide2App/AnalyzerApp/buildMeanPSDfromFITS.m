function MeanNoise=buildMeanPSDfromFITS(file,varargin)
%%%%% funcion para construir el PSD promedio de un fichero de 
%%% baselines para crear el filtro optimo.
%%% 2-sided.
import matlab.io.*
DataUnit=2;%!default 2.
info=fitsinfo(file);
N=info.BinaryTable(DataUnit-1).Rows;
fptr=fits.openFile(file);
fits.movAbsHDU(fptr,DataUnit);%!
SR=str2num(fits.readKey(fptr,'SR'));
RL=str2num(fits.readKey(fptr,'RL'));
fits.closeFile(fptr);

if nargin==2
    index=varargin{1};%por si hacemos un filtrado previo de los baselines.
else
    index=1:N;
end
aux=zeros(RL,1);
window=[];
%window=hamming(RL);
for i=index
    noise=readFITSpulse(file,i,DataUnit);%%%asumimos baselines en Dataunit=2
    %%%noise contiene ya time y data
    %[psd,freqs]=PSD(noise,1);%%%lo hacemos 2-sided
    [psd,freqs]=periodogram(noise(:,2),window,RL,SR,'two-sided');
    %size(aux),size(psd)
    aux=aux(:)+psd(:);
end
Mpsd=aux/length(index);
MeanNoise(:,1)=freqs;
MeanNoise(:,2)=sqrt(abs(Mpsd));%devolver directamente sqrt(Mpsd)?