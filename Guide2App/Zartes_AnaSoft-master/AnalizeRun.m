function AnalizedData=AnalizeRun(analizeOptions)
%%%%%Función para lanzar un análisis automático sobre un RUN completo desde
%%%%%cualquier directorio de análisis. Podemos pasar como argumento sólo el
%%%%%datadir (path al run a analizar) y cogerá opciones por defecto, o
%%%%%pasar una estructura con las opciones de análisis, donde el datadir es
%%%%%obligatorio y el resto si no están, se cogen por defecto.

olddir=pwd;
if ischar(analizeOptions)
    datadir=analizeOptions;
else
    datadir=analizeOptions.datadir;
end

if isfield(analizeOptions,'PTrange')
    PTrange=analizeOptions.PTrange;
else
    PTrange=[0.2:0.01:0.9];
end

if isfield(analizeOptions,'PTmodel')
    PTmodel=analizeOptions.PTmodel;
else
    PTmodel=BuildPTbModel('GTcdirect'); %%%Definimos el modelo para el fit.
end

if isfield(analizeOptions,'RpTES')
    RpTES=analizeOptions.RpTES;
else
    RpTES=0.75;
end

if isfield(analizeOptions,'Tmax')
    Tmax=analizeOptions.Tmax;%%%Pasamos la temperatura máxima para hacer el fit de las IVs. Esto hay que mirarlo a mano, pero una vez hecho la primera vez, queda para otros analisis.
else
    Tmax=1;
end

if isfield(analizeOptions,'ZfitOpt')
    ZfitOpt=analizeOptions.ZfitOpt;
else
    ZfitOpt.TFdata='HP';
    ZfitOpt.Noisedata='HP';
    ZfitOpt.f_ind=[1 1e5];%rango de frecuencias para fit de Zs.
    %%%[fmin fmax] De momento no admite un rango arbitrario.
    %%%En realidad puede ser una matriz con f_ind(1,:)=[fmin1 fmax1],
    %%%f_ind(2,:)=[fmin2 fmax2], etc.
    %ZfitOpt.Temps=50;%Temp en mK.
    %ZfitOpt.mjofrange=[];%frecuencias para el fit de Mjo.
    %ZfitOpt.mphfrange=[];%frecuencias para el fit de Mph.
    ZfitOpt.ThermalModel='default';
    ZfitOpt.NoiseFilterModel.model='medfilt'; %see BuildNoiseOptions
    ZfitOpt.NoiseFilterModel.wmed=40;
end

% if nargin>2
%     dir=varargin{1};
%     cd(dir);
% end

faux=figure('visible','off');

%%%gestionar la posibilidad de que la unidad este listada en ESP o ENG.
% Unidad='G:\';
% x_esp=ls(strcat(Unidad,'Unidades compartidas'));
% x_eng=ls(strcat(Unidad,'Shared drives'));
% if ~isempty(x_esp)
%     datadir=strrep(datadir,'Shared drives','Unidades compartidas');
% else
%     datadir=strrep(datadir,'Unidades compartidas','Shared drives');
% end

cd(datadir);
%cd2CloudDataDir(datadir);

%[IVset,IVsetN]=LoadIVsets(analizeOptions.circuit);
try
    evalin('caller','load(''circuit.mat'')'); %%esto va a ir machacando la estructura circuit del workspace, ojo si se usa en un analisis conjunto.
catch
end
circuit=evalin('caller','circuit');
if isfield(analizeOptions,'circuit')
    circuit=analizeOptions.circuit;
end
%%%Para asegurarse de que se usa un circuit determinado o poder
%%%analizar con distintos circuits, es mejor pasarlo como opcion en anaopt.

try
    [IVset,IVsetN]=LoadIVsets(datadir,circuit);
catch
end
if isfield(analizeOptions,'IVset')
    IVset=analizeOptions.IVset;
end
if isfield(analizeOptions,'IVsetN')
    IVsetN=analizeOptions.IVsetN;
end

%%%Cargamos las IVs. Como el 'caller' es AnalizeRun, y no pasamos el circuit a LoadIVsets, dentro se ejecutara
%%% el load(circuit) desde dentro del datadir, por lo que se cargara el
%%% circuit correcto.

ind=[IVset.Tbath]<=Tmax;
if isfield(analizeOptions,'IVpskip')
    ivpskip=analizeOptions.IVpskip;
    for i=1:length(ivpskip)
        IVset(ivpskip(i)).good=0;
    end
end
if isfield(analizeOptions,'IVnskip')
    ivnskip=analizeOptions.IVnskip;
    for i=1:length(ivnskip)
        IVsetN(ivnskip(i)).good=0;
    end
end
NegativesFlag=0;
if isfield(analizeOptions,'NegativesFlag')
    NegativesFlag=analizeOptions.NegativesFlag;
