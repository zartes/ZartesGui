function [FileList, NoisePath]  = GetFilesFromRp(IVset,Tbath,Rp,NoiseOption,varargin)
%%%Funcion para dar la lista de ficheros a una Tbath dada a los porcentajes
%%%Rp. V0: hay que estar en el directorio raiz del TES a analizar.
%%%Pasar Tbath como string numerico en milikelvin sin el mK: Tbath='50'.
%%%%V1: cambio input Tbath de string a numeric por uniformizar.

if nargin == 3
    pattern = '\HP_noise*';
else
    pattern = NoiseOption;%%%Pasamos la cadena de caracteres a buscar.(HP_noise o PXI_noise.)
end

if nargin == 5
    NoisePath = uigetdir(varargin{1},'Select a path where Noise files are located.');
    if NoisePath == 0
        errordlg();
    else
        NoisePath = [NoisePath filesep];
    end
    
    Tbath = sscanf(NoisePath(max(find(NoisePath(1:end-1) == filesep))+1:end),'%dmK\');
    Tbathstr = num2str(Tbath);
    files = dir([NoisePath pattern]);
    
%     files = ls([NoisePath str.name pattern]);
            
    for i = 1:size(files,1)
        Iaux(i) = sscanf(char(regexp(files(i).name,'\d+(\.\d*)?','match')),'%f');
    end
    
    %Iaux
    Ibs = BuildIbiasFromRp(IVset,Rp);
    
    for i = 1:length(Rp)
        [~,jj] = min(abs(Iaux-Ibs(i)));
        FileList{i} = files(jj).name;
    end
    
    
    
else
    NoisePath = [];
    t = '';
    str = dir([t '*mK']);
    Tbathstr = num2str(Tbath);
    for i = 1:length(str)
        if strfind(str(i).name,Tbathstr) & str(i).isdir
            break;
        end%%%Para pintar automáticamente los ruido a una cierta temperatura.50mK.(tiene que funcionar con 50mK y 50.0mK, pero ojo con 50.2mK p.e.)
    end
    
    Tdir = str(i).name
    files = ls(strcat(str(i).name,pattern));
    
    
    [ii,jj]=size(files);
    for i=1:ii
        Iaux(i)=sscanf(char(regexp(files(i,:),'\d+(\.\d*)?','match')),'%f');
    end
    
    %Iaux
    Ibs=BuildIbiasFromRp(IVset,Rp);
    
    for i=1:length(Rp)
        [~,jj]=min(abs(Iaux-Ibs(i)))
        FileList{i}=files(jj,:);
    end
end
%%

% str=dir('*mK');


