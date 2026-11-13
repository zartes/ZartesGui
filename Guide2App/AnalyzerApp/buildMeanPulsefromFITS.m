function pulso=buildMeanPulsefromFITS(file,varargin)
%%%%% funcion para construir el Pulso promedio a partir de un FITS.
%%% V0 no se resta el DC.

import matlab.io.*
DataUnit=2;%!
info=fitsinfo(file);
N=info.BinaryTable(DataUnit-1).Rows;
fptr=fits.openFile(file);
fits.movAbsHDU(fptr,DataUnit);
SR=str2num(fits.readKey(fptr,'SR'));
RL=str2num(fits.readKey(fptr,'RL'));
fits.closeFile(fptr);

if nargin==2
    index=varargin{1};%por si hacemos un filtrado previo de los pulsos.
else
    index=1:N;
end
L=length(index);
aux=zeros(RL,1);
window=[];
%window=hamming(RL);
for i=index
    auxpulse=readFITSpulse(file,i,DataUnit);%%%asumimos baselines en Dataunit=2

    aux=aux(:)+auxpulse(:,2);%
end
pulso=double([auxpulse(:,1) aux(:)/L]);