end
Gset=fitPvsTset(IVset(ind),PTrange,PTmodel);
GsetN=[];
if NegativesFlag
    GsetN=fitPvsTset(IVsetN(ind),PTrange,PTmodel);%%%Ajusto los datos P-Tbath.
end
close(faux);

%RpTES=0.75;%%%Defino el %Rn al que fijar los datos del TES.
TES=BuildTESStructFromRp(RpTES,Gset);
TESN=[];
if NegativesFlag
    TESN=BuildTESStructFromRp(RpTES,GsetN);
end

IVset=GetIVTES(circuit,IVset,TES);
if NegativesFlag
    IVsetN=GetIVTES(circuit,IVsetN,TESN);
end
if isfield(analizeOptions,'TES_sides')
    TES.sides=analizeOptions.TES_sides;
    gammas=[2 0.729]*1e3; %valores de gama para Mo y Au
    rhoAs=[0.107 0.0983]; %valores de Rho/A para Mo y Au
    %hMo=45e-9; hAu=270e-9; %hAu=1.5e-6;%%%1Z11.!!!!!!!!!!!!!
    hMo=40e-9;hAu=220e-9;%3Z13.
    hAu=2.5e-6;
    %CN=(gammas.*rhoAs)*([hMo ;hAu]*sides.^2).*TES.Tc; %%%Calculo directo
    CN=(gammas.*rhoAs).*([hMo hAu]*TES.sides.^2).*TES.Tc; %%%calculo de cada contribucion por separado.
    CN=sum(CN);
    TES.CN=CN;
    TESN.CN=CN;
else
    TES.CN=100e-15;%%%%Valores por defecto si no pasamos TES_sides, para que no de error.
    TESN.CN=100e-15;
end

if isfield(analizeOptions,'Cabs')
    TES.Cabs=analizeOptions.Cabs;
end
TES.Rn=circuit.Rn; %TES.sides=(lado). Actualizo la estructura TES para incluir Rn.
TESN.Rn=TES.Rn;%66.9e-3;%%%<-%%%%%%
%TFS=importTF('TFS.txt');%%%Necesitamos la TF en estado 'S'!

TESDATA=BuildDataStruct;
if strcmp(ZfitOpt.TFdata,'HP')
    TFS=importTF('TFS_HP.txt');
    try
        TFN=importTF('TFN_HP.txt');
    catch
        TFN=[];
    end
elseif strcmp(ZfitOpt.TFdata,'PXI')
    TFS=importTF('TFS_PXI.txt');
    try
        TFN=importTF('TFN_PXI.txt');
    catch
        TFN=[];
    end
end
%%%cargamos la TFGS adecuada.Ojo, hay que nombrarla así en el dir.
TESDATA.TFS=TFS;%%Esta TFS sobreescribe la TFS.txt que se carga por defecto en FitZset_remote
if ~isempty(TFN)
    TESDATA.TFN=TFN;
end
%P=FitZset(IVset,circuit,TES,TFS);%%%Ajustamos las Z positivas.
P=FitZset_remote(TESDATA,ZfitOpt);

%%%Solucion temporal para analizar tb negativas.
PN=P;
if(NegativesFlag)
    cd(strcat(datadir,'\Negative Bias'))
    TESDATAN.IVset=IVsetN;
    TESDATAN.circuit=TESDATA.circuit;
    TESDATAN.TES=TESN;
    %TESDATAN.TFS=TESDATA.TFS;
    %TFS=importTF('..\TFS.txt');
    TESDATAN.TFS=TFS;
    if ~isempty(TFN)
        TESDATAN.TFN=TFN;
    end
    PN=FitZset_remote(TESDATAN,ZfitOpt);
    cd ..
end
%PN=FitZset(IVsetN,circuit,TESN,TFS); 


cd(olddir)

AnalizedData.circuit=TESDATA.circuit;
AnalizedData.IVset=IVset;
if(NegativesFlag)
    AnalizedData.IVsetN=IVsetN;
    AnalizedData.GsetN=GsetN;
    AnalizedData.TESN=TESN;
end
AnalizedData.PTmodel=PTmodel;
AnalizedData.Gset=Gset;

AnalizedData.RpTES=RpTES;
AnalizedData.TES=TES;

AnalizedData.TFS=TFS;
if ~isempty(TFN)
    AnalizedData.TFN=TFN;
end
AnalizedData.P=P;
AnalizedData.PN=PN;
AnalizedData.analizeOptions.datadir=datadir;
AnalizedData.analizeOptions.PTrange=PTrange;
AnalizedData.analizeOptions.PTmodel=PTmodel;
AnalizedData.analizeOptions.RpTES=RpTES;
AnalizedData.analizeOptions.ZfitOpt=ZfitOpt;
if isfield(analizeOptions,'TES_sides')
    AnalizedData.analizeOptions.TES_sides=TES.sides;
end
%devolvemos ya directamente la clase.
AnalizedData=BasicAnalisisClass(AnalizedData);

