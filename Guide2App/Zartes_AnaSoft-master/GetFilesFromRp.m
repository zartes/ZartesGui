function FileList=GetFilesFromRp(IVset,Tbath,Rp,varargin)
%%%Funcion para dar la lista de ficheros a una Tbath dada a los porcentajes
%%%Rp. V0: hay que estar en el directorio raiz del TES a analizar.
%%%Pasar Tbath como string numerico en milikelvin sin el mK: Tbath='50'.
%%%%V1: cambio input Tbath de string a numeric por uniformizar.
%%%V2(16-04-20): encapsulo la parte de buscar el dir en GetDirfromTbath,
%%%que funciona tanto con string como con numerico (en K o mK).

if nargin==3
    pattern='\HP_noise*';
else
    pattern=varargin{1};%%%Pasamos la cadena de caracteres a buscar.(HP_noise o PXI_noise.). Puede ser tb 'TF_*' para buscar las TFs. 
end

Tdir=GetDirfromTbath(Tbath);%%%Esto funciona tanto si pasamos Tbath como string (que tiene que ser el propio directorio por lo que esto esredundante)
%%%como si lo pasamos numérico sea en Kelvin o mK.

files=ls(strcat(Tdir,pattern));

if isempty(files) error('No Noise Files found');end
[ii,~]=size(files);
for i=1:ii
Iaux(i)=sscanf(char(regexp(files(i,:),'-?\d+(\.\d*)?','match')),'%f');
end

%Iaux
Ibs=BuildIbiasFromRp(IVset,Rp);

for i=1:length(Rp)
    [~,jj]=min(abs(Iaux-Ibs(i)));
    FileList{i}=files(jj,:);
end

