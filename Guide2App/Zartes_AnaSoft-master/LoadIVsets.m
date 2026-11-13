function [IVset,IVsetN]=LoadIVsets(varargin)
%%%%Función para cargar las IVset directamente listando etc.
%%%%%% V2.(11-junio-2019). Modifico la función para poder pasar en
%%%%%% cualqueir orden dos parámetros, el datadir y el circuit. Si no le
%%%%%% paso el circuit lo busca en el workspace y si no en el datadir. Si
%%%%%% no encuentra circuit las carga pero sin calcular Ites,Vtes, etc.
%%%%%% Sólo si se intenta ejecutar sin pasar el datadir desde un directorio
%%%%%% sin datos dará error. Con esta nueva versión se puede estar
%%%%%% analizando desde un directorio de análisis sin tener que ir saltando
%%%%%% al dir de datos. Combinarla con FitZset_remote.

%colordir=GetCloudDataDir();%%%La variable colores está en el directorio raiz principal de los datos en la nube.
% command=strcat('''load(''''',colordir,'\','colores.mat',''''')''')
% evalin('caller',command); no funciona.

olddir=pwd;

try %%%en realidad no necesitamos aqui 'colores' para nada y en LowTPC da error.
    cd(colordir)%%%Cargamos automaticamente la estructura colores para trabajar con ella
    %evalin('caller','load(''colores.mat'')');
    load('colores.mat');
    cd(olddir)
catch
end
datadir=[];
circuit=[];

for i=1:length(varargin) 
    if ischar(varargin{i})
        datadir=varargin{i};
    end
    if isstruct(varargin{i})
        circuit=varargin{i};
    end
end

    if ~isempty(datadir)
        cd(datadir);
    end
    
    try%%%podemos pasar un dir cualquiera con IVs 
        filesP=ListInTbathOrder('*_p_*matlab.txt');
        filesN=ListInTbathOrder('*_n_*matlab.txt');
        raizdir=0;
    catch%%%o como siempre, el raiz con subcarpeta IVs.
        filesP=ListInTbathOrder('IVs\*_p_*matlab.txt');
        filesN=ListInTbathOrder('IVs\*_n_*matlab.txt');
        raizdir=1;
    end

    if raizdir 
        cd 'IVs';
    end
%IVset=ImportFullIV(filesP);
IVset=ImportRawIVs(filesP);
%IVsetN=ImportFullIV(filesN);
IVsetN=ImportRawIVs(filesN);
    if raizdir
        cd ..
    end

    if isempty(circuit)
        vars=evalin('caller','who');
        if sum(strcmp(vars,'circuit'))
        circuit=evalin('caller','circuit');%%%%Ojo, primero coge el circuit del WS si existe.
        %IVset=ApplyOffset(IVset,circuit);
        %circuit.voffset=-1.1249;%%%!!!
        IVset=CentrarIVs(IVset,circuit);
        IVset=GetIVTES(circuit,IVset);
        %IVsetN=ApplyOffset(IVsetN,circuit);
        %circuit.voffset=1.0091;%%%!!!
        IVsetN=CentrarIVs(IVsetN,circuit);
        IVsetN=GetIVTES(circuit,IVsetN);
        else
            try
                evalin('caller','load(''circuit.mat'')');
                vars=evalin('caller','who');
                circuit=evalin('caller','circuit');
                %IVset=ApplyOffset(IVset,circuit);
                IVset=CentrarIVs(IVset,circuit);
                IVset=GetIVTES(circuit,IVset);
                %IVsetN=ApplyOffset(IVsetN,circuit);
                IVsetN=CentrarIVs(IVsetN,circuit);
                IVsetN=GetIVTES(circuit,IVsetN);
            catch
                    if ~isempty(datadir)
                        cd(olddir);
                    end
                warning('no circuit structure')    
                return
            end
            
        end
    else
        %IVset=ApplyOffset(IVset,circuit);
        IVset=CentrarIVs(IVset,circuit);
        IVset=GetIVTES(circuit,IVset);
        %IVsetN=ApplyOffset(IVsetN,circuit);
        IVsetN=CentrarIVs(IVsetN,circuit);
        IVsetN=GetIVTES(circuit,IVsetN);
    end
    
if ~isempty(datadir)
        cd(olddir);
end