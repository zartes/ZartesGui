function data=ScanRun(varargin)
%%%funcion para escanear los datos de un run y contar los ficheros de cada
%%%tipo a cada temperatura. Asume que existe la carpeta de Negative Bias
%%%con exactamente las mismas temperaturas que con positive bias.

oldd=pwd;
if nargin==1 %si ejecutamos desde dir CHx pasamos el run que queremos analizr.
    d=lower(varargin{1});
    x=dir('RUN*');
    for i=1:length(x)
        if strfind(lower(x(i).name),d) break;end
    end
    cd(x(i).name);
end

%%%Chequeo de temperaturas
str=dir('*mK');
if isempty(str) 
    cd(oldd);
    error('Run sin medidas de Z o ruido.');
    %return;
end
for k=1:2
    if k==2
        cd('Negative Bias');
    end
for jjj=1:length(str)
    %%%HP noises
    data.Temps{jjj}=str(jjj).name;
    x=ls(strcat(str(jjj).name,'\HP_noise*'));
    if isempty(x) NHPnoises(jjj)=0; else NHPnoises(jjj)=numel(x(:,1));end
    %%%PXI noises
    x=ls(strcat(str(jjj).name,'\PXI_noise*'));
    if isempty(x) NPXInoises(jjj)=0; else NPXInoises(jjj)=numel(x(:,1));end
    %%%HP TFs
    x=ls(strcat(str(jjj).name,'\TF_*'));
    if isempty(x) NHPTFs(jjj)=0; else NHPTFs(jjj)=numel(x(:,1));end
    %%% PXI TFs
    x=ls(strcat(str(jjj).name,'\PXI_TF*'));
    if isempty(x) NPXITFs(jjj)=0; else NPXITFs(jjj)=numel(x(:,1));end
end
if k==1
    data.P.NHPnoises=NHPnoises;
    data.P.NPXInoises=NPXInoises;
    data.P.NHPTFs=NHPTFs;
    data.P.NPXITFs=NPXITFs;
else
    data.N.NHPnoises=NHPnoises;
    data.N.NPXInoises=NPXInoises;
    data.N.NHPTFs=NHPTFs;
    data.N.NPXITFs=NPXITFs;
    cd ..
end
end
cd(oldd